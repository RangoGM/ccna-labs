<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |


## Lab 05B - Spanning Tree Protocol (STP) Root Bridge

### Topology
This lab builds on **Lab 05 - Spanning Tree Protocol (STP)**.

The same three-switch triangular topology is used. The purpose of this lab
is to manually influence the STP root bridge election.

**📸 Screenshot:**

<img width="756" height="246" alt="image" src="https://github.com/user-attachments/assets/2aa83d59-f7bd-43c9-84a4-2b6f01b06c1c" />


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
  - SW1 is elected as the root bridge. **(IN THIS CML CASE I CHOOSED SW2 TO ELECTED AS ROOT BRIDGE)**

**📸 Screenshot:**

<img width="645" height="444" alt="Screenshot 2026-02-01 202921" src="https://github.com/user-attachments/assets/d46f8ba2-61e2-4a97-9c91-8b3c8df02edb" />

*(SW1 - **28673**)*

<img width="650" height="430" alt="Screenshot 2026-02-01 202935" src="https://github.com/user-attachments/assets/a58ca059-e459-445d-a917-d50c5f1bf4e8" />


*(SW2 - **24577**)*

*(When manually configured root bridge on the switch it will lower the priority than default priority **32768**, on SW1 because I manually configured **seccondary root** so it lower than default priority via SW3 and SW2 is lowest because it is **primary root**)* 
  
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

| [⬅️ Previous Lab](../05%20STP%20(CML%20%2B%20PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../05C%20STP%20Port%20Fast%20%26%20BDPU%20GUARD%20(CML%20%2B%20PKT)) |
|:--- | :---: | ---: |

