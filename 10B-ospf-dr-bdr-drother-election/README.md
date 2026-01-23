## Lab 10B - OSPF DR / BDR / DROTHER Election

### Topology
This lab demonstrates **OSPF Designated Router (DR)**, **Backup Designated Router (BDR)**, **and DROTHER election** behavior on a broadcast multi-access network.

The topology includes both **point-to-point links** and a **shared broadcast segment**, allowing clear observation of OSPF neighbor states and election results.

---

### Goal
- Understand when and why OSPF elects DR and BDR
- Observe OSPF behavior on broadcast vs point-to-point networks
- Verify DR / BDR / DROTHER roles based on router IDs
- Confirm best-practice placement of DR and DROTHER routers

---

### Topology Design

#### Devices
- Routers: **R1, R2, R3, R4**
- Switch (broadcast network)
- INTERNET (simulated)

---

#### Network Segments

##### Point-to-Point Links
- **R1 - R4**
  - R1 G0/0: `192.168.10.1/30`
  - R4 G0/0: `192.168.10.2/30`
- **R1 - R3**
  - R1 G0/1: `192.168.20.1/30`
  - R3 G0/1: `192.168.20.2/30`
*(No DR/BDR election on point-to-point links)*

---

#### Broadcast Multi-Access Network (DR Election)
- **Network**: `192.168.50.0/24`
- Connected via switch:
  - R3 G0/2: `192.168.50.1/24`
  - R4 G0/2: `192.168.50.2/24`
  - R2 G0/0: `192.168.50.3/24`

 ---

 #### Internet Edge
 - **R2 - INTERNET**
   - R2 G0/0/0: `1.2.3.5/30`
   - INTERNET G0/0/0: `1.2.3.6/30`
  
---

#### Router IDs

| Router | Router ID |
|----|---------|
| R1 | 1.1.1.1 |
| R2 | 2.2.2.2 |
| R3 | 3.3.3.3 |
| R4 | 4.4.4.4 |

---

### Key Concepts
- OSPF broadcast network behavior
- DR / BDR / DROTHER election
- Router ID priority
- OSPF neighbor states
- Design best practices

---

### Key Configuration
- Enable OSPF on all routers
- Configure unique router IDs
- Advertise all internal networks into **Area 0**
- Configure passive interfaces where appropriate
- Do **not** manually set OSPF priority (use default behavior)

--- 

### Example Configuration (OSPF)
```bash
router ospf 1
  router-id <router-id>
  network <network> <wildcard-mask> area 0
```
*(Network statements vary per router)*

---

### Verification
- Verify OSPF neighbors:
  - *`show ip ospf neighbor`*
- Verify OSPF interface type:
  - *`show ip ospf interface`*
- Confirm DR / BDR / DROTHER roles on the 192.168.50.0/24 segment
- Test connectivity across the network

---

### Expected Election Result (192.168.50.0/24)

|Router|Role|
|------|----|
|R4 (RID 4.4.4.4)|**DR**|
|R3 (RID 3.3.3.3)|**BDR**|
|R2 (RID 2.2.2.2)|**DROTHER**|

---

### Result
- DR and BDR are elected only on the broadcast segment
- Point-to-point links do not participate in DR election
- Edge router (R2) correctly operates as DROTHER
- OSPF neighbor states reach FULL
- Network connectivity is maintained

---

### Troubleshooting / Common Mistakes
- Expecting DR election on point-to-point links
- Confusing router ID with interface IP address
- Assuming **`FULL/DR`** refers to the local router
- Using /30 networks and expecting DROTHER routers
- Placing Internet edge routers as DR unintentionally

---

### Notes
OSPF elects DR and BDR **only on broadcast and NBMA networks**, not on point-to-point links.

Router ID is the primary factor in DR election when interface priority is not manually configured.

Best practice is to place DR and BDR on routers located at the core or distribution layer, while edge routers (such as Internet-facing routers) operate as DROTHER.
