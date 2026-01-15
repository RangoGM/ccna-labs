## Lab 07 - Static Routing

### Topology
This lab introduces static routing in a multi-router environment.

A simple topology with multiple routers is used, where routes between
networks are manually configured using static routes.

---

### Goal
- Understand the purpose of static routing
- Configure static routes between routers
- Compare static routing with dynamic routing
- Verify end-to-end connectivity using static routes

---

### Topology Design

**Devices**
- 3 Routers (R1, R2, R3)
- PCs (optional, for connectivity testing)

**Links**
- Point-to-point connections between routers
- Each router connects to a unique LAN

---

### IP Addressing Plan (Example)

| Device | Interface | Network |
|------|-----------|---------|
| R1 | LAN | 192.168.1.0/24 |
| R1–R2 | WAN | 10.0.12.0/30 |
| R2–R3 | WAN | 10.0.23.0/30 |
| R3 | LAN | 192.168.3.0/24 |

---

### Key Concepts
- Static routing
- Next-hop IP address
- Directly connected vs remote networks
- Administrative distance

---

### Key Configuration

- Configure IP addressing on all router interfaces
- Manually configure static routes on each router
- Use next-hop IP addresses for route definition

---

### Example Configuration

```bash
ROUTER(config)# ip route <destination-network> <subnet-mask> <next-hop-ip>
```
*(Repeat static route configuration for all remote networks)

---

### Verification
- Verify routing table:
  - *`show ip route`*
- Verify static routes:
  - *`show ip route static`*
- Test connectivity using ping between LANs

---

### Result 
- Routers can reach remote networks using static routes
- Routing tables contain manually configured routes
- End devices can communicate across different networks

---

### Troubleshooting / Common Mistakes
- Missing static routes on intermediate routers
- Incorrect next-hop IP address
- Overlapping or incorrect network statements
- Forgetting that static routes do not adapt automatically to topology changes

---

### Notes
Static routing requires manual configuration and does not scale well in large networks.

This lab helps build a foundation for understanding dynamic routing protocols such as RIP, EIGRP and OSPF.
