## Lab 10C - OSPF Multi-Area (ABR & LSA Propagation)

### Topology

This lab demonstrates **multi-area OSPF operation** using three OSPF areas:
- Area 0 (Backbone)
- Area 1
- Area 2
The topology includes **two Area Border Routers (ABRs)** that connect non-backbone areas to the backbone, allowing observation of inter-area routing and LSA propagation.

---

### Goal
- Understand OSPF multi-area design
- Identify the role of Area 0 (backbone)
- Configure ABRs to connect non-backbone areas
- Verify inter-area routing and end-to-end connectivity across OSPF areas
- Observe OSPF behavior across multiple areas

---

### Topology Design

#### Devices
- Routers: **R1, R2, R3, R4, R5**
- Switches
- Hosts (IP addressing via DHCP - omitted)

--- 

### Network & Area Design

#### Area 1
- **LAN 1**
  - R1 G0/1: `192.168.1.1/24`
- **Transit Link**
  - R1 G0/2: `192.168.2.1/24`
  - R2 G0/2: `192.168.2.2/24`

---

#### Area 0 (Backbone)
- **R2 - R3**
  - R2 G0/0: `192.168.3.1/24`
  - R3 G0/0: `192.168.3.2/24`
- **R3 - R4**
  - R3 G0/1: `192.168.4.1/24`
  - R4 G0/1: `192.168.4.2/24`

---

#### Area 2 
- **Transit Link**
  - R4 G0/0: `192.168.5.1/24`
  - R5 G0/0: `192.168.5.2/24`
- **LAN 2**
  - R5 G0/1: `192.168.6.1/24`

---

### Router Roles

|Router|Role|
|------|----|
|R1|Internal router (Area 1)|
|R2|**ABR (Area 1 ↔ Area 0)**|
|R3|Backbone router (Area 0)|
|R4|**ABR (Area 0 ↔ Area 2)**|
|R5|Internal router (Area 2)|

---

### Key Concepts
- OSPF Area 0 (Backbone)
- Area Border Router (ABR)
- Inter-area routing
- LSA Type 1, Type 2, Type 3
- OSPF hierarchy and scalability

---

### Key Configuration
- Enable OSPF on all routers
- Assign interfaces to the correct OSPF areas
- Ensure **Area 1 and Area 2 connect to Area 0 via ABRs**
- Configure passive interfaces for LAN-facing ports
- Do **not** use static routes

---

### Example Configuration (OSPF)

```bash
router ospf 1
 router-id <router-id>
 network <network> <wildcard-mask> area <area-id>
```
*(Network statements vary per router and area)*

---

### Verification

- Verify OSPF neighbors:
  - *`show ip ospf neighbor`*
- Verify OSPF routes:
  - *`show ip route ospf`*
- Verify OSPF areas:
  - *`show ip ospf`*
- Verify LSAs:
  - *`show ip ospf database`*
- Test connectivity:
  - Host in Area 1 -> Host in Area 2

---

### Result
- OSPF neighbors form successfully across all areas
- ABRs correctly propagate inter-area routes
- Hosts in Area 1 and Area 2 can communicate
- OSPF maintains hierarchical routing structure
- Network connectivity is maintained across multiple areas

---

### Troubleshooting / Common Mistakes
- Area 1 or Area 2 not connected to Area 0
- Incorrect area assignment on router interfaces
- Expecting direct routing between non-backbone areas
- Forgetting to configure ABRs correctly
- Passive interfaces blocking OSPF adjacencies

---

### Notes
OSPF requires all non-backbone areas to connect to **Area 0** for inter-area routing.

ABRs generate **Type 3 LSAs** to advertise networks between areas.

In Packet Tracer, OSPF adjacencies may occasionally fail to update correctly after configuration changes.
If Layer 1-3 checks are correct but routing does not converge, **reloading the affected routers may be required**.

This lab represents a typical enterprise OSPF design with hierarchical routing and improved scalability.
