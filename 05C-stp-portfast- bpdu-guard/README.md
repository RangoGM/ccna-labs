## Lab 05C - Spanning Tree Protocol (STP) Protection  
### PortFast & BPDU Guard

### Topology
This lab builds on **Lab 05 - Spanning Tree Protocol (STP)**.

The same Layer 2 topology is reused. The focus of this lab is to apply
basic STP protection features on access ports to prevent accidental
network loops caused by end devices.

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

#### *(Optional: Enable globally for all PortFast ports)*
```bash
SWITCH(config)# spanning-tree portfast default
SWITCH(config)# spanning-tree bpduguard default
```

---

### Verification
- Verify PortFast status:
  - *`show spanning-tree interface <interface> detail`*
- Verify BPDU Guard configuration:
  - *`show spanning-tree summary`*
- (Optional) Connect a switch to an access port and observe behavior

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

PortFast is designed for end-device access ports and should not be used on links between switches.

BPDU Guard provides protection by disabling a port that receives BPDUs, preventing accidental or unauthorized switches from affecting the STP topology.

These features are commonly used together as a best practice in enterprise access-layer networks.
