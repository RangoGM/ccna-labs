<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |

## Lab 04 - DHCP (Router as DHCP Server)

### Topology
This lab builds on **Lab 03 - Inter-VLAN Routing (Router-on-a-Stick)**.

The router performs both Layer 3 routing and DHCP services.
Each VLAN receives IP addresses dynamically from the router.

**📸 Screen shot:**

<img width="820" height="290" alt="Screenshot 2026-02-01 175613" src="https://github.com/user-attachments/assets/e4df7481-3d61-45bc-93e4-b21ef0dbab82" />


---

### Goal
- Understand DHCP operation in a multi-VLAN environment
- Configure a router as a DHCP server
- Provide dynamic IP addressing for each VLAN
- Verify DHCP lease assignment and connectivity

---

### VLAN Design

**Switch**
- VLAN 10 - SALES
- VLAN 20 - IT
- VLAN 30 - HR

**Router**
- Acts as:
  - Default gateway for all VLANs
  - DHCP server for all VLANs

---

### IP Addressing Plan (Example)

| VLAN | Subnet | Default Gateway |
|------|--------|-----------------|
| 10 | 192.168.10.0/24 | 192.168.10.1 |
| 20 | 192.168.20.0/24 | 192.168.20.1 |
| 30 | 192.168.30.0/24 | 192.168.30.1 |

---

### Key Configuration
- Reuse VLAN, trunk, and inter-VLAN routing configuration from Lab 03
- Exclude gateway and reserved addresses from DHCP
- Create one DHCP pool per VLAN
- Assign:
  - Network
  - Default gateway
  - (Optional) DNS server
- Configure end devices to use DHCP

---

### Example Configuration

#### DHCP Excluded Addresses

```bash
ROUTER(config)# ip dhcp excluded-address 192.168.10.1 192.168.10.10
ROUTER(config)# ip dhcp excluded-address 192.168.20.1 192.168.20.10
ROUTER(config)# ip dhcp excluded-address 192.168.30.1 192.168.30.10
```

**📸 Screen shot:**

<img width="400" height="76" alt="Screenshot 2026-02-01 180403" src="https://github.com/user-attachments/assets/a8c50faf-d53f-4711-8d17-701739e1d13a" />

*(Example configuration)*

#### DHCP Pools

```bash
ROUTER(config)# ip dhcp pool VLAN10
ROUTER(dhcp-config)# network 192.168.10.0 255.255.255.0
ROUTER(dhcp-config)# default-router 192.168.10.1

ROUTER(config)# ip dhcp pool VLAN20
ROUTER(dhcp-config)# network 192.168.20.0 255.255.255.0
ROUTER(dhcp-config)# default-router 192.168.20.1

ROUTER(config)# ip dhcp pool VLAN30
ROUTER(dhcp-config)# network 192.168.30.0 255.255.255.0
ROUTER(dhcp-config)# default-router 192.168.30.1
```
*(DNS configuration is optional and omitted for brevity)*

**📸 Screen shot:**

<img width="288" height="227" alt="Screenshot 2026-02-01 180411" src="https://github.com/user-attachments/assets/d69f017c-bab6-4996-98d5-44e966669b0f" />

*(Example configuration)*

---

### Verification

- Verify DHCP bindings:
  - *`show ip dhcp binding`*

 **📸 Screen shot:**

 <img width="804" height="23" alt="Screenshot 2026-02-01 181751" src="https://github.com/user-attachments/assets/8ce212f0-c04b-4025-910f-26d5797ba9f6" />

<img width="805" height="18" alt="Screenshot 2026-02-01 181759" src="https://github.com/user-attachments/assets/4a179553-35f5-496f-9400-8ff38cd06ded" />

<img width="817" height="74" alt="Screenshot 2026-02-01 181809" src="https://github.com/user-attachments/assets/f081a99e-60ce-4cb6-bab6-cb2fde9d0eb5" />


- Verify DHCP pools:
  - *`show ip dhcp pool`*
 
 **📸 Screen shot:**

<img width="646" height="197" alt="Screenshot 2026-02-01 182025" src="https://github.com/user-attachments/assets/7d87b70c-45d6-4903-ae77-4875c41ab158" />

*(VLAN 10)*

<img width="645" height="194" alt="image" src="https://github.com/user-attachments/assets/3f6ebd89-eebd-4871-a168-7be050db8449" />

*(VLAN 20)*

<img width="641" height="191" alt="image" src="https://github.com/user-attachments/assets/a27d2811-ae7c-4c61-a390-b74939594e86" />

*(VLAN 30)*

     
- Verify IP configuration on PCs:
  - *`ipconfig /all`*

  **📸 Screen shot:**

  <img width="660" height="462" alt="Screenshot 2026-02-01 180659" src="https://github.com/user-attachments/assets/c2f00505-df0b-4793-8ad8-52759f3f6981" />

  *(KALI_IT in VLAN 10)*

  <img width="543" height="422" alt="Screenshot 2026-02-01 180745" src="https://github.com/user-attachments/assets/55f8100e-15be-4744-9d92-09a358656418" />

  *(KALI_HR in VLAN 20)*

<img width="1120" height="97" alt="Screenshot 2026-02-01 180517" src="https://github.com/user-attachments/assets/9c3c6985-4382-4d79-8d54-02dec7ed4801" />

<img width="621" height="21" alt="Screenshot 2026-02-01 180527" src="https://github.com/user-attachments/assets/5bb40e81-95b9-459b-811c-5470b0b247dd" />

*(ROUTER_SALES act like a client in VLAN 30)*

- Test connectivity using ping:
  - Same VLAN
  - Different VLANs

 **📸 Screen shot:**

 <img width="1278" height="332" alt="Screenshot 2026-02-01 180951" src="https://github.com/user-attachments/assets/39042512-d8ff-49c8-8132-965aeee4a069" />

 *(VLAN 10 -> VLAN 20, 30)*

 <img width="1266" height="286" alt="Screenshot 2026-02-01 180904" src="https://github.com/user-attachments/assets/eab38764-477e-4eb0-953f-294d34e5fa82" />

 *(VLAN 20 -> VLAN 10, 30)*

 <img width="567" height="194" alt="Screenshot 2026-02-01 181151" src="https://github.com/user-attachments/assets/70dd940b-41c8-4c77-aa8c-48113d926ebb" />

 <img width="1255" height="168" alt="Screenshot 2026-02-01 181211" src="https://github.com/user-attachments/assets/f5d29e89-3a8f-44f4-8e7c-8acd49ce10b8" />

 <img width="1268" height="168" alt="Screenshot 2026-02-01 181216" src="https://github.com/user-attachments/assets/19b7e6a8-ae8f-47c1-9472-9680a522b6d4" />

 *(VLAN 30 -> VLAN 10, 20)*

--- 

### Result 
- End devices receive IP addresses dynamically
- Correct default gateway is assigned per VLAN
- Inter-VLAN communication works with DHCP-assigned addresses

### Troubleshooting / Common Mistakes
- PC does not receive an IP address
  - Verify DHCP pool configuration
  - Check excluded-address range
- Incorrect default gateway assigned
  - Verify default-router in DHCP pool
- DHCP pool not matching VLAN subnet
  - Verify network statement
- DHCP working for one VLAN but not others
  - Verify router subinterface configuration

---

### Notes
> [!NOTE]
> - In this lab, the router provides DHCP services for multiple VLANs.
> - Because the router is directly connected to all VLANs via subinterfaces, no DHCP relay (*`ip helper-address`*) is required.
> - The first ten IP addresses are excluded to reserve space for infrastructure devices. 
> - This range is optional and used for demonstration purposes.
> - This design is common in small to medium-sized networks.

---
| [⬅️ Previous Lab](../03-Inter-VLAN-Routing-(CML-%2B-PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../05-STP-(CML-%2B-PKT)) |
|:--- | :---: | ---: |

