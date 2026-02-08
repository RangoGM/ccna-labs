<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |

---
## Lab 02B - VLAN Trunking (Allowed VLAN Restriction)

### Topology
This lab reuses the same topology from **Lab 02A - VLAN Trunking (Default Allow All)**.

The only change in this lab is the allowed VLAN configuration on the trunk
link between the two switches.

---

### Goal
- Understand how the allowed VLAN list affects trunk traffic
- Observe VLAN behavior when a VLAN is not permitted on the trunk
- Compare restricted trunk behavior with default trunk behavior (Lab 02A)

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
- Reuse VLAN and access port configuration from Lab 02A
- Configure a trunk link between the switches
- Restrict allowed VLANs on the trunk
- VLAN 30 is intentionally excluded from the allowed VLAN list

---

### Example Configuration (Trunk Port)

```bash
SW-CORE(config)# interface <trunk-interface>
SW-CORE(config-if)# switchport mode trunk
SW-CORE(config-if)# switchport trunk allowed vlan 10,20
```

---

### Verification
- Verify allowed VLANs on the trunk by using *`show interfaces trunk`* command
- Verify VLAN database by using *`show vlan brief`*
- Test connectivity using ping:
  - VLAN 10, different switch → **Success**
  - VLAN 20, different switch → **Success**
  - VLAN 30, different switch → **Fail**
 
### Result 
- VLAN 10 and VLAN 20 traffic is successfully forwarded across the trunk
- VLAN 30 traffic is blocked by the allowed VLAN configuration
- Trunk remains operational despite VLAN restriction

---

### Troubleshooting/Common Mistakes
- Forgetting to include a VLAN in the allowed VLAN list
  - Verify using *`show interfaces trunk`*
- Confusing missing VLAN traffic with trunk failure
  - Ensure the trunk is operational before checking allowed VLANs
- Assuming that VLAN existence alone allows traffic across a trunk
  - VLANs must also be explicitly permitted on the trunk

---

### Notes
This lab uses the same topology as Lab 02A.
The only variable changed is the allowed VLAN configuration, which clearly
demonstrates the impact of VLAN restriction on trunk links.
Although VLAN 30 exists on both switches, it is not included in the allowed
VLAN list on the trunk. As a result, frames belonging to VLAN 30 are dropped
and cannot traverse the trunk link.

---
| [⬅️ Previous Lab](../02A%20VLAN%20TRUNK%20DEFAULT%20(PKT%20%2B%20CML)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../02C%20Native%20VLAN%20mismatch%20(PKT%20%2B%20CML)) |
|:--- | :---: | ---: |
