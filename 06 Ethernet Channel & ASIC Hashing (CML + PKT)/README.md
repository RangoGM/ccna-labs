## Lab 06 - EtherChannel (LACP)

### Topology
This lab builds on **Lab 05B - Spanning Tree Protocol (STP) Root Bridge**.

The same three-switch topology is reused, where **SW1 is configured as the
STP root bridge**. Multiple parallel links between two switches are bundled
using EtherChannel to demonstrate how STP interacts with a logical
Port-channel interface.

**📸 Screen shots:**

<img width="875" height="290" alt="Screenshot 2026-02-02 014854" src="https://github.com/user-attachments/assets/83fa1367-84bf-42b3-b4c4-bb2048fa6988" />

---

### Goal
- Understand the purpose of EtherChannel
- Configure EtherChannel using LACP
- Observe how EtherChannel interacts with STP
- Verify redundancy and link aggregation behavior

**🔷 Key Goal:** 

**1. Validate Flow-Based Load Balancing:**

Per-Flow, Not Per-Packet: Confirm that EtherChannel distributes traffic by "flows" (Source/Destination pairs) rather than individual packets.

Packet Integrity: Verify that all packets in a single flow stay on the same physical link to prevent **TCP Out-of-Order** delivery.

**2. Algorithm vs. Packet Ordering:**

Deterministic Behavior: Prove that changing the algorithm (e.g., from `src-mac` to `src-dst-ip`) does not break packet ordering.

ASIC Limitation (CML vs. Reality): Acknowledge that while hardware ASICs are more efficient, the software-based IOL (IOS on Linux) in CML is prone to Hash Polarization. This explains why multiple simulated flows might still "clump" onto one link.

**3. Analyze the Entropy Gap:**

Low Entropy Challenge: Identify why ICMP (Ping) traffic in a small lab (1 Host, 1 Router) provides insufficient entropy for the hashing function.

Algorithm Convergence: Explain why src-mac and src-dst-ip results appear identical in low-scale environments: the limited number of unique headers leads to Hash Collisions, forcing all traffic onto a single interface.

---

### Topology Design

**Devices**
- 3 Switches (SW1, SW2, SW3)
- PCs (optional, for connectivity testing)

**Links**
- Multiple parallel links between **SW1 and SW2**
- Switch-to-switch links are trunk ports
- EtherChannel is formed only between SW1 and SW2

---

### Key Concepts
- EtherChannel
- Port-channel interface
- LACP (Link Aggregation Control Protocol)
- Interface configuration consistency
- STP interaction with EtherChannel

---

### Key Configuration

- Reuse VLAN, trunk, and STP configuration from Lab 05B
- Ensure all member interfaces have **identical Layer 2 configurations**
- Configure EtherChannel using **LACP active mode**
- Apply trunk configuration on the **Port-channel interface**
- Do not mix trunk and access ports within the same EtherChannel

---

### Example Configuration

**📸 Screen shots:**

<img width="651" height="409" alt="Screenshot 2026-02-01 232029" src="https://github.com/user-attachments/assets/efb753a7-f5ae-4432-ad0b-311aea6968c8" />

<img width="577" height="424" alt="Screenshot 2026-02-01 232255" src="https://github.com/user-attachments/assets/09aa419a-25c2-47cc-ac5b-36a7febb86f4" />

<img width="651" height="409" alt="Screenshot 2026-02-01 232433" src="https://github.com/user-attachments/assets/6c2b6bf3-f1f5-4a88-a8e9-40a53155a1fc" />

*(As beginning after configured trunk links, etc.. Spanning Tree Table appeared alots of Interfaces, with Ethernet Channel configuration the STP Table should be more abbreviated and calculates the *Prior.Nbr** again)*

#### Configure EtherChannel Member Interfaces (LACP)

```bash
SWITCH(config)# interface range <interfaces>
SWITCH(config-if-range)# switchport mode trunk
SWITCH(config-if-range)# channel-group 1 mode active
```

**📸 Screen shots:**

<img width="307" height="121" alt="Screenshot 2026-02-01 233206" src="https://github.com/user-attachments/assets/958caf74-1d58-43d4-a8dc-d0c606c2027d" />

*(Example Configuration every links is all the same except the interfaces connected to end hosts)*

#### Configure Port-Channel Interface
```bash
SWITCH(config)# interface port-channel 1
SWITCH(config-if)# switchport mode trunk
```
<img width="313" height="81" alt="Screenshot 2026-02-01 233155" src="https://github.com/user-attachments/assets/01ef1511-ca52-44da-9cbe-1aeb36e943f4" />

<img width="313" height="77" alt="Screenshot 2026-02-01 233400" src="https://github.com/user-attachments/assets/0f0ea614-3491-4ac8-92b1-5280cd662b0b" />

*(Example)*

*(Physical interfaces inherit configuration from the Port-channel interface)*

---

### Verification
- Verify EtherChannel status:
  - *`show etherchannel summary`*
- Verify Port-channel interface:
  - *`show interfaces port-channel 1`*
 
**📸 Screen shots:**


<img width="669" height="180" alt="Screenshot 2026-02-01 233753" src="https://github.com/user-attachments/assets/8e5ca7aa-7523-45dd-9a2e-744aaa6f719a" />



<img width="551" height="181" alt="Screenshot 2026-02-01 233927" src="https://github.com/user-attachments/assets/35c8c7ae-d555-4438-b98c-e2a5a8c9aae6" />


<img width="598" height="154" alt="Screenshot 2026-02-01 233941" src="https://github.com/user-attachments/assets/12c8cb2d-e8dd-4b70-86d3-0d727796b54e" />


*(Make sure it is IN USE (SU) state & bundled in port (P) state if it is not you must fix it and configure properbly)*

- Verify trunk status:
  - *`show interfaces trunk`*
- Verify STP behavior:
  - *`show spanning-tree`*

**📸 Screen shots:**

<img width="639" height="105" alt="Screenshot 2026-02-01 234318" src="https://github.com/user-attachments/assets/f8462980-8442-4dd2-a6ed-5f4e2261dc89" />

*(SW1)*

<img width="548" height="107" alt="Screenshot 2026-02-01 234335" src="https://github.com/user-attachments/assets/1b043cc0-66c6-450f-83b4-a2fbe53109c0" />

*(SW2)*

<img width="490" height="93" alt="Screenshot 2026-02-01 234351" src="https://github.com/user-attachments/assets/62b46f62-b495-469b-9445-52f419e64a64" />



*(SW3)*



*(By bundling physical interfaces into a single logical EtherChannel, STP views them as one link. This eliminates the need to block redundant paths, allowing for load balancing and faster convergence.)*
 
---

### Extra KEY INSIGHTS

#### **Load Balancing** in Ethernet channel and ASCI CML function compared to **REAL** ASCI on Cisco Devices

#### 🔷 Before

**📸 Screen shots:**

<img width="739" height="153" alt="Screenshot 2026-02-01 235626" src="https://github.com/user-attachments/assets/1da3d6f1-497f-4a6e-938e-f040a3542c8c" />

*(Resetting interface packet counters to analyze flow distribution under the `src-mac` load-balancing algorithm).*

<img width="452" height="194" alt="Screenshot 2026-02-01 235247" src="https://github.com/user-attachments/assets/9a992447-49d1-4d48-a7ff-4e021535118e" />

<img width="818" height="139" alt="Screenshot 2026-02-01 235751" src="https://github.com/user-attachments/assets/68399f6c-7f98-4d2d-835e-c3b7c9b9233b" />

*(Generating a high volume of traffic to analyze the distribution of `src-mac` based flows).*

<img width="432" height="77" alt="Screenshot 2026-02-01 235914" src="https://github.com/user-attachments/assets/e1458701-c841-480d-8282-181cf0b72e40" />


**➡️ Conclusion:** When using the `src-mac` load-balancing algorithm with only a single source MAC address, the switch deterministically selects **Interface Et1/2** to forward all packets. This confirms that only a single flow is created. This behavior is 100% consistent with real-world production environments, as EtherChannel prioritizes maintaining packet order within a flow over balanced link utilization in low-entropy scenarios.

---

#### 🔷 After

**📸 Screen shots:**


<img width="457" height="158" alt="Screenshot 2026-02-02 001626" src="https://github.com/user-attachments/assets/a7c69c5f-95a5-4968-b9b4-b621fafd0372" />

**➡️ Scaling Entropy:** From `src-mac` to `src-dst-ip` with iperf3
When migrating from `src-mac` to `src-dst-ip`, the switch incorporates additional variables (IP headers) into its **hashing algorithm** to determine flow distribution.

The **ICMP Entropy Challenge:** Most ICMP-based tests are characterized by **Low Entropy**. Since ICMP lacks Layer 4 port information, the hashing result remains **static**, often leading to all traffic being pinned to a **single interface** in **small-scale environments**.

Objective Testing with **iperf3:** To achieve an objective result, I deployed a dual-Kali setup (Server and Client). By running iperf3 across **multiple TCP ports**, I introduced high entropy into the traffic stream, **forcing the switch to evaluate distinct flows**.

**⚠️ NOTE on Virtualization: Please be aware that this is a demonstration within Cisco Modeling Labs (CML). The software-based hashing used in IOL (IOS on Linux) images may behave differently than the dedicated Hardware ASICs found in physical switches. While this provides an objective look at flow mechanics, real-world hardware ASICs often have more advanced distribution capabilities**

**📸 Screen shots:**

<img width="905" height="285" alt="Screenshot 2026-02-02 191715" src="https://github.com/user-attachments/assets/e55c351e-da33-48ce-9a1f-8556c6c4c5b8" />

<img width="1272" height="420" alt="Screenshot 2026-02-02 191621" src="https://github.com/user-attachments/assets/1e78b1d5-c535-456e-8189-7dcf373fa3dc" />

*(KALI_SERVER)*

<img width="633" height="266" alt="Screenshot 2026-02-02 191643" src="https://github.com/user-attachments/assets/286855fb-68c8-4c0f-ae23-2f360a498033" />

*(KALI_CLIENT)*

<img width="432" height="76" alt="Screenshot 2026-02-02 143136" src="https://github.com/user-attachments/assets/57d93751-2577-454d-9412-ed1503516d12" />

*(Result)*

- However, a **perfect 50/50** split is rarely achieved in a lab environment for several reasons:

  - **Hash Polarization:** Even with 20 parallel flows, the deterministic nature of the algorithm may still map multiple flows into the same "hash bucket," resulting in skewed counters.

  - **Statistical Scalability:** EtherChannel is built for Scalability, not perfect symmetry. In production, thousands of unique users provide the high entropy needed for the "Law of Large Numbers" to balance traffic across the bundle.

  - **Deterministic vs. Software ASIC:** CML utilizes software-based IOL (IOS on Linux) hashing, which is a functional simulation and may lack the granular distribution found in physical hardware ASICs.

**🔴 The observed imbalance isn't a failure; it proves the algorithm is correctly prioritizing Flow Integrity (keeping packets in order) over forced mathematical equality.**

---

#### 🔷 Redundacy

**📸 Screen shots:**

<img width="643" height="61" alt="Screenshot 2026-02-02 202657" src="https://github.com/user-attachments/assets/29056793-166e-4883-9ba9-56a428568777" />

*(Interface ether1/2 is **Down**, only Interface ether2/1 is **Up**)*

<img width="878" height="544" alt="Screenshot 2026-02-02 202900" src="https://github.com/user-attachments/assets/5d69644b-e8ba-4f33-80b8-9b36ec810c82" />

<img width="478" height="105" alt="Screenshot 2026-02-02 202828" src="https://github.com/user-attachments/assets/7a123564-5cae-4bea-92db-39456354e660" />

*(Testing connectivity again and the server still recieved packets but packets only passthrough **Interface ether2/1**)*

---

### Result 
- Multiple physical links operate as a single logical Port-channel
- EtherChannel forms successfully only when interface configurations match
- STP treats the Port-channel as one logical link
- STP blocking states may change after EtherChannel formation
- Network connectivity is maintained if a member link fails

---

### Troubleshooting / Common Mistakes
- Attempting to bundle interfaces with different configurations
- Mixing trunk and access ports in the same EtherChannel
- Using different EtherChannel modes on each side
- Applying trunk configuration only on physical interfaces
- Expecting STP to block individual links inside an EtherChannel
---

### Notes
EtherChannel requires all member interfaces to have identical Layer 2 configurations, including switchport mode, encapsulation, and VLAN settings.

When EtherChannel is formed, STP no longer sees individual physical links. Instead, the Port-channel is treated as a single logical interface, which may cause STP to recalculate port roles and blocking states.

LACP is an IEEE standard protocol and is recommended for safer and more predictable EtherChannel negotiation.
