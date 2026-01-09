## Lab 03 - Inter-VLAN Routing (Router-on-a-Stick)

### Topology
This lab builds on **Lab 02A - VLAN Trunking (Default Allow All)**.

All VLANs are already allowed on the trunk between switches, ensuring
Layer 2 connectivity before implementing inter-VLAN routing.
A router is added and connected to the switch using a trunk link.

---

### Goal
- Understand inter-VLAN routing concepts
- Configure router-on-a-stick using subinterfaces
- Enable communication between different VLANs
- Verify Layer 3 connectivity between VLANs

---

### VLAN Design

**Switch**
- VLAN 10 - SALES
- VLAN 20 - IT
- VLAN 30 - HR

**Router**
- One physical interface
- One subinterface per VLAN
- Acts as the default gateway for all VLANs

---

### IP Addressing Plan (Example)

| VLAN | Subnet | Default Gateway |
|------|--------|-----------------|
| 10 | 192.168.10.0/24 | 192.168.10.1 |
| 20 | 192.168.20.0/24 | 192.168.20.1 |
| 30 | 192.168.30.0/24 | 192.168.30.1 |

---

### Key Configuration
- Reuse VLAN and access port configuration from Lab 02A
- Keep trunk configuration unchanged (all VLANs allowed)
- Configure a trunk link between the switch and the router
- Create router subinterfaces for each VLAN
- Assign IP addresses to subinterfaces
- Configure end devices with the correct default gateway

---

### Example Configuration

#### Switch (Trunk to Router)

```bash
SWITCH(config)# interface <interface-to-router>
SWITCH(config-if)# switchport mode trunk
```

#### Router (Router-on-a-Stick)

```bash
ROUTER(config)# interface <physical-interface>.10
ROUTER(config-subif)# encapsulation dot1Q 10
ROUTER(config-subif)# ip address 192.168.10.1 255.255.255.0

ROUTER(config)# interface <physical-interface>.20
ROUTER(config-subif)# encapsulation dot1Q 20
ROUTER(config-subif)# ip address 192.168.20.1 255.255.255.0

ROUTER(config)# interface <physical-interface>.30
ROUTER(config-subif)# encapsulation dot1Q 30
ROUTER(config-subif)# ip address 192.168.30.1 255.255.255.0
```
*(Physical router interface is enabled by default)*

--- 

### Verification 

- Verify router subinterfaces:
  - *```show ip interface brief```*
- Verify trunk configuration on the switch:
  - *```show interfaces trunk```*
- Test connectivity using ping:
  - VLAN 10 -> VLAN 20
  - VLAN 10 -> VLAN 30
  - VLAN 20 -> VLAN 30

---

### Result 

- Devices in different VLANs can communicate successfully
- Inter-VLAN routing is performed by the router
- Layer 2 VLAN segmentation is preserved

---

### Troubleshooting / Common Mistakes

- Router physical interface is administratively down
  - Enable it using *`no shutdown`*
- Incorrect VLAN encapsulation on router subinterfaces
  - Verify *`encapsulation dot1Q`* values
- Missing or incorrect default gateway on end devices
  - Verify IP configuration on PCs
- VLAN traffic not reaching the router
  - Verify trunk configuration between switch and router

---

### Notes

Inter-VLAN routing requires a Layer 3 device.
In this lab, a single router interface is used with multiple subinterfaces,
each associated with a VLAN using IEEE 802.1Q tagging.

This lab demonstrates how Layer 3 routing enables communication between
separate VLANs while maintaining Layer 2 segmentation.
