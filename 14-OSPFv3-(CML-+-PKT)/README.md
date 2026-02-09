<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |


## Lab 14 - OSPFv3 (IPv6 Dynamic Routing)

### Topology
This lab introduces **OSPFv3** using a **new multi-router IPv6 topology.**

Three routers are connected in a linear chain.
Only the **first router** and **last router** connect to end hosts.

OSPFv3 is used to dynamically exchange IPv6 routes between routers, eliminating the need for static routing.

**📸 Screenshot:**


<img width="1065" height="221" alt="Screenshot 2026-02-08 164709" src="https://github.com/user-attachments/assets/d5318595-fab8-4087-9a0b-97de140f5b46" />


---

### Goal
- Configure OSPFv3 on multiple routers
- Understand interface-based OSPFv3 configuration
- Observe dynamic IPv6 route learning
- Verify end-to-end IPv6 connectivity
- Reinforce OSPFv3 neighbor formation using IPv6 link-local addresses

---

### Topology Design

#### Devices
- Routers: **R1, R2, R3**
- Switches: **SW1, SW2**
- Hosts: **PC1, PC2**

--- 

### IPv6 Addressing Plan

#### LAN 1 (PC1 ↔ R1)
- Network: `2001:db8:1::/64`
- R1 G0/1: `2001:db8:1::1/64`
- PC1: `2001:db8:1::10/64`
- Default Gateway: `2001:db8:1::1`

---

#### R1 ↔ R2
- Network: `2001:db8:12::/64`
- R1 G0/0: `2001:db8:12::1/64`
- R2 G0/0: `2001:db8:12::2/64`

---

#### R2 ↔ R3
- Network: `2001:db8:23::/64`
- R2 G0/1: `2001:db8:23::1/64`
- R3 G0/0: `2001:db8:23::2/64`

---

#### LAN 2 (R3 ↔ PC2)
- Network: `2001:db8:3::/64`
- R3 G0/1: `2001:db8:3::1/64`
- PC2: `2001:db8:3::10/64`
- Default Gateway: `2001:db8:3::1`

---

*(R1 example configuration)*

### Router IDs

|**Router**|**Router ID**|
|-|-|
|R1|1.1.1.1|
|R2|2.2.2.2|
|R3|3.3.3.3|

> [!NOTE]
> #### The 32-bit Router-ID in an IPv6 World
> *A common question in OSPFv3 is: "Since IPv6 uses 128-bit addresses, why does OSPFv3 still require a 32-bit Router-ID in the x.x.x.x format?"*
> - **The Reasons:**
>   - **SPF Algorithm Compatibility:** OSPFv3 is an evolution of OSPFv2. Retaining the **32 bits** format allows the protocol to use the same **Shortest Path First (SPF)** engine and **Dijkstra** algorithm logic to build the topology map.
>   - **Identification vs. Routing:** The Router-ID is a logical "name" for a node in the Link-State Database (LSDB). It is used for identification, not for packet forwarding. Therefore, it does not need to match the **128 bits** IPv6 address format.

>[!WARNING]
> #### **Mandatory Manual Configuration:** In OSPFv2, a router could "auto-elect" an ID from its IPv4 interfaces. In an IPv6-only environment (like this lab), there are no IPv4 addresses to pick from. If you don't manually set the `router-id`, the OSPFv3 process will **fail to start.**

**➡️ *In OSPFv3, the Router-ID is an abstract 32-bit identifier. Without an IPv4 address on the interface, the router-id command becomes a mandatory first step for protocol initialization.***

---

### Key Concepts 
- OSPFv3 overview
- Interface-based routing protocol
- IPv6 link-local neighbor adjacency
- Router ID requirement
- SPF algorithm (Dijkstra)
- Dynamic IPv6 route exchange

---

### Key Configuration

#### Enable IPv6 Routing (All Routers)
```bash
ipv6 unicast-routing
```

---

#### Configure OSPFv3 Process & Router ID
```bash
ipv6 router ospf 1
  router-id <router-id>
```

**📸 Screenshot:**

<img width="248" height="56" alt="Screenshot 2026-02-08 165030" src="https://github.com/user-attachments/assets/9ff94ae0-392b-400a-995a-7a073b5fc8b2" />

*(R1 example configuration)*


---

#### Enable OSPFv3 on Interfaces
```bash
interface <interface>
  ipv6 ospf 1 area 0
```

**📸 Screenshot:**


<img width="292" height="91" alt="Screenshot 2026-02-08 162245" src="https://github.com/user-attachments/assets/d8657dd4-a3fc-4664-a011-93e822b844e0" />

<img width="299" height="98" alt="Screenshot 2026-02-08 162254" src="https://github.com/user-attachments/assets/450dfebe-c567-48df-91d2-c361d2381524" />

*(R1 example configuration)*

Apply OSPFv3 to:
- LAN-facing interfaces
- Inter-router interfaces


---

### Example Configuration (R2)
```
ipv6 router ospf 1
  router-id 2.2.2.2
```
```
interface g0/0
  ipv6 ospf 1 area 0
```
```
interface g0/1
  ipv6 ospf 1 area 0
```

---

### Verification
- Verify OSPFv3 neighbors:
```show ipv6 ospf neighbor```

**📸 Screenshot:**

<img width="633" height="115" alt="Screenshot 2026-02-08 160454" src="https://github.com/user-attachments/assets/54048d01-ab71-44fb-bc2c-49a186d2e107" />

<img width="652" height="58" alt="Screenshot 2026-02-08 163301" src="https://github.com/user-attachments/assets/85f35b7d-2e54-41b3-9365-a2943359cc00" />

*(3 routers has elected DR / BDR and adjacency with each other)*

- Verify IPv6 routing table:
```show ipv6 route ospf```

**📸 Screenshot:**

<img width="294" height="94" alt="Screenshot 2026-02-08 160203" src="https://github.com/user-attachments/assets/3c4d5c8b-c86d-45e5-acd1-43f43ede3ad6" />

*(Noticed that OSPF is learned by **Link-Local Addresses (fe80::)** not **Global-Unicast Addresses**)*

>[!NOTE]
> #### Why OSPFv3 Uses Link-Local Addresses (LLA)
> - Unlike OSPFv2 (IPv4) which relies on interface IPs, OSPFv3 uses **Link-Local Addresses (fe80::)** as its foundation. This shift provides three major advantages:
>   - **Decoupling of Topology and Addressing:** OSPFv3 separates "network mapping" from "prefix advertising." Routers establish adjacencies using LLAs first. Global Unicast Addresses (GUAs) are then treated simply as "prefix information" rather than the basis for the connection.
>   - **Enhanced Stability:** Modifying, adding, or deleting Global Unicast prefixes on an interface will not cause OSPF neighbor flaps. In OSPFv2, changing an interface IP resets the adjacency; in OSPFv3, the neighbor relationship remains rock-solid.
>   - **Protocol Efficiency:** On Point-to-Point links, OSPFv3 can form neighbors and route traffic using only Link-Local addresses. Configuring Global Unicast addresses becomes optional for transit links, simplifying the addressing scheme.

**➡️ *In short: OSPFv2 is 'IP-specific', while OSPFv3 is 'Link-specific'. This makes IPv6 routing much more resilient to addressing changes*.**

- Verify OSPFv3 process:
```show ipv6 ospf```

**📸 Screenshot:**

<img width="705" height="785" alt="Screenshot 2026-02-08 170833" src="https://github.com/user-attachments/assets/2d005552-d84a-4e44-bbfe-a760de6c7937" />


- Test end-to-end connectivity:
```
ping ipv6 2001:db8:3::10
ping ipv6 2001:db8:1::10
```

**📸 Screenshot:**

<img width="690" height="82" alt="Screenshot 2026-02-08 161928" src="https://github.com/user-attachments/assets/c6a81c40-839e-4b44-8cb8-ed18024e33c4" />

<img width="681" height="221" alt="Screenshot 2026-02-08 161949" src="https://github.com/user-attachments/assets/8acf4e2b-fe27-4b7c-bb56-e1718d64027c" />

*(Kali specifications and ping test)*

<img width="512" height="169" alt="Screenshot 2026-02-08 162030" src="https://github.com/user-attachments/assets/bb15f2c4-1a5f-47f5-acfa-6f19074b8737" />

<img width="413" height="170" alt="Screenshot 2026-02-08 162015" src="https://github.com/user-attachments/assets/f8686db9-26ff-423e-a700-d27307542795" />

*(Window specifications and ping test)*

<img width="1917" height="74" alt="Screenshot 2026-02-08 160048" src="https://github.com/user-attachments/assets/a918051f-6866-4215-b2bd-2cf7c0248699" />

*(OSPFv3 **Hello Packets** captured on the link)

<img width="798" height="479" alt="Screenshot 2026-02-08 160119" src="https://github.com/user-attachments/assets/96d62556-773a-4b4b-8385-cc9f77bc9b2d" />

- **FF02::5** is OSPFv3 IPv6 **Multicast Address**.

- Verify OSPFv3 Database:
```show ipv6 ospf database```

**📸 Screenshot:**

<img width="602" height="140" alt="Screenshot 2026-02-08 172019" src="https://github.com/user-attachments/assets/ebc2adfa-7c0f-4f3e-a865-a2eaeaa8312a" />

*(R1 database)*

<img width="602" height="286" alt="Screenshot 2026-02-08 163550" src="https://github.com/user-attachments/assets/f6ed8fb7-c461-450b-84f8-ae4a00cf19dc" />

*(R2 database)*

---

#### LSA Evolution: From "Summary" to "Inter-Area-Prefix"

OSPFv3 renames several LSA types to better reflect their functions in an IPv6 environment. The most notable change is with **Type 3 LSAs:**

- **OSPFv2 (IPv4)**: Known as **Summary LSA**.

- **OSPFv3 (IPv6)**: Renamed to **Inter-Area-Prefix-LSA**.

**Why the change?**

- **Descriptive Naming:** The new name is more precise. It explicitly states its role: carrying IPv6 Prefixes between different OSPF **Areas.**

- **Protocol Neutrality:** By focusing on "Prefixes" rather than "Networks/Subnets," the naming convention aligns with the IPv6 philosophy where addressing is treated as an attribute of the link, not the link itself.

> [!NOTE]
> |LSA Type|OSPFv2 Name (IPv4)|**OSPFv3 Name (IPv6)**|
> |-|-|-|
> |**Type 3**|Summary LSA|**Inter-Area-Prefix-LSA**|
> |**Type 4**|ASBR Summary LSA|**Inter-Area-Router-LSA**|
> |**Type 8**|*N/A*|**Link-LSA** (New - Only v3)|
> |**Type 9**|*N/A*|**Intra-Area-Prefix-LSA** (New - Only v3)|

- **OSPFv3 LSA Type Evolution - Observations:**

- **Type 8 (Link-LSA):** Observed routers exchanging Link-Local addresses and prefix lists for each attached link. This confirms OSPFv3's link-local centric operation.

- **Type 9 (Intra-Area-Prefix-LSA):** Witnessed the separation of prefix information from topology data. Unlike OSPFv2, prefixes within the same area are now advertised via Type 9 LSAs, enhancing SPF calculation efficiency.

--- 

> [!TIP]
> ### Optimization Insight: Beyond DR/BDR Election

In my previous **OSPFv2 (IPv4)** labs, I focused on manipulating the election process by adjusting interface priorities to force specific DR/BDR roles or bypass the election.

In this **OSPFv3 (IPv6)** lab, I want to highlight an even more efficient method for transit links: the **Point-to-Point (P2P) network type.**

- **The Method:** Instead of managing priorities, we explicitly define the link as Point-to-Point.

- **The Benefit:** This completely eliminates the need for DR/BDR election on that segment. It results in faster adjacency convergence (transitioning directly to the **FULL/-** state) and a leaner Link-State Database (LSDB) by removing Type 2 Network LSAs.

**📸 Screenshot:**

<img width="293" height="114" alt="Screenshot 2026-02-08 173205" src="https://github.com/user-attachments/assets/eeb4960a-86aa-4cf5-af76-9cd6ead238e2" />\

*(Applied to all routers connection except the link connecting to host)*

<img width="623" height="113" alt="Screenshot 2026-02-08 164538" src="https://github.com/user-attachments/assets/e75f6aa7-6634-486c-88a5-007dab5f0fab" />

<img width="640" height="80" alt="Screenshot 2026-02-08 164554" src="https://github.com/user-attachments/assets/d7e63bb1-7af4-4dc8-88d7-9c7dabf1aba4" />

*(No DR / BDR elected)*

> [!IMPORTANT]
> #### Remind OSPF adjacencies step: 
> #### `Down` → `Init` → `Two-Way` → `ExStart` → `Exchange` → `Loading` → `Full`.

- So in this case it is **Full State** without DR / BDR elections.

---

### Expected Result
- OSPFv3 neighbors form correctly between R1-R2 and R2-R3
- IPv6 routes are learned dynamically
- Routing table displays **O (OSPF)** entries
- PC1 can ping PC2 successfully
- No static routes are required

--- 

### Troubleshooting / Common Mistakes
- Forgetting `ipv6 unicast-routing`
- Missing router ID
- Enabling OSPFv3 globally but not on interfaces
- Expecting `network` command (OSPFv3 does not use it)
- Interfaces in mismatched OSPF areas

---

### Notes
>[!NOTE]
> - OSPFv3 is **interface-based**, unlike OSPFv2
> - Neighbor adjacencies use **link-local IPv6 addresses**
> - Router ID is mandatory and uses IPv4 format
> - This topology reflects a **realistic IPv6 routed enterprise segment**

| [⬅️ Previous Lab](../13-IPv6-Static-Routing-(CML-%2B-PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../15-DHCPv6-Implementation-STATELESS-%26-STATEFUL-(CML-FOCUSED)) |
|:--- | :---: | ---: |

