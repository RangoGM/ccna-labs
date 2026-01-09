## Lab 02C - Native VLAN Mismatch (Extra)

### Topology

This lab reuses the same topology from **Lab 02B - VLAN Trunking (Allowed VLAN Restriction)**.

The VLAN design and access port configuration remain unchanged.
The only modification is the native VLAN configuration on the trunk link
between the two switches.

---

### Goal

- Understand the concept of the native VLAN on an IEEE 802.1Q trunk
- Observe the behavior and warnings caused by native VLAN mismatch
- Recognize why native VLAN mismatches are considered a best-practice risk

---

### VLAN Design

**Switch 1**
- VLAN 10 - SALES
- VLAN 20 - IT
- VLAN 30 - HR
- Native VLAN: VLAN 1 (default)

**Switch 2**
- VLAN 10 - SALES
- VLAN 20 - IT
- VLAN 30 - HR
- Native VLAN: VLAN 99 (non-default)

---

### Key Configuration

- Reuse VLAN, access port, and trunk configuration from Lab 02B
- Change the native VLAN on the trunk on one switch only
- Do not modify allowed VLAN settings

---

### Example Configuration (Native VLAN)

```bash
SWITCH(config)# interface <trunk-interface>
SWITCH(config-if)# switchport mode trunk
SWITCH(config-if)# switchport trunk native vlan 99
```

*(Native VLAN is left unchanged on the other switch)*

---

### Verification

- Verify trunk status:
  - *```show interfaces trunk```*
- Observe console messages or warnings related to native VLAN mismatch
- Verify connectivity for allowed VLANs (behavior may vary depending on traffic)

---

### Result 

- Trunk link remains up
- A native VLAN mismatch condition exists between the switches
- Warning messages indicate a native VLAN mismatch
- Tagged VLAN traffic (VLAN 10, 20, 30) continues to function normally

---

### Troubleshooting / Common Mistakes

- Assuming a trunk is fully healthy just because the link is up
- Forgetting to match native VLANs on both ends of a trunk
- Using the native VLAN for user traffic
- Ignoring console warnings related to native VLAN mismatch

---

### Notes

This lab intentionally introduces a native VLAN mismatch on an IEEE 802.1Q
trunk to demonstrate a common configuration issue.

By default, the native VLAN carries untagged frames on a trunk. When the native
VLAN is different on each side of the trunk, untagged traffic may be
misinterpreted, leading to potential security and stability risks.

In this lab, a dedicated VLAN (VLAN 99) is used as the native VLAN on one switch.
No end devices are assigned to this VLAN, which helps avoid unintended traffic
leakage and misleading connectivity results.

Although the trunk link remains operational, a native VLAN mismatch condition
exists and warning messages may be observed.

Best practice is to avoid using a user VLAN as the native VLAN and to explicitly
configure and match the native VLAN on both ends of a trunk.


