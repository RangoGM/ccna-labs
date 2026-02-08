<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |



## Lab 11B Enterprise-Grade High Availability "X-House" Topology

#### HSRP Multi-Group, IP SLA Tracking, and Symmetric Routing Design

### Project Overview

This lab implements a highly resilient "Diamond" (X-House) topology designed for **High Availability (HA)** and **Deterministic Path Control.** The goal was to move beyond basic connectivity and design a network capable of sub-second logical failover and **more optimal** than **Packet Tracer** load sharing across multiple VLANs.

**📸 Screenshot:**

<img width="560" height="449" alt="Screenshot 2026-02-06 214046" src="https://github.com/user-attachments/assets/0a22e5e9-364e-4cfe-a88a-c60680e03d92" />

*(At this lab i have recognized some interesting stuff such as in CML **does not count external connection** as a **node** so I decided to download Windows 10 VMware to test connectivity, **VLAN 1 default function**, etc..)*

---

### Key Technical Implementations (Same as Lab 11A but more optimize commands)

**1. Layer 2 Redundancy (Rapid-PVST+)**

- **Deterministic Root Bridge:** SW1 is the Root Bridge for VLAN 1; SW2 is the Root Bridge for VLAN 2.

- **Traffic Alignment:** STP topology is synchronized with HSRP states to prevent unnecessary traffic hairpining across the Peer-link.

- **Edge Port Optimization:** `spanning-tree portfast` enabled on host ports to ensure immediate DHCP acquisition for Windows/Kali clients.

**2. Layer 3 Redundancy (Multi-Group HSRP v2)**

- **Active/Active Load Sharing:**
  - **R2:** Active for VLAN 1 (Priority 110), Standby for VLAN 2 (Priority 90).

  - **R3:** Active for VLAN 2 (Priority 110), Standby for VLAN 1 (Priority 90).

- **Virtual Gateway:** `192.168.x.254` serves as the consistent VIP for all end-nodes.

**📸 Screenshot:**

<img width="314" height="138" alt="Screenshot 2026-02-06 001635" src="https://github.com/user-attachments/assets/e504f7db-1e29-4a00-9bfd-91e302c48f18" />

<img width="319" height="131" alt="Screenshot 2026-02-06 001704" src="https://github.com/user-attachments/assets/cb45e3bc-887b-44cf-a9d7-1f8d64e9c5da" />

*(R2 example configuration & vice versa for R3)*

>[!TIP]
> #### **3. Advanced Failover (IP SLA & Object Tracking)**
> To handle **"Silent Link Failures"** (where an interface stays UP but the path is DEAD), I implemented:
> - **Outbound Tracking:** R2 and R3 monitor upstream reachability to the ISP via ICMP Echo. If the probe fails, HSRP decrements priority by 10, triggering a graceful failover to the healthy peer.

**📸 Screenshot:**

<img width="420" height="74" alt="Screenshot 2026-02-06 205927" src="https://github.com/user-attachments/assets/093ba88f-df48-4a91-a30e-2877d4c26498" />

- `ip sla [id]`: Initializes a Service Level Agreement probe.
- `icmp-echo [destination] source-interface [interface]`: Configures the probe to send ICMP Echo (Ping) packets to a specific destination (ISP) using a specific source interface to ensure the correct path is tested.
- `frequency [seconds]`: Sets how often the probe runs (e.g., every 5 seconds).
- `ip sla schedule [id] life forever start-time now`: Starts the SLA probe immediately and sets it to run indefinitely.

<img width="247" height="55" alt="Screenshot 2026-02-06 210227" src="https://github.com/user-attachments/assets/0a227335-ae73-4f99-96d9-a848f13582ff" />

- `track [track-id] ip sla [sla-id] reachability`: Creates a Tracking Object that stays UP if the SLA probe is successful and goes DOWN if it fails.

<img width="269" height="17" alt="Screenshot 2026-02-06 205905" src="https://github.com/user-attachments/assets/55c34426-fcfb-472f-9156-b8b43c7057ea" />

- `standby [group] track [track-id] decrement [value]`: Links HSRP to the tracking object. If the upstream ISP link fails (Track goes DOWN), HSRP decrements the router's priority (e.g., by 10), allowing the Standby router to take over as Active.

<img width="367" height="19" alt="Screenshot 2026-02-06 205918" src="https://github.com/user-attachments/assets/2eedeb66-153a-4b08-8c51-6bd0f9a8a1c3" />

- `ip route 0.0.0.0 0.0.0.0 [ISP] track [id]:` A **Conditional Default Route**. This route only exists in the Routing Information Base (RIB) as long as the Tracking Object (IP SLA) is **UP.**

*(R3 is the same with all the configuration above but different the **ISP destination** and **source Interface**)*

>[!TIP]
> #### **4. Symmetric Routing & Floating Static Routes**
> Configured on the ISP (R1) to ensure traffic returns to the LAN via the correct Active gateway.
> - **Inbound Tracking (ISP Side):** Configured IP SLA on the **ISP (R1)** to track the internal gateways. This allows the ISP to dynamically switch between Floating Static Routes (AD 1 vs. AD 5), ensuring symmetric return traffic.

**📸 Screenshot:**

<img width="240" height="57" alt="Screenshot 2026-02-06 210018" src="https://github.com/user-attachments/assets/18f8cbe6-620b-405d-a7b3-ae8e740dc0a5" />

<img width="445" height="100" alt="Screenshot 2026-02-06 210000" src="https://github.com/user-attachments/assets/44e2d53c-16dd-4bd2-ac23-a7856d7214b1" />

- `ip route [network] [mask] [next-hop] track [id]:` **A Conditional Static Route.** This route only exists in the Routing Information Base (RIB) as long as the Tracking Object (IP SLA) is **UP.**

- `ip route [network] [mask] [next-hop] [Administrative Distance]:` Creates a **Floating Static Route.** By assigning a higher Administrative Distance (e.g., AD 5), this route stays "hidden" and only activates if the primary route (AD 1) is withdrawn due to an SLA failure.

  - *Lab Insight:* This ensures the ISP automatically switches its return path to R3 if R2's link fails, maintaining symmetric traffic flow.

---

### Critical Troubleshooting

> [!WARNING]
> ⚠️ The VLAN 1 "Native Trap"
> - **The Issue:** HSRP entered a **Dual-Active** state for VLAN 1 even though the configuration seemed correct.

**📸 Screenshot:**

<img width="654" height="156" alt="Screenshot 2026-02-06 001540" src="https://github.com/user-attachments/assets/ddc475ca-018e-4135-a63a-d75b0bd68277" />

*(Try to used **VLAN 1** & only created **VLAN 2** instead of created 2 **seperated VLAN** (e.g., **VLAN 2** for Host 1, **VLAN 3** for Host 2)

> [!CAUTION]
> #### **Root Cause:** Cisco IOSv automatically appends the `native` keyword to `encapsulation dot1q 1`. This caused the router to send **untagged frames**. Since the Switch used a different Native VLAN (1001), it misidentified the untagged HSRP hellos, isolating the two routers.

**📸 Screenshot:**

<img width="314" height="138" alt="Screenshot 2026-02-06 001635" src="https://github.com/user-attachments/assets/bac6fbce-d0b8-4c15-8a6c-508239110258" />


<img width="319" height="131" alt="Screenshot 2026-02-06 001704" src="https://github.com/user-attachments/assets/435a4dbe-9bcb-40c2-acb2-5c8eb3693127" />

➡️ The ping from every packets has **entered** the routers with **VLAN 1** then **sent out will be untagged** and **request time out**.

>[!TIP]
> #### **The Fix:** Explicitly removed the `native` keyword or moved the native VLAN away from VLAN 1 to force explicit tagging.

**📸 Screenshot:**

<img width="275" height="76" alt="image" src="https://github.com/user-attachments/assets/50df2fa0-0dc6-4e7f-9a26-b45ce2caeb93" />

*(moved `native` from VLAN 1 to VLAN 1001)*

> [!CAUTION]
> **❗❗❗ PLEASE BE AWARE ALL THE VLANS LABS SUCH AS 01, 02A, 02B, 02C, 03, etc.. ❗❗❗**

--- 

> [!WARNING]
> ##### ⚠️ Encapsulation Side-Effects

- **Observation:** During troubleshooting, IP addresses were mysteriously disappearing from sub-interfaces.

- **Discovery:** In Cisco IOS, re-applying or modifying the encapsulation dot1q command wipes the assigned IP address.

>[!TIP]
> #### **Lesson:** Always verify Layer 3 configuration after modifying Layer 2 encapsulation parameters.

---


> [!WARNING]
> #### ⚠️ Stale Object States

- **Scenario:** IP SLA was functional (ICMP OK), but the Track Object stayed DOWN.

>[!TIP]
> #### **Resolution:** Re-initialized the track and ip sla schedule processes. In virtualized environments like CML, process synchronization can occasionally lag, requiring a configuration "refresh."

---

### Verification Commands

- `show standby brief`: Verify HSRP Active/Standby states

**📸 Screenshot:**

<img width="638" height="114" alt="Screenshot 2026-02-06 004310" src="https://github.com/user-attachments/assets/2940d335-822a-491d-93fc-d7839c589e2c" />

- `show ip sla statistics`: Monitor reachability probes

**📸 Screenshot:**

<img width="482" height="387" alt="Screenshot 2026-02-06 210250" src="https://github.com/user-attachments/assets/5e3a7892-19db-4603-81aa-7837d2d5deef" />


*(ISP)*

<img width="458" height="194" alt="Screenshot 2026-02-06 210309" src="https://github.com/user-attachments/assets/edf8e5a0-f4e4-4965-990d-1323759eb010" />

*(R2)*


- `show track`: Verify logical path status

**📸 Screenshot:**

<img width="293" height="193" alt="Screenshot 2026-02-06 210323" src="https://github.com/user-attachments/assets/c59787b3-97ef-4339-b684-f74c0fc962fb" />


- `show ip dhcp binding`: Confirm dynamic IP assignment for end-nodes

**📸 Screenshot:**

<img width="806" height="152" alt="Screenshot 2026-02-06 232659" src="https://github.com/user-attachments/assets/321698dd-9308-4379-b8b5-fcc896fd7e23" />

- `show ip route`: Verify Floating Static Route injection on ISP

---

### Failure Scenarios Tested

#### Normal

**📸 Screenshot:**

<img width="672" height="466" alt="Screenshot 2026-02-06 192745" src="https://github.com/user-attachments/assets/49ec78f2-5c04-42d6-bc2c-0ee7456c812c" />

*(Kali 1 has successfully binding address with **DHCP Server**)*

<img width="575" height="377" alt="Screenshot 2026-02-06 192929" src="https://github.com/user-attachments/assets/2f25a9dc-ab44-446d-8ea1-61afa62126a4" />

*(Kali 2 has successfully binding address with **DHCP Server**)*

<img width="975" height="209" alt="Screenshot 2026-02-06 213520" src="https://github.com/user-attachments/assets/7f316fa1-fae3-4e37-9f21-d95a91aeeff3" />

*(Windows has successfully binding address with **DHCP Server**)* - It is good to be back with familiar OS than Linux 😉

**👁️ NOTICE**

<img width="635" height="98" alt="Screenshot 2026-02-06 192902" src="https://github.com/user-attachments/assets/16ee6457-757e-4291-86c7-1580b18f378a" />

<img width="458" height="61" alt="Screenshot 2026-02-06 193017" src="https://github.com/user-attachments/assets/c8cfa110-ae1f-4ee4-9421-0cdb6eb41a64" />

<img width="975" height="185" alt="Screenshot 2026-02-06 213519" src="https://github.com/user-attachments/assets/4d45346f-2bc7-4199-90a8-6ff4ad416bef" />

>[!NOTE]
> #### **FHRP Table:**
> |**FHRP**|**Terminology**|**Multicast IP**|**Virtual MAC**|**Cisco Proprietary**|
> |-|-|-|-|-|
> | **HSRPv1** | **Active / Standby** | **224.0.0.2** | **00-00-0c-07-ac-XX** | **Yes** |
> | **HSRPv2** | **Active / Standby** | **224.0.0.102** | **00-00-0c-09-fX-XX** | **Yes** |
> | **VRRP** | **Master / Backup** | **224.0.0.18** | **00-00-5e-00-01-XX** | **No** |
> | **GLBP** | **AVG / AVF** | **224.0.0.102** | **00-07-b4-00-XX-YY** | **Yes** |

**📸 Screenshot:**

<img width="942" height="392" alt="Screenshot 2026-02-06 234738" src="https://github.com/user-attachments/assets/58c5c249-0193-4d3c-b484-71c5129ecc8c" />

*(In this case it is **HSRPv2**)*

- **Ping test**

**📸 Screenshot:**

<img width="1919" height="786" alt="Screenshot 2026-02-06 193251" src="https://github.com/user-attachments/assets/7f541c60-6051-4420-824b-66acd5ad3abe" />

*(As expected VLAN 1 is **only go through** **Ethernet0/0** because it is **VLAN 1 primary links** via **R2 HSRP Active for VLAN 1 gateway** and **reply** the same packets **within same VLAN** - no **VLAN 2** packets is pass through the link this meant HSRP **Standby** for VLAN 2)*

<img width="1919" height="792" alt="Screenshot 2026-02-06 193257" src="https://github.com/user-attachments/assets/68a249a0-22ee-4e07-8895-249691c6ebeb" />

*(And the **opposite** with R2 for R3 is **HSRP Active for VLAN 2 gateway** this **allowed VLAN 2 packets go through the links** and **no VLAN 1** is go through this because the R3 HSRP gateway for VLAN 1 is **standby** waitng for the **Active Router VLAN 1** to **down** then it will become **Active**)*

<img width="590" height="480" alt="Screenshot 2026-02-07 1" src="https://github.com/user-attachments/assets/e80650e0-6f3f-40d3-b694-2a9978283a19" />

*(VLAN 1 and VLAN 2 paths)*


#### Shutdown R2

**📸 Screenshot:**

<img width="333" height="167" alt="Screenshot 2026-02-06 193347" src="https://github.com/user-attachments/assets/d4124929-dc43-43aa-9aa4-d86f1929b5f3" />

<img width="692" height="41" alt="Screenshot 2026-02-06 193351" src="https://github.com/user-attachments/assets/79af34e8-9be3-4027-b58d-33eb9abbeb89" />

*(R3 noticed the R2 VLAN 1 gateway in **Active** mode is now down then R3 become **Active** gateway for **VLAN1** from **Standby** mode)*

<img width="596" height="285" alt="Screenshot 2026-02-06 204957" src="https://github.com/user-attachments/assets/8827f513-81de-4c8c-8397-edf04e28e8c5" />

*(There is a sequence jump while routers change from **Standby** to **Active** mode)*

> [!WARNING]
> #### ⚠️ Because the implemented of **IP SLA** this worked properbly normal:

**📸 Screenshot:**

<img width="615" height="41" alt="Screenshot 2026-02-06 210550" src="https://github.com/user-attachments/assets/ab94254d-fd80-4483-950c-bca9a2177f2d" />

*(ISP noticed the link is down when **Interface still maintaining UP** by IP SLA implemented)*

<img width="359" height="19" alt="Screenshot 2026-02-06 210555" src="https://github.com/user-attachments/assets/822cfe50-aaac-48e6-8f2c-825df57e636f" />

*(**Floating Static** comes in the routing table become the reply packets links for **both VLAN** instead of **Symmetric Routing**)*


<img width="1919" height="217" alt="Screenshot 2026-02-06 205020" src="https://github.com/user-attachments/assets/4a489f8f-a932-4f3e-9825-c75b2b616d93" />

*(The Ethernet0/1 will now **1 hand** carried both VLAN 1 and VLAN 2 packets instead of 2 hands carried it own VLAN packets)*

<img width="560" height="449" alt="Screenshot 2026-02-06 214046" src="https://github.com/user-attachments/assets/a4dbb7c7-151a-4637-95da-d178d2e8d0f3" />

*(VLAN 1 and VLAN 2 paths)*

> [!CAUTION]
**❗❗❗ With **no IP SLA implemented** this will cause the **"Silent Link Failures"** (where an interface stays UP but the path is DEAD) the ping will **stuck forever** because ISP **never replace the floating static route** when it **doesnt know the link is DEAD** so it is **keep forwarding** packets to DEAD link - Shows that **static routing** has **its sub-optimal aspects**, in the **Packet Tracer** is function very simple when you just down the Router and the link turn red so it is surely dead but in CML it is a **very big story** to work with❗❗❗**


---

###  Final Result
- **Full Redundancy:** The network survives a total failure of either R2 or R3 without dropping end-node sessions.

- **Load Balanced:** VLAN 1 and VLAN 2 utilize separate physical uplinks simultaneously.

- **Symmetric Flow:** Traffic leaves and returns through the same gateway, ensuring compatibility with stateful firewalls.

---

### Notes
> [!NOTE]
> |**Criteria**|**IP SLA (Static)**|**BFD (Dynamic)**|
> |-|-|-|
> |**Mechanism**| Sends **ICMP packets** **(Ping)** and **responds**| Two devices continuously send **extremely lightweight packets to each other**|
> |**Speed**| **Slower speed (s)** | **Extremely fast (ms)**|
> |**System Load**| **More CPU load** because it has to process the full ICMP packet |Very **lightweight**, can be handled by hardware **(ASIC)**|
> |**Application**| **Static Route** or when **depth testing** is needed | Specifically used for **OSPF, BGP, EIGRP** for **immediate and gentle disconnection** (Neighbor) when a connection is established|

| [⬅️ Previous Lab](../11A%20HSRP%20Enterprise%20Redundancy%20(PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../12A%20IPv6%20Addressing%20%26%20Basic%20Connectivity%20(PKT)) |
|:--- | :---: | ---: |




