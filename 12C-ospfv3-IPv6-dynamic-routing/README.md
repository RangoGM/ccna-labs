## Lab 12C - OSPFv3 (IPv6 Dynamic Routing)

### Topology
This lab introduces **OSPFv3** using a **new multi-router IPv6 topology.**

Three routers are connected in a linear chain.
Only the **first router** and **last router** connect to end hosts.

OSPFv3 is used to dynamically exchange IPv6 routes between routers, eliminating the need for static routing.

---

### Goal
- Configure OSPFv3 on multiple routers
- Understand interface-based OSPFv3 configuration
- Observe dynamic IPv6 route learning
- Verify end-to-end IPv6 connectivity
- Reinforce OSPFv3 neighbor formation using IPv6 link-local addresses

---

### Topology Design

#### Devices
- Routers: **R1, R2, R3**
- Switches: **SW1, SW2**
- Hosts: **PC1, PC2**

--- 

### IPv6 Addressing Plan

#### LAN 1 (PC1 ↔ R1)
- Network: `2001:db8:1::/64`
- R1 G0/1: `2001:db8:1::1/64`
- PC1: `2001:db8:1::10/64`
- Default Gateway: `2001:db8:1::1`

---

#### R1 ↔ R2
- Network: `2001:db8:12::/64`
- R1 G0/0: `2001:db8:12::1/64`
- R2 G0/0: `2001:db8:12::2/64`

---

#### R2 ↔ R3
- Network: `2001:db8:23::/64`
- R2 G0/1: `2001:db8:23::1/64`
- R3 G0/0: `2001:db8:23::2/64`

---

#### LAN 2 (R3 ↔ PC2)
- Network: `2001:db8:3::/64`
- R3 G0/1: `2001:db8:3::1/64`
- PC2: `2001:db8:3::10/64`
- Default Gateway: `2001:db8:3::1`

---

### Router IDs

|**Router**|**Router ID**|
|-|-|
|R1|1.1.1.1|
|R2|2.2.2.2|
|R3|3.3.3.3|

---

### Key Concepts 
- OSPFv3 overview
- Interface-based routing protocol
- IPv6 link-local neighbor adjacency
- Router ID requirement
- SPF algorithm (Dijkstra)
- Dynamic IPv6 route exchange

---

### Key Configuration

#### Enable IPv6 Routing (All Routers)
```bash
ipv6 unicast-routing
```

---

#### Configure OSPFv3 Process & Router ID
```bash
ipv6 router ospf 1
  router-id <router-id>
```

---

#### Enable OSPFv3 on Interfaces
```bash
interface <interface>
  ipv6 ospf 1 area 0
```

Apply OSPFv3 to:
- LAN-facing interfaces
- Inter-router interfaces


---

### Example Configuration (R2)
```
ipv6 router ospf 1
  router-id 2.2.2.2
```
```
interface g0/0
  ipv6 ospf 1 area 0
```
```
interface g0/1
  ipv6 ospf 1 area 0
```

---

### Verification
- Verify OSPFv3 neighbors:
```show ipv6 ospf neighbor```
- Verify IPv6 routing table:
```show ipv6 route ospf```
- Verify OSPFv3 process:
```show ipv6 ospf```
- Test end-to-end connectivity:
```
ping ipv6 2001:db8:3::10
ping ipv6 2001:db8:1::10
```

--- 

### Expected Result
- OSPFv3 neighbors form correctly between R1-R2 and R2-R3
- IPv6 routes are learned dynamically
- Routing table displays **O (OSPF)** entries
- PC1 can ping PC2 successfully
- No static routes are required

--- 

### Troubleshooting / Common Mistakes
- Forgetting `ipv6 unicast-routing`
- Missing router ID
- Enabling OSPFv3 globally but not on interfaces
- Expecting `network` command (OSPFv3 does not use it)
- Interfaces in mismatched OSPF areas

---

### Notes
- OSPFv3 is **interface-based**, unlike OSPFv2
- Neighbor adjacencies use **link-local IPv6 addresses**
- Router ID is mandatory and uses IPv4 format
- This topology reflects a **realistic IPv6 routed enterprise segment**

