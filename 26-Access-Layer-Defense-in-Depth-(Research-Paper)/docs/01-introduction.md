# 1. Introduction

## 1.1 Motivation

For many years, enterprise network security has focused on external threats through firewalls, IDS/IPS, and perimeter controls. This model assumes that everything inside the internal network is trustworthy — an assumption that is increasingly out of step with reality.

At the **Access Layer** — where end devices connect directly to the switching infrastructure — many foundational protocols operate on an implicit-trust model. ARP does not authenticate the origin of a reply, DHCP has no mechanism to verify a server, and STP does not protect BPDUs against forgery. An attacker who already has Layer 2 adjacency, whether an internal employee or a physical intruder, can exploit these weaknesses directly without bypassing any upper-layer security.

Real-world consequences include: spoofing the gateway to intercept all internal traffic (Man-in-the-Middle); deploying a rogue DHCP server to redirect the traffic of every newly connected device (Rogue DHCP); manipulating Spanning Tree Protocol to control the Layer 2 topology (STP Manipulation); or exploiting IPv6 Router Advertisements to completely bypass an already-deployed IPv4 protection layer (Rogue RA).

Although many Access Layer security mechanisms have been proposed and deployed independently — Port Security, 802.1X, DHCP Snooping, Dynamic ARP Inspection — a combined evaluation of their effectiveness within a complete Defense-in-Depth model, especially in the context of legacy equipment and a dual-stack IPv4/IPv6 environment, remains under-studied in Vietnam.

This project aims to fill that gap — building, deploying, and evaluating a multi-layer security model at the Access Layer on real Cisco Catalyst hardware, scoped appropriately for small and medium-sized enterprises (SMEs) in Vietnam.

## 1.2 Research Objectives

Analyze the risks at the Access Layer; build and experimentally validate a Defense-in-Depth model; identify residual risks; and propose a feasible deployment plan for SMEs.

## 1.3 Subject and Scope

- **Subject:** First-Hop and Layer 2 security mechanisms (802.1X/MAB, Port Security, DHCP Snooping, DAI, IPSG, RA/DHCPv6 Guard, Storm Control) together with a monitoring system (Syslog).
- **Infrastructure:** Physical Cisco Catalyst 2960 hardware (IOS 15.0(2)SE11) for features that require an ASIC.
- **Scale:** A hypothetical enterprise network (~100–200 endpoints). Excludes Application-layer security, Wireless, and complex Cisco ISE architectures.

## 1.4 Threat Actor Profile

Because of the technical nature of Layer 2, almost all Access Layer attacks require the attacker to have a physical or logical presence in the same broadcast domain — i.e. **Layer 2 adjacency**. This is the prerequisite that distinguishes them from traditional remote attacks over the Internet. This study separates threat actors into two main groups.

*(Figure 1.1: The two threat-actor groups and the Layer 2 adjacency condition.)*

### 1.4.1 Insider Threat

This group includes actors who already have legitimate network access or physical presence in the organization: internal employees, contractors, interns, or maintenance technicians. They have been granted network connectivity — through 802.1X/MAB or simply by plugging into an open port — and therefore hold legitimate Layer 2 adjacency.

Insider Threat is the most dangerous category because it is hard to detect (initial behavior is indistinguishable from a normal user), it can sustain long-running attacks without raising suspicion, and the actor often knows the internal network structure. In the experimental model, the Kali attacker plays the role of an Insider Threat connected into the same VLAN 10 as the Client/Victim.

**Table 1.1: Insider Threat by technical sophistication.**

| Insider type | Technical level | Attack capability | Example scenario |
|---|---|---|---|
| Disgruntled employee | Low–Medium | Off-the-shelf tools (Kali Linux) | Download and run arpspoof, yersinia |
| Contractor / Technician | Medium–High | Understands the network; easily bypasses physical barriers | Brings a personal laptop and plugs directly into an IP phone or access point port |
| Targeted insider (APT) | High | Stealth techniques, maintains persistence | MITM stealth + long-term exfiltration |

### 1.4.2 Unauthorized Physical Access

This group includes actors with no legitimate access but the ability to reach the physical infrastructure: visitors, attackers posing as technicians, or anyone plugging a device into a network port in a public area (meeting rooms, reception, hallways). Once physically connected to the switch, this group has full Layer 2 adjacency and can perform all the same techniques as an Insider Threat.

This is precisely why **802.1X (port-based NAC) is the first and most important protection layer** in the Defense-in-Depth model — blocking unauthenticated devices right at the physical port, before any traffic is allowed through.

Every attack scenario in this study assumes the attacker already has Layer 2 adjacency. This is the prerequisite of every Layer 2 attack vector and the clear scope boundary of the project — it does not analyze remote attacks over the Internet or techniques that bypass the perimeter firewall.

## 1.5 The Challenge of a Dual-Stack IPv4/IPv6 Environment

Many modern operating systems — Windows 10/11, Linux, macOS — enable IPv6 by default, even when the enterprise has not formally deployed IPv6. In a dual-stack environment, IPv4 and IPv6 coexist on every endpoint, and both can be exploited independently.

The core challenge here is **asymmetric protection**: common mechanisms such as Dynamic ARP Inspection and DHCP Snooping mainly protect IPv4 traffic, whereas IPv6 uses entirely different mechanisms (NDP/ICMPv6 instead of ARP/DHCP). If IPv6 is not controlled in kind, an attacker can exploit Router Advertisement or Neighbor Discovery to bypass the entire deployed IPv4 protection.

**Table 1.2: Security asymmetry in a dual-stack environment.**

| Protocol | Attack mechanism | IPv4 defense | IPv6 status |
|---|---|---|---|
| IPv4 – ARP | ARP Poisoning / MITM | Dynamic ARP Inspection | Not applicable to IPv6 |
| IPv4 – DHCP | Rogue DHCP Server | DHCP Snooping | Not applicable to DHCPv6 |
| IPv6 – NDP/RA | Rogue Router Advertisement | None (DAI/DHCP Snooping do not protect) | Requires a separate RA Guard |
| IPv6 – DHCPv6 | Rogue DHCPv6 Server | None | Requires a separate DHCPv6 Guard |

The practical consequence: an enterprise that deploys complete IPv4 security but ignores IPv6 can still be fully attacked through the IPv6 vector with no warning. The attacker only needs to send a forged ICMPv6 Router Advertisement, and every dual-stack host in the broadcast domain will automatically reconfigure its IPv6 default gateway toward the attacker, while IPv4 traffic still flows correctly.

A second challenge is that **RA Guard is unavailable under the default SDM template** (IPv4-only), but can be enabled after switching to dual-stack (IPv4/IPv6). This is one of the project's most important findings — many administrators do not know about, or do not perform, this step. It is experimentally validated in Section 4 (Results and Discussion).

## 1.6 Rationale for Choosing Defense-in-Depth

Access Layer security mechanisms are usually deployed independently to address one specific threat at a time. However, no single mechanism can guarantee comprehensive safety. Each has a clear limit:

- **802.1X** controls device access but does not prevent protocol spoofing after a successful authentication.
- **DHCP Snooping and DAI** protect IPv4 but do not directly handle IPv6 mechanisms such as Neighbor Discovery or Router Advertisement.
- **Port Security** limits the number of MAC addresses but does not prevent MAC cloning by a device that is not 802.1X-authenticated — detected via MAC Move Notification when the same MAC appears on a different port.
- **Storm Control** protects Layer 2 stability but does not authenticate device identity.
- **RA Guard** protects IPv6 but has no effect on IPv4 attacks.

Each mechanism solves one specific attack vector, but the attacker only needs to find a single unprotected layer to exploit. The project therefore proposes and deploys a Defense-in-Depth model at the Access Layer: mechanisms organized into multiple, mutually supporting control layers, so that when one layer is bypassed or misconfigured, the remaining layers can still detect and limit the attack.

**Table 1.3: Mapping attack vectors to defense layers.**

| Attack vector | Layer bypassed if missing | Remaining backup layer |
|---|---|---|
| Unauthorized device connects | Layer 1: 802.1X/MAB | Layer 2: Port Security limits MACs |
| ARP Poisoning / MITM | Layer 3: DAI | Layer 6: Syslog detects ARP rate violation |
| Rogue DHCP Server | Layer 3: DHCP Snooping | Layer 6: Log DHCP offer from untrusted port |
| MAC cloning bypasses MAB | Layer 1: MAB | Layer 3: DAI detects IP-MAC binding mismatch |
| STP Manipulation | Layer 5: BPDU Guard | Layer 6: Syslog errdisable event |
| Rogue RA (IPv6) | Layer 4: RA Guard | **No backup — residual risk on the 2960** |
| Rogue DHCPv6 | Layer 4: DHCPv6 Guard (non-functional on 2960) | Layer 7: switchport protected (IoT VLAN only) — the user VLAN has no backup |

Table 1.3 also highlights the biggest blind spot in legacy infrastructure: IPv6 attacks (such as Rogue RA) have no backup layer at all on devices like the Catalyst 2960. This structurally hardware-bound residual risk is analyzed in depth in Section 5 (Conclusion and Recommendations).

The Defense-in-Depth approach is especially suited to network operations in Vietnamese SMEs — where legacy equipment is still common, security budgets are limited, and misconfiguration as well as unpatched devices remain frequent realities. The model lets an organization deploy each layer by priority and budget, instead of having to invest comprehensively from the outset.
