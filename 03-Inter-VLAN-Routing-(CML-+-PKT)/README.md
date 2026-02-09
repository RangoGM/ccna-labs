<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |

---

## Lab 03 - Inter-VLAN Routing (Router-on-a-Stick) (PKT + CML)

### Topology
This lab builds on **Lab 02A - VLAN Trunking (Default Allow All)**.

All VLANs are already allowed on the trunk between switches, ensuring
Layer 2 connectivity before implementing inter-VLAN routing.
A router is added and connected to the switch using a trunk link.

**📸 Screenshot:**

<img width="758" height="316" alt="Screenshot 2026-01-31 225725" src="https://github.com/user-attachments/assets/c5c4188f-d567-4918-b213-4c5f4c96e428" />

*(I used router to act like a client)*

---

### Goal
- Understand inter-VLAN routing concepts
- Configure router-on-a-stick using subinterfaces
- Enable communication between different VLANs
- Verify Layer 3 connectivity between VLANs

---

### VLAN Design

**Switch**
- VLAN 10 - SALES
- VLAN 20 - IT
- VLAN 30 - HR

**Router**
- One physical interface
- One subinterface per VLAN
- Acts as the default gateway for all VLANs
 
---

### IP Addressing Plan (Example)

| VLAN | Subnet | Default Gateway |
|------|--------|-----------------|
| 10 | 192.168.1.0/24 | 192.168.1.1 |
| 20 | 192.168.2.0/24 | 192.168.2.1 |
| 30 | 192.168.3.0/24 | 192.168.3.1 |

**📸 Screenshot:**

<img width="638" height="120" alt="Screenshot 2026-01-31 225433" src="https://github.com/user-attachments/assets/2a7f8349-1c53-43f0-bd14-b10660423a44" />


---

### Key Configuration
- Reuse VLAN and access port configuration from Lab 02A
- Keep trunk configuration unchanged (all VLANs allowed)
- Configure a trunk link between the switch and the router
- Create router subinterfaces for each VLAN
- Assign IP addresses to subinterfaces
- Configure end devices with the correct default gateway

---

### Example Configuration

#### Switch (Trunk to Router)

```bash
SWITCH(config)# interface <interface-to-router>
SWITCH(config-if)# switchport mode trunk
```

**📸 Screenshot:**

<img width="605" height="213" alt="Screenshot 2026-01-31 225453" src="https://github.com/user-attachments/assets/5e2e52d2-26bb-4f75-83c7-351958b3accf" />


#### Router (Router-on-a-Stick)

```bash
ROUTER(config)# interface <physical-interface>.10
ROUTER(config-subif)# encapsulation dot1Q 10
ROUTER(config-subif)# ip address 192.168.1.1 255.255.255.0

ROUTER(config)# interface <physical-interface>.20
ROUTER(config-subif)# encapsulation dot1Q 20
ROUTER(config-subif)# ip address 192.168.2.1 255.255.255.0

ROUTER(config)# interface <physical-interface>.30
ROUTER(config-subif)# encapsulation dot1Q 30
ROUTER(config-subif)# ip address 192.168.3.1 255.255.255.0
```

**📸 Screenshot:**

<img width="325" height="271" alt="Screenshot 2026-01-31 225212" src="https://github.com/user-attachments/assets/1199b21b-6a28-4049-8189-c14f70777afe" />

*(Physical router interface is enabled by default)*

--- 

### Verification 

- Verify router subinterfaces:
  - *```show ip interface brief```*
- Verify trunk configuration on the switch:
  - *```show interfaces trunk```*
- Test connectivity using ping:
  - VLAN 10 -> VLAN 20

**📸 Screenshot:**

<img width="659" height="262" alt="Screenshot 2026-01-31 225953" src="https://github.com/user-attachments/assets/da3a5e37-82a4-4b68-9f32-6bd4076fd385" />


<img width="1276" height="758" alt="Screenshot 2026-01-31 230431" src="https://github.com/user-attachments/assets/8ad27d80-4fd4-40a6-967d-6c440f287679" />

*(You can use Wireshark to capture icmp packet)*

  - VLAN 20 -> VLAN 10

**📸 Screenshot:**

<img width="482" height="128" alt="Screenshot 2026-01-31 230528" src="https://github.com/user-attachments/assets/1a0505a4-6f28-438a-b277-e685bcf3a7c0" />

<img width="1699" height="238" alt="Screenshot 2026-01-31 230622" src="https://github.com/user-attachments/assets/d048464a-62b9-4c21-9519-70d66cf48e40" />


  - VLAN 10, 20 -> VLAN 30

**📸 Screenshot:**

<img width="614" height="129" alt="Screenshot 2026-01-31 230718" src="https://github.com/user-attachments/assets/f570ab7d-4a51-4ebb-a82e-35792f3edc09" />

<img width="907" height="65" alt="Screenshot 2026-01-31 230738" src="https://github.com/user-attachments/assets/08439d01-339a-42a6-8a54-f690280d36df" />

---

### Result 

- Devices in different VLANs can communicate successfully
- Inter-VLAN routing is performed by the router
- Layer 2 VLAN segmentation is preserved

---

### Troubleshooting / Common Mistakes

- Router physical interface is administratively down
  - Enable it using *`no shutdown`*
- Incorrect VLAN encapsulation on router subinterfaces
  - Verify *`encapsulation dot1Q`* values
- Missing or incorrect default gateway on end devices
  - Verify IP configuration on PCs
- VLAN traffic not reaching the router
  - Verify trunk configuration between switch and router

---

### Notes
> [!NOTE]
> - Inter-VLAN routing requires a Layer 3 device.
> - In this lab, a single router interface is used with multiple subinterfaces,
each associated with a VLAN using IEEE 802.1Q tagging.
> - Only one router is required, as inter-VLAN routing is performed per VLAN,
not per switch.
> - This lab demonstrates how Layer 3 routing enables communication between
separate VLANs while maintaining Layer 2 segmentation.

---
| [⬅️ Previous Lab](../02C-Native-VLAN-mismatch-(PKT-%2B-CML)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../04-DHCP-(CML-%2B-PKT)) |
|:--- | :---: | ---: |
