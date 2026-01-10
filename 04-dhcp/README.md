## Lab 04 - DHCP (Router as DHCP Server)

### Topology
This lab builds on **Lab 03 - Inter-VLAN Routing (Router-on-a-Stick)**.

The router performs both Layer 3 routing and DHCP services.
Each VLAN receives IP addresses dynamically from the router.

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

---

### Verification

- Verify DHCP bindings:
  - *`show ip dhcp binding`*
- Verify DHCP pools:
  - *`show ip dhcp pool`*
- Verify IP configuration on PCs:
  - *`ipconfig /all`*
- Test connectivity using ping:
  - Same VLAN
  - Different VLANs

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

In this lab, the router provides DHCP services for multiple VLANs.
Because the router is directly connected to all VLANs via subinterfaces, no DHCP relay (*`ip helper-address`*) is required.
The first ten IP addresses are excluded to reserve space for infrastructure devices. 
This range is optional and used for demonstration purposes.

This design is common in small to medium-sized networks.
