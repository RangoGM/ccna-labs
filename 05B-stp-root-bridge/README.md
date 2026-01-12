## Lab 05B - Spanning Tree Protocol (STP) Root Bridge

### Topology
This lab builds on **Lab 05 - Spanning Tree Protocol (STP)**.

The same three-switch triangular topology is used. The purpose of this lab
is to manually influence the STP root bridge election.

---

### Goal
- Understand how the STP root bridge is elected
- Manually influence root bridge selection
- Observe STP reconvergence after root bridge changes

---

### Topology Design

**Devices**
- 3 Switches (SW1, SW2, SW3)
- PCs (optional, for connectivity testing)

**Links**
- All switch-to-switch links are configured as trunk ports

---

### Key Concepts
- Root Bridge election
- Bridge Priority
- STP reconvergence

---

### Key Configuration

- Reuse the topology from Lab 05
- Manually configure SW1 as the STP root bridge
- Configure STP root primary
- (Optional) Configure a secondary root bridge

---

### Example Configuration

#### Configure Root Bridge

```bash
SW1(config)# spanning-tree vlan 1 root primary
```
*(Primary root bridge)*

```bash
SW2(config)# spanning-tree vlan 1 root secondary
```
*(Secondary root bridge)*

---

### Verification
- Verify STP status:
  - *`show spanning-tree`*
- Confirm:
  - SW1 is elected as the root bridge
  - Port roles and states adjust accordingly
- (Optional) shut down a link or reload a switch to observe STP reconvergence

---

### Result 

- SW1 is elected as the root bridge after manual STP configuration.
- STP recalculates port roles based on the new root
- Network connectivity is maintained during topology changes

--- 

### Troubleshooting / Common Mistakes
- Configuring root priority on the wrong VLAN
- Forgetting that STP runs per VLAN (PVST+)
- Assuming STP automatically selects the optimal root
- Making multiple switches root primary unintentionally

--- 

### Notes 
STP root bridge selection is based on bridge priority and MAC address.

Using *`root primary`* simplifies priority configuration and helps ensure
a predictable Layer 2 topology.

The root bridge is selected using the `root primary` command, without
manually tuning bridge priority or path cost.

In production networks, the root bridge is typically placed at the
distribution or core layer rather than the access layer.

