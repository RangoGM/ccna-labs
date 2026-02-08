<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |


## Lab 08 - Dynamic Routing Protocol (RIP v2)

### Topology
This lab introduces dynamic routing using RIP version 2.

A simple multi-router topology is used, where multiple routers are
connected through different networks. RIP is configured to dynamically
exchange routing information between routers.

**📸 Screenshot:**

<img width="901" height="340" alt="Screenshot 2026-02-03 114248" src="https://github.com/user-attachments/assets/a1bfb59e-c8a1-4331-983f-895e78394705" />


---

### Goal
- Understand the purpose of dynamic routing protocols
- Configure RIP version 2
- Observe automatic route learning
- Verify end-to-end connectivity using dynamic routing

---

### Topology Design (PKT)

**Devices**
- 3 Routers (R1, R2, R3)
- PCs (optional, for connectivity testing)

**Links**
- Point-to-point connections between routers
- Each router connects to a unique LAN

---

### IP Addressing Plan (Example)

| Device | Interface | Network |
|------|-----------|---------|
| R1 | LAN | 192.168.1.0/24 |
| R1–R2 | WAN | 10.0.12.0/30 |
| R2–R3 | WAN | 10.0.23.0/30 |
| R3 | LAN | 192.168.3.0/24 |

---

### Key Concepts
- Static routing vs Dynamic routing
- Distance Vector routing protocol
- Hop count metric


   **📸 Screenshot:**
  
<img width="1011" height="450" alt="Screenshot 2026-02-03 104929" src="https://github.com/user-attachments/assets/9ed9e380-4908-4182-8fb9-13ccb5879299" />

<img width="908" height="427" alt="Screenshot 2026-02-03 104937" src="https://github.com/user-attachments/assets/37dae2ec-2e5d-405e-9acd-beb860a95af1" />

*(On top: Configured the path on both links with **bandwidth = 56kpbs***


<img width="786" height="326" alt="Screenshot 2026-02-03 104859" src="https://github.com/user-attachments/assets/95c64e0b-af92-4f1c-811d-48621ff483b4" />

<img width="881" height="378" alt="Screenshot 2026-02-03 104906" src="https://github.com/user-attachments/assets/ebe8f57e-c0d3-4058-b15c-af0e25cda722" />

<img width="866" height="410" alt="Screenshot 2026-02-03 104916" src="https://github.com/user-attachments/assets/812005df-0cff-4efb-bcb2-c12de7e76794" />


*(At bottom: Configured the path on all links with **bandwidth = 1000000 kpbs (1Gbps)**)*

*(And lets see how RIP transmitting packets based on **Hop counts** preffered than **Bandwidth**)*
  
- RIP limitations in **full mesh** Topology

   **📸 Screenshot:**

<img width="816" height="331" alt="Screenshot 2026-02-03 114238" src="https://github.com/user-attachments/assets/45060747-50eb-40ec-a404-80887905050e" />


- RIP v1 (**with no VLSM support**) vs RIP v2 (**with VLSM suport**)

---

### Key Configuration

- Configure IP addressing on all router interfaces
- Enable RIP version 2
- Advertise connected networks
- Disable classful routing using `no auto-summary`

---

### Example Configuration

#### Enable RIP v2

```bash
ROUTER(config)# router rip
ROUTER(config-router)# version 2
ROUTER(config-router)# no auto-summary
ROUTER(config-router)# network <network>
```
*(Repeat network statements for all directly connected networks)*

---

### Verification 
- Verify RIP routes:
  - *`show ip route rip`*


**📸 Screenshot:**

<img width="536" height="78" alt="Screenshot 2026-02-03 105048" src="https://github.com/user-attachments/assets/9d49cce2-9af4-4002-8619-c115857a4415" />

*Example random routers output*

*In this output, the notation [120/X] reveals RIP's simplistic routing logic:*

***[120/1]:** The destination is 1 hop away. The packet reaches the target via one next-hop router.*

***[120/2]:** The destination is 2 hops away. The packet must traverse two routers to reach the target.**

RIPv2 only counts the number of "stops" (routers) along the path, completely ignoring link speed or bandwidth.

- Verify routing table:
  - *`show ip route`*
- Verify RIP configuration:
  - *`show ip protocols`*
- Test connectivity using ping between LANs

 **📸 Screenshot:**

<img width="623" height="236" alt="Screenshot 2026-02-03 105212" src="https://github.com/user-attachments/assets/70f37d31-5c21-4899-9409-64679fb33493" />

<img width="1900" height="761" alt="Screenshot 2026-02-03 105237" src="https://github.com/user-attachments/assets/9fb13077-b4c0-4ad7-9018-72308263780b" />

***Host 1** can now reach **Host 2** but:*

- RIPv2 is a Distance Vector protocol that uses a single, simplistic metric: **Hop Count.**
- **Metric Ignorance:** RIPv2 does not understand **"Bandwidth", "Delay," or "Link Speed".** It only counts how many **routers** a packet must pass through.
- The Comparison:
  - **Path A Metric** = 2 (**R_HQ** - **R2** - **R_BRANCH**)
  - **Path B Metric** = 3 (**R_HQ** - **R3** - **R4** - **R_BRANCH**)
- The Decision: Since **2 < 3**, RIPv2 considers the **56kbps** link as the **"Best Path"** and installs it in the routing table, **completely ignoring** the superior capacity of the **longer route**.
**Key Takeaway:** This lab demonstrates why RIPv2 is **obsolete** for **modern, high-speed networks**. It prioritizes the **"shortest"** path over the **"fastest"** path, leading to severe performance **bottlenecks**.
---

#### Shutdown Best Link

 **📸 Screenshot:**

<img width="1911" height="666" alt="Screenshot 2026-02-03 105901" src="https://github.com/user-attachments/assets/6117bc58-5e4f-4021-b284-19430d9c18f9" />

*ICMP Packets go through **Backup links***

🛑 **The "Cable Cut" Paradox: Shutdown vs. Physical Failure**

In this lab, I tested two failure scenarios:


**Software Shutdown:** The router immediately poisons the route, and traffic failover happens in seconds. *(But it is still not working efficiently in modern network with high scalability devices")*

**📸 Screenshot:**


<img width="739" height="389" alt="Screenshot 2026-02-03 110256" src="https://github.com/user-attachments/assets/088f6dcb-8e61-42f4-b455-77004a363907" />

**Physical Disconnect (CML Link Break):** This revealed the fatal flaw of RIPv2. Because RIPv2 relies on **periodic timers** rather than **active neighbor keepalives**, the network suffered a **180-second** outage. The neighbors kept **forwarding traffic** into the **"broken" link** because they were waiting for the **Invalid Timer** to **expire**.

**📸 Screenshot:**

<img width="495" height="293" alt="Screenshot 2026-02-03 110640" src="https://github.com/user-attachments/assets/7006a49a-183c-418d-8eb3-3b47a607fe9d" />

*Link still remains **UP** state*

<img width="1253" height="562" alt="Screenshot 2026-02-03 105827" src="https://github.com/user-attachments/assets/b3c63aa5-848d-4d20-bdbc-667251f5820c" />

*Taking 3 minutes to let the router decided to forwarding the packets through the **backup** links*

This 3-minute downtime is unacceptable for modern business networks...

- Can reduce **router rip timers basic** to lower the updates packet times, this lead to the router could decided forwarding the frame to the **backup** links as soon as possible, but again still not reliable if manually every routers in high scalability network.

**📸 Screenshot:**

<img width="409" height="39" alt="Screenshot 2026-02-03 110353" src="https://github.com/user-attachments/assets/54b5afc4-cdf9-4d4d-93a6-5802d77a9d8e" />

*(Updates each 5 secconds and confirm the links is broken in 15 secconds processing)*

<img width="662" height="323" alt="Screenshot 2026-02-03 111253" src="https://github.com/user-attachments/assets/dfd0c977-f135-4369-a190-8579cd9ea23a" />

---

#### VLSM

**The "Classful" Trap:** Why no `auto-summary` is **Mandatory**
In this experiment, I tested RIPv2's behavior with **Auto-Summary** enabled. Because RIPv2 has **"Classful"** roots, it attempts to **summarize subnets** to their major network boundaries **(Class A, B, or C)** when advertising them across a different network.

The Result: When I assigned `172.16.1.0/24` to **R1** and `172.16.2.0/24` to **R3**, both routers advertised the exact same `172.16.0.0/16` summary to the core. This created a **Discontiguous Network** conflict. **The core router**, receiving the **same summary** from **two different directions**, became **confused—leading** to **unstable routing** and **broken connectivity.**

**📸 Screenshot:**

<img width="520" height="35" alt="Screenshot 2026-02-03 112538" src="https://github.com/user-attachments/assets/9eb25655-37b4-4596-967c-ed02cf426e52" />

*Because RIPv2 summarized the specific /24 subnets (`172.16.1.0 and 172.16.2.0`) into a single Class B boundary (`172.16.0.0/16`), the core router assumed both paths led to the same destination. This created a routing conflict where the router performed equal-cost load balancing for a network that was actually split across different locations.*

<img width="594" height="268" alt="Screenshot 2026-02-03 112509" src="https://github.com/user-attachments/assets/a06133c7-92a8-4e3b-9252-c31c6aac677c" />

 *My ping tests returned "Destination Host Unreachable". The packets were being "black-holed" or sent to the wrong router half the time, proving that without the no auto-summary command, RIPv2 cannot effectively support VLSM or discontiguous networks.*

**The Fix:** By issuing the `no auto-summary` command, I forced RIPv2 to include the **specific subnet mask (VLSM)** in its updates. This allows the protocol to function in a **"Classless"** manner, ensuring that specific subnets are recognized and routed correctly across the entire topology.

---

#### Full Mesh Topology: Redundancy or Chaos?

**📸 Screenshot:**


<img width="568" height="178" alt="Screenshot 2026-02-03 113858" src="https://github.com/user-attachments/assets/9056d0fa-e311-4c92-aa69-19a08a93871a" />

<img width="563" height="210" alt="Screenshot 2026-02-03 113904" src="https://github.com/user-attachments/assets/59194922-b1e2-4818-9d70-6866e3c13b87" />


My **final experiment** with RIPv2 in a **Full Mesh topology** revealed its **biggest weakness:** **Inefficiency.** As seen in the debug logs, the periodic updates create constant **CPU and bandwidth overhead.** Furthermore, **the routing table is now cluttered with multiple Equal-Cost Multi-Path (ECMP) entries** because the protocol only sees **"Hops**", not speed or link quality.

**A mesh this complex is too noisy for such a simple protocol**. It's time to move on to more intelligent, event-driven routing...

That's why we are leaving the 90s behind and heading to OSPF and Security labs. 😉

**Final Verdict on RIPv2:** It is automated, yes. But it is **noisy, slow to heal, and mathematically "shallow"**. It treats a **world-class fiber optic** link and a **rusty copper wire** exactly the same if they are both one hop away.

---

### Result
- Routers dynamically learn routes using RIP v2
- Routing tables are updated automatically
- End devices can communicate across different networks
- Manual static routes are not required

---

### Troubleshooting / Common Mistakes
- Forgetting to enable RIP version 2
- Missing *`no auto-summary`*
- Incorrect network statements
- Expecting RIP to scale in large networks
- Forgetting that RIP uses hop count as its metric

---

### Notes
RIP is a distance-vector routing protocol that uses hop count as its metric.
The maximum hop count supported by RIP is 15, which limits its scalability.

Although RIP is rarely used in modern production networks, it is included in CCNA to help understand the fundamentals of dynamic routing protocols.


| [⬅️ Previous Lab](../07%20Static%20Routing%20(CML%20%2B%20PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../09A%20EIGRP%20Feasible%20Successor%20(CML%20%2B%20PKT)) |
|:--- | :---: | ---: |
