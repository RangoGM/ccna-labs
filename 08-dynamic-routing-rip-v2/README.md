## Lab 08 - Dynamic Routing Protocol (RIP v2)

### Topology
This lab introduces dynamic routing using RIP version 2.

A simple multi-router topology is used, where multiple routers are
connected through different networks. RIP is configured to dynamically
exchange routing information between routers.

---

### Goal
- Understand the purpose of dynamic routing protocols
- Configure RIP version 2
- Observe automatic route learning
- Verify end-to-end connectivity using dynamic routing

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
- Static routing vs Dynamic routing
- Distance Vector routing protocol
- Hop count metric
- RIP limitations
- RIP v1 vs RIP v2

---

### Key Configuration

- Configure IP addressing on all router interfaces
- Enable RIP version 2
- Advertise connected networks
- Disable classful routing using `no auto-summary`

---

### Example Configuration

#### Enable RIP v2

```bash
ROUTER(config)# router rip
ROUTER(config-router)# version 2
ROUTER(config-router)# no auto-summary
ROUTER(config-router)# network <network>
```
*(Repeat network statements for all directly connected networks)*

---

### Verification 
- Verify RIP routes:
  - *`show ip route rip`*
- Verify routing table:
  - *`show ip route`*
- Verify RIP configuration:
  - *`show ip protocols`*
- Test connectivity using ping between LANs

---

### Result
- Routers dynamically learn routes using RIP v2
- Routing tables are updated automatically
- End devices can communicate across different networks
- Manual static routes are not required

---

### Troubleshooting / Common Mistakes
- Forgetting to enable RIP version 2
- Missing *`no auto-summary`*
- Incorrect network statements
- Expecting RIP to scale in large networks
- Forgetting that RIP uses hop count as its metric

---

### Notes
RIP is a distance-vector routing protocol that uses hop count as its metric.
The maximum hop count supported by RIP is 15, which limits its scalability.

Although RIP is rarely used in modern production networks, it is included in CCNA to help understand the fundamentals of dynamic routing protocols.
