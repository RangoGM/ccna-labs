<div align="center">
  
![Header](https://capsule-render.vercel.app/api?type=waving&color=auto&height=200&section=header&text=Rango-Networking-Lab&fontSize=70)

</div>


<div align="center">

## CCNA Labs: Bridging Simulation (Packet Tracer) and High-Fidelity Reality (CML) 

</div>


<div align="center">
  
![CCNA](https://img.shields.io/badge/CCNA-200--301-blue?style=for-the-badge&logo=cisco) 


<pre align="center">
  

  /$$$$$$   /$$$$$$  /$$   /$$  /$$$$$$ 
 /$$__  $$ /$$__  $$| $$$ | $$ /$$__  $$
| $$  \__/| $$  \__/| $$$$| $$| $$  \ $$
| $$      | $$      | $$ $$ $$| $$$$$$$$
| $$      | $$      | $$  $$$$| $$__  $$
| $$    $$| $$    $$| $$\  $$$| $$  | $$
|  $$$$$$/|  $$$$$$/| $$ \  $$| $$  | $$
 \______/  \______/ |__/  \__/|__/  |__/

[ NETWORK & RESEARCH ]
                                    
</pre>                                 

---

<table align="center">
<tr>
    <td align="center">
      <img src="https://github-readme-stats-sigma-five.vercel.app/api?username=RangoGM&show_icons=true&theme=tokyonight" height="195px" alt="Stats" />
    </td>
    <td align="center">
      <img src="https://github-readme-streak-stats.herokuapp.com/?user=RangoGM&theme=tokyonight" height="195px" alt="Streak" />
    </td>
  </tr>
</table>

<p align="center">
  <img src="https://raw.githubusercontent.com/platane/snk/output/github-contribution-grid-snake-dark.svg" alt="Snake" width="80%" />
</p>

</div>

---

### 🚀 My Lab Philosophy: Quality over Quantity


In my CCNA journey, I utilize two distinct environments to master networking:
1. **Cisco Packet Tracer (PT):** Used for large-scale Enterprise topologies where I need to practice architectural design and multi-node routing (overcoming the node limits of virtual labs).

2. **Cisco Modeling Labs (CML) + VMware:** Used for **High-Fidelity Labs**. When a protocol requires real-world behavior, authentic IOSv commands, or complex OS-to-Network interaction (Linux/Windows), I migrate the core logic to CML.


> [!IMPORTANT]
> ### 🛠 Why I transition to CML & Linux VMs?
> While Packet Tracer is excellent for learning basic CLI, it has limitations that only real IOS images and Linux Kernels can solve:
> - **Command Authenticity:** CML runs real Cisco IOSv/IOSv-L2 images. Many advanced commands and sub-options missing in PT are fully functional here.
> - **The 5-Node Challenge:** Working with the CML free/community version (limited to 5 nodes) forced me to be strategic. I design "surgical" labs—focusing on the most critical parts of the network to observe real traffic flow and kernel-level reactions.
> - **Real OS Interaction:** By connecting Linux VMs on VMware to CML routers, I troubleshoot real-world issues like Kernel Sysctl parameters, IPv6 RA behavior, and firewall interactions that a simulator simply cannot replicate.

<p align="center">
  <img src="https://img.shields.io/badge/Learning_Mode-ON-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Target-CCNA_Certified-blue?style=for-the-badge" />
</p>

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

### 📂 Labs Included

#### [Enterprise Topology Labs - Packet Tracer Focus]
#### [High-Fidelity Labs - CML/VMware Focus]
- **L2 Security:** MAC Flooding and DHCP Starvation using Kali Linux against real IOSvL2 images.
- **IPv6 SLAAC Deep-Dive:** Analyzing Linux host behavior and tuning `net.ipv6.conf.all.accept_ra` to ensure RA acceptance.
- **DHCP Snooping & IP Source Guard:** Hardware-level security verification.
#### LABS LIST:

|LAB #|Topic & Objective|(CML)|Status|Difficulty|
|-----|-----------------|-----|------|----------|
|[**LAB 01**](./01-VLAN-BASIC-(PKT))|Basic VLAN Configuration (Access Ports)|❌|✅ Done|⭐|
|[**LAB 02A**](./02A-VLAN-TRUNK-DEFAULT-(PKT-+-CML))|VLAN Trunking (Default Trunk)|✅|✅ Done|⭐⭐|
|[**LAB 02B**](./02B-VLAN-Trunking-(Allowed-VLAN-Restriction)-(PKT))|VLAN Trunking (Allowed VLAN Restriction)|❌|✅ Done|⭐⭐|
|[**LAB 02C**](./02C-Native-VLAN-mismatch-(PKT-+-CML))|**(EXTRA)** VLAN Trunking (Native VLAN mismatch)|✅|✅ Done|⭐⭐⭐|
|[**LAB 03**](./03-Inter-VLAN-Routing-(CML-+-PKT))|Inter-VLAN Routing (Router-on-a-Stick)|✅|✅ Done|⭐⭐|
|[**LAB 04**](./04-DHCP-(CML-+-PKT))|DHCP|✅|✅ Done|⭐⭐|
|[**LAB 05(A)**](./05-STP-(CML-+-PKT))|STP|✅|✅ Done|⭐⭐|
|[**LAB 05B**](./05B-STP-Root-Bridge-(CML-+-PKT))|STP Root Bridge|✅|✅ Done|⭐⭐|
|[**LAB 05C**](./05C-STP-Port-Fast-&-BDPU-GUARD-(CML-+-PKT))|STP PortFast & BPDU Guard|✅|✅ Done|⭐⭐|
|[**LAB 06**](./06-Ethernet-Channel-&-ASIC-Hashing-(CML-+-PKT))|Ethernet Channel & ASIC Hashing|✅|✅ Done|⭐⭐⭐|
|[**LAB 07**](./07-Static-Routing-(CML-+-PKT))|Static Routing|✅|✅ Done|⭐⭐⭐|
|[**LAB 08**](./08-Dynamic-Routing-RIPv2-(CML-+-PKT))|Dynamic Routing (RIPv2)|✅|✅ Done|⭐⭐⭐|
|[**LAB 9A**](./09A-EIGRP-Feasible-Successor-(CML-+-PKT))| 🏆 Dynamic Routing (EIGRP - Feasible Successor) + **BFD**|✅|✅ Done|⭐⭐⭐⭐|
|[**LAB 9B**](./09B-EIGRP-Unequal-Cost-(CML-+-PKT))|Dynamic Routing (EIGRP - Unequal-Cost Load Balancing)|✅|✅ Done|⭐⭐⭐|
|[**LAB 10A**](./10A-OSPF-Single-Area-(CML-+-PKT))|Dynamic Routing (OSPF - Single Area)|✅|✅ Done|⭐⭐⭐|
|[**LAB 10B**](./10B-OSPF-Elections-(CML-+-PKT))|Dynamic Routing (OSPF - DR - BDR - DROTHER Election)|✅|✅ Done|⭐⭐⭐|
|[**LAB 10C**](./10C-OSPF-Multi-Area-(CML-+-PKT))|Dynamic Routing (OSPF - Multi Area)|✅|✅ Done|⭐⭐⭐|
|[**LAB 11A**](./11A-HSRP-Enterprise-Redundancy-(PKT))| 🏆 HSRP Enterprise Redundancy (PKT Optimized)|❌|✅ Done|⭐⭐⭐⭐|
|[**LAB 11B**](./11B-HSRP-Enterprise-Grade-High-Availability-(CML))| 🏆 HSRP Enterprise-Grade High Availability (CML more Optimized)|✅|✅ Done|⭐⭐⭐⭐⭐|
|[**LAB 12A**](./12A-IPv6-Addressing-&-Basic-Connectivity-(PKT))|IPv6 Addressing & Basic Connectivity|❌|✅ Done|⭐⭐|
|[**LAB 12B**](./12B-IPv6-Basic-Connectivity-&-Windows-Stack-Deep-Dive-(CML))| 🏆 IPv6 Basic Connectivity & Windows Stack Deep-Dive|✅|✅ Done|⭐⭐⭐⭐|
|[**LAB 12C**](./12C-IPV6-SLAAC-(CML-FOCUSED))| 🏆 IPv6 SLAAC & Linux Kernel Behavior (**CML FOCUSED**)|✅|✅ Done|⭐⭐⭐⭐|
|[**LAB 13**](./13-IPv6-Static-Routing-(CML-+-PKT))|IPv6 Static Routing|✅|✅ Done|⭐⭐⭐|
|[**LAB 14**](./14-OSPFv3-(CML-+-PKT))| 🏆 OSPFv3|✅|✅ Done|⭐⭐⭐⭐|
|[**LAB 15 (15.1 + 15.2)**](./15-DHCPv6-Implementation-STATELESS-&-STATEFUL-(CML-FOCUSED))| 🏆 DHCPv6 Implement Stateless/Statefull (**CML FOCUSED**)|✅|✅ Done|⭐⭐⭐⭐|
|[**LAB 16**](./16-IPv6-RA-GUARD-(CML-FOCUSED))| 🏆 IPv6 RA GUARD (**CML FOCUSED**)|✅|✅ Done|⭐⭐⭐⭐|
|[**LAB 17**](./17-Hybrid-DNS-Infrastructure-(CML))|🏆 Hybrid DNS Infrastructure & Kali Linux Server (**LINUX FOCUSED**)|✅|✅ Done|⭐⭐⭐⭐⭐|
|[**LAB 18**](./18-Standard-ACL-(CML-+-PKT))| Standard ACL - Enterprise Traffic Engineering & Security Baseline |✅|✅ Done|⭐⭐|
|[**LAB 19**](./19-NAT-(CML-+-PKT))|Comprehensive NAT Architectures - Static, Dynamic & PAT|✅|✅ Done|⭐⭐⭐|
|[**LAB 20**](./20-Extended-ACL-&-Services-(CML-+-PKT))|🏆 Advanced Network Security - Extended ACL & Service Hardening **(LINUX FOCUSED)**|✅|✅ Done|⭐⭐⭐⭐⭐|
|[**LAB 21**](./21-Enterprise-Syslog-(CML-+-PKT))|🏆 Enterprise Centralized Logging - Rsyslog, MariaDB & Web UI Hardening **(LINUX FOCUSED)**|✅|✅ Done|⭐⭐⭐⭐⭐⭐|
|[**LAB 22**](./22-NTP-(CML-+-PKT))|Infrastructure Hardening: Automated Syslog & Secure NTP Orchestration **(LINUX FOCUSED)**|✅|✅ Done|⭐⭐⭐|
|[**LAB 23**](./23-SNMPv3-(CML))|🏆 Full-Stack Enterprise SNMPv3 Monitoring & Control (**CML & LINUX FOCUSED**)|✅|✅ Done|⭐⭐⭐⭐⭐|
|[**LAB 24**](./24-Port-Security-(Research))|:electron: Port Security Enforcement & Temporal Authorization Analysis (**Research Project**)|✅|✅ Done|![Research Grade](https://img.shields.io/badge/LEVEL-RESEARCH_ANALYSIS-black?style=for-the-badge&logo=target)|
|[**LAB 25**](./25-802.1X-Control-Plane-(Research))|:electron: IEEE 802.1X Control-Plane Integration & Platform Capability Validation (**Research Project**)|✅|✅ Done|![Research Grade](https://img.shields.io/badge/LEVEL-RESEARCH_ANALYSIS-black?style=for-the-badge&logo=target)|


*Note: These labs focus on building large-scale networks to understand complex routing propagation and redundancy.*

---

### 🎯 Professional Goal
I don't just "input commands"; I analyze how data moves from the **Application Layer of a real Linux OS** down to the **Cisco Silicon logic**. This repository documents my transition from a student using simulators to a technician handling real-world network complexities.

---

<div align="center">

![Views](https://komarev.com/ghpvc/?username=RangoGM&color=blueviolet&style=for-the-badge&label=PROFILE+VIEWS)

</div>


