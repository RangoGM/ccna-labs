## Lab 06 - EtherChannel (LACP)

### Topology
This lab builds on **Lab 05B - Spanning Tree Protocol (STP) Root Bridge**.

The same three-switch topology is reused, where **SW1 is configured as the
STP root bridge**. Multiple parallel links between two switches are bundled
using EtherChannel to demonstrate how STP interacts with a logical
Port-channel interface.

---

### Goal
- Understand the purpose of EtherChannel
- Configure EtherChannel using LACP
- Observe how EtherChannel interacts with STP
- Verify redundancy and link aggregation behavior

---

### Topology Design

**Devices**
- 3 Switches (SW1, SW2, SW3)
- PCs (optional, for connectivity testing)

**Links**
- Multiple parallel links between **SW1 and SW2**
- Switch-to-switch links are trunk ports
- EtherChannel is formed only between SW1 and SW2

---

### Key Concepts
- EtherChannel
- Port-channel interface
- LACP (Link Aggregation Control Protocol)
- Interface configuration consistency
- STP interaction with EtherChannel

---

### Key Configuration

- Reuse VLAN, trunk, and STP configuration from Lab 05B
- Ensure all member interfaces have **identical Layer 2 configurations**
- Configure EtherChannel using **LACP active mode**
- Apply trunk configuration on the **Port-channel interface**
- Do not mix trunk and access ports within the same EtherChannel

---

### Example Configuration

#### Configure EtherChannel Member Interfaces (LACP)

```bash
SWITCH(config)# interface range <interfaces>
SWITCH(config-if-range)# switchport mode trunk
SWITCH(config-if-range)# channel-group 1 mode active
```

#### Configure Port-Channel Interface
```bash
SWITCH(config)# interface port-channel 1
SWITCH(config-if)# switchport mode trunk
```
*(Physical interfaces inherit configuration from the Port-channel interface)*

---

### Verification
- Verify EtherChannel status:
  - *`show etherchannel summary`*
- Verify Port-channel interface:
  - *`show interfaces port-channel 1`*
- Verify trunk status:
  - *`show interfaces trunk`*
- Verify STP behavior:
  - *`show spanning-tree`*
 
---

### Result 
- Multiple physical links operate as a single logical Port-channel
- EtherChannel forms successfully only when interface configurations match
- STP treats the Port-channel as one logical link
- STP blocking states may change after EtherChannel formation
- Network connectivity is maintained if a member link fails

---

### Troubleshooting / Common Mistakes
- Attempting to bundle interfaces with different configurations
- Mixing trunk and access ports in the same EtherChannel
- Using different EtherChannel modes on each side
- Applying trunk configuration only on physical interfaces
- Expecting STP to block individual links inside an EtherChannel
---

### Notes
EtherChannel requires all member interfaces to have identical Layer 2 configurations, including switchport mode, encapsulation, and VLAN settings.

When EtherChannel is formed, STP no longer sees individual physical links. Instead, the Port-channel is treated as a single logical interface, which may cause STP to recalculate port roles and blocking states.

LACP is an IEEE standard protocol and is recommended for safer and more predictable EtherChannel negotiation.
