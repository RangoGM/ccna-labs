## Lab 05 - Spanning Tree Protocol (STP)

### Topology
This lab demonstrates the operation of Spanning Tree Protocol (STP)
in a Layer 2 network with redundant links.

Three switches are connected in a triangular topology, creating a potential
Layer 2 loop. STP is used to prevent loops while maintaining network
connectivity.

---

### Goal
- Understand why STP is required in Layer 2 networks
- Identify the root bridge
- Observe port roles and port states
- Verify how STP prevents Layer 2 loops

---

### Topology Design

**Devices**
- 3 Switches (SW1, SW2, SW3)
- 2 or more PCs (optional, for connectivity testing)

**Links**
- All switch-to-switch links are configured as trunk ports
- The topology intentionally creates a loop

---

### Key Concepts
- Root Bridge
- Root Port
- Designated Port
- Blocking (Alternate) Port

---

### Key Configuration
- Use default STP configuration (no tuning required)
- Ensure all inter-switch links are trunks
- Do not disable STP

*(STP runs automatically by default on Cisco switches)*

---

### Verification

- Verify STP status:
  - *`show spanning-tree`*

---

### Identify
- Root bridge
- Root ports
- Designated ports

---

### (Optional) Test connectivity:
- Ping between PCs to verify network stability

---

### Result
- SW3 is elected as the root bridge by default based on STP priority and MAC address.
- One or more redundant ports are placed in a blocking state
- Layer 2 loops are prevented
- Network connectivity is maintained

---

### Troubleshooting / Common Mistakes
- Assuming a blocked port indicates a failure
- Forgetting that STP operates automatically
- Misinterpreting STP blocking as a misconfiguration
- Disabling STP and causing a broadcast storm

---

### Notes
STP is enabled by default on Cisco switches and operates automatically to prevent Layer 2 loops.

Although some ports may appear blocked, this behavior is expected and ensures a stable and loop-free network.

End devices use static IP addresses for basic connectivity testing.

STP recalculates the topology if a link fails, allowing blocked ports to transition into a forwarding state.
