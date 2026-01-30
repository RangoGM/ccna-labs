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
- **End-Nodes:** Authentic Linux Distributions (Ubuntu, Kali, Debian).
- **Analysis:** Wireshark, tcpdump, sysctl for kernel tuning.

---

### 📂 Labs Included

#### [High-Fidelity Labs - CML/VMware Focus] **(Start At Lab 12D)**
- **L2 Security:** MAC Flooding and DHCP Starvation using Kali Linux against real IOSvL2 images.
- **IPv6 SLAAC Deep-Dive:** Analyzing Linux host behavior and tuning `net.ipv6.conf.all.accept_ra` to ensure RA acceptance.
- **DHCP Snooping & IP Source Guard:** Hardware-level security verification.
- **Lab 12D**: IPv6 SLAAC
- **Lab 12E (12E.1 + 12E.2)**: DHCPv6 Implement Stateless/Statefull

#### [Enterprise Topology Labs - Packet Tracer Focus]
- **Lab 01**: Basic VLAN Configuration (Access Ports)
- **Lab 02A**: VLAN Trunking (Default Trunk)
- **Lab 02B**: VLAN Trunking (Allowed VLAN Restriction)
- **Lab 02C** **(EXTRA)**: VLAN Trunking (Native VLAN mismatch)
- **Lab 03**: Inter-VLAN Routing (Router-on-a-Stick)
- **Lab 04**: DHCP
- **LAB 05(A)**: STP
- **LAB 05B**: STP Root Bridge
- **LAB 05C**: STP PortFast & BPDU Guard
- **LAB 06**: Ethernet Channel
- **LAB 07**: Static Routing
- **LAB 08**: Dynamic Routing (RIPv2)
- **LAB 9A**: Dynamic Routing (EIGRP - Feasible Successor)
- **LAB 9B**: Dynamic Routing (EIGRP - Unequal-Cost Load Balancing)
- **LAB 10A**: Dynamic Routing (OSPF - Single Path)
- **LAB 10B**: Dynamic Routing (OSPF - DR - BDR - DROTHER Election)
- **LAB 10C**: Dynamic Routing (OSPF - Multi Area)
- **LAB 11**: HSRP Enterprise Redundancy
- **LAB 12A**: IPv6 Addressing & Basic Connectivity
- **LAB 12B**: IPv6 Static Routing
- **LAB 12C**: IPv6 - OSPFv3 IPv6 Dynamic Routing

*Note: These labs focus on building large-scale networks to understand complex routing propagation and redundancy.*

---

### 🎯 Professional Goal
I don't just "input commands"; I analyze how data moves from the **Application Layer of a real Linux OS** down to the **Cisco Silicon logic**. This repository documents my transition from a student using simulators to a technician handling real-world network complexities.
