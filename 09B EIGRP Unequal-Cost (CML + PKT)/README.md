<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |


## Lab 09B - EIGRP Unequal-Cost Load Balancing

### Topology
This lab demonstrates EIGRP unequal-cost load balancing in a multi-path
network. Builds directly on Lab 09A - EIGRP Feasible Successor.

EIGRP is configured to allow unequal-cost routing, enabling multiple routes with different metrics
to be installed in the routing table.

An external network (INTERNET) is connected to R3 and reached via a
default route. 

📸: Screenshot

<img width="519" height="249" alt="image" src="https://github.com/user-attachments/assets/92b59b76-2d35-4247-bbb0-1210a26dc24a" />

*(In CML)*

---

### Goal
- Configure EIGRP in a multi-router topology
- Observe EIGRP unequal-cost load balancing
- Verify that multiple routes are installed in the routing table
- Confirm end-to-end connectivity from LAN to INTERNET
- **The ultimate goal** of networking isn't just connectivity; it's **deterministic behavior**. By using BFD for sub-second failure detection and EIGRP UCLB for intelligent bandwidth utilization, we move from a 'hope-it-works' network to a highly available, high-performance infrastructure.

---

### Key Concepts
- EIGRP Autonomous System
- DUAL algorithm
- Feasible Distance (FD) and Advertised Distance (AD)
- Unequal-cost load balancing
- Passive interface
- Default routing

---

### Key Configuration

- Configure IP addressing on all interfaces
- Enable EIGRP with AS 100
- Disable automatic summarization
- Advertise all connected networks
- Configure passive interfaces for:
  - LAN-facing interface
  - Internet-facing interface
- Configure a default route on R3 pointing to the INTERNET
- Observe EIGRP unequal-cost load balancing behavior

---

### Example Configuration (EIGRP)

📸: Screenshot

<img width="422" height="59" alt="Screenshot 2026-02-03 224506" src="https://github.com/user-attachments/assets/ce75ce21-55bf-42fb-9449-a3a7b13cd546" />

<img width="584" height="268" alt="Screenshot 2026-02-03 215102" src="https://github.com/user-attachments/assets/97e1c302-5bdc-450f-9cef-f53ac1cbddc9" />


*(Last lab theres are only **one** EIGRP route was in routing table to the **destination 3.3.3.3** , if you want router to ativated **unequal-cost load-balancing** you must use the `variance` comands)*

`
router eigrp 100
  varriance X
`

- In this case if you want to use both links to transmitting data use must use "X" = 3 as long as this condition is met:

**FD multiply Variance > Metric thats you want the link to perform unequal cost load balancing**

**448000 x 3 > 921600 (Accept)**

**448000 x 2 < 921600 (Not Qualified)**

---
### Verification
- Verify EIGRP neighbors:
  - *`show ip eigrp neighbors`*
- Verify routing table:
  - *`show ip route eigrp`*
 
📸: Screenshot

<img width="579" height="96" alt="Screenshot 2026-02-03 215229" src="https://github.com/user-attachments/assets/6f489a92-0961-4226-a329-981105c50471" />

*(In routing tables theres are now appeard 2 path with different metric to perform unequal load balancing)*

- Verify unequal-cost routes:
  - Observe multiple EIGRP routes to the same destination
- Test connectivity:
  - PC -> INTERNET
  - PC -> all internal networks

---

### Result
- All routers learn multiple EIGRP routes to the same destination
- Unequal-cost load balancing is observed
- Routing tables display multiple EIGRP paths
- PC can successfully reach the INTERNET and all internal networks

📸: Screenshot

<img width="1908" height="556" alt="Screenshot 2026-02-03 220917" src="https://github.com/user-attachments/assets/98bc067e-f69b-45bc-971b-1112f8bfe029" />

*(Ping only one Host to destination, as in the picture because the **interface Ethernet1/3** with **lower metric (448000)** is **preffered** than the interface **Ethernet1/2** with **higher metric (921600)** so the router deciding to forward the packets out of **Interface Ethernet1/3**)*

<img width="1876" height="834" alt="Screenshot 2026-02-03 220025" src="https://github.com/user-attachments/assets/c95089fb-29bc-4f56-b9c9-c4b2fddd5eee" />

*(Ping both Hosts, this time the unequal load balancing method is performed more clearly)*

- To visually confirm the **proportional traffic distribution**, I used `hping3` in flood mode from the Kali hosts. Unlike a standard ping, this generates a high volume of packets, allowing us to observe the **Traffic Share Ratio** in real-time.

📸: Screenshot

<img width="1267" height="48" alt="Screenshot 2026-02-03 222713" src="https://github.com/user-attachments/assets/9c23b959-4cc7-4282-9e7b-b020c9b9c089" />

<img width="925" height="362" alt="Screenshot 2026-02-03 222510" src="https://github.com/user-attachments/assets/cf63f39c-9ed0-4d51-855d-114681d82f0b" />

**Final Proof:** Proportional Traffic Distribution in UCLB

The ultimate test of EIGRP's **Unequal Cost Load Balancing** was verified through real-time interface statistics. By utilizing two distinct traffic flows, the router successfully distributed packets across both the primary and backup links simultaneously.

**The Data:**

**Primary Link (Low Metric):** 612 Packets/Sec

**Backup Link (High Metric):** 474 Packets/Sec

- Analysis: This ratio confirms that EIGRP does not just load balance; it **load weighs**. The DUAL algorithm intelligently calculates a traffic share count, ensuring that higher-capacity links handle the bulk of the data while secondary links provide supplemental bandwidth rather than remaining dormant.

**Conclusion:** With **BFD** for instant failover and **UCLB** for optimized throughput, this EIGRP configuration represents a robust, high-availability enterprise design.

---

### Troubleshooting / Common Mistakes

- EIGRP neighbors do not form
  - Verify that all routers use the same EIGRP AS number
  - Check that interfaces are not incorrectly configured as passive
  - Verify IP addressing and subnet masks on inter-router links

- Routes are not learned dynamically
  - Verify correct `network` statements with proper wildcard masks
  - Ensure `no auto-summary` is configured on all routers
  - Check that the interfaces belong to the advertised networks

- Unequal-cost load balancing is not observed
  - Verify that multiple paths exist between routers
  - Check EIGRP metrics (bandwidth and delay)
  - Verify that alternate routes satisfy the feasibility condition
  - Confirm multiple EIGRP routes appear in the routing table

- PC cannot reach the INTERNET
  - Verify default route configuration on R3
  - Ensure the INTERNET-facing interface is excluded from EIGRP
  - Verify return routing from INTERNET to R3

---

### Notes
EIGRP supports unequal-cost load balancing, allowing multiple routes with different metrics to be installed in the routing table as long as they satisfy the feasibility condition.

This behavior is useful in networks with redundant links of different bandwidths or delays.

| [⬅️ Previous Lab](../09A%20EIGRP%20Feasible%20Successor%20(CML%20%2B%20PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../10A%20OSPF%20Single%20Area%20(CML%20%2B%20PKT)) |
|:--- | :---: | ---: |

  
