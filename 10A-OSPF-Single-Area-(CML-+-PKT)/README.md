<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |


## Lab 10A - OSPF Single Area (Path Selection & Convergence) **(Long Lab - CCNA Focused)**

### Topology (PKT)
This lab reuses the topology from **Lab 09A - EIGRP Unequal-Cost Load Balancing**.

The routing protocol is changed from EIGRP to OSPF. All routers participate
in a single OSPF area (Area 0). The topology provides multiple paths between
routers, allowing observation of OSPF path selection and convergence behavior.

### Topology (CML)

**📸 Screenshot:**

<img width="1040" height="301" alt="Screenshot 2026-02-05 000357" src="https://github.com/user-attachments/assets/a33bb94b-4b60-47d3-8385-4f394b6fee24" />


---

### Goal
- Configure OSPF in a single-area topology
- Manually configure router IDs
- Observe OSPF cost-based path selection
- Verify OSPF convergence during link failure and recovery
- Inject a Dynamic Default Route to simulate internet connectivity

---

### Topology Design (PKT)

**Devices**
- Routers: R1, R2, R3
- Switch (LAN)
- PC
- INTERNET (simulated router)

**Routing Protocol**
- OSPFv2
- Single Area (Area 0)

---

### IP Addressing
Reuse the same IP addressing plan from **Lab 09A**.

---

### Key Concepts
- OSPF single-area operation
- Router ID selection
- OSPF cost metric
- Shortest Path First (SPF) algorithm
- OSPF convergence

---

### Key Configuration

- Remove EIGRP configuration from all routers
- Enable OSPF process
- Manually configure router IDs
- Advertise all internal networks into OSPF Area 0
- Configure passive interfaces for:
  - LAN-facing interface
  - Internet-facing interface
- Configure a default route on the edge router (R3)

---

### Example Configuration

#### Enable OSPF and Set Router ID

```bash
router ospf 1
 router-id <router-id>
 network <network> <wildcard-mask> area 0
```

#### Enable OSPF ASBR

```
router ospf 1
  default-information originate
```

*(Repeat network statements for all OSPF-enabled interfaces)*

---

### Verification
- Verify OSPF neighbors:
  - *`show ip ospf neighbor`*

 **📸 Screenshot:**

 <img width="629" height="67" alt="Screenshot 2026-02-05 002744" src="https://github.com/user-attachments/assets/cff01859-dfeb-4f56-b359-4fb2ede15b49" />

 

- Verify routing table:
  - *`show ip route ospf`*

 **📸 Screenshot:**

 <img width="588" height="270" alt="Screenshot 2026-02-04 230209" src="https://github.com/user-attachments/assets/1543d1fa-171d-4e61-b19b-968bd621d08c" />


- Verify OSPF interface state:
  - *`show ip ospf interface`*
- Verify OSPF topology information:
  - *`show ip ospf database`*

 **📸 Screenshot:**

 <img width="617" height="398" alt="Screenshot 2026-02-04 230101" src="https://github.com/user-attachments/assets/68de3847-999b-4868-80d0-d57d45e4ad4f" />


- Test connectivity:
  - PC -> INTERNET
  - PC -> all internal networks
 
- **(Bonus)** Verify OSPF sending **Hello Packets** with multicast address **224.0.0.5** - **ALL OSPF ROUTERS** on every single interfaces but not **224.0.0.6** - **DR/BDR/DROTHER** multicast address which will be mentioned in the next lab.

 **📸 Screenshot:**

 <img width="938" height="72" alt="Screenshot 2026-02-04 230352" src="https://github.com/user-attachments/assets/598a0be8-1765-4839-860c-cd3800055e3e" />

 <img width="753" height="89" alt="Screenshot 2026-02-05 004540" src="https://github.com/user-attachments/assets/a9ac46ea-1406-4a12-8959-d9f7a02de990" />

- **Encapsulation:** The OSPF Packets is next to **IP Header**. No **TCP** or **UDP** header is **encapsulated** in the packets. That is meant the **OSPF protocol** is belong to **Layer 3** not **Layer 4**.

<img width="512" height="404" alt="Screenshot 2026-02-04 230509" src="https://github.com/user-attachments/assets/f6bf24b4-7f4d-49e6-b288-fd75e0446e82" />

- **IP Header:** Look at the **TTL (Time to Live)** field. For a **Hello packet,** the normal **TTL is 1**. Why? Because OSPF doesn't want the **Hello message** to be **forwarded too far** over the line by other routers.

<img width="372" height="228" alt="Screenshot 2026-02-04 230516" src="https://github.com/user-attachments/assets/a21d92b2-d748-4497-95e1-a6619759afd0" />

- **Version:** **2** - For IPv4 supported; **3** - Both IPv4 and IPv6 (Further Lab).
- **Area 0**: Is always the **backbone** area.

<img width="477" height="178" alt="Screenshot 2026-02-04 230525" src="https://github.com/user-attachments/assets/eb1caa62-7dda-41a8-9a03-77e889b86437" />

- Default **Hello timer** is 10 seconds, **Dead timer** is 40 seconds.

---

### Convergence Test
>[!CAUTION]
> Shut down the primary OSPF path between R1 and R3 - **When a device is shut down, the router immediately recognizes the "Good-bye" signal**. So the reconvergence also like **EIGRP** but is **IMPORTANT** to know this,
last EIGRP - Feasible Successor Lab (I have **highlight** the word **MINIMAL PACKET LOSS**) and this is why:

#### EIGRP vs OSPF – Final Conclusion

>[!WARNING]
> **EIGRP** converges **faster** than **OSPF** at the **control-plane** level due to its event-driven **DUAL algorithm**. However, lab testing shows that **EIGRP** may still experience **packet loss** because **CEF/FIB** updates in the **data plane** are not **instantaneous**, creating a **short forwarding gap**.
> - **As Cisco states:**
> - *“DUAL guarantees loop-free convergence, not lossless forwarding.”*
> - **OSPF**, while logically **slower** due to **SPF recalculation**, often forwards traffic **more smoothly** in **small topologies** because **SPF and CEF** updates occur in a **batched manner**, resulting in **little or no observable packet loss.**

>[!TIP]
> In real-world networks, minimizing packet loss requires **BFD**, regardless of whether **EIGRP or OSPF** is used.

➡️ **EIGRP decides faster, OSPF forwards smoother in small labs; BFD is the real solution in production.**

- Observe routing table updates and traffic flow
- Verify traffic reroutes via R1 -> R2 -> R3
- Restore the link and observe OSPF reconvergence to the shortest path
- Again try to stop the link while both of **Interfaces Status** still remaining **UP**:

**📸 Screenshot:**

<img width="511" height="398" alt="Screenshot 2026-02-05 000720" src="https://github.com/user-attachments/assets/e40740a3-50ec-40da-8f88-90acd09b5fa9" />

<img width="782" height="93" alt="Screenshot 2026-02-04 231441" src="https://github.com/user-attachments/assets/93524951-b7f0-4065-affc-22844564e85c" />

*(The ping stop here)*

<img width="657" height="62" alt="Screenshot 2026-02-04 231501" src="https://github.com/user-attachments/assets/3751ff55-548b-4cec-a9ac-c879d28d933b" />

*(Converges and the ping works again with **78% packets loss**)*

- With **BFD** Implemented:

<img width="682" height="126" alt="Screenshot 2026-02-04 235759" src="https://github.com/user-attachments/assets/a2c426ef-de6e-4cbd-bc77-eff7a11e7bf4" />

*(Only **1% packet** loss)*

---

### Simulating Internet Exit with default-information originate

In this lab, I corrected a crucial oversight from my previous Packet Tracer experiments by implementing a dynamic default route injection.

- **The Strategy:**

Configured **R3** as the **ASBR** connecting to a simulated Internet host (Kali 2).

Established a static default route on R3 pointing towards the external network.

Utilized the `default-information originate` command within the OSPF process to flood a **Type 5 LSA** across the entire 5-node pentagon.

➡️ **The Outcome:** All internal routers (R1, R2, R4, R5) now automatically receive an **O*E2** default route. This ensures that any traffic from Kali 1 destined for unknown networks is correctly forwarded through the OSPF backbone to the Internet gateway at R3.

**📸 Screenshot:**

<img width="299" height="37" alt="Screenshot 2026-02-04 234217" src="https://github.com/user-attachments/assets/16111112-93ac-4290-be94-44eef3cff5c1" />

*(R3 configuration)*

<img width="530" height="79" alt="Screenshot 2026-02-05 001132" src="https://github.com/user-attachments/assets/fcf7170b-19d9-4175-bfdb-bd0e23f4a38c" />

<img width="488" height="384" alt="Screenshot 2026-02-05 001200" src="https://github.com/user-attachments/assets/782df868-28a1-4a0e-ba68-daa69ca2648b" />

<img width="489" height="79" alt="Screenshot 2026-02-04 234209" src="https://github.com/user-attachments/assets/7fb70a33-78ff-40ea-b0b5-b6800cd60428" />

> [!TIP]
> **Edge Security:** Applied passive-interface on the gateway link to Kali 2, ensuring **OSPF control** traffic is not leaked to the **external network**.

**End-to-End Verification:** A ping from the internal host (Kali 1) to a **non-existent external** IP (`1.2.3.4`) was successfully traced all the way to the "Internet" interface on R3.

**📸 Screenshot:**

<img width="691" height="126" alt="Screenshot 2026-02-04 234316" src="https://github.com/user-attachments/assets/4d7ac629-8117-439f-a7f9-d022c3590622" />

*(Packets just transmitting but not receiving is different with **HOST DESTINATION LOST**)*

<img width="1913" height="745" alt="Screenshot 2026-02-04 234252" src="https://github.com/user-attachments/assets/3705ee5c-be41-4535-8752-8101791b295b" />

*(Packets stuck here: between **R3 - Internet** links)*


➡️ **This demonstrates a real-world enterprise edge configuration where OSPF interacts with external static routing.**

---

### Precision Routing: Adjusting OSPF Reference Bandwidth

> [!WARNING]
> By default, OSPF uses a reference bandwidth of **100 Mbps**, which fails to distinguish between modern High-Speed Ethernet links (Gigabit and beyond). 

$$\text{Cost} = \frac{\text{Reference Bandwidth}}{\text{Interface Bandwidth}}$$

**Link 100 Mbps (Fast Ethernet)**: $\frac{100}{100} = \mathbf{1}$ 

**Link 1000 Mbps (Fast Ethernet)**: $\frac{100}{1000} = \mathbf{1}$ (*Still 1*)

> [!TIP]
> **The Solution:** Just changed the `auto-cost reference-bandwidth` command higher than default (*100Mps*). This ensures that the SPF algorithm can accurately differentiate between $100$ Mbps and $1000$ Mbps links, preventing suboptimal routing and Equal-Cost Load Balancing over mismatched speed paths.

**Link 100 Mbps (Fast Ethernet)**: $\frac{1000}{100} = \mathbf{10}$ 

**Link 1000 Mbps (Fast Ethernet)**: $\frac{1000}{1000} = \mathbf{1}$ (*Preferred*)

> [!WARNING]
> But in this case the `auto-cost` already **higher** than my **interfaces Bandwidth** so I just **decrease** my **bandwidth** from **preffered path**:

 **📸 Screenshot:**

<img width="542" height="72" alt="Screenshot 2026-02-05 002151" src="https://github.com/user-attachments/assets/fc325be9-3553-4107-a5a7-d27f286936ff" />

<img width="510" height="80" alt="Screenshot 2026-02-05 002022" src="https://github.com/user-attachments/assets/4878b3d7-2acc-4230-8ad6-7173475f4c34" />

- **Longer Path** has **lower metric** so now it is choosed to **forwarding the packets**.

 **📸 Screenshot:**

<img width="1919" height="450" alt="Screenshot 2026-02-05 002100" src="https://github.com/user-attachments/assets/6e897040-2581-4146-a590-a26cfa59083d" />


---

### Result
- OSPF selects the shortest path based on cost
- Routing tables update dynamically during link failures
- Network connectivity is maintained during convergence
- OSPF reconverges to the optimal path when the link is restored

---

### Troubleshooting / Common Mistakes
- OSPF neighbors do not form
  - Verify matching area IDs
  - Check router ID uniqueness
  - Ensure interfaces are not incorrectly configured as passive
- Routes are missing from the routing table
  - Verify correct network statements
  - Check wildcard masks
  - Confirm interfaces belong to Area 0
- Unexpected path selection
  - Verify interface cost values
  - Check bandwidth and cost calculation
 
---

### Notes 

> [!NOTE]
> - This lab demonstrates basic OSPF single-area operation using cost-based path selection.
> - Manual router ID configuration ensures predictable OSPF behavior and simplifies troubleshooting.
> - OSPF automatically recalculates the shortest path using the SPF algorithm when topology changes occur.

| [⬅️ Previous Lab](../09B-EIGRP-Unequal-Cost-(CML-%2B-PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../10B-OSPF-Elections-(CML-%2B-PKT)) |
|:--- | :---: | ---: |
