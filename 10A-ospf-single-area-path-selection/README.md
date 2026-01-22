## Lab 10A - OSPF Single Area (Path Selection & Convergence)

### Topology
This lab reuses the topology from **Lab 09A - EIGRP Unequal-Cost Load Balancing**.

The routing protocol is changed from EIGRP to OSPF. All routers participate
in a single OSPF area (Area 0). The topology provides multiple paths between
routers, allowing observation of OSPF path selection and convergence behavior.

---

### Goal
- Configure OSPF in a single-area topology
- Manually configure router IDs
- Observe OSPF cost-based path selection
- Verify OSPF convergence during link failure and recovery

---

### Topology Design

**Devices**
- Routers: R1, R2, R3
- Switch (LAN)
- PC
- INTERNET (simulated router)

**Routing Protocol**
- OSPFv2
- Single Area (Area 0)

---

### IP Addressing
Reuse the same IP addressing plan from **Lab 09A**.

---

### Key Concepts
- OSPF single-area operation
- Router ID selection
- OSPF cost metric
- Shortest Path First (SPF) algorithm
- OSPF convergence

---

### Key Configuration

- Remove EIGRP configuration from all routers
- Enable OSPF process
- Manually configure router IDs
- Advertise all internal networks into OSPF Area 0
- Configure passive interfaces for:
  - LAN-facing interface
  - Internet-facing interface
- Configure a default route on the edge router (R3)

---

### Example Configuration

#### Enable OSPF and Set Router ID

```bash
router ospf 1
 router-id <router-id>
 network <network> <wildcard-mask> area 0
```
*(Repeat network statements for all OSPF-enabled interfaces)*

---

### Verification
- Verify OSPF neighbors:
  - *`show ip ospf neighbor`*
- Verify routing table:
  - *`show ip route ospf`*
- Verify OSPF interface state:
  - *`show ip ospf interface`*
- Verify OSPF topology information:
  - *`show ip ospf database`*
- Test connectivity:
  - PC -> INTERNET
  - PC -> all internal networks

---

### Convergence Test
- Shut down the primary OSPF path between R1 and R3
- Observe routing table updates and traffic flow
- Verify traffic reroutes via R1 -> R2 -> R3
- Restore the link and observe OSPF reconvergence to the shortest path

---

### Result
- OSPF selects the shortest path based on cost
- Routing tables update dynamically during link failures
- Network connectivity is maintained during convergence
- OSPF reconverges to the optimal path when the link is restored

---

### Troubleshooting / Common Mistakes
- OSPF neighbors do not form
  - Verify matching area IDs
  - Check router ID uniqueness
  - Ensure interfaces are not incorrectly configured as passive
- Routes are missing from the routing table
  - Verify correct network statements
  - Check wildcard masks
  - Confirm interfaces belong to Area 0
- Unexpected path selection
  - Verify interface cost values
  - Check bandwidth and cost calculation
 
---

### Notes 

This lab demonstrates basic OSPF single-area operation using cost-based path selection.

Manual router ID configuration ensures predictable OSPF behavior and simplifies troubleshooting.

OSPF automatically recalculates the shortest path using the SPF algorithm when topology changes occur.
