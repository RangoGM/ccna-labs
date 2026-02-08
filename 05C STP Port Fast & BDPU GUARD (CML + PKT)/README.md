<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |

## Lab 05C - Spanning Tree Protocol (STP) Protection  
### PortFast & BPDU Guard

### Topology
This lab builds on **Lab 05 - Spanning Tree Protocol (STP)**.

The same Layer 2 topology is reused. The focus of this lab is to apply
basic STP protection features on access ports to prevent accidental
network loops caused by end devices.

**📸 Screenshot:**

<img width="756" height="246" alt="Screenshot 2026-02-01 203118" src="https://github.com/user-attachments/assets/15336e30-2d70-48b7-b039-4440b6b87a5e" />


---

### Goal
- Understand the purpose of STP protection mechanisms
- Configure PortFast on access ports
- Configure BPDU Guard to protect the STP topology
- Observe port behavior when a BPDU is received on an access port

---

### Topology Design

**Devices**
- 3 Switches (SW1, SW2, SW3)
- 1 or more PCs

**Links**
- Switch-to-switch links remain trunk ports
- PC-facing ports are access ports

---

### Key Concepts
- PortFast
- BPDU Guard
- Err-disabled port
- STP protection best practices

---

### Key Configuration

- Reuse STP topology from Lab 05
- Enable PortFast on access ports
- Enable BPDU Guard on PortFast-enabled ports
- Do not apply PortFast or BPDU Guard on trunk links

---

### Example Configuration

#### Enable PortFast on an Access Port

```bash
SWITCH(config)# interface <access-interface>
SWITCH(config-if)# switchport mode access
SWITCH(config-if)# spanning-tree portfast
```
---

#### Enable BPDU Guard on the Same Port

```bash
SWITCH(config-if)# spanning-tree bpduguard enable
```
---

**📸 Screenshot:**

<img width="266" height="98" alt="Screenshot 2026-02-01 205329" src="https://github.com/user-attachments/assets/bd8c4410-0824-4c5f-b790-d9102651baae" />


#### *(Optional: Enable globally for all PortFast ports)*
```bash
SWITCH(config)# spanning-tree portfast default
SWITCH(config)# spanning-tree bpduguard default
```

---

### Verification
- Verify PortFast status:
  - *`show spanning-tree interface <interface> detail`*
 
**📸 Screenshot:**

<img width="521" height="229" alt="Screenshot 2026-02-01 205559" src="https://github.com/user-attachments/assets/2e3eaf34-1ecb-4c4c-9865-1d9b8f19b939" />

*(SW1)*

<img width="512" height="226" alt="Screenshot 2026-02-01 205542" src="https://github.com/user-attachments/assets/0e42ebf0-cb89-47c3-a460-2e8e65fd1060" />

*(SW2)*


- Verify BPDU Guard configuration:
  - *`show spanning-tree summary`*
- (Optional) Connect a switch to an access port and observe behavior

**📸 Screenshot:**

<img width="285" height="83" alt="Screenshot 2026-02-01 210439" src="https://github.com/user-attachments/assets/041bf2b4-2ec3-4c9d-8283-7c03b2ae7fdb" />

*(Ethernet0/0 on SW1 was an access port with BPDU Guard enabled)*

<img width="1170" height="114" alt="Screenshot 2026-02-01 210536" src="https://github.com/user-attachments/assets/4ed775d6-c2d8-4e2f-b46c-c2cc980c8315" />

*(Because Ethernet0/0 recieved BDPUs from new switch with BDPU Guard enabled this put the interface on SW1 into **err-disabled** state)*

---

### Result 
- Access ports transition immediately to the forwarding state
- Ports protected by BPDU Guard are placed into err-disabled state when a BPDU is received
- STP topology is protected from accidental loops

---

### Troubleshooting / Common Mistakes
- Enabling PortFast on trunk ports
- Applying BPDU Guard on inter-switch links
- Forgetting to set the port as access before enabling PortFast
- Misinterpreting err-disabled state as a hardware failure

---

### Notes

>[!NOTE]
> - PortFast is designed for end-device access ports and should not be used on links between switches.
> - BPDU Guard provides protection by disabling a port that receives BPDUs, preventing accidental or unauthorized switches from affecting the STP topology.
> - These features are commonly used together as a best practice in enterprise access-layer networks.

| [⬅️ Previous Lab](../05B%20STP%20Root%20Bridge%20(CML%20%2B%20PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../06%20Ethernet%20Channel%20%26%20ASIC%20Hashing%20(CML%20%2B%20PKT)) |
|:--- | :---: | ---: |
