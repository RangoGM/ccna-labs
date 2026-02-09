## CCNA Labs: Bridging Simulation (Packet Tracer) and High-Fidelity Reality (CML) 


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

</div>                                        

---

<p align="center">
  <img src="[https://github-readme-stats-eight-theta.vercel.app/api?username=RangoGM&show_icons=true&theme=tokyonight](https://github-readme-stats-eight-theta.vercel.app/api?username=RangoGM&show_icons=true&theme=tokyonight)" alt="RangoGM Stats" />
  <br/>
  <img src="[https://github-readme-stats-eight-theta.vercel.app/api/top-langs/?username=RangoGM&layout=compact&theme=tokyonight](https://github-readme-stats-eight-theta.vercel.app/api/top-langs/?username=RangoGM&layout=compact&theme=tokyonight)" alt="Top Langs" />
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


<div align="center">
  
### 🛠 Tech Stack & Tools
  
### 💻 Virtualization & Network Engine
![VMware](https://img.shields.io/badge/VMware_Workstation_Pro-607078?style=for-the-badge&logo=vmware&logoColor=white)
![Cisco CML](https://img.shields.io/badge/Cisco_CML-Modeling_Labs-orange?style=for-the-badge&logo=cisco&logoColor=white)
![Packet Tracer](https://img.shields.io/badge/Packet_Tracer-Simulation-005A70?style=for-the-badge&logo=cisco&logoColor=white)

### 🐧 Operating Systems
![Kali Linux](https://img.shields.io/badge/Kali_Linux-PenTesting-557C94?style=for-the-badge&logo=kali-linux&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-Linux-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Windows 10/11](https://img.shields.io/badge/Windows_10/11-Stack-0078D6?style=for-the-badge&logo=windows&logoColor=white)

### 🔍 Analysis & Kernel Tuning
![Wireshark](https://img.shields.io/badge/Wireshark-Packet_Analysis-1679A7?style=for-the-badge&logo=wireshark&logoColor=white)
![tcpdump](https://img.shields.io/badge/tcpdump-CLI_Analysis-4169E1?style=for-the-badge)
![sysctl](https://img.shields.io/badge/sysctl-Kernel_Tuning-black?style=for-the-badge)

</div>

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
|[**Lab 01**](./01%20VLAN%20BASIC%20(PKT))|Basic VLAN Configuration (Access Ports)|❌|✅ Done|★|
|[**Lab 02A**](./02A%20VLAN%20TRUNK%20DEFAULT%20(PKT%20+%20CML))|VLAN Trunking (Default Trunk)|✅|✅ Done|★ ★|
|[**Lab 02B**](./02B%20VLAN%20Trunking%20(Allowed%20VLAN%20Restriction)%20(PKT))|VLAN Trunking (Allowed VLAN Restriction)|❌|✅ Done|★ ★|
|[**Lab 02C**](./02C%20Native%20VLAN%20mismatch%20(PKT%20+%20CML))|**(EXTRA)** VLAN Trunking (Native VLAN mismatch)|✅|✅ Done|★ ★ ★|
|[**Lab 03**](./03%20Inter%20VLAN%20Routing%20(CML%20+%20PKT))|Inter-VLAN Routing (Router-on-a-Stick)|✅|✅ Done|★★|
|[**Lab 04**](./04%20DHCP%20(CML%20+%20PKT))|DHCP|✅|✅ Done|★ ★|
|[**LAB 05(A)**](./05%20STP%20(CML%20+%20PKT))|STP|✅|✅ Done|★ ★|
|[**LAB 05B**](./05B%20STP%20Root%20Bridge%20(CML%20+%20PKT))|STP Root Bridge|✅|✅ Done|★ ★|
|[**LAB 05C**](./05C%20STP%20Port%20Fast%20&%20BDPU%20GUARD%20(CML%20+%20PKT))|STP PortFast & BPDU Guard|✅|✅ Done|★ ★|
|[**LAB 06**](./06%20Ethernet%20Channel%20&%20ASIC%20Hashing%20(CML%20+%20PKT))|Ethernet Channel & ASIC Hashing|✅|✅ Done|★ ★ ★|
|[**LAB 07**](./07%20Static%20Routing%20(CML%20+%20PKT))|Static Routing|✅|✅ Done|★ ★ ★|
|[**LAB 08**](./08%20Dynamic%20Routing%20RIPv2%20(CML%20+%20PKT))|Dynamic Routing (RIPv2)|✅|✅ Done|★ ★ ★|
|[**LAB 9A**](./09A%20EIGRP%20Feasible%20Successor%20(CML%20+%20PKT))| 🏆 Dynamic Routing (EIGRP - Feasible Successor) + **BFD**|✅|✅ Done|★ ★ ★ ⯪|
|[**LAB 9B**](./09B%20EIGRP%20Unequal-Cost%20(CML%20+%20PKT))|Dynamic Routing (EIGRP - Unequal-Cost Load Balancing)|✅|✅ Done|★ ★ ★|
|[**LAB 10A**](./10A%20OSPF%20Single%20Area%20(CML%20+%20PKT))|Dynamic Routing (OSPF - Single Area)|✅|✅ Done|★ ★ ★|
|[**LAB 10B**](./10B%20OSPF%20Elections%20(CML%20+%20PKT))|Dynamic Routing (OSPF - DR - BDR - DROTHER Election)|✅|✅ Done|★ ★ ★|
|[**LAB 10C**](./10C%20OSPF%20Multi-Area%20(CML%20+%20PKT))|Dynamic Routing (OSPF - Multi Area)|✅|✅ Done|★ ★ ★|
|[**LAB 11A**](./11A%20HSRP%20Enterprise%20Redundancy%20(PKT))| 🏆 HSRP Enterprise Redundancy (PKT Optimized)|❌|✅ Done|★ ★ ★ ★|
|[**LAB 11B**](./11B%20HSRP%20Enterprise-Grade%20High%20Availability%20(CML))| 🏆 HSRP Enterprise-Grade High Availability (CML more Optimized)|✅|✅ Done|★ ★ ★ ★ ⯪|
|[**LAB 12A**](./12A%20IPv6%20Addressing%20&%20Basic%20Connectivity%20(PKT))|IPv6 Addressing & Basic Connectivity|❌|✅ Done|★ ⯪|
|[**LAB 12B**](./12B%20IPv6%20Basic%20Connectivity%20&%20Windows%20Stack%20Deep-Dive%20(CML))| 🏆 IPv6 Basic Connectivity & Windows Stack Deep-Dive|✅|✅ Done|★ ★ ★ ⯪|
|[**LAB 12C**](./12C%20IPV6%20SLAAC%20(CML%20FOCUSED))| 🏆 IPv6 SLAAC & Linux Kernel Behavior (**CML FOCUSED**)|✅|✅ Done|★ ★ ★ ★|
|[**Lab 13**](./13%20IPv6%20Static%20Routing%20(CML%20+%20PKT))|IPv6 Static Routing|✅|✅ Done|★ ★ ⯪|
|[**Lab 14**](./14%20OSPFv3%20(CML%20+%20PKT))| 🏆 OSPFv3|✅|✅ Done|★ ★ ★ ★|
|[**Lab 15 (15.1 + 15.2)**](./15%20DHCPv6%20Implementation%20STATELESS%20&%20STATEFUL%20(CML%20FOCUSED))| 🏆 DHCPv6 Implement Stateless/Statefull (**CML FOCUSED**)|✅|✅ Done|★ ★ ★ ★ ⯪|
|[**Lab 16**](./16%20IPv6%20RA%20GUARD%20(CML%20FOCUSED))| 🏆 IPv6 RA GUARD (**CML FOCUSED**)|✅|✅ Done|★ ★ ★ ★ ★|

*Note: These labs focus on building large-scale networks to understand complex routing propagation and redundancy.*

---

### 🎯 Professional Goal
I don't just "input commands"; I analyze how data moves from the **Application Layer of a real Linux OS** down to the **Cisco Silicon logic**. This repository documents my transition from a student using simulators to a technician handling real-world network complexities.

---

<div align="center">

### 📍 CURRENT BASE & CONNECT
![Location](https://img.shields.io/badge/Location-Ho_Chi_Minh_City,_Vietnam-EA4335?style=for-the-badge&logo=google-maps&logoColor=white)
[![Facebook](https://img.shields.io/badge/Facebook-1877F2?style=for-the-badge&logo=facebook&logoColor=white)](https://www.facebook.com/dat.trangia.96)
[![Discord](https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white)](discordapp.com/users/698729316703404154)

</div>





