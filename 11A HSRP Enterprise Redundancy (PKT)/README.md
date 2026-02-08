<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |



## Lab 11 - HSRP Enterprise Redundancy (PKT Optimal)

#### **(HSRP + STP Load Sharing + Dual DHCP on L3 Switches)**

---

### Topology

This lab demonstrates an **enterprise-style gateway redundancy design** using **HSRP, STP load sharing, and dual DHCP services** on Layer 3 switches.

The topology is designed to provide **high availability** at both **Layer 2 and Layer 3**, ensuring uninterrupted connectivity for end devices even during device or link failures.

**📸 Screen shot:**

<img width="487" height="510" alt="Screenshot 2026-01-27 021802" src="https://github.com/user-attachments/assets/cbff6ff5-6ad0-4a1f-b1dc-d441f8f0b9e3" />


---

### Goal 
- Configure HSRP for default gateway redundancy
- Implement per-VLAN HSRP load sharing
- Combine HSRP with STP root placement
- Provide DHCP redundancy using two Layer 3 switches
- Verify network resilience during multiple failure scenarios

---

### Topology Design

#### Devices
- 1 Router (Internet edge)
- 2 Layer 3 Switches (Distribution layer - SVI + DHCP + HSRP)
- 2 Layer 2 Switches (Access layer)
- PCs (end devices)

--- 

### VLAN Design

|**VLAN**|**Purpose**|**Virtual IP (HSRP)**|
|--------|-----------|---------------------|
|10|Users / SALES|192.168.10.254|
|20|Users / IT|192.168.20.254|

---

### SVI & HSRP Design

#### Distribution Switch 1 (DSW1)
- VLAN 10
  - SVI: `192.168.10.1/24`
  - HSRP priority: **105 (Active)**
- VLAN 20
  - SVI: `192.168.20.2/24`
  - HSRP priority: **95 (Standby)**

#### Distribution Switch 2 (DSW2)
- VLAN 10
  - SVI: `192.168.10.2/24`
  - HSRP priority: **95 (Standby)**
- VLAN 20
  - SVI: `192.168.20.1/24`
  - HSRP priority: **105 (Active)**

--- 

### STP Design (Load Sharing)
|**VLAN**|**Root Primary**|**Root Secondary**|
|--------|-----------|---------------------|
|10|DSW1|DSW2|
|20|DSW2|DSW1|

This ensures:
- VLAN 10 traffic prefers DSW1
- VLAN 20 traffic prefers DSW2
- Balanced traffic flow across the distribution layer

---

### DHCP Design
- Both Layer 3 switches act as DHCP servers
- One DHCP pool per VLAN on each switch
- Excluded addresses:
  - `192.168.10.1 - 192.168.10.10`
  - `192.168.20.1 - 192.168.20.10`
- Default gateway provided via **HSRP Virtual IP**

---

### Key Configuration

#### HSRP (Example - VLAN 10)
```bash
interface vlan 10
  ip address 192.168.10.1 255.255.255.0
  standby 1 ip 192.168.10.254
  standby 1 priority 105
  standby 1 preempt
```
*(DSW2 uses lower priority for VLAN 10)*

---

#### DHCP (Example)
```bash
ip dhcp excluded-address 192.168.10.1 192.168.10.10

ip dhcp pool VLAN10
 network 192.168.10.0 255.255.255.0
 default-router 192.168.10.254
```

---

### Verification 
- Verify HSRP status:
  - `show standby brief`
- Verify STP root roles:
  - `show spanning-tree vlan 10`
  - `show spanning-tree vlan 20`
- Verify DHCP bindings:
  - `show ip dhcp binding`
- Test connectivity:
  - PC -> Default Gateway
  - PC -> Internet

---

### Failure Scenarios Tested
- One Layer 3 switch failure
- One access switch uplink failure
- HSRP active gateway failure
- DHCP service loss on one switch
- No manual intervention required during failover


✅ In all scenarios, PCs retain connectivity and can reach the Internet.

---

### Result
- HSRP provides seamless gateway redundancy
- STP ensures optimal Layer 2 path selection
- DHCP services remain available during failures
- Network maintains connectivity despite device or link outages
- Enterprise-grade high availability is achieved

--- 

### Troubleshooting / Common Mistakes
- Forgetting to enable `preempt` on HSRP
- Incorrect HSRP priority values
- STP root not aligned with HSRP active gateway
- DHCP pools overlapping excluded addresses
- Access switch uplinks not properly redundant

---

### Notes
This lab represents a **real-world enterprise campus design** combining:
- Layer 2 redundancy
- Layer 3 gateway redundancy
- Service-level redundancy (DHCP)

HSRP and STP are intentionally aligned to optimize traffic flow and avoid suboptimal forwarding paths.

This design scales well and serves as a strong foundation for advanced technologies such as routing protocols, IP SLA tracking, and automation.


| [⬅️ Previous Lab](../10C%20OSPF%20Multi-Area%20(CML%20%2B%20PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../11B%20HSRP%20Enterprise-Grade%20High%20Availability%20(CML)) |
|:--- | :---: | ---: |


