## Lab 12B - IPv6 Static Routing

### Topology

This lab builds directly on **Lab 12A - IPv6 Addressing & Basic Connectivity.**

The physical topology and IPv6 addressing remain unchanged.
In this lab, **IPv6 static routes** are added to enable communication between remote IPv6 networks.

---

### Goal
- Configure IPv6 static routing
- Understand different IPv6 static route types
- Compare recursive, fully specified, and directly connected routes
- Verify end-to-end IPv6 connectivity across routers

---

### Topology Design
Reuse the same topology from **Lab 12A**

---

### IPv6 Addressing 
Reuse all IPv6 addresses from **Lab 12A**

---
### Key Concepts 
- IPv6 static routing
- Recursive static route
- Fully specified static route
- Directly connected static route
- IPv6 next-hop behavior
- Routing table resolution

---

### Static Route Types (Overview)

1️⃣ **Recursive Static Route**
- Uses **next-hop IPv6 address only**
- The router performs a recursive lookup to resolve the exit interface
```bash
ipv6 route <destination-prefix> <next-hop-address>
```

---

2️⃣ **Directly Connected Static Route**
- Uses **exit interface only**
- No next-hop address specified
```bash
ipv6 route <destination-prefix> <exit-interface>
```
⚠️ *In IPv6, this method may cause issues in some scenarios and is not recommended.*

---
3️⃣ **Fully Specified Static Route (Recommended)**
- Uses **both exit interface and next-hop IPv6 address**
- Most explicit and deterministic method
```bash
ipv6 route <destination-prefix> <exit-interface> <next-hop-address>
```

---

### Key Configuration

#### Configure IPv6 static routes on R1

```bash
ipv6 route 2001:db8:2::/64 2001:db8:12::2
```
*(recursive static route)*

```bash
ipv6 route 2001:db8:2::/64 g0/0
```
*(Directly connected static route - for demonstration only)*

```bash
ipv6 route 2001:db8:2::/64 g0/0 2001:db8:12::2
```
*(Fully specified static route - preferred method)*

---

#### Configure IPv6 static routes on R2

```bash
ipv6 route 2001:db8:1::/64 2001:db8:12::1
```

```bash
ipv6 route 2001:db8:1::/64 g0/0 2001:db8:12::1
```

---

### Verification
- Verify IPv6 routing table:
  - `show ipv6 route`
- Verify static routes:
  - `show ipv6 route static`
- Test connectivity:
  - PC1 → PC2
  - PC2 → PC1
  - PC → remote router LAN interface

```bash
ping ipv6 <destination>
```

---

### Expected Result
- IPv6 static routes appear in the routing table
- Recursive and fully specified routes resolve correctly
- End-to-end IPv6 connectivity is achieved
- Hosts can communicate across remote IPv6 networks

---

### Troubleshooting / Common Mistakes
- Missing static route on one router
- Incorrect next-hop IPv6 address
- Using only exit-interface static routes in IPv6
- Forgetting that IPv6 routing behavior differs from IPv4
- Expecting IPv6 static routes to behave identically to IPv4

--- 

### Notes
- IPv6 static routing supports **recursive, directly connected, and fully specified routes**
- **Fully specified static routes are recommended** in IPv6 to avoid ambiguity
- Directly connected IPv6 static routes may fail in some implementations
- Recursive static routing is commonly used and preferred for simplicity
- This lab demonstrates why IPv6 static routing must be configured more carefully than IPv4
