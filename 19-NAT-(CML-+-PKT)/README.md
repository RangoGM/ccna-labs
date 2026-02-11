<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |

## Lab 19: Comprehensive NAT Architectures - Static, Dynamic & PAT

### Objective

This lab demonstrates the practical implementation of various **Network Address Translation (NAT)** methods. We compare **Static NAT** (used for specific hosts) against **PAT (Port Address Translation)** used for high-capacity user branches, while ensuring end-to-end reachability through a simulated ISP backbone.

### Topology Diagram

The network is split into two primary branches connected via an **Internet Router (ISP)** to a centralized **Public Server (1.1.1.1)**.

- **Branch 1 (Upper):** `Kali ➔ SW1 ➔ R1` (Focus: Static & Dynamic Pool NAT)

- **Branch 2 (Lower):** `Windows ➔ SW2 ➔ R2` (Focus: PAT/NAT Overload)

**📸 Screenshot:**

<img width="952" height="331" alt="Screenshot 2026-02-11 171041" src="https://github.com/user-attachments/assets/539ce187-cdc8-46ed-8513-9539685755b3" />

---

### Configuration Phase

#### Branch 1: R1 - Static & Dynamic NAT (1-to-1 / M-to-M)

Branch 1 simulates a scenario where internal hosts need fixed public mappings.

- **Network Specs:** LAN `192.168.1.0/24` | Public Subnet `203.0.113.0/24`.
- **Static NAT (Single Host): Maps one private IP to one specific public IP.

```bash
R1(config)# interface e0/1
R1(config-if)# ip nat inside
R1(config)# interface e0/0
R1(config-if)# ip nat outside
R1(config)# ip nat inside source static 192.168.1.12 203.0.113.10
```

**📸 Screenshot:**

<img width="1152" height="234" alt="Screenshot 2026-02-11 191416" src="https://github.com/user-attachments/assets/e33d628e-5b4f-4a2a-a233-c5c31838ec75" />

- **Dynamic NAT (Pool Optimization):** If the branch grows, we transition to a **NAT Pool.**

> [!NOTE]
> ##### Use this for multiple hosts requiring their own public IP from a reserved range (Demo in Packet Tracer File).

```bash
// Define the range of available Public IPs
R1(config)# ip nat pool POOL1 203.0.113.10 203.0.113.20 prefix-length 24
// Define which internal IPs are allowed to NAT
R1(config)# access-list 1 permit 192.168.1.0 0.0.0.255
// Bind the list to the pool
R1(config)# ip nat inside source list 1 pool POOL1
```

---

#### Branch 2: R2 - PAT / NAT Overload (M-to-1)

Branch 2 simulates a typical residential or small office branch where many users share a single public IP.

- **Network Specs:** `LAN 192.168.2.0/24` | Public Subnet `203.0.114.0/30`.
- **PAT Implementation:** Uses Port numbers to distinguish between internal flows.

```bash
R2(config)# interface e0/0
R2(config-if)# ip nat inside
R2(config)# interface e0/1
R2(config-if)# ip nat outside
R2(config)# access-list 1 permit 192.168.2.0 0.0.0.255
// The 'overload' keyword enables Port Address Translation
R2(config)# ip nat inside source list 1 interface e0/1 overload
```

**📸 Screenshot:**

<img width="1146" height="237" alt="Screenshot 2026-02-11 192333" src="https://github.com/user-attachments/assets/d18aec47-6063-4828-89fc-d55089e4e636" />

---

#### Routing Configuration: The OSPF Backbone (INTERNET)

To ensure the NAT addresses are reachable across the infrastructure, we implement OSPF. However, we must be careful about which networks we advertise.

- **The Correct "Best Practice" Config**
In a real-world ISP scenario, we only advertise the **Public Interconnects** and the **Server** path. We keep the Private LANs invisible.

```bash
// On R1 (Static NAT Branch)
R1(config)# router ospf 1
R1(config-router)# network 203.0.113.0 0.0.0.255 area 0  // Public Subnet only

// On R2 (PAT Branch)
R2(config)# router ospf 1
R2(config-router)# network 203.0.114.0 0.0.0.3 area 0    // Public Link only

// On Internet Router
INTERNET(config)# router ospf 1
INTERNET(config-router)# network 1.1.1.0 0.0.0.3 area 0  // Server (The destination for both branch to reach)
INTERNET(config-router)# network 203.0.113.0 0.0.0.255 area 0
INTERNET(config-router)# network 203.0.114.0 0.0.0.3 area 0
```
---

> [!IMPORTANT]
> ### Comparison Table: NAT Flavors

|Method|Scaling|Use Case|Mapping Logic|
|-|-|-|-|
|**Static NAT**|Limited|Web Servers, Mail Servers|$1:1$ (Fixed)|
|**Dynamic NAT**|Moderate|Limited Public IP resources|$M:M$ (Dynamic)|
|**PAT (Overload)**|High|General Users / Internet Access|$M:1$ (Port-based)|

--- 

### Verification & Key Findings

1. **NAT Table Check:** Use `show ip nat translations` to see the mapping in real-time.
2. **DNS Reachability:** Both branches use `1.1.1.1` as a **Name Server**, proving that NAT supports **UDP/53** traffic.

#### Static NAT

**📸 Screenshot:**

<img width="613" height="75" alt="image" src="https://github.com/user-attachments/assets/40b61074-0a76-472e-90fe-4b3584891b2a" />

Based on the `show ip nat translations` output:
- **Static NAT (The --- entry):** The bottom entry with `---` indicates a **Permanent Static Mapping.** It establishes a fixed $1:1$ relationship between the Inside Local IP (`192.168.1.12`) and the Inside Global IP (`203.0.113.10`). This entry never expires or changes.
- **Active Session (The `udp` entry):** The top entry shows a real-time traffic flow (a DNS query to `1.1.1.1` on port `53`). The router utilizes the pre-defined Static IP to translate this specific session.

>[!NOTE]
> **Key takeaway:** The `---` symbols are the "identity card" of Static NAT, proving that the Public IP is exclusively reserved for that specific host 24/7.

#### PAT / NAT Overload

**📸 Screenshot:**

<img width="635" height="81" alt="Screenshot 2026-02-11 195313" src="https://github.com/user-attachments/assets/2cc76c56-ec0d-4c34-8b03-913021c89570" />

By comparing the output of `show ip nat translations` on **R2** with **R1**, we can see the fundamental behavior of **PAT:**

- **No Persistent Entry (No `---`):** Unlike R1, the translation table on R2 does **not** contain any permanent entries marked with `---`. This is because PAT is **dynamic and stateful**—it only creates a mapping when an internal host initiates a connection.

- **Port-Based Mapping:** Notice the addition of port numbers (e.g., `:4785` and `:54811`) attached to the IP addresses. R2 uses these unique source ports to "overload" a single Public IP, allowing thousands of internal sessions to share the same global address simultaneously.

- **On-Demand Translation:** The `udp` entry only exists as long as the DNS session to `1.1.1.1` is active. Once the communication ends and the timer expires, the entry is automatically purged from the table to save resources.

>[!NOTE]
> **Key takeaway:** The absence of the `---` symbols proves that R2 is not wasting Public IPs on idle hosts. It only translates traffic "on the fly" using Port Multiplexing, making it the most efficient method for large-scale user networks.

Successful reachability in this lab depends on two distinct layers working in harmony: **NAT (The Mask**) and **Routing (The Map).**

>[!WARNING]
> #### 1. NAT is NOT Routing
> During testing, we confirmed that simply configuring NAT is not enough.
> - **The Mask:** NAT successfully hides the private IP (`192.168.1.12`) behind a public alias (`203.0.113.10`) and can ping the INTERNET (`203.0.113.1`) without routing but dont be get trick by this because the **Private IP** has been changed to **Inside Global** got the **same subnet** as the INTERNET so that is why the packets can sending out towards the INTERNET.
> - **The Map:** However, without **OSPF**, the packets have no "map" to reach the Server (`1.1.1.1`). NAT only changes the identity; it does not build the road to the destination.
> #### 2. The Return Path (ISP Role)
> The most critical part of verification is the Return Path.
> - For the Server's "Reply" to reach the Windows/Kali hosts, the Internet Router must possess specific routes back to our Public Subnets (`203.0.113.0/24` and `203.0.114.0/30`).
> - If these routes are missing from the ISP's routing table, the reply packets are dropped, resulting in `Request timed out` even if the outbound NAT was successful.

➡️ **Conclusion of Verification**
**"NAT hides the home, but Routing builds the road."**

Our successful pings prove that our **OSPF Dynamic Routing** effectively advertised the NAT Public addresses to the ISP, completing the end-to-end communication loop.


> [!IMPORTANT]
> **Lesson Learned:** Dynamic NAT still consumes one Public IP per active session. If you have 100 users and a pool of 10 IPs, only 10 users can go online at once. **PAT (Overload)** is the only way to support hundreds of users with just one Public IP.

**📸 Screenshot:**

<img width="856" height="498" alt="Screenshot 2026-02-11 203020" src="https://github.com/user-attachments/assets/f038dfd1-0adc-4419-9f1d-45697dd0b802" />

*(**Windows - Branch 2**: Can ping the **SERVER** but not the **Private IP** or **R1** Addresses - **Branch 1**)*

<img width="736" height="585" alt="Screenshot 2026-02-11 203108" src="https://github.com/user-attachments/assets/e29d2139-447b-484e-a5b1-c00d2f2de89a" />

*(Vice versa as **Branch 1**)*

<img width="1281" height="613" alt="Screenshot 2026-02-11 203411" src="https://github.com/user-attachments/assets/91844206-359c-4755-bd09-00d8d3396d82" />

*(**Public Server** does not have permission to access **Private IP** & **Branch Routers**)*

--- 

> [!CAUTION]
> ### Post-Verification: The "Route Leaking" Experiment
What happens if we "accidentally" advertise the Private LANs (`192.168.x.x`) into OSPF? This experiment reveals the fundamental security difference between **Static NAT** and **PAT.**

#### Scenario: Advertising 192.168.1.0 and 192.168.2.0 into Area 0

|Test Case|Result|Technical Explanation|
|-|-|-|
|**R2 pings R1 (192.168.1.1)**|✅ **SUCCESS**|**Static NAT Vulnerability**: Static NAT is bi-directional and lacks an intrinsic Access List. When OSPF leaks the route, R1 accepts the incoming packet because the mapping is permanent.|
|**R1 pings R2 (192.168.2.1)**|❌ **FAILED**|**PAT Security:** Even if the route is known, PAT (NAT Overload) uses an **Access List** and a **Stateful Table**. Since R2 didn't "ask" for this connection first, it drops the unsolicited packet.|

**📸 Screenshot:**

<img width="368" height="103" alt="Screenshot 2026-02-11 173355" src="https://github.com/user-attachments/assets/fc050b57-b164-452b-a93e-f8a33b498e31" />

*(This is not good, imagine when your neighbor have the IP Addesses of your home Router even they can not access to your devices IP address (`192.168.1.12`) because this IP has map to **Public NAT IP Address** so it automatically drops other outside IP when reach to `192.168.1.12`)*

> [!NOTE]
> #### 🥇 Best Practice Conclusion
> While the experiment above shows that we can reach internal IPs if we misconfigure OSPF, it is not **recommended.**
> - **Isolation:** Only advertise **Public IPs** to the core. Internal private IPs should remain hidden behind the NAT boundary.
> - **Explicit Control:** If you use Static NAT, always pair it with an **Inbound ACL** to prevent unauthorized access from other branches, as Static NAT does not have the "Stateful" protection that PAT offers.
> - **Scalability:** PAT (NAT Overload) remains the superior choice for user subnets due to both IP conservation and its "one-way" security nature.

 ---

>[!IMPORTANT]
> ### Understanding NAT Terminology (The 4 Pillars)

To avoid confusion between Private and Public perspectives, we use this standard table to track our packets. Let's use **Branch 1 (Static NAT)** as the example:


|Term|Simple Defination|Example in Lab|
|-|-|-|
|**Inside Local**|The **real IP** of the host inside your network.|`192.168.1.12`|
|**Inside Global**|The **Public IP** that the world sees you as (The Mask).|`203.0.113.10`|
|**Outside Global**|The **real Public IP** of the destination server.|`1.1.1.1`|
|**Outside Local**|How the destination looks to your internal host (usually same as Outside Global).|`1.1.1.1`|

>[!TIP]
> **How to remember it easily:**
> - **Inside:** Everything in your office/house.
> - **Outside:** Everything in the Internet.
> - **Local:** The address as seen from inside your LAN.
> - **Global:** The address as seen from the Public Internet

#### 💡 Why this matters for Troubleshooting:
When you run `show ip nat translations`, you are looking at how the Router maps the **Inside Local** (your private identity) to the **Inside Global** (your public identity) so it can talk to the **Outside Global** (the server).

---

### Real-World Scenario: The "Good Neighbor" Policy
To truly understand the value of this Lab, imagine **Branch 1** is your home network and **Branch 2** is your neighbor’s network. Both of you can access the public internet and global servers like `8.8.8.8` or `1.1.1.1` .

However, thanks to **NAT Overload** and **Static NAT** logic:

- You **cannot** ping your neighbor's private IP or access their internal router.

- Your neighbor **cannot** "see" into your private network either.

**This is the "Single Gatekeeper" effect of NAT.** It creates a secure boundary where internal identities are hidden, and unsolicited external traffic is blocked by default. This is exactly how modern ISPs and Enterprise networks are designed to ensure privacy and security between different customers.

**📊 Lab Realism Score: 80% (Production Grade)**
- **Why 80%?** You have successfully integrated **Dynamic OSPF Routing** (the ISP backbone), **NAT Overload/Static** (Client Connectivity), and **Access-Lists** (Traffic Policy) .

- **The missing 20%?** In a 100% real-world ISP, we would use **BGP** instead of OSPF for the internet core and **Firewalls** for deeper packet inspection.

➡️ **Final Verdict:** This Lab is a near-perfect simulation of how the global Internet delivers connectivity while maintaining strict isolation between private subscribers.

**📸 Screenshot:**

<img width="956" height="200" alt="Screenshot 2026-02-11 213821" src="https://github.com/user-attachments/assets/4f3973b7-ca5e-43e4-9e59-9e44eb1ca1db" />

*(Real world simulation NAT working invincibility with the INTERNET)*


| [⬅️ Previous Lab](../18-Standard-ACL-(CML-+-PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️]|
|:--- | :---: | ---: |



