## Lab 09A - EIGRP Unequal-Cost Load Balancing

### Topology
This lab demonstrates EIGRP unequal-cost load balancing in a multi-path
network.

Three routers (R1, R2, R3) are interconnected using redundant links,
creating multiple paths between networks. EIGRP is configured to allow
unequal-cost routing, enabling multiple routes with different metrics
to be installed in the routing table.

An external network (INTERNET) is connected to R3 and reached via a
default route.

---

### Goal
- Configure EIGRP in a multi-router topology
- Observe EIGRP unequal-cost load balancing
- Verify that multiple routes are installed in the routing table
- Confirm end-to-end connectivity from LAN to INTERNET

---

### Topology Design

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

```bash
router eigrp 100
 no auto-summary
 network 192.168.1.0 0.0.0.15
 network 192.168.30.0 0.0.0.3
 network 192.168.40.0 0.0.0.3
 network 192.168.50.0 0.0.0.3
 passive-interface g0/2
 passive-interface g0/0/0
```
*(Network statements vary per router)*

---
### Verification
- Verify EIGRP neighbors:
  - *`show ip eigrp neighbors`*
- Verify routing table:
  - *`show ip route eigrp`*
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
  
