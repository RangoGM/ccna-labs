## CCNA Labs: Bridging Simulation (Packet Tracer) and High-Fidelity Reality (CML)

### 🚀 My Lab Philosophy: Quality over Quantity
In my CCNA journey, I utilize two distinct environments to master networking:
1. **Cisco Packet Tracer (PT):** Used for large-scale Enterprise topologies where I need to practice architectural design and multi-node routing (overcoming the node limits of virtual labs).

2. **Cisco Modeling Labs (CML) + VMware:** Used for **High-Fidelity Labs**. When a protocol requires real-world behavior, authentic IOSv commands, or complex OS-to-Network interaction (Linux/Windows), I migrate the core logic to CML.

### 🛠 Why I transition to CML & Linux VMs?
While Packet Tracer is excellent for learning basic CLI, it has limitations that only real IOS images and Linux Kernels can solve:
- **Command Authenticity:** CML runs real Cisco IOSv/IOSv-L2 images. Many advanced commands and sub-options missing in PT are fully functional here.

- **The 5-Node Challenge:** Working with the CML free/community version (limited to 5 nodes) forced me to be strategic. I design "surgical" labs—focusing on the most critical parts of the network to observe real traffic flow and kernel-level reactions.

- **Real OS Interaction:** By connecting Linux VMs on VMware to CML routers, I troubleshoot real-world issues like Kernel Sysctl parameters, IPv6 RA behavior, and firewall interactions that a simulator simply cannot replicate.

---

### 📂 Repository Structure
Each folder represents one independent lab and contains:
- **Lab Files:** Packet Tracer files (`.pkt`) for large topologies.
- **Visual Documentation:** High-quality **Screenshots** of CML topologies and CLI outputs for high-fidelity labs.
- **Lab-specific README with:**
  - **Topology Description:** Visual and text breakdown.
  - **Goal:** What I aim to achieve/verify.
  - **Example Configuration:** Key CLI snippets.
  - **Verification:** Proof of connectivity or security enforcement (e.g., show commands, Wireshark captures).
  - **Troubleshooting Notes:** Real-world issues encountered (e.g., Linux RA acceptance, interface states).
 
---

### 🛠 Tech Stack & Tools
- **Virtualization:** VMware Workstation Pro.
- **Network Engine:** Cisco Modeling Labs (CML) & Cisco Packet Tracer.
- **Operating Systems** Authentic Linux Distributions (Ubuntu, Kali, Debian), Window 10/11 Stack.
- **Analysis:** Wireshark, tcpdump, sysctl for kernel tuning.

---

### 📂 Labs Included

#### [Enterprise Topology Labs - Packet Tracer Focus]
#### [High-Fidelity Labs - CML/VMware Focus]
- **L2 Security:** MAC Flooding and DHCP Starvation using Kali Linux against real IOSvL2 images.
- **IPv6 SLAAC Deep-Dive:** Analyzing Linux host behavior and tuning `net.ipv6.conf.all.accept_ra` to ensure RA acceptance.
- **DHCP Snooping & IP Source Guard:** Hardware-level security verification.
##### LABS LIST:
- [Lab 01: Basic VLAN Configuration (Access Ports)](./01%20VLAN%20BASIC%20(PKT))
- [**Lab 02A**: VLAN Trunking (Default Trunk)](./02A%20VLAN%20TRUNK%20DEFAULT%20(PKT%20+%20CML)) 
- [**Lab 02B**: VLAN Trunking (Allowed VLAN Restriction)](./02B%20VLAN%20Trunking%20(Allowed%20VLAN%20Restriction)%20(PKT))
- [**Lab 02C** **(EXTRA)**: VLAN Trunking (Native VLAN mismatch)](./02C%20Native%20VLAN%20mismatch%20(PKT%20+%20CML))
- [**Lab 03**: Inter-VLAN Routing (Router-on-a-Stick)](./03%20Inter%20VLAN%20Routing%20(CML%20+%20PKT))
- [**Lab 04**: DHCP](./04%20DHCP%20(CML%20+%20PKT))
- [**LAB 05(A)**: STP](./05%20STP%20(CML%20+%20PKT))
- [**LAB 05B**: STP Root Bridge](./05B%20STP%20Root%20Bridge%20(CML%20+%20PKT))
- [**LAB 05C**: STP PortFast & BPDU Guard](./05C%20STP%20Port%20Fast%20&%20BDPU%20GUARD%20(CML%20+%20PKT))
- [**LAB 06**: Ethernet Channel & ASIC Hashing](./06%20Ethernet%20Channel%20&%20ASIC%20Hashing%20(CML%20+%20PKT))
- [**LAB 07**: Static Routing](./07%20Static%20Routing%20(CML%20+%20PKT))
- [**LAB 08**: Dynamic Routing (RIPv2)](./08%20Dynamic%20Routing%20RIPv2%20(CML%20+%20PKT))
- [**LAB 9A**: Dynamic Routing (EIGRP - Feasible Successor)](./09A%20EIGRP%20Feasible%20Successor%20(CML%20+%20PKT))
- [**LAB 9B**: Dynamic Routing (EIGRP - Unequal-Cost Load Balancing)](./09B%20EIGRP%20Unequal-Cost%20(CML%20+%20PKT))
- [**LAB 10A**: Dynamic Routing (OSPF - Single Area)](./10A%20OSPF%20Single%20Area%20(CML%20+%20PKT))
- [**LAB 10B**: Dynamic Routing (OSPF - DR - BDR - DROTHER Election)](./10B%20OSPF%20Elections%20(CML%20+%20PKT))
- [**LAB 10C**: Dynamic Routing (OSPF - Multi Area)](./10C%20OSPF%20Multi-Area%20(CML%20+%20PKT))
- [**LAB 11A**: HSRP Enterprise Redundancy (PKT Optimized)](./11A%20HSRP%20Enterprise%20Redundancy%20(PKT))
- [**LAB 11B**: HSRP Enterprise-Grade High Availability (CML more Optimized)](./11B%20HSRP%20Enterprise-Grade%20High%20Availability%20(CML))
- [**LAB 12A**: IPv6 Addressing & Basic Connectivity](./12A%20IPv6%20Addressing%20&%20Basic%20Connectivity%20(PKT))
- [**LAB 12B**: IPv6 Basic Connectivity & Windows Stack Deep-Dive](./12B%20IPv6%20Basic%20Connectivity%20&%20Windows%20Stack%20Deep-Dive%20(CML))
- [**LAB 12C**: IPv6 SLAAC & Linux Kernel Behavior (**CML FOCUSED**)](./12C%20IPV6%20SLAAC%20(CML%20FOCUSED))
- [**Lab 13**: IPv6 Static Routing](./13%20IPv6%20Static%20Routing%20(CML%20+%20PKT))
- [**Lab 14**: OSPFv3](./14%20OSPFv3%20(CML%20+%20PKT))
- [**Lab 15 (15.1 + 15.2)**: DHCPv6 Implement Stateless/Statefull (**CML FOCUSED**)](./15%20DHCPv6%20Implementation%20STATELESS%20&%20STATEFUL%20(CML%20FOCUSED))
- [**Lab 16**: IPv6 RA GUARD (**CML FOCUSED**)](./16%20IPv6%20RA%20GUARD%20(CML%20FOCUSED))

*Note: These labs focus on building large-scale networks to understand complex routing propagation and redundancy.*

---

### 🎯 Professional Goal
I don't just "input commands"; I analyze how data moves from the **Application Layer of a real Linux OS** down to the **Cisco Silicon logic**. This repository documents my transition from a student using simulators to a technician handling real-world network complexities.
