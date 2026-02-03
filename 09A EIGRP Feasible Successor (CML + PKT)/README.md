## Lab 09A - EIGRP Feasible Successor (Single Best Path)

### Topology

Three routers (R1, R2, R3) are interconnected using redundant links, creating multiple paths between networks. (PKT)

The objective of this lab is to modify EIGRP behavior so that only one
best route is installed in the routing table, while alternate paths are
kept as backup (feasible successors).

An external network (INTERNET) is connected to R3 and reached via a default route.

**📸: Screenshot**

<img width="1234" height="340" alt="1231" src="https://github.com/user-attachments/assets/8561c77f-5c05-4ac9-9bb8-cc30f28e6b96" />

*(In CML)*

---

### Topology Design (PKT)

**Devices**
- Routers: R1, R2, R3
- Switch (LAN)
- PC
- INTERNET (simulated router)

---

### IP Addressing Plan

**LAN**
- R1 G0/2: 192.168.1.1/28
- PC: 192.168.1.10/28

**Inter-router Links**
- R1 G0/0 – R2 G0/0: 192.168.30.0/30
- R1 G0/1 – R3 G0/1: 192.168.40.0/30
- R2 G0/2 – R3 G0/2: 192.168.50.0/30

**Internet Link**
- R3 G0/0/0: 1.2.3.5/30
- INTERNET G0/0/0: 1.2.3.6/30

---

### Goal
- Observe EIGRP single best-path routing behavior
- Understand successor and feasible successor concepts
- Verify fast failover without routing loops

---

### Key Concepts
- Successor
- Feasible Successor
- Feasibility Condition
- EIGRP topology table vs routing table
- Fast convergence

---

### Key Configuration

- Adjust EIGRP metrics by modifying interface bandwidth / delay
- Ensure one path is preferred as the primary route
- Keep the alternate path as a feasible successor
- Do not allow multiple routes in the routing table

---

### Example Configuration (Metric Tuning)

#### Adjust Bandwidth on Secondary Path

```bash
interface <interface-to-secondary-path>
 bandwidth 1000
```
*(Bandwidth / delay is adjusted to make this path less preferred while still satisfying the feasibility condition)*

---

### Verification 

- Verify routing table:
  - *`show ip route`*

 **📸: Screenshot**

 <img width="584" height="268" alt="Screenshot 2026-02-03 215102" src="https://github.com/user-attachments/assets/3993facd-8868-48e7-ac9e-50ed18ea8e7b" />

  - Confirm only one EIGRP route per destination
- Verify EIGRP topology table:
  - *`show ip eigrp topology`*
 
 **📸: Screenshot**

 <img width="422" height="59" alt="Screenshot 2026-02-03 224506" src="https://github.com/user-attachments/assets/e6004934-271a-4282-ba15-31b44a0f2e03" />

  - Confirm presence of a feasible successor
- Simulate failure:

**📸: Screenshot**

<img width="678" height="115" alt="Screenshot 2026-02-03 205947" src="https://github.com/user-attachments/assets/7f8b0fb9-a2f7-45f4-8e2c-1b32a4d133fe" />

  - Shut down the primary link: **In this case is Ethernet 1/3**
- Observe:
  - Immediate failover to the backup route
  - No routing loop
  - **Minimal packet loss**

**📸: Screenshot**

<img width="739" height="55" alt="Screenshot 2026-02-03 210609" src="https://github.com/user-attachments/assets/792ab0eb-21c3-44af-a523-2a4d794430ab" />

- During the **failover test**, the **ICMP sequence numbers jumped significantly** (e.g., from **7 to 20**) instead of returning **"Destination Host Unreachable"** errors.
  - **Zero Re-calculation:** This **"jump"** proves that EIGRP did not **drop** the **destination** from its routing table. Instead, it performed an immediate switchover to the **Feasible Successor**. While a few packets were lost during the physical transition, the network maintained its **"Passive"** state throughout the failure, demonstrating the superior convergence speed of the **DUAL algorithm** compared to legacy protocols like RIP.

 --- 

 
### Optimization: Achieving Sub-Second Failover in Virtual Environments (Extra)

Although EIGRP's **Feasible Successor** provides a ready-to-use backup path, the default detection time (15s Hold Timer) is too slow for modern standards. To achieve near-zero redundancy downtime in CML, I implemented **BFD (Bidirectional Forwarding Detection).**

**The Solution:** By offloading link failure detection to BFD with a 50ms interval, the router no longer waits for EIGRP Hello timeouts.


**📸: Screenshot**

<img width="346" height="58" alt="Screenshot 2026-02-03 212117" src="https://github.com/user-attachments/assets/f012b3d8-d26c-4e9a-863a-3779368947bd" />

(***1st line** and **2nd line** is for **both interfaces** configuration in **Router** (e.g. **R1** configured **BFD** for **Ethernet 1/2** & **Ethernet 1/3***) 
(***3rd line** is for `router eigrp` configuration and applied on all interfaces*)

- **Explanation** : Check every 50ms, if 3 packets (150ms) are lost, the service will be cut off.

-> Configured this with all Routers.


**The Result:** The "sequence jump" in ICMP traffic was minimized to the point of being negligible, proving that sub-second convergence is possible even in a virtualized CPU-bound environment.

**📸: Screenshot**

<img width="696" height="65" alt="Screenshot 2026-02-03 212102" src="https://github.com/user-attachments/assets/4ad2f1b7-231b-4e64-b735-f9b9cdab0aca" />


**This marks the transition from basic routing to High Availability (HA) design.**

--- 

### ⚠️ The "Anti-Theory" Test: Breaking the Feasibility Condition

In this experiment, I intentionally increased the **delay** on the backup neighbor (R4) to ensure its **Reported Distance (RD)** **exceeded** the primary **Feasible Distance (FD)**.
- The Consequence:
  - The backup path was stripped of its **Feasible Successor** status.
  - Upon primary link failure, the router entered the **ACTIVE state**, sending out **DUAL Queries** to find a new path.
  - Even with BFD enabled, the recovery was noticeably slower because the router had to perform a full re-calculation instead of an instant switchover.
- **Verdict:** A physical backup link is useless for high availability if it doesn't satisfy EIGRP's logic **($RD < FD$).**

---


### Result
- Only the best EIGRP route is installed in the routing table
- Alternate paths are stored as feasible successors
- Backup route becomes active immediately after primary link failure
- Network connectivity is maintained during failover


### Troubleshooting / Common Mistakes
- Multiple routes still appear in the routing table
  - Verify EIGRP metrics are not equal
  - Check interface bandwidth / delay values
- No backup route during link failure
  - Verify the feasibility condition is met
  - Check EIGRP topology table for feasible successors
- Backup route is missing
  - Bandwidth may be reduced too aggressively
  - Restore a reasonable metric difference

---

### Notes
In this lab, EIGRP metrics are influenced by adjusting interface bandwidth / delay.

Only the best path is installed in the routing table, while alternate paths that satisfy the feasibility condition are kept in the EIGRP topology table as feasible successors.

This behavior demonstrates EIGRP's fast convergence and reliability compared to traditional distance-vector routing protocols.
