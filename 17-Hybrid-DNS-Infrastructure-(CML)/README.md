<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |

## Lab 17: Hybrid DNS Infrastructure & Packet Analysis

### Objective
This lab aims to simulate a high-level **Global DNS Hierarchy** within a controlled Service Provider (ISP) environment. We move beyond basic DNS to implement a **Hybrid DNS Node** that functions as both a **Conditional Forwarder** (Proxying global queries) and an **Authoritative Master** (Hosting local domains), proving the flexibility of `bind9` in a multi-hop OSPF network.

### Topology & Network Architecture

To eliminate "Local Resolution Shortcuts," this lab is designed with a strictly routed path, forcing every DNS query to traverse the ISP core.

|Device|Role|IP Address|Server Logic|
|------|----|----------|------------|
|Windows 10|DNS Client|`192.168.1.12`|Pointing to 1.1.1.1 for resolution|
|Router R1|Edge Gateway|`192.168.1.1`|Advertising LAN via OSPF, DHCP Server (Optional)|
|Router ISP|ISP Core|`1.2.3.x`|Managing the "Internet" backbone|
|Kali 1|Hybrid Resolver|`1.1.1.1`|Master for `server.com` / Forwarder for `ccnp-lab.com`|
|Kali 2|Remote Master|`172.247.1.1`|Authoritative for the `ccnp-lab.com` zone|

**📸 Screenshot:**

![alt text](https://github.com/user-attachments/assets/f80e035f-a865-4501-9dec-a4c0a17638b5" />

---
### Install Bind9 on Linux 

```bash
sudo apt update && sudo apt install bind9 bind9utils bind9-doc -y
```

- Check if the service is **Active (Running)**

```bash
systemctl status named
```
**📸 Screenshot:**



<img width="1000" height="400" alt="Screenshot 2026-02-10 015639" src="https://github.com/user-attachments/assets/30265da2-9521-42f9-89e5-af70aa2b95c3" />




- If not use this command to activate the Service:

```bash
systemctl start named
```

>[!WARNING]
> #### On Kali Linux, Bind9 runs as the `named` daemon. 

>[!TIP]
> #### 💡 Check Port 53
> ```ss -tulnp | grep :53```
> - **📸 Screenshot:**
> <img width="631" height="124" alt="Screenshot 2026-02-10 021812" src="https://github.com/user-attachments/assets/87d4f923-2bb4-4af8-b7a2-42c872bd59d6" />
> 
> - *Explanation:* Used to **investigate networking sockets**, displaying detailed information about **TCP, UDP, and Unix** domain socket connections
>
> #### 💡 DNS Local
> ```dig @127.0.0.1 localhost```
> - **📸 Screenshot:**
> <img width="706" height="446" alt="Screenshot 2026-02-10 023617" src="https://github.com/user-attachments/assets/9e7f8214-ed42-4630-9fa9-6c31fc72c6ef" />

---

### Execution Phase: The "Hybrid" Configuration

#### Phase 1: Authoritative Master Setup (The "Source of Truth")
We define the **SOA (Start of Authority)** on Kali 1 to host the `server.com` domain locally.

##### 1. Zone Declaration (`/etc/bind/named.conf.local`):

**📸 Screenshot:**

<img width="441" height="66" alt="image" src="https://github.com/user-attachments/assets/ec12bf9c-d920-4cda-af75-c3c4345469ad" />

```text
zone "server.com" {
  type master;
  file "etc/bind/db.server.com";
};
```
**📸 Screenshot:**

<img width="1720" height="243" alt="image" src="https://github.com/user-attachments/assets/b5e7d10b-3f23-46f9-ade3-97ced23e13e9" />

#### 📂 Local Zone Declaration (`named.conf.local`)
This file tells the Bind9 service where to find the "Phonebook" (Zone file) for a specific domain:

- `type master;`: Defines Kali 1 as the **primary source of truth** for this domain. It does not need to query external servers for `server.com`.

- `file "/etc/bind/db.server.com";`: The absolute path to the database file containing all the records listed above.

*(Remember to save the config `Ctrl + 0`)*
>[!IMPORTANT]
> Verify the config, if does not see any outputs you are good to go and if any outputs when excute commands you need to fix it

**📸 Screenshot:**

<img width="554" height="196" alt="Screenshot 2026-02-10 030844" src="https://github.com/user-attachments/assets/a435e4eb-5248-44a7-8dbb-3ea89c2dcb78" />


##### 2. Zone File Anatomy (/etc/bind/db.server.com):

**📸 Screenshot:**

<img width="401" height="38" alt="Screenshot 2026-02-10 005600" src="https://github.com/user-attachments/assets/59b4f297-c4cf-4b5b-a7e3-a17c6138f2d4" />

```bash
$TTL    604800
@       IN      SOA     server.com. root.server.com. (
                        2026021001 ; Serial (YYYYMMDDNN)
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL
;
@       IN      NS      ns1.server.com.
ns1     IN      A       1.1.1.1
@       IN      A       1.1.1.1
```

**📸 Screenshot:**

<img width="1710" height="374" alt="Screenshot 2026-02-10 030006" src="https://github.com/user-attachments/assets/f007657e-e11d-43ed-9ad7-1656695fd029" />

#### 📘 DNS Configuration Breakdown (Bind9)

**1. SOA Record (Start of Authority)**
The SOA record defines the global parameters for the zone.
- `$TTL 604800`: Time To Live. Directs clients (e.g., Windows) to cache this DNS record for 1 week (604800 seconds) before requesting an update.
- `@ IN SOA server.com. root.server.com.`:
- `@`: Shorthand representing the current origin domain (`server.com`).
- `SOA`: Designates the primary authoritative server for the zone.
- `root.server.com`: The administrator's email address (the first `.` replaces the @ symbol)

**2. Technical Parameters (The Numbers)**
These values manage how DNS synchronization and caching work:

|Parameter|Value|Meaning|
|-|-|-|
|**Date**|`20260210`|Date of changing update|
|**Serial**|`1`|**Version Control.** Must be incremented (e.g., 1 to 2) after every change to trigger updates on secondary servers.|
|**Refresh**|	`604800` |How often Secondary (Slave) servers poll the Master for zone updates (1 week).|
|**Retry**|	`86400`	| Wait time for a Secondary server to retry if the Master is unreachable (1 day).|
|**Expire**|	`2419200`	| If the Master is offline for this long, the Secondary server stops serving the zone (4 weeks).|
|**Negative TTL**|	`604800`|	Cache duration for "NXDOMAIN" (Name Error) responses (1 week).|

**3. Resource Records (NS & A)**
- `IN NS ns1.server.com.`: **Name server**. Specifies that the host `ns1` is the designated server for this zone.
- `ns1 IN A 1.1.1.1`: **Address Record**. Maps the hostname `ns1` to the physical IP address `1.1.1.1`.
- `@ IN A 1.1.1.1:` Maps the **Apex domain** `server.com` directly to `1.1.1.1`.

>[!IMPORTANT]
> Verify the config, if is said `OK` you are good to go

**📸 Screenshot:**

<img width="610" height="79" alt="Screenshot 2026-02-10 010529" src="https://github.com/user-attachments/assets/dda90ffc-0d62-4b05-8dfb-6383e39fc15a" />

---

#### Phase 2: Conditional Forwarding (The "Proxy")

On the same Kali 1 node, we configure the `named.conf.options` to redirect unknown queries for remote zones to Kali 2.

```bash
options {
    directory "/var/cache/bind";
    forwarders {
        172.247.1.1; // Redirecting to Remote Master
    };
    allow-query { any; };
    listen-on { any; };
};
```
**📸 Screenshot:**

<img width="333" height="274" alt="Screenshot 2026-02-10 000642" src="https://github.com/user-attachments/assets/dc4bd2e9-1c99-45df-9f74-6e68ebc465a7" />


#### ⚙️ Understanding Global Options (`named.conf.options`)
This file defines the behavior of the DNS service for any requests that it doesn't host locally. It acts as the "routing logic" for DNS traffic.

- `directory "/var/cache/bind";`: Specifies the working directory where BIND stores its runtime data and cache files.

- `forwarders { 172.247.1.1; };`: **Conditional Forwarding.** This is the most critical part. It tells Kali 1: "If you don't know the answer to a query (like ccnp-lab.com), don't give up. Instead, ask the server at `172.247.1.1` (Kali 2)." * Analogy: It’s like a librarian calling another library to find a book they don't have.

- `allow-query { any; };`: **Access Control.** By default, DNS servers are very restrictive. Setting this to `any` allows all devices in your Lab (Windows, Routers, etc.) to send queries to this server. Without this, you would get a "Query Refused" error.

- `listen-on { any; };`: Network Interface Binding. This commands the BIND service to listen for incoming DNS requests on all available network interfaces (both local and external). If not set, the server might only listen to itself (`127.0.0.1`), ignoring your Windows client.

>[!IMPORTANT]
> Same as the verification of Phase 1 if you does not see any outputs you are good to go

**📸 Screenshot:**

<img width="543" height="107" alt="image" src="https://github.com/user-attachments/assets/5fa01b13-41d9-4d6e-9015-40e72c850734" />

>[!TIP]
>#### Used `sudo named-checkconf` to check both `named.conf.options` & `named.conf.local`

---
>[!NOTE]
> #### 📝 Summary of the "Hybrid" Logic
> With this configuration, Kali 1 now has a "split personality":
> 1. For `server.com`: It looks at `named.conf.local`, sees it is the **Master**, and answers directly.
> 2. **For everything else**: It looks at `named.conf.options`, sees the **Forwarder**, and asks Kali 2.
---

>[!IMPORTANT]
> #### Kali 2 which is `172.247.1.1` is configured the same as Kali 1 just replace the `server.com` in `/etc/bind/named.conf.local` to `ccnp-lab.com` & `/etc/bind/db.ccnp-lab.com` too, dont change anything in `/etc/bind/named.conf.options` because it does not forwarding to any servers else.

---

### Router Configuration (ISP & R1)

```bash
ip name-server 1.1.1.1
ip domain lookup
```

---

### Verification & Packet Analysis

#### 🔍 Scenario A: Local Domain Resolution
- **Command:** `nslookup server.com`
- **Result:** Instant response from `1.1.1.1.` Kali 1 identifies itself as the Master and provides its own IP.
#### 🔍 Scenario B: Remote Domain Resolution & Path Validation
- **Command:** `ping ccnp-lab.com`
- **Wireshark Analysis:**
1. **DNS Phase:** Windows initiates a query to 1.1.1.1.
2. **Forwarding Phase:** Kali 1 transparently queries Kali 2 via the ISP core.
3. **Execution Phase:** ICMP Echo packets follow the OSPF path.

**📸 Screenshot:**

<img width="361" height="163" alt="Screenshot 2026-02-10 002803" src="https://github.com/user-attachments/assets/b2e89cbe-1edb-4cdd-ace1-e6aa1a552308" />

*(Kali 1 can resolve Kali 2 IP Address to ccnp-lab.com)*

<img width="564" height="99" alt="Screenshot 2026-02-10 002854" src="https://github.com/user-attachments/assets/326e1b54-a00a-4a44-8e09-70387e7fb32d" />

<img width="567" height="93" alt="Screenshot 2026-02-10 002947" src="https://github.com/user-attachments/assets/fbbe1c14-9922-4f80-987e-467db77aa12e" />

*(Both Routers too)*

<img width="355" height="152" alt="Screenshot 2026-02-10 010619" src="https://github.com/user-attachments/assets/ae4f545f-e652-42cf-ad5a-2da3d18d1158" />

<img width="402" height="203" alt="Screenshot 2026-02-10 010637" src="https://github.com/user-attachments/assets/ce76120f-321f-457e-bb34-f64770750bc6" />

<img width="406" height="192" alt="Screenshot 2026-02-10 003146" src="https://github.com/user-attachments/assets/ae4bad03-557c-4e25-933c-73b4840d7fa8" />

*(Last but not least the Windows host can now resolve IP Address from **BOTH** Server)*

<img width="1911" height="172" alt="Screenshot 2026-02-10 011652" src="https://github.com/user-attachments/assets/8aae702e-8538-4e6a-8c5a-3aa122873eaf" />

*(Host first query to `1.1.1.1` when excute `nslookup`)*

<img width="799" height="434" alt="Screenshot 2026-02-10 011748" src="https://github.com/user-attachments/assets/a4ce1a9a-3d2a-4a94-9e1c-2e3314fbb8c9" />

<img width="630" height="503" alt="Screenshot 2026-02-10 011808" src="https://github.com/user-attachments/assets/35d6b169-f7ce-4ea5-9b58-4e1104b0f3be" />
<img width="630" height="503" alt="Screenshot 2026-02-10 011808" src="https://github.com/user-attachments/assets/35d6b169-f7ce-4ea5-9b58-4e1104b0f3be" />

>[!IMPORTANT]
> *(DNS is **UDP Port 53**)*

*(Feel free to explore more content in the picture for knowledges)*

---
### Troubleshooting & Lessons Learned

> [!IMPORTANT]
> - **Syntax Enforcement:** Use `named-checkconf` and `named-checkzone` religiously. A missing trailing dot (`.`) in the SOA record is the #1 cause of `SERVFAIL` errors.
> - **Service Recovery:** Encountering `exit-code` often indicates a permissions issue on the zone file or a stray bracket in the config.
> - **The "Flush" Requirement:** Always run `ipconfig /flushdns` on Windows between tests, or you'll be analyzing "Ghost Traffic" from the local cache instead of the live network.

| [⬅️ Previous Lab](../16-IPv6-RA-GUARD-(CML-FOCUSED)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../18-Standard-ACL-(CML-%2B-PKT)) |
|:--- | :---: | ---: |
