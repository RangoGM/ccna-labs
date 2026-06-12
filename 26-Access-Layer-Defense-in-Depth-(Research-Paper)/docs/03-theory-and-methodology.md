# 3. Content and Methodology

## 3.1 Research Method

The project uses an experimental research method combined with qualitative analysis, conducted on a physical network environment using real equipment. The process: (1) build the network model and set up the infrastructure components; (2) simulate attack scenarios with Kali Linux; (3) deploy and evaluate Access Layer security mechanisms; and (4) collect and cross-reference system logs and the binding table to analyze the effectiveness of each protection and identify remaining risk.

## 3.2 Theoretical Background

### 3.2.1 The Enterprise Network Model and the Access Layer

In Cisco's hierarchical network model, enterprise infrastructure is organized into three functional layers: Core, Distribution, and Access. The Core provides high-speed forwarding, the Distribution performs routing and policy, and the **Access Layer** is the direct connection point for end devices.

The Access Layer has the largest attack surface: many physical ports, diverse endpoints (PC, laptop, printer, IP phone, IoT), and an attacker only needs to plug in a cable to gain Layer 2 adjacency. In this project, the hypothetical enterprise is an SME (~100–200 endpoints) with one Cisco Catalyst 2960 at the Access Layer.

### 3.2.2 Attacker Classification and the Attack Lifecycle

**3.2.2.1 Classifying network attackers.** Attackers are usually classified by purpose and level of authorization. The three most common groups:

**Table 3.1: Classifying network attackers.**

| Type | Description | Purpose | Typical example |
|---|---|---|---|
| White Hat | Authorized security expert | Legally find and patch vulnerabilities | Pen tester, security researcher |
| Black Hat | Unauthorized attacker | Profit, sabotage, data theft | Cybercriminal, nation-state attacker |
| Gray Hat | Between legal and illegal | Often discloses vulnerabilities without permission | Hacktivist, unsolicited pentester |

In this project, the simulated attacker behaves like a Black Hat — with physical or logical access to the internal network, attacking to intercept traffic or disrupt operations. More specifically, the attacker is split into two groups: Insider Threat (already has legitimate access) and Unauthorized Physical Access (physical intrusion), detailed in Section 1.4.

**3.2.2.2 The Attack Lifecycle.** The Attack Lifecycle (or Cyber Kill Chain) describes the sequential steps from identifying a target to achieving the objective. Understanding it helps the security team pick the most effective intervention point.

**Table 3.2: The Attack Lifecycle and corresponding defenses.**

| Step | Stage | Description | Defense (Access Layer) |
|---|---|---|---|
| 1 | Reconnaissance | Scan the network for IP, MAC, VLAN, running services. At Layer 2: passive sniff, ARP scan, CDP/LLDP. | Disable CDP/LLDP on access ports; monitor anomalies via Syslog |
| 2 | Scanning | Identify weaknesses: switch model, IOS version, DHCP lease, STP topology, IPv6 RA. | Port Security limits MACs; DHCP Snooping prevents DHCP discovery leak |
| 3 | Gaining Access | Execute attacks: ARP Poisoning, Rogue DHCP, STP Root Bridge attack, Rogue RA. This is where FHS mechanisms directly intervene. | DAI, DHCP Snooping, IPSG, RA Guard, BPDU Guard — the core of this project |
| 4 | Maintaining Access | Sustain the MITM session: arpspoof loop, rogue DHCP lease refresh, persistent RA. The attacker tries to stay invisible. | Rate limiting, errdisable, MAC Notification log |
| 5 | Covering Tracks | Few clear traces at Layer 2, but logging still records anomalies: ARP rate violation, DHCP drop, dot1x failure. | Centralized Syslog + LogAnalyzer: post-event detection |

Most Access Layer mechanisms concentrate on the **Gaining Access** stage. However, the monitoring system (Syslog + LogAnalyzer) is important in the remaining stages — especially detecting Reconnaissance and Covering Tracks after the event. At Layer 2, the boundary between Reconnaissance and Gaining Access is very blurred: the attacker can often start exploiting immediately upon having Layer 2 adjacency, without a prolonged scanning phase.

### 3.2.3 Foundational Layer 2 Protocols and Their Weaknesses

**3.2.3.1 MAC Address and CAM Table.** A MAC address is a 48-bit unique identifier for each NIC. The switch uses the CAM table to map MAC addresses to physical ports to forward unicast frames correctly. The CAM table has finite capacity tied to the device's hardware memory (TCAM). This limit is the surface exploited by MAC-flooding attacks.

**3.2.3.2 Address Resolution Protocol (ARP).** ARP (RFC 826) maps IP to MAC within a subnet. Its core weakness is the lack of authentication. Any host can send an ARP Reply without a preceding ARP Request (Gratuitous ARP). This is the foundation of ARP Poisoning — cache entries can be poisoned by forged ARP Replies.

**3.2.3.3 Dynamic Host Configuration Protocol (DHCP).** DHCP (RFC 2131) automatically assigns network configuration to endpoints via the 4-step DORA process: Discover (broadcast to find a server), Offer (server proposes an IP), Request (client confirms), ACK (server confirms assignment). Its weakness: it relies on broadcast and does not authenticate the server. Any host in the broadcast domain can impersonate a DHCP server.

**3.2.3.4 Spanning Tree Protocol (STP).** STP (IEEE 802.1D) prevents loops in networks with redundant paths. It elects a Root Bridge and computes a spanning tree, keeping only one active path between any pair of switches. Bridge ID = Priority (2 bytes) + MAC Address (6 bytes) — the switch with the lowest Bridge ID becomes Root. Because BPDUs are not authenticated, STP is exploitable in STP Manipulation attacks.

**3.2.3.5 Neighbor Discovery Protocol (NDP) – IPv6.** NDP (RFC 4861) is the IPv6 replacement for ARP, also providing Router Discovery and Stateless Address Autoconfiguration (SLAAC). It uses ICMPv6 over multicast instead of broadcast.

**Table 3.3: Important NDP message types.**

| ICMPv6 Type | Name | Function |
|---|---|---|
| 133 | Router Solicitation (RS) | Host requests a router to send an RA |
| 134 | Router Advertisement (RA) | Router announces prefix, gateway — exploited in Rogue RA |
| 135 | Neighbor Solicitation (NS) | Equivalent to IPv4 ARP Request |
| 136 | Neighbor Advertisement (NA) | Equivalent to IPv4 ARP Reply |

SLAAC lets a host auto-configure its IPv6 address and default gateway from a received RA without DHCPv6. This is the weakness exploited in Rogue RA.

### 3.2.4 Access Layer Attack Vectors

**3.2.4.1 MAC Flooding.** Floods the switch CAM table by continuously sending frames with random, forged source MACs. When the CAM table reaches capacity (8,192 entries on the Catalyst 2960), the switch cannot learn new MACs and enters fail-open behavior — unknown unicast frames are flooded to all ports in the VLAN, letting the attacker receive other hosts' traffic in the same broadcast domain. The common tool is `macof` (dsniff), which can send thousands of frames/second with random source MACs.

**3.2.4.2 ARP Poisoning / MITM.** Exploits ARP's lack of authentication to poison hosts' ARP caches and redirect traffic through the attacker. The attacker periodically sends Gratuitous ARP to maintain the poisoning. When the victim's cache changes, the gateway MAC points to the attacker, so all traffic between victim and gateway passes through the attacker. This project specifically analyzes **MITM Stealth** — maintaining the MITM while minimizing detectability by the victim (detailed in Section 4.4).

**3.2.4.3 Rogue DHCP Server.** Deploys an unauthorized DHCP server that responds to client DHCP Discover before the legitimate server. The client accepts the first Offer and confirms with a Request. If the rogue responds first, the client receives configuration from the attacker — including a forged default gateway and DNS — routing all traffic through the attacker. It is among the most dangerous vectors because it affects every newly connected host and every lease renewal. Common tools: Yersinia or dnsmasq on Kali.

**3.2.4.4 STP Manipulation.** Exploits the Root Bridge election. The attacker sends BPDUs with a lower Bridge Priority than the current Root, forcing reconvergence and seizing the Root Bridge role. As Root, the attacker can redirect Layer 2 traffic. The attacker can also send continuous BPDUs to cause repeated reconvergence, destabilizing the entire Layer 2 domain.

**3.2.4.5 Rogue Router Advertisement (IPv6).** Exploits SLAAC. The attacker sends a forged ICMPv6 Type 134 (RA) with malicious gateway and prefix. Dual-stack hosts auto-configure their IPv6 address and gateway from it, routing IPv6 traffic through the attacker. It is dangerous because it operates entirely in IPv6 — bypassing deployed IPv4 protections. In many enterprises that have not formally deployed IPv6 but whose OSes still run dual-stack, this risk is often ignored.

**3.2.4.6 MAC Address Cloning.** The attacker copies the MAC of a legitimate, authenticated device to bypass MAC-based controls such as Port Security or MAB. This is an important residual risk — even after a successful 802.1X authentication, the attacker can clone a legitimate MAC without additional protection layers.

**Table 3.4: Summary of Access Layer attack vectors.**

| Attack vector | Protocol exploited | Impact | Defense |
|---|---|---|---|
| MAC Flooding | Ethernet / CAM table | VLAN-wide traffic interception | Port Security, Storm Control |
| ARP Poisoning / MITM | ARP (RFC 826) | Traffic interception, credential theft | Dynamic ARP Inspection (DAI) |
| Rogue DHCP Server | DHCP (RFC 2131) | Redirect traffic, DNS spoofing | DHCP Snooping |
| IP Spoofing | IPv4 (DHCP binding) | Bypass ACL, hide identity | IP Source Guard (IPSG) |
| STP Manipulation | STP (IEEE 802.1D) | Traffic redirect, instability | BPDU Guard, Root Guard |
| Rogue Router Advertisement | NDP/ICMPv6 (RFC 4861) | IPv6 MITM, bypass IPv4 security | RA Guard |
| MAC Address Cloning | Ethernet | Bypass Port Security, MAB | 802.1X + DAI (defense-in-depth) |

### 3.2.5 AAA Framework, 802.1X and MAB

**3.2.5.1 AAA Framework.** AAA (Authentication, Authorization, Accounting) controls network access across three dimensions: verify identity, determine post-authentication permissions, and record activity. In enterprises, AAA is usually implemented with RADIUS (RFC 2865) between the Network Access Device (switch) and the Authentication Server (FreeRADIUS).

**3.2.5.2 IEEE 802.1X.** 802.1X (IEEE 802.1X-2010) is a port-based network access control standard defining three components: Supplicant (the endpoint to authenticate), Authenticator (the switch, acting as intermediary), and Authentication Server (RADIUS, deciding Accept/Reject). Before successful authentication, the port is Unauthorized and only passes EAPOL traffic; after success, it becomes Authorized and passes normal traffic. The mechanism requires hardware-level processing for low latency and accuracy, hence the use of physical Catalyst 2960 hardware.

**3.2.5.3 MAC Authentication Bypass (MAB).** MAB is a fallback for devices that do not support an 802.1X supplicant — printers, IP phones, IP cameras. Instead of a credential, the switch uses the device's MAC as the username and password sent to RADIUS. MAB's weakness is that it can be bypassed via MAC cloning — an important residual risk analyzed in Section 5.

### 3.2.6 First-Hop Security IPv4

**3.2.6.1 DHCP Snooping.** A Layer 2 mechanism acting as a firewall between DHCP client and server to prevent Rogue DHCP. It classifies ports as Trusted (to the legitimate server or uplink — all DHCP messages allowed) and Untrusted (endpoints — only DHCP Discover/Request allowed; Offer/ACK blocked). Its most important output is the **DHCP Snooping Binding Table**, mapping MAC, IP, VLAN, and port for each legitimate client — the foundation for DAI and IPSG.

**3.2.6.2 Dynamic ARP Inspection (DAI).** Prevents ARP Poisoning by validating every ARP packet on untrusted ports against the DHCP Snooping Binding Table. If the IP-MAC does not match, the packet is dropped and logged. DAI can be strengthened with Additional Validation: checking src/dst MAC in the Ethernet header against the ARP payload.

**3.2.6.3 IP Source Guard (IPSG).** Prevents IP spoofing by filtering IP traffic on untrusted ports against the binding table. Only traffic whose IP-MAC pair matches the binding is allowed. IPSG creates an implicit ACL per untrusted port — especially effective against source-IP-spoofing bypass techniques.

### 3.2.7 First-Hop Security IPv6

**3.2.7.1 RA Guard.** RA Guard (RFC 6105) protects against Rogue Router Advertisements in IPv6. Like DHCP Snooping, it classifies ports as router (trusted — may send RA) and host (untrusted — RA dropped). Deploying it depends on the hardware resource configuration, specifically the SDM template. On devices like the Catalyst 2960, IPv6 protections such as RA Guard are only available when the device is configured with a suitable SDM template — showing that security depends not only on device capability but on the actual deployment configuration.

**3.2.7.2 DHCPv6 Guard.** Operates like DHCP Snooping but for DHCPv6, dropping all DHCPv6 server messages (Advertise, Reply) from ports not configured as trusted. In a dual-stack environment, deploying both DHCP Snooping (IPv4) and DHCPv6 Guard (IPv6) is necessary to ensure configuration integrity for both protocols.

### 3.2.8 Layer 2 Stability Protection

**3.2.8.1 Storm Control.** Supports two actions when traffic exceeds a threshold: shutdown (err-disable, full cutoff) and trap (drop excess traffic but keep the port up, send a Syslog alert). Note: only one action applies to all traffic types on a port — you cannot set shutdown for broadcast and trap for unicast separately. The action choice depends on traffic characteristics and is analyzed in Section 4.

**3.2.8.2 BPDU Guard and Root Guard.** BPDU Guard applies on PortFast-enabled ports (endpoint connections). Both protect the STP topology from manipulation. If an attacker sends a superior BPDU, the topology can change.

**Table 3.5: BPDU Guard vs. Root Guard.**

| Mechanism | Applied on | Trigger | Action |
|---|---|---|---|
| BPDU Guard | PortFast (access) port | Receives any BPDU | Err-disable (shutdown) port |
| Root Guard | Port to a downstream switch | Receives a superior BPDU | Root-inconsistent (block, no shutdown) |

**3.2.8.3 Port Isolation (switchport protected).** Blocks all direct Layer 2 communication between protected ports in the same VLAN — including unicast, multicast, and broadcast. Traffic between protected ports must traverse the router (hairpinning) to be controlled at Layer 3. Suitable for VLANs of devices that do not need east-west communication (IoT, cameras, printers), but unsuitable for user VLANs because of the router bottleneck under heavy internal traffic.

**3.2.8.4 Control Plane Policing (CoPP).** On newer switches such as the Catalyst 2960-X, 2960-XR, and 2960-CX, administrators can configure CoPP via `mls qos copp protocol` to rate-limit each type of control-plane traffic sent to the CPU. The original Catalyst 2960 (2960-24TT-L, IOS 15.0(2)SE11) does not support this — confirmed because `mls qos` on the device shows only basic QoS options (aggregate-policer, map, queue-set, rewrite, srr-queue) and no `copp` option. Consequently, Storm Control is the only mechanism capable of mitigating traffic floods at the Access Layer on this platform.

### 3.2.9 Defense-in-Depth at the Access Layer

Defense-in-Depth (DiD) deploys multiple independent, mutually supporting control layers, so that when one is bypassed the others still detect and limit the attack. At the Access Layer, the DiD model is organized into the following control layers:

**Table 3.6: Defense-in-Depth model at the Access Layer.**

| Layer | Mechanism | Function — attack vector mitigated |
|---|---|---|
| 1. Identity | 802.1X / MAB | Control which device may connect — unauthorized device access |
| 2. MAC | Port Security | Limit rogue devices at the access port — MAC flooding, basic MAC cloning |
| 3. IPv4 FHS | DHCP Snooping + DAI + IPSG | Protect IP-MAC binding, prevent IPv4 spoofing — Rogue DHCP, ARP Poisoning, IP Spoofing |
| 4. IPv6 FHS | RA Guard + DHCPv6 Guard | Protect the IPv6 attack surface in dual-stack — Rogue RA, Rogue DHCPv6 |
| 5. Stability | Storm Control + BPDU Guard | Protect Layer 2 stability — MAC flood, STP manipulation |
| 6. Monitoring | Syslog + LogAnalyzer | Early detection of anomalous behavior |
| 7. Isolation | Switchport protected | Prevent east-west attacks between devices in the same VLAN — neutralizes Rogue RA / DHCPv6 between protected ports |

When designing the model, beyond the stated dependencies, technical conflicts matter: **Cisco does not recommend enabling Port Security together with 802.1X** — since 802.1X already controls MAC per port, Port Security becomes redundant and can conflict in some cases. In real SME infrastructure, flexibly choosing control layers based on risk, device capability, and budget is analyzed in detail in Sections 4 and 5.

## 3.3 The Hypothetical Enterprise Model and Experimental Environment

### 3.3.1 Organization Scale and Structure

The project builds a hypothetical network for a Vietnamese SME (100–200 employees) — a high-risk group due to limited security budgets and frequent use of legacy equipment (such as the Catalyst 2960). The infrastructure is divided into zones: VLAN 10 (internal users, where ARP Poisoning and MAC Flooding risks lurk) and the Server Side (sensitive data storage and management services).

### 3.3.2 Threat Surface by Organizational Structure

With this structure, the Access Layer threat surface is clearly differentiated: the user zone (VLAN 10) and public ports face unauthorized access, ARP Poisoning, and MAC Flooding directly, while the entire dual-stack infrastructure is exposed to Rogue RA. Rather than repeat them, all location-based risks are mapped directly to each defense layer (802.1X, DHCP Snooping, DAI, RA Guard) per the Defense-in-Depth architecture summarized in Table 3.6 (Section 3.2.9).

## 3.4 Devices and Software

Detailed device, software, and tool tables, the topology, and the baseline configuration are in the next section: **[04-lab-design-and-topology.md](04-lab-design-and-topology.md)**.
