# Building and Evaluating a Layered Security Model at the Enterprise Network Access Layer on the Cisco Catalyst 2960

> An 8-phase, hardware-validated **Defense-in-Depth** research project on a physical Cisco Catalyst 2960 access switch — attack, defend, measure, and analyze residual risk in a dual-stack IPv4/IPv6 environment.

**Author:** Dat Tran Gia  
**Platform:** Cisco Catalyst 2960-24TT-L (IOS 15.0(2)SE11, LAN Base), Cisco 2811 Router, Ubuntu Server (bare-metal), Kali Linux (VMware)  
**Scope:** First-Hop Security and Layer 2 controls at the enterprise Access Layer for SMEs

---

## Overview

Most enterprise security investment is spent at the perimeter (firewall, IDS/IPS), under the implicit assumption that everything inside the LAN is trustworthy. That assumption breaks down at the **Access Layer**, where foundational protocols (ARP, DHCP, STP, IPv6 NDP) trust each other by default. Any attacker with **Layer 2 adjacency** — whether a malicious insider or someone with unauthorized physical access — can exploit these protocols directly without ever crossing a perimeter control.

This project builds, deploys, and measures a complete Defense-in-Depth model at the Access Layer on **real hardware**, across **8 sequential phases** that alternate between offense (Kali Linux) and defense (Cisco IOS), recording CPU impact, log fidelity, and binding-table state at every step. The central thesis: **no single control is sufficient** — the layers must reinforce one another, and where the hardware cannot cover a vector, the residual risk must be made explicit.

## The 8-Layer Model

| # | Layer | Mechanism | Primary attack vector mitigated |
|---|-------|-----------|---------------------------------|
| 1 | Identity | 802.1X / MAB | Unauthorized device access |
| 2 | MAC | Port Security | MAC flooding, basic MAC cloning |
| 3 | IPv4 FHS | DHCP Snooping + DAI + IPSG | Rogue DHCP, ARP poisoning, IP spoofing |
| 4 | IPv6 FHS | RA Guard + DHCPv6 Guard | Rogue RA, rogue DHCPv6 |
| 5 | Stability | Storm Control + BPDU Guard | Broadcast storm, STP manipulation |
| 6 | Monitoring | Syslog + LogAnalyzer | Early detection of anomalies |
| 7 | Isolation | Switchport protected | East-west attacks within a VLAN |

## Headline Findings

- **DAI alone is bypassable.** A raw spoofed-IP packet (Scapy) sails past DAI entirely — router CPU hit **99%** and the victim lost **73%** of its packets. Adding **IPSG** blocked it completely (victim back to **100%** delivery). This is the experimental proof for *why* Cisco recommends deploying DAI **and** IPSG together.
- **MITM Stealth defeats every client-side check.** With a spoofed MAC, TTL rewriting, and traceroute suppression, none of `arp -a`, ping TTL, or `tracert` reveal the attacker. **Only DAI at the switch level** stops it.
- **Log fidelity differs dramatically by mechanism.** For an identical 120 violations at the same rate: **DAI** preserved **100%** of logs (log-buffer aggregation), **Port Security Restrict** lost **88%**, and **RA Guard** lost **50%**.
- **The Catalyst 2960 has no CoPP.** Storm Control is the *only* flood-mitigation mechanism available on this platform.
- **Defense layers interact.** IPSG / Port Security drop BPDUs sourced from a spoofed MAC *before* they reach the STP process; BPDU Guard then only has to handle BPDUs from a legitimate MAC — err-disabling instantly.
- **One residual risk remains: DHCPv6 Guard does not work.** The 2960 ASIC cannot parse IPv6 at L3/L4, so rogue DHCPv6 succeeds with **no drop and no log** — a silent failure. RA Guard, by contrast, works correctly in every scenario (including Extension-Header evasion) once the SDM template is switched to dual-stack.

## Repository Layout

```
26-Access-Layer-Defense-in-Depth-(Research-Paper)/
├── README.md                         ← you are here
└── docs/
    ├── 00-abstract.md
    ├── 01-introduction.md
    ├── 02-literature-review.md
    ├── 03-theory-and-methodology.md
    ├── 04-lab-design-and-topology.md
    ├── 05-phase0-baseline.md
    ├── 06-phase1-port-security-and-storm-control.md
    ├── 07-phase2-rogue-dhcp-and-snooping.md
    ├── 08-phase3-arp-poisoning-mitm-and-dai.md
    ├── 09-phase4-ip-spoofing-and-ipsg.md
    ├── 10-phase5-ipv6-ra-guard-and-dhcpv6.md
    ├── 11-phase6-stp-bpdu-guard-and-root-guard.md
    ├── 12-phase7-8021x-and-mab.md
    ├── 13-phase8-centralized-monitoring.md
    ├── 14-conclusion-and-recommendations.md
    └── 15-references.md
```

Start at [docs/00-abstract.md](docs/00-abstract.md), or jump straight to a phase.

## A Note on Sanitization

This is a public, portfolio-facing version of the original research paper. To make it safe to publish, the following were intentionally redacted or genericized while **all technical substance, measurements, and RFC1918 lab addressing were preserved**:

- Shared secrets and credentials (e.g. the RADIUS key, test user accounts) are replaced with placeholders such as `<RADIUS_SHARED_SECRET>`.
- Internal hostnames/domains were swapped for `*.corp.local` equivalents.
- Real device hardware MAC addresses are masked to their last octets (e.g. `001f.6c95.xxxx`). The documented attacker placeholder MAC `aa:bb:cc:11:22:33` is retained because it is fictitious by design.

Figure callouts from the original (e.g. *"Figure 4.5"*) are kept as references to the screenshots/diagrams in the source document; the images themselves are not included in this text-only version.

---

*Translated from the original Vietnamese research report and prepared for public review.*
