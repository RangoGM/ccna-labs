<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |


## Lab 13 - IPv6 Static Routing

### Topology

This lab builds directly on **Lab 12A - IPv6 Addressing & Basic Connectivity.**

The physical topology and IPv6 addressing remain unchanged.
In this lab, **IPv6 static routes** are added to enable communication between remote IPv6 networks.

**📸 Screenshot:**

<img width="1214" height="279" alt="Screenshot 2026-02-08 134931" src="https://github.com/user-attachments/assets/684217f4-639b-4607-8801-a7a2a96572f4" />


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

**📸 Screenshot:**

<img width="166" height="20" alt="Screenshot 2026-02-08 135416" src="https://github.com/user-attachments/assets/77a6c7b2-b92b-4a40-bc8e-b47864f0b0dc" />

<img width="306" height="170" alt="Screenshot 2026-02-08 135427" src="https://github.com/user-attachments/assets/82caf421-6f30-476a-8120-d6e35bb596cc" />

<img width="434" height="19" alt="Screenshot 2026-02-08 135435" src="https://github.com/user-attachments/assets/60f2d7cf-fbfb-4823-8efb-337c51525118" />

*(Example Configuration on R1)*

---

### Verification
- Verify IPv6 routing table:
  - `show ipv6 route`
 
**📸 Screenshot:**

<img width="328" height="232" alt="Screenshot 2026-02-08 135447" src="https://github.com/user-attachments/assets/1e6b42d1-cd3d-478f-8e94-8190e4ac1a3b" />

- Verify static routes:
  - `show ipv6 route static`
- Test connectivity:
  - PC1 → PC2
  - PC2 → PC1
  - PC → remote router LAN interface
 
<img width="670" height="78" alt="Screenshot 2026-02-08 135623" src="https://github.com/user-attachments/assets/5442de74-43eb-4d06-900f-ce5e07e6e8ee" />

*(Kali)*

<img width="544" height="199" alt="Screenshot 2026-02-08 135657" src="https://github.com/user-attachments/assets/ea0ff665-cc32-4a61-a4d6-f0bdb5ac1ac9" />

*(Window)*

<img width="663" height="271" alt="Screenshot 2026-02-08 135758" src="https://github.com/user-attachments/assets/f22c4967-1133-442f-bb5c-4d4c9358ee87" />

*(Test connectivity from Windows to Kali)*

<img width="1088" height="122" alt="Screenshot 2026-02-08 135550" src="https://github.com/user-attachments/assets/3a70f4ed-c892-446b-9387-20509f16d000" />

*(Kali has received the request packets and sending Replies)*

<img width="1897" height="416" alt="Screenshot 2026-02-08 135517" src="https://github.com/user-attachments/assets/a27d39be-6aaf-4c35-a37c-33fa8b28a5d6" />

*(Capture packets on the link)*

```bash
ping ipv6 <destination>
```

---
### "Golden Rule: IP SLA goes hand-in-hand with Static Routing for both IPv4 and IPv6."

- **The Limitation:** Standard Static Routes are "blind"—they remain in the routing table as long as the local interface is 'Up', even if the destination is unreachable further down the path.

- **The Solution:** IP SLA adds intelligence to static paths. By tracking network health (e.g., ICMP Echo), it allows the router to dynamically remove or failover static routes when the target becomes unresponsive. This is a fundamental technique for achieving **High Availability (HA)** in fixed-routing environments.

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

| [⬅️ Previous Lab](../12C%20IPV6%20SLAAC%20(CML%20FOCUSED)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../14%20OSPFv3%20(CML%20%2B%20PKT)) |
|:--- | :---: | ---: |

