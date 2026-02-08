<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |


## Lab 10B - OSPF DR / BDR / DROTHER Election

### Topology (PKT)
This lab demonstrates **OSPF Designated Router (DR)**, **Backup Designated Router (BDR)**, **and DROTHER election** behavior on a broadcast multi-access network.

The topology includes both **point-to-point links** and a **shared broadcast segment**, allowing clear observation of OSPF neighbor states and election results.

### CML (CML)

**📸 Screenshot:**

<img width="511" height="226" alt="image" src="https://github.com/user-attachments/assets/64f64c41-995d-42d9-817b-9fee29759c48" />


---

### Goal
- Understand when and why OSPF elects DR and BDR
- Observe OSPF behavior on broadcast vs point-to-point networks
- Verify DR / BDR / DROTHER roles based on router IDs
- Confirm best-practice placement of DR and DROTHER routers

---

### Topology Design

#### Devices
- Routers: **R1, R2, R3, R4**
- Switch (broadcast network)
- INTERNET (simulated)

---

#### Network Segments 

##### Point-to-Point Links (PKT)
- **R1 - R4**
  - R1 G0/0: `192.168.10.1/30`
  - R4 G0/0: `192.168.10.2/30`
- **R1 - R3**
  - R1 G0/1: `192.168.20.1/30`
  - R3 G0/1: `192.168.20.2/30`
*(No DR/BDR election on point-to-point links)*

---

#### Broadcast Multi-Access Network (DR Election)
- **Network**: `192.168.50.0/24`
- Connected via switch:
  - R3 G0/2: `192.168.50.1/24`
  - R4 G0/2: `192.168.50.2/24`
  - R2 G0/0: `192.168.50.3/24`

 ---

 #### Internet Edge
 - **R2 - INTERNET**
   - R2 G0/0/0: `1.2.3.5/30`
   - INTERNET G0/0/0: `1.2.3.6/30`
  
---

#### Router IDs

| Router | Router ID |
|----|---------|
| R1 | 1.1.1.1 |
| R2 | 2.2.2.2 |
| R3 | 3.3.3.3 |
| R4 | 4.4.4.4 |

---

### Key Concepts
- OSPF broadcast network behavior
- DR / BDR / DROTHER election
- Router ID priority
- OSPF neighbor states
- Design best practices

---

### Key Configuration
- Enable OSPF on all routers
- Configure unique router IDs
- Advertise all internal networks into **Area 0**
- Configure passive interfaces where appropriate

--- 

### Example Configuration (OSPF)
```bash
router ospf 1
  router-id <router-id>
  network <network> <wildcard-mask> area 0
```
*(Network statements vary per router)*
```bash
interface <interface-id>
  ip ospf priority <0-255>
```
*(Manually set priority for Routers)*

---

### Verification

- **DR/BDR Selection:** Confirmed **R4** as **DR** and **R3** as **BDR** based on the highest **Router ID**.

- Verify OSPF neighbors:
  - *`show ip ospf neighbor`*

**📸 Screenshot:**

<img width="625" height="72" alt="Screenshot 2026-02-05 115818" src="https://github.com/user-attachments/assets/70fc6237-cb95-48fa-b87a-d068e4ba2da9" />

*(R1's perspective)*

- **Packet Analysis:** Captured traffic to **224.0.0.6**, proving that **DROTHERs** correctly send **Link-State Updates (LSUs)** to the **designated authorities.**

**📸 Screenshot:**

<img width="1919" height="438" alt="Screenshot 2026-02-05 115216" src="https://github.com/user-attachments/assets/15769f0d-a140-45b3-a0b5-358c0192a913" />

*(**R4 interfaces** recieved multicast address of **224.0.0.6** for **DR / BDR / DROTHER elections**)

<img width="766" height="444" alt="Screenshot 2026-02-05 115448" src="https://github.com/user-attachments/assets/c9a63ddf-a324-4c03-8105-8dbb9b9c4f5c" />

<img width="308" height="169" alt="Screenshot 2026-02-05 115542" src="https://github.com/user-attachments/assets/b91ce8c8-5d09-4ddb-9240-5173ef4c090b" />

*(**LSA** was **encapsulated** in packets)*


**State Machine:** Observed FULL adjacencies with **DR/BDR**, while maintaining **2-WAY** status between **non-designated nodes**, optimizing the control plane overhead.

**📸 Screenshot:**

<img width="633" height="116" alt="Screenshot 2026-02-05 115236" src="https://github.com/user-attachments/assets/fe82dab5-2f92-4dc4-80c0-f61e10125a4d" />

*(R4's perspective)*

- Verify OSPF interface type:
  - *`show ip ospf interface`*
- Confirm DR / BDR / DROTHER roles on the 192.168.50.0/24 segment (PKT)
- Test connectivity across the network

---

### Advanced OSPF Adjacency & Election Experiments

#### SHUT DOWN R4

**1. Non-Preemptive Behavior:** Verified that increasing priority on a DROTHER to 255 does not trigger an immediate re-election. The current DR remains until the process is manually cleared or the DR fails.

**📸 Screenshot:**

<img width="225" height="19" alt="Screenshot 2026-02-05 120407" src="https://github.com/user-attachments/assets/f82852dd-5071-4ff0-a340-670b5f18a638" />

*(Change the priority of R1's Interface to 255)*

<img width="499" height="363" alt="Screenshot 2026-02-05 120632" src="https://github.com/user-attachments/assets/02dd5455-65d3-43c3-af39-41d06f4d93ef" />

*(R4 is still the **DR** Router and sill advertising)*


**2. The BDR Promotion:** Demonstrated that upon DR failure, the BDR is immediately promoted to DR, and a new BDR is elected from the remaining DROTHERs. 

**📸 Screenshot:**

<img width="559" height="190" alt="Screenshot 2026-02-05 121228" src="https://github.com/user-attachments/assets/633f0b84-897f-4f9d-93fb-97153899a8d9" />

<img width="1048" height="75" alt="Screenshot 2026-02-05 121259" src="https://github.com/user-attachments/assets/4e59af7e-f57e-4575-8663-dc2348dc8844" />

*(R3 knows that R4 is **dead**)*

<img width="1912" height="344" alt="Screenshot 2026-02-05 121345" src="https://github.com/user-attachments/assets/8b0f69e1-3d41-46e3-b14b-07267683119b" />

*(R3's Interface received the **LSA Updated** to elected BDR / DROTHERS from both R1 and R2)*

<img width="574" height="303" alt="Screenshot 2026-02-05 121310" src="https://github.com/user-attachments/assets/c15b3cfc-bad9-4032-a967-ce5edbd1a758" />

*(R3 elected as a **DR** because is already **BDR** before, and R1 now from **DROTHERS** to **BDR** - The **priority** is happens before all routers is not elected DR / BDR yet not **after** the elected have been created in the tables)*

<img width="501" height="59" alt="Screenshot 2026-02-05 121242" src="https://github.com/user-attachments/assets/b8a4363a-3dca-43d0-bbc3-39215518cf6c" />


**3. Data Plane vs. Control Plane:** Confirmed that R1 and R2 can successfully exchange ICMP traffic despite being in a **2-WAY state**. Adjacency state only dictates the exchange of Link-State information, not reachability.

**4. LSA Type 2 Identification:** Captured and analyzed Network **LSAs (Type 2)** in the LSDB, which are exclusive to multi-access segments and originated by the DR.

**📸 Screenshot:**

<img width="556" height="340" alt="Screenshot 2026-02-05 121719" src="https://github.com/user-attachments/assets/328da436-2fcc-4f3f-8469-a38851332022" />

*(**DR** Router via R3 is now the **Advertising Router**)*

---

#### SHUT DOWN R3 

**📸 Screenshot:**

<img width="1096" height="515" alt="Screenshot 2026-02-05 121913" src="https://github.com/user-attachments/assets/7d7362ce-75f5-438b-9143-193e8a150ae8" />

*(R2 noticed that R3 is **dead**, the election begins)*

<img width="622" height="72" alt="Screenshot 2026-02-05 121927" src="https://github.com/user-attachments/assets/44992fff-b4e1-41a7-b4a0-46acbdf9a829" />

*(R1's perspective: Now **R2** is from **DROTHERS** to **BDR**, and **R1** from **BDR** to **DR**)*

<img width="526" height="219" alt="Screenshot 2026-02-05 121957" src="https://github.com/user-attachments/assets/1779c665-f493-498f-89c9-344c93f122e2" />

*(And it is the **Advertising Router**)*

---

### Priority 0 (No election on all cased)

- **Permanent Exclusion (Priority 0)** Configured R4 with ip ospf `priority 0`. Even after all other routers were **disabled**, R4 remained a **DROTHER**. This demonstrates how to **prevent underpowered devices** from taking **intensive management roles** in a **multi-access** segment.

**📸 Screenshot:**
  
<img width="625" height="78" alt="Screenshot 2026-02-05 124018" src="https://github.com/user-attachments/assets/2dd645e2-8e79-4d83-b6ec-dfb6ac3e6f9a" />

*(Case: **R2 (BDR)**, **R3 (DR)**, **R1 & R4 (DROTHERS)**)* 
- *Just noticed the R4 when manually configured the `priority 0`*

<img width="527" height="218" alt="Screenshot 2026-02-05 124348" src="https://github.com/user-attachments/assets/165f6bf5-733f-4608-93b7-8ccbbb9158cc" />

*(Shutdown 3 routers **except R4**)*

<img width="213" height="22" alt="Screenshot 2026-02-05 124333" src="https://github.com/user-attachments/assets/0a038996-14e3-49f2-902f-e975c6e11aaf" />

- As expected is **stuck** at DROTHERS. No elections is exchanged.

---


### Result
- DR and BDR are elected only on the broadcast segment
- Point-to-point links do not participate in DR election
- Edge router (R2) correctly operates as DROTHER
- OSPF neighbor states reach FULL
- Network connectivity is maintained

---

### Troubleshooting / Common Mistakes
- Expecting DR election on point-to-point links
- Confusing router ID with interface IP address
- Assuming **`FULL/DR`** refers to the local router
- Using /30 networks and expecting DROTHER routers
- Placing Internet edge routers as DR unintentionally

---

### Notes
OSPF elects DR and BDR **only on broadcast and NBMA networks**, not on point-to-point links.

- **224.0.0.5** Multicast Address: For all OSPF Routers.

- **224.0.0.6** Multicast Address: For DR / BDR elections.

Router ID is the primary factor in DR election when interface priority is not manually configured.

Best practice is to place DR and BDR on routers located at the core or distribution layer, while edge routers (such as Internet-facing routers) operate as DROTHER.

| [⬅️ Previous Lab](../10A%20OSPF%20Single%20Area%20(CML%20%2B%20PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../10C%20OSPF%20Multi-Area%20(CML%20%2B%20PKT)) |
|:--- | :---: | ---: |


