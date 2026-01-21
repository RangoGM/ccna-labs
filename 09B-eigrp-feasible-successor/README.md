## Lab 09B - EIGRP Feasible Successor (Single Best Path)

### Topology
This lab builds directly on **Lab 09A - EIGRP Unequal-Cost Load Balancing**.

The physical topology and IP addressing remain unchanged.
The objective of this lab is to modify EIGRP behavior so that only one
best route is installed in the routing table, while alternate paths are
kept as backup (feasible successors).

---

### Goal
- Observe EIGRP single best-path routing behavior
- Understand successor and feasible successor concepts
- Verify fast failover without routing loops
- Compare routing behavior with Lab 09A

---

### Key Concepts
- Successor
- Feasible Successor
- Feasibility Condition
- EIGRP topology table vs routing table
- Fast convergence

---

### Key Configuration

- Reuse all configurations from Lab 09A
- Adjust EIGRP metrics by modifying interface bandwidth
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
*(Bandwidth is adjusted to make this path less preferred while still satisfying the feasibility condition)*

---

### Verification 

- Verify routing table:
  - *`show ip route`*
  - Confirm only one EIGRP route per destination
- Verify EIGRP topology table:
  - *`show ip eigrp topology`*
  - Confirm presence of a feasible successor
- Simulate failure:
  - Shut down the primary link
- Observe:
  - Immediate failover to the backup route
  - No routing loop
  - Minimal packet loss

### Result
- Only the best EIGRP route is installed in the routing table
- Alternate paths are stored as feasible successors
- Backup route becomes active immediately after primary link failure
- Network connectivity is maintained during failover

### Troubleshooting / Common Mistakes
- Multiple routes still appear in the routing table
  - Verify EIGRP metrics are not equal
  - Check interface bandwidth values
- No backup route during link failure
  - Verify the feasibility condition is met
  - Check EIGRP topology table for feasible successors
- Backup route is missing
  - Bandwidth may be reduced too aggressively
  - Restore a reasonable metric difference

---

### Notes
In this lab, EIGRP metrics are influenced by adjusting interface bandwidth.

Only the best path is installed in the routing table, while alternate paths that satisfy the feasibility condition are kept in the EIGRP topology table as feasible successors.

This behavior demonstrates EIGRP's fast convergence and reliability compared to traditional distance-vector routing protocols.
