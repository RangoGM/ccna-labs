## Lab 02A - VLAN Trunking (Default Allow All)

### Topology
This lab reuses the access-layer topology from **Lab 01 - Basic VLAN Configuration**.

The same VLAN and access port configuration is appllied on both switches. A second switch is added, and the two switches are connected using an IEEE 802.1Q trunk link.

---

### Goal 
- Understand IEEE 802.1Q trunking
- Verify VLAN communication across multiple switches
- Observe default trunk behavior (all VLANs allowed)

---

### VLAN Design

**Switch 1**
- VLAN 10 - SALES
- VLAN 20 - IT
- VLAN 30 - HR

**Switch 2**
- VLAN 10 - SALES
- VLAN 20 - IT
- VLAN 30 - HR

---

### Key Configuration 
- Reuse VLAN and access port configuration from Lab 01
- Create the same VLANs on both switches
- Configure a trunk link between the switches
- Do not restrict allowed VLANs on the trunk (This will be covered in lab 02B)

---

### Example Configuration (Trunk Port)

```bash
SW-CORE(config)#interface <trunk-interface>
SW-CORE(config-if)#switchport mode trunk
```

*(Access port configuration is omited for brevity)*

---

### Verification
- Verify VLAN database by using *```show vlan brief```* command
- Verify trunk status by using *```show interfaces trunk```* command
- Test connectivity using ping:
  - Same VLAN, different switch
  - Different VLAN

---

### Result 
- Devices in VLAN 10, VLAN 20, and VLAN 30 can communicate across switches
- Trunk operates with default settings, allowing all VLANs

--- 

### Troubleshooting / Common Mistakes

- Devices within the same VLAN are configured with different IP subnets  
  - Verify IP addressing on end devices

- Interface is administratively down  
  - Check interface status and enable it using *`no shutdown`*

- Trunk link is not formed between switches  
  - Verify trunk configuration and cable type

- Link does not come up due to incorrect cable type  
  - Ensure correct cable is used if auto-MDIX is not available
 
---

### Notes
This lab builds directly on Lab 01 and serves as a foundation for VLAN trunk
restriction and inter-VLAN routing.

By default, an IEEE 802.1Q trunk allows all VLANs. Since the same VLANs exist
on both switches and no restrictions are applied, traffic is successfully
forwarded across the trunk.

VLAN 1 is used as the native VLAN by default. Native VLAN configuration and
mismatch scenarios are not covered in this lab.
