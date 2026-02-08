<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |


## Lab 12A - IPv6 Addressing & Basic Connectivity 

### Topology
This lab introduces **basic IPv6 addressing and local connectivity** in a routed environment.

Two routers are connected back-to-back, each providing IPv6 connectivity to a local LAN. At this stage, **no static or dynamic routing is configured** between routers.

The purpose of this lab is to verify **IPv6 addressing, neighbor discovery, and local forwarding behavior**, not end-to-end routing across multiple IPv6 networks.

---

### Goal 
- Understand IPv6 address structure and notation
- Configure IPv6 addresses manually
- Enable IPv6 routing on routers
- Verify local IPv6 connectivity
- Observe the routing limitation without static routes

--- 

### Topology Design

#### Devices
- Routers: **R1, R2**
- Switches: **SW1, SW2**
- Hosts: **PC1, PC2**

---

### IPv6 Addressing Plan

#### LAN 1 (PC1 ↔ R1)
- Network: `2001:db8:1::/64`
- R1 G0/1: `2001:db8:1::1/64`
- 2 PC: `2001:db8:1::2/64`, `2001:db8:1::3/64`
- Default Gateway: `2001:db8:1::1`

---

#### LAN 2 (R2 ↔ PC2)
- Network: `2001:db8:2::/64`
- R2 G0/1: `2001:db8:2::1/64`
- 2 PC: `2001:db8:2::2/64`, `2001:db8:2::3/64`
- Default Gateway: `2001:db8:2::1`

---

#### Inter-router Link (R1 ↔ R2)
- Network: `2001:db8:12::/64`
- R1 G0/0: `2001:db8:12::1/64`
- R2 G0/0: `2001:db8:12::2/64`

---

### Key Concepts
- IPv6 Global Unicast Address
- Link-local address (FE80::/10)
- IPv6 Neighbor Discovery (ND)
- IPv6 forwarding behavior
- Routing table dependency for inter-network reachability

---

### Key Configuration

#### Enable IPv6 Routing (Both Routers)
```bash
ipv6 unicast-routing
```

#### Configure IPv6 Addresses
```bash
interface <interface>
  ipv6 address <ipv6-address>/64
  no shutdown
```

---

### Verification

#### Expected Connectivity (Success)
- PC → Local PC (Same LAN)
- PC → Default Gateway
- PC → Router interface on the same subnet
- PC → R1 inter-router interface (`2001:db8:12::1`)

#### Expected Connectivity (Failure)
- PC1 → R2 LAN (`2001:db8:2::/64`) ❌
- PC2 → R1 LAN (`2001:db8:1::/64`) ❌
```bash
ping ipv6 <destination>
```

---

### Result
- IPv6 addresses are configured correctly on all devices
- Hosts can communicate within the same LAN
- Hosts can reach their default gateway
- Hosts can reach router interfaces on directly connected IPv6 networks
- Hosts **cannot reach remote IPv6 networks** due to missing routes
- IPv6 forwarding works locally but **inter-network routing is not yet available**

---

### Notes
- IPv6 automatically generates **link-local addresses** on all interfaces
- Neighbor Discovery (ND) is used instead of ARP
- `ipv6 unicast-routing` enables forwarding but **does not create routes**
- Additional routing configuration is required to reach remote IPv6 networks

➡️ **This limitation will be addressed in Lab 12B - IPv6 Static Routing**

| [⬅️ Previous Lab](../11B%20HSRP%20Enterprise-Grade%20High%20Availability%20(CML)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../12B%20IPv6%20Basic%20Connectivity%20%26%20Windows%20Stack%20Deep-Dive%20(CML)) |
|:--- | :---: | ---: |

