<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |


## Lab 05 - Spanning Tree Protocol (STP)

### Topology
This lab demonstrates the operation of Spanning Tree Protocol (STP)
in a Layer 2 network with redundant links.

Three switches are connected in a triangular topology, creating a potential
Layer 2 loop. STP is used to prevent loops while maintaining network
connectivity.

**📸 Screenshot:**

<img width="747" height="247" alt="Screenshot 2026-02-01 184625" src="https://github.com/user-attachments/assets/6f2103dd-dff9-4933-9958-897aa5718ff8" />



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
 
**📸 Screenshot:**

<img width="643" height="393" alt="Screenshot 2026-02-01 184755" src="https://github.com/user-attachments/assets/3d47a0c7-b830-44d8-b778-520e8be9c72f" />

*(SW1)*

<img width="654" height="406" alt="Screenshot 2026-02-01 184811" src="https://github.com/user-attachments/assets/d17f1fc0-c1a0-4e20-8ab7-1654dce528d7" />

*(SW2)*

<img width="662" height="408" alt="Screenshot 2026-02-01 184733" src="https://github.com/user-attachments/assets/cfda2060-8ddf-4f29-8324-4cce9b311b18" />

*(SW3)*


---

### Identify
- Root bridge
- Root ports
- Designated ports

---

### (Optional) Test connectivity:
- Ping between PCs to verify network stability

**📸 Screenshot:**

<img width="539" height="214" alt="Screenshot 2026-02-01 185015" src="https://github.com/user-attachments/assets/9a722895-d94c-45cc-aea5-0c7a83b509c5" />

<img width="1256" height="241" alt="Screenshot 2026-02-01 185053" src="https://github.com/user-attachments/assets/157d0d97-1bc4-4bef-a9da-dc88a941fb44" />


---

### Result
- SW2 is elected as the root bridge by default based on STP priority and MAC address (PKT Labs). **IN THIS CASE THE ROOT BRIDGE IS SW1**
- One or more redundant ports are placed in a blocking state
- Layer 2 loops are prevented
- Network connectivity is maintained

---

### Key Insight

**📸 Screenshot:**

<img width="314" height="82" alt="Screenshot 2026-02-01 185659" src="https://github.com/user-attachments/assets/febcdc3a-fcf7-498a-b7eb-c40aa5c602b7" />

<img width="1914" height="414" alt="Screenshot 2026-02-01 185724" src="https://github.com/user-attachments/assets/9cdc528a-26b8-4ab8-8962-96fca2b2f94b" />

*(The ICMP is go through the shortest link via a root port **(SW1 -> SW2)** with **Prio.Nbr: 128.2** to reach the destination)*

- But the link between **SW1 - SW3** is also a rootport at **SW3**, but the ICMP packet did not pass this link. Why?

**Here is how the STP Intelligence and Loop Prevention works**

<img width="436" height="30" alt="Screenshot 2026-02-01 12" src="https://github.com/user-attachments/assets/8ccd24a9-7742-4320-813f-8f4a1101b5d1" />

*(Link between **(SW2 - SW3)** has the **highest priority** and it is in **BLK (Blocking State)** to prevent **L2 loop** and instead of the ICMP packets will pass **(SW1 -> SW3 -> SW2)**, the STP will calculates which path is the shortest path between switches **(SW -> SW2)**)*

- So what does these links will do when all switches has calculate their best path

**📸 Screenshot:**

<img width="182" height="217" alt="Screenshot 2026-02-01 185751" src="https://github.com/user-attachments/assets/a5ca3d36-27bf-477f-b5fe-a741f129d2f9" />

<img width="1919" height="476" alt="Screenshot 2026-02-01 185759" src="https://github.com/user-attachments/assets/20207c80-8a6a-4cb6-961a-0637697cb6a3" />

*(SW1 - SW3)*

<img width="185" height="213" alt="Screenshot 2026-02-01 185806" src="https://github.com/user-attachments/assets/bc7a88aa-af9d-46a9-b548-be9ef5733c4b" />

<img width="1919" height="500" alt="Screenshot 2026-02-01 185813" src="https://github.com/user-attachments/assets/7d8ca97f-a92c-45d5-a10a-074b4628c691" />

*(SW1 - SW2)*

- This Backup links remain in a blocking state, only processing BPDUs for redundancy purposes while preventing ICMP and other data packets from passing through.
- Only STP protocol is capture on links, no ICMP Packets is passing through.

**📸 Screenshot:**

<img width="538" height="246" alt="Screenshot 2026-02-01 194545" src="https://github.com/user-attachments/assets/05ca31e6-1894-4653-9f73-a4190a35b453" />

<img width="535" height="304" alt="Screenshot 2026-02-01 194602" src="https://github.com/user-attachments/assets/54c27738-ca8b-4271-9f2a-adec71512ec0" />

<img width="303" height="82" alt="Screenshot 2026-02-01 194614" src="https://github.com/user-attachments/assets/8b76698a-b0fc-4f61-8d83-f01110e831ab" />

#### Shut Down Lowest Priority Links

**📸 Screenshot:**

<img width="1918" height="719" alt="Screenshot 2026-02-01 190558" src="https://github.com/user-attachments/assets/3df7b627-e8ef-477f-903c-832b551b00f4" />

*(SW1 - SW3)*

<img width="1919" height="791" alt="Screenshot 2026-02-01 190619" src="https://github.com/user-attachments/assets/014349f9-ed41-477a-b084-4734167bc3e5" />

*(SW3 - SW2)*

→ Once the direct link between SW1 and SW2 is shut down, STP triggers a recalculation, rerouting ICMP traffic through **SW1-SW3-SW2** to maintain network availability.

→ And now the link between **(SW2 - SW3)** has the **highest priority** is in **Forwarding State** and become a **Root port**

**📸 Screenshot:**

<img width="422" height="19" alt="Screenshot 2026-02-01 200116" src="https://github.com/user-attachments/assets/0cfbc638-1cb7-4f16-903c-b79c4749468d" />


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

---
| [⬅️ Previous Lab](../04%20DHCP%20(CML%20%2B%20PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../05B%20STP%20Root%20Bridge%20(CML%20%2B%20PKT)) |
|:--- | :---: | ---: |


