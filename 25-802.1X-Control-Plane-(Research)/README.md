<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |


## Lab 25: IEEE 802.1X Control-Plane Integration & Platform Capability Validation

<div align=center>
 
### 🔍 Research Project

#### Design and Empirical Evaluation of a Layered Access-Control Security Model for Enterprise Access Networks

(IP-Version Agnostic Architecture with Dual-Stack Considerations)

</div>

---

**📝 Core Focus:** Identity-Based Access Architecture & Control-Plane Validation

**🏗️ Environment:** Cisco Modeling Labs (**IOSvL2**) + FreeRADIUS (**Ubuntu VM on VMware**)

**🌐 Author: RangoGM (2026 Grinding Series)**


---

### I. Objective

This lab evaluates the architectural deployment of IEEE 802.1X within a virtualized access-layer environment.

#### 📍 Quick Navigation

* [**II. Architectural Context**](#ii-architectural-context)
* [**III. RADIUS Integration Validation**](#iii-radius-integration-validation)
* [**IV. Expected IEEE 802.1X Authentication Flow**](#iv-expected-ieee-8021x-authentication-flow)
* [**V. Observed Behavior in IOSvL2 (CML Free)**](#v-observed-behavior-in-iosvl2-cml-free)
* [**VI. Architectural Interpretation**](#vi-architectural-interpretation)
* [**VII. Platform Capability Limitation**](#vii-platform-capability-limitation)
* [**VIII. Security Design Implications**](#vii-temporal-authorization-window-race-condition)
* [**IX. Research Significance**](#ix-research-significance)
* [**X. Forward Path**](#x-forward-path)

> [!WARNING]
> #### Due to platform constraints (**IOSvL2 in CML Free**), the goal is not **full end-to-end host authorization**, but to:
> - **Validate AAA & RADIUS integration**
> - **Observe 802.1X control-plane behavior**
> - A**nalyze EAP authentication workflow**
> - **Identify implementation limitations in virtual L2 environments**

This experiment represents **Phase II – Identity Enforcement Architecture Analysis** within the overall security model.

**📸 Screenshot:**

<img width="870" height="466" alt="image" src="https://github.com/user-attachments/assets/1a89c8f8-f7eb-4ba4-ae46-311bb5a688d8" />


---

### II. Architectural Context

#### Components

<div align=center>
  
|Role|Device|Function|
|-|-|-|
|Authenticator|**IOSvL2 Switch (CML Free)**|Access port control|
|Authentication Server|**Ubuntu FreeRADIUS**|Credential validation|
|Supplicant (Test 1)|**Kali Linux (CLI – wpa_supplicant)**|EAP client|
|Supplicant (Test 2)|**Windows (GUI 802.1X)**|EAP client|
|Routing Layer|**R1**|Inter-VLAN communication|

</div>

---

### III. RADIUS Integration Validation

#### RADIUS Server Setup

```bash
sudo apt update && sudo apt install freeradius freeradius-utils -y
```

- **Configure clients:** `sudo nano /etc/freeradius/3.0/clients.conf` & **scroll down to bottom** add these commands:

```bash
client Cisco_Switch {
  ipaddr = <your_ip_address>
  secret = <your_password>
  nas_type = cisco
}
```
**📸 Screenshot:**


<img width="759" height="243" alt="Screenshot 2026-02-18 132346" src="https://github.com/user-attachments/assets/d66637d5-4e99-43e4-b175-7d81cbd1270b" />

*(`Ctrl + 0` → `Enter` → `Ctrl + X`)*

- **Configure User Identify:** `sudo nano /etc/freeradius/3.0/users` & add at the **top of the file:**

```bash
"<your_user_name>"  Cleartext-Password := "<your_username_password>"
```

**📸 Screenshot:**

<img width="1280" height="405" alt="Screenshot 2026-02-18 132613" src="https://github.com/user-attachments/assets/db9533eb-18ec-451b-8560-6691f12b89c6" />

*(`Ctrl + 0` → `Enter` → `Ctrl + X`)*

- Use `sudo freeradius -X` to run as **Foreground Debug** mode to **Analyzing/inspecting** the packet **line-by-line during processing**

>[!IMPORTANT]
> #### Last output must be `Ready to process requests` this meant that Ubuntu has confirm to be an Authentication Server.
> **📸 Screenshot:**
>
> <img width="1283" height="312" alt="Screenshot 2026-02-18 132713" src="https://github.com/user-attachments/assets/58614a0b-87df-4b32-ace6-c09e19c05237" />
>
> #### Check if Port 1812 & 1813 is available: `ss -tulnp` & use these commands to ensure:
> ```bash
> sudo ufw allow 1812/udp
> sudo ufw allow 1813/udp
> sudo ufw reload
> ```
> **📸 Screenshot:**
>
> <img width="580" height="118" alt="image" src="https://github.com/user-attachments/assets/7d7d9f5b-fc31-41af-a6ca-517bf89bd468" />



- Open new Terminal and keep `freeradius -X` running to test **internal operation** of the server:

```bash
radtest <your_user_name> <your_username_password> localhost 0 testing123
```

**📸 Screenshot:**

<img width="654" height="191" alt="Screenshot 2026-02-18 133540" src="https://github.com/user-attachments/assets/13e128af-e7e8-41aa-a35c-f1718185a97c" />

<img width="1061" height="803" alt="Screenshot 2026-02-18 133608" src="https://github.com/user-attachments/assets/4de0e378-f035-4784-9fd4-0673662b5264" />



#### AAA Configuration

<details>
<summary><b>⚙️ Click to see Full Switch Running-Config and Explanation</b></summary>

```bash
interface Vlan1
 ip address 192.168.99.2 255.255.255.0
 no shut
exit
ip radius source-interface Vlan1

aaa new-model
radius server RADIUS_UBUNTU
  address ipv4 192.168.99.99 auth-port 1812 acct-port 1813
  key cisco123
exit

aaa group server radius RADIUS_GROUP
 server name RADIUS_UBUNTU
exit

aaa authentication dot1x default group RADIUS_GROUP
aaa authorization network default group RADIUS_GROUP
dot1x system-auth-control

interface Ethernet0/2
 switchport mode access
 authentication port-control auto
 dot1x pae authenticator
 spanning-tree portfast
exit
```

📘 Configuration Breakdown (Technical Explanation)

**1. Global AAA Activation**

- `aaa new-model`: Initializes the Authentication, Authorization, and Accounting (AAA) framework. This command migrates the switch from local authentication to a centralized AAA model, enabling advanced identity-based security features.

**2. RADIUS Server Definition**

- `radius server RADIUS_UBUNTU`: Defines a logical object representing the remote Authentication Server (FreeRADIUS on Ubuntu).

- `address ipv4 192.168.99.99...`: Specifies the Layer 3 reachability and the standard UDP ports (1812 for Authentication, 1813 for Accounting).

- `key cisco123`: Configures the **Shared Secret**. This is the cryptographic key used to encrypt communications between the Authenticator and the RADIUS server.

**3. Server Grouping**

 - `aaa group server radius RADIUS_GROUP`: Groups individual RADIUS servers into a named cluster. This abstraction allows for high availability and load balancing in enterprise environments.

**4. Authentication & Authorization Policies**

- `aaa authentication dot1x default group RADIUS_GROUP`: Instructs the switch to use the specified RADIUS group as the primary method for all IEEE 802.1X authentication requests.

- `aaa authorization network default group RADIUS_GROUP`: Ensures that once a user is authenticated, their network access privileges (such as VLAN assignment) are authorized by the RADIUS server.

5. System-Wide 802.1X Control

- `dot1x system-auth-control`: The global "master switch" for 802.1X. Without this command, the switch will not process any EAPOL frames, even if the individual ports are configured.

6. Port-Level Enforcement (**Interface Ethernet 0/2**)

- `authentication port-control auto`: Sets the port's authorization state to "Auto." The port remains in an **unauthorized** state (blocking data traffic) until the client successfully authenticates via RADIUS.

- `dot1x pae authenticator`: Configures the port as a **Port Access Entity (PAE)** with the role of an **Authenticator**. It enables the port to send and receive EAPOL (Extensible Authentication Protocol over LAN) frames to and from the Supplicant.

- `spanning-tree portfast`: Optimizes the transition to the forwarding state by bypassing the standard listening/learning phases, preventing DHCP timeouts during the 802.1X handshake.

</details>

#### Observed Behavior

- Using Wireshark and `freeradius -X`:

- Switch sends **Access-Request**

- FreeRADIUS responds with **Access-Accept**

- Message-Authenticator **validated**

- **NAS-IP-Address** correctly identified

- **Round-trip latency < 10ms** (lab environment)

**📸 Screenshot:**

- Test **Access-Request** from Switch: `test aaa group radius <your_username> <your_username_password>`, use `debug dot1x all`, `debug authentication all` & `debug radius authentication` to verify:

<img width="840" height="476" alt="Screenshot 2026-02-18 190318" src="https://github.com/user-attachments/assets/8a55633b-5e24-4954-8f6e-4c6c75528535" />

<img width="1913" height="74" alt="Screenshot 2026-02-18 152712" src="https://github.com/user-attachments/assets/d42eacc8-90ba-4afa-86f9-fe93666ec42d" />

<img width="1919" height="573" alt="Screenshot 2026-02-18 152722" src="https://github.com/user-attachments/assets/668d6481-6367-4006-a38f-d7147554f6c4" />

*(Capture Packets between Switch and RADIUS Server)*

<img width="1113" height="564" alt="Screenshot 2026-02-18 141929" src="https://github.com/user-attachments/assets/96a34afe-e7b1-478e-ae85-6bf38a9764dd" />

*(At `freeradius -X`)*

<img width="1586" height="360" alt="Screenshot 2026-02-18 191227" src="https://github.com/user-attachments/assets/0aa9bb1e-0f6c-4f46-b15e-6a0b27e8af5f" />

*(Use `show aaa servers` for more details)*

This **confirms:**

- **✔ RADIUS server operational**
- **✔ Shared secret correct**
- **✔ User credentials valid**
- **✔ Control-plane AAA communication functioning properly**

---

### IV. Expected IEEE 802.1X Authentication Flow

#### In a fully supported environment, the authentication process should follow:

1. Supplicant sends **EAPOL-Start**

2. Switch responds with **EAP-Request/Identity**

3. Supplicant replies with **EAP-Response/Identity**

4. Switch **forwards identity** to RADIUS

5. RADIUS returns **Access-Accept**

6. Port transitions from *unauthorized* to *authorized*

7. Data traffic permitted

---

### V. Observed Behavior in IOSvL2 (CML Free)

#### Endpoint Testing (Cross-Platform Validation)

#### Both Kali Linux (CLI-based supplicant) and Windows (GUI-based supplicant) were tested.

#### Observed results:

- Supplicant transmits EAPOL frames

- ❌ **No** EAP-Request received from switch

- ❌ **No** EAPOL negotiation state transition

- Port remains in **connected state**

- ❌ **No MAC address learned**

- ❌ **No** access-session state table available

- Create a file to run Baseline: `sudo nano wired.conf` and add these commands:

```bash
network={
  key_mgmt=IEEE8021X
  eap=MD5
  identity="rango"
  password="rango123"
}
```

- Execute `sudo wpa_supplicant -i eth0 -c wired.conf -D wired -dd` to start `Authenticate`:

- `-c wired.conf`: Points to the **Configuration File**. This file contains the security policy, EAP method (MD5), and the identity credentials (`rango`/`rango123`) defined for the session.

- `-D wired`: Selects the **Driver**. Since we are using a standard Ethernet connection rather than a wireless one, the `wired` driver is specified to handle EAPOL (EAP over LAN) frames correctly.

- `-dd`: Enables **Extra Verbose Debugging**. This is the most critical flag for research purposes.

  - It provides a real-time, hexadecimal-level view of the EAPOL state machine.

  - It allows the observer to identify exactly where the handshake fails (e.g., during the Solicitation phase or Identity exchange).


**📸 Screenshot:**

<img width="760" height="595" alt="Screenshot 2026-02-18 150348" src="https://github.com/user-attachments/assets/4e79448a-75b8-4988-8949-e7108f8854b9" />

*(Freeze here and a **Fail** Outputs after that)*

<img width="367" height="192" alt="Screenshot 2026-02-18 143008" src="https://github.com/user-attachments/assets/e1cbc8df-1796-4dc5-a4d1-10122ee40de0" />

<img width="417" height="39" alt="Screenshot 2026-02-18 142959" src="https://github.com/user-attachments/assets/19befadb-11e0-47fd-88a9-715f011fd495" />

*(No Mac Addresses learned even the **VMWare MAC**)*

<img width="844" height="611" alt="Screenshot 2026-02-18 202938" src="https://github.com/user-attachments/assets/8dde87db-fe64-4623-aad9-ee39ac9d706f" />

*(Same as **Windows**)*

#### Platform Indicators

- show **authentication sessions not available**

- ❌ **No** dot1x session tracking

- ❌ **No** port authorization state change

- ❌ **No** EAPOL state machine enforcement observed

- Can confirm more about this through commands `sudo tcpdump -i eth0 ether proto 0x888e` while execute `sudo wpa_supplicant -i eth0 -c wired.conf -D wired -dd` and use **Wireshark** to capture the packets:

**📸 Screenshot:**

<img width="1712" height="695" alt="Screenshot 2026-02-18 200016" src="https://github.com/user-attachments/assets/c3c0c1d9-8c2b-413a-90b0-72777c8a8e03" />

*(Supplicant successfully transmitted multiple **EAPOL-Start frames** but **Zero response frames** were observed from the **switch's interface MAC**. The expected **EAP-Request/Identity** handshake **never** initiated)* 

<img width="1004" height="64" alt="Screenshot 2026-02-18 200729" src="https://github.com/user-attachments/assets/ea4a26c9-c129-4fc1-bf03-1e625b1847b0" />

<img width="969" height="65" alt="Screenshot 2026-02-18 200742" src="https://github.com/user-attachments/assets/2974361f-dea8-4b16-9a4e-d677086942f0" />

*(No **dot1x** features verify commands)*

---

### VI. Architectural Interpretation

The experiment demonstrates a clear separation between:

#### Control-Plane AAA Functionality

- RADIUS **communication works**

- **Access-Accept received**

- **Authentication logic at RADIUS validated**

#### Data-Plane 802.1X Enforcement

- ❌ **No** authenticator state machine active

- ❌ **No** session-based authorization

- ❌ **No** port-level access control transition

>[!WARNING]
> #### This indicates that **IOSvL2 in CML Free does not implement a full IEEE 802.1X authenticator engine.**

---

### VII. Platform Capability Limitation

#### Although AAA integration is successful, the following limitations were identified:

- Absence of **EAPOL** negotiation handling

- ❌ **No** access-session management

- ❌ **No** dynamic port authorization control

- ❌ **No** enforcement of unauthorized state

#### This highlights an important research principle:

- Platform capability must be **validated** before drawing conclusions about **security feature** behavior.

- **Virtualized L2 environments** may not fully replicate **enterprise hardware** functionality.

---

### VIII. Security Design Implications

#### This lab reinforces several architectural insights:

- Identity-based access control requires a fully implemented authenticator engine.

- AAA communication alone does not guarantee enforcement.

- Virtual lab environments may simulate control-plane traffic but not data-plane policy enforcement.

- Security validation must consider implementation boundaries.

<div align=center>
  
|Feature|Port Security (Lab 24)|802.1X Baseline (Lab 25)|
|-|-|-|
|**Trust Model**|	Trust by Port/MAC	|**Trust by Identity (User/Pass)**|
|**MAC Spoofing Resilience**|	Low (Vulnerable to Cloning)|**Architecturally High** (*Pending Full Enforcement Validation*)|
|**Centralization**|	Decentralized (Local Config)|**Centralized (RADIUS/Database)**|
|**Failure Result**|	Shutdown/Restrict|	**Blocked at Ingress (Expected in Fully Supported Platforms)** |

</div>

---

#### IX. Research Significance

#### Despite the absence of full port authorization enforcement, this lab successfully:

- [✔] Validated RADIUS infrastructure deployment

- [✔] Confirmed AAA communication workflow

- [✔] Demonstrated cross-platform supplicant testing

- [✔] Identified platform constraints affecting identity enforcement

#### This contributes to the broader research objective by:

- [✔] Distinguishing MAC-based enforcement from identity-based architecture

- [✔] Documenting validation constraints in virtualized environments

- [✔] Providing a realistic boundary condition for further research

---

### X. Forward Path

#### Due to IOSvL2 limitations, future work will focus on:

- **Conceptual comparison: Port Security vs MAB vs 802.1X**

- **Dependency risk modeling (RADIUS availability)**

- **Access-layer monitoring and logging integration**

- **Defense-in-depth hardening at Layer 2**

>[!NOTE]
> #### Full enterprise-grade 802.1X enforcement remains future work requiring hardware-capable platforms (e.g., Catalyst 9000 series).
