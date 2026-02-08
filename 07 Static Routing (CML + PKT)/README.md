<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |

## Lab 07 - Static Routing

### Topology
This lab introduces static routing in a multi-router environment.

A simple topology with multiple routers is used, where routes between
networks are manually configured using static routes.

**📸 Screenshot:**

<img width="1298" height="518" alt="image" src="https://github.com/user-attachments/assets/7d2b8894-d729-404b-96f0-5668387a8be5" />


---

### Goal
- Understand the purpose of static routing
- Configure static routes between routers
- Compare static routing with dynamic routing
- Verify end-to-end connectivity using static routes

---

### Topology Design (PKT)

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

**📸 Screenshot:**

<img width="491" height="137" alt="Screenshot 2026-02-02 231548" src="https://github.com/user-attachments/assets/406753e0-c9b2-4d9a-b33b-8f06ac9de388" />

*(HQ)*

<img width="476" height="135" alt="Screenshot 2026-02-02 231603" src="https://github.com/user-attachments/assets/2c78d954-b1ab-418b-8361-7f6361ccb8fe" />

*(PRIME)*

<img width="475" height="130" alt="Screenshot 2026-02-02 231615" src="https://github.com/user-attachments/assets/35dfefc0-7293-40eb-98a0-004a84b5fd0c" />

*(BACK)*

<img width="355" height="105" alt="Screenshot 2026-02-02 231627" src="https://github.com/user-attachments/assets/6151c8f1-d7aa-4369-8a40-46508ce0d9bc" />

*(BRANCH)*

<img width="462" height="76" alt="Screenshot 2026-02-02 231649" src="https://github.com/user-attachments/assets/232f0dcf-f3ec-470e-a831-eff50f353836" />

*(SERVER)*

- In CML I choosed **PRIME** router with the AD is lower than **BACK** Router.

**📸 Screenshot:**

<img width="379" height="169" alt="Screenshot 2026-02-02 232529" src="https://github.com/user-attachments/assets/c5cf5933-08a7-4950-a95d-0f21bfc3e560" />


<img width="351" height="155" alt="Screenshot 2026-02-02 232443" src="https://github.com/user-attachments/assets/926ae0a4-64cd-466c-b987-0f5a4822a489" />

- By `show ip static route` command *(Not available in Packet Tracer)* we can actually which route is **active [A]** and which is **none active** **[N]**, the none active route is acting like a backup route in the topology.


---

### Verification
- Verify routing table:
  - *`show ip route`*
- Verify static routes:
  - *`show ip route static`*
- Test connectivity using ping between LANs

**📸 Screenshot:**

<img width="1277" height="799" alt="Screenshot 2026-02-02 225052" src="https://github.com/user-attachments/assets/7fe38907-07c2-4587-b44c-97d99b73873e" />

*(Test connectivity between hosts)*

<img width="1265" height="276" alt="Screenshot 2026-02-02 225149" src="https://github.com/user-attachments/assets/d0e746c1-145c-4934-9a4b-6862cb571f21" />

*(`Traceroute` to see which path would the ICMP Packets should be going through)*

<img width="667" height="249" alt="Screenshot 2026-02-02 231858" src="https://github.com/user-attachments/assets/f5fb148a-23ca-41b2-868f-d3e2ae97d27a" />

*(**Loopback** in R_SERVER could be known as **DNS**)*

<img width="1919" height="743" alt="Screenshot 2026-02-02 232800" src="https://github.com/user-attachments/assets/b6162951-f30a-42e2-9b23-8cd3c175afd4" />

*(As expected the ICMP Packets go through the path with **lowest AD** - in this case is the path to **R_PRIME**)*

<img width="1919" height="628" alt="Screenshot 2026-02-02 232819" src="https://github.com/user-attachments/assets/1105fcf7-2e22-49e6-a5d9-1f59d72f7385" />

*(By assigning a **higher AD** to the **redundant link**, I created a **Floating Static Route**. This ensures the backup path stays **dormant**; **no ICMP packets** or **data flows** will transit this link unless the **primary route is removed from the routing table due to a failure**)*.

---

#### Shutting down R_PRIME

**📸 Screenshot:**

<img width="468" height="160" alt="Screenshot 2026-02-02 232930" src="https://github.com/user-attachments/assets/d94bda0f-3f40-4068-978b-0d91c1ce5a87" />


*(R1_HQ changing to the **Backup Path** with **AD from [1/0] -> [5/0]**)*

<img width="337" height="80" alt="Screenshot 2026-02-02 233441" src="https://github.com/user-attachments/assets/f80bd2b9-b3dd-44be-b2d8-c7f1f73e9af9" />

*(Because it is take only 1 route via **loopback 0** between **R_BRANCH** - **R_SERVER** so there is no changing to the different path here)*

<img width="1916" height="667" alt="Screenshot 2026-02-02 233513" src="https://github.com/user-attachments/assets/af7b7970-21fd-4a07-9b54-f7af046cee15" />

*(**ICMP Packets now only go through **Backup Path****)*

---

#### ⚠️ The Static Routing "Black Hole" Effect

**Static routing** is fundamentally "blind" to remote network changes. In this multi-router topology, I observed a critical **limitation**: **Asymmetric Routing**.

**📸 Screenshot:**

<img width="785" height="306" alt="Screenshot 2026-02-02 234616" src="https://github.com/user-attachments/assets/b0ef7b3a-9d1e-41d5-9563-df2c3988fc23" />

*(Link between **R_PRIME** - **R_BRANCH** is still maintaining **UP**)*

<img width="1280" height="318" alt="Screenshot 2026-02-02 234632" src="https://github.com/user-attachments/assets/cfb3ea29-12f0-4752-9eca-023551d3b0c1" />

*(Ping suddenly stop when shut down **1 primary link** of **total 2** between src and dst Routers & **not changing to backup** path too)*

When a primary link fails, the local router successfully switches to the floating static path. However, the remote router remains unaware of the failure and continues to forward return traffic toward the dead link. Without a mechanism to communicate link states between nodes, the data simply drops into a routing black hole.

Manual path management is clearly not scalable for high-availability environments...

**That’s why we will be deploying Dynamic Routing Protocols in the next lab.** 😉

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

| [⬅️ Previous Lab](../06%20Ethernet%20Channel%20%26%20ASIC%20Hashing%20(CML%20%2B%20PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../08%20Dynamic%20Routing%20RIPv2%20(CML%20%2B%20PKT)) |
|:--- | :---: | ---: |

