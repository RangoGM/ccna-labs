# 2. Literature Review

## 2.1 Domestic Research (Vietnam)

A survey of Vietnamese university theses, graduation projects, and domestic technical sources shows that work on internal network security has mostly followed two directions.

The **first direction** introduces and configures individual security mechanisms in isolation. Many graduation projects and theses cover 802.1X in the context of WLAN security, or deploy DHCP Snooping and Dynamic ARP Inspection as standalone switch features. Popular technical materials in the Vietnamese networking community — telecom-academy curricula, CCNA training materials, and online LAN Security courses — all present Port Security, DHCP Snooping, and DAI as separate configuration steps, without analyzing the interdependencies between mechanisms (for example, that DHCP Snooping is the foundation for most real-world deployments of DAI and IPSG) or evaluating effectiveness under controlled attack conditions.

The **second direction** describes the principles of Layer 2 attack techniques. Internship reports, discussion papers, and domestic technical materials present ARP Spoofing, MAC Flooding, and Rogue DHCP at the level of introducing attack tools (macof, arpspoof, Yersinia) and mention corresponding defenses. However, these works mostly stop at describing principles or practicing on purely virtual environments (Packet Tracer, GNS3), without validating on real hardware and without assessing resource impact (CPU, CAM table) when security mechanisms run simultaneously.

Notably, no domestic work has yet evaluated the entire chain of security mechanisms within a complete Defense-in-Depth model on real hardware, identified residual risk when layers interact, or simultaneously analyzed both IPv4 and IPv6 attack vectors on the legacy devices common in Vietnamese SMEs. IPv6 security at the Access Layer — especially the Rogue Router Advertisement risk in a dual-stack environment — is entirely absent from domestic scientific publications.

## 2.2 International Research

Access Layer protections have been widely studied and deployed. Cisco Systems (2020) published guidance for deploying Port Security, DHCP Snooping, Dynamic ARP Inspection (DAI), and IP Source Guard (IPSG). However, that material is mainly configuration guidance, without experimental evaluation under realistic attack scenarios.

Penetration-testing literature, notably Rafay Baloch (2017), analyzes Layer 2 attack techniques such as ARP Poisoning, DHCP Starvation, and MAC Flooding in detail. These works, however, focus on the attack side and do not evaluate the effectiveness of defenses deployed in combination.

Some academic studies have evaluated mechanisms such as Dynamic ARP Inspection in simulated environments. While they show effectiveness against ARP Spoofing, they typically consider one mechanism in isolation, do not evaluate the case where multiple mechanisms operate simultaneously, and do not analyze advanced techniques such as MITM stealth.

Research on defense-in-depth in enterprise LANs emphasizes combining multiple security layers. Most of it, however, is carried out in simulated environments and has not been validated on physical hardware.

For IPv6, the IETF proposed the RA Guard mechanism in RFC 6105 to counter Rogue Router Advertisements. This mechanism has limitations on legacy devices, leaving residual security risks.

Beyond preventive mechanisms, some studies emphasize the role of monitoring and log-analysis systems in detecting and analyzing security incidents. These studies, however, are usually separated from Access Layer protections and are not integrated into an overall evaluation model.

## 2.3 Identified Gaps and Approach

From the above, several main gaps can be identified:

1. Research mostly focuses on individual mechanisms, without evaluating overall effectiveness when deployed as defense-in-depth.
2. Most research is done in simulated environments, not reflecting real factors such as hardware limits and device behavior.
3. Advanced attack techniques such as MITM stealth are not fully analyzed from the angle of evading client-side detection.
4. The difference between ordinary users and administrators in detecting attacks is not adequately considered.
5. Security issues in dual-stack IPv4/IPv6 environments, especially on legacy devices, are not comprehensively evaluated.
6. The role of centralized monitoring in detecting and supporting attack analysis is not fully integrated with Access Layer protections.
7. No research has experimentally demonstrated *why* DAI and IPSG must be deployed together — Cisco and current sources only note a “powerful combination” without evidence of the vulnerability when deployed alone.

These gaps point to the need for experimental research evaluating the effectiveness of security mechanisms under real operating conditions.

**Table 2.1: Related work and the gaps this project addresses.**

| Study / Source | Mechanisms covered | Limitation | How this project addresses it |
|---|---|---|---|
| Cisco Hardening Guide (2020) | Port Security, DHCP Snooping, DAI, IPSG | Configuration guidance, no experimental attack evaluation | Validate with real, controlled attacks |
| R. Baloch (2017) | ARP Poisoning, DHCP Starvation, MAC Flooding | Focus on attack, no defense evaluation | Combine attack and defense in one experiment |
| RFC 6105 / Convery & Miller (2004) | RA Guard, IPv6 FHS | Notes hardware limits, no experiment | Validate hardware limits, identify residual risk |
| Studies on DAI in simulation | Dynamic ARP Inspection | Virtual environment, one mechanism, no CPU measurement | Measure CPU, MITM Stealth, multi-layer combination |
| Studies on multi-layer LAN security | Layered Security Framework | Fully virtual, no IPv6 | Hybrid lab, real hardware validation |
| Current Vietnamese studies | 802.1X or DHCP Snooping in isolation | No integration, no hybrid, no IPv6 | 8-phase Defense-in-Depth model |

## 2.4 Contributions

This project makes the following main contributions:

1. **Builds and evaluates a multi-layer Access Layer security model** combining Port Security, DHCP Snooping, DAI, IPSG, Storm Control, RA Guard, BPDU Guard, and 802.1X/MAB within a unified Defense-in-Depth architecture, validated on physical Cisco Catalyst 2960 hardware.
2. **Analyzes and experiments with MITM Stealth**, showing that every client-side detection method (`arp -a`, TTL, traceroute) is neutralized — only DAI at the switch level is effective.
3. **Provides experimental evidence for why DAI and IPSG must be deployed together:** DAI controls only ARP, and a forged raw IP packet bypasses DAI completely — something Cisco and current sources only recommend without proving.
4. **Discovers interaction between defense layers:** IPSG/Port Security not only block forged IP/MAC but also indirectly protect the STP topology by discarding BPDUs from an invalid MAC before they reach the control plane. BPDU Guard then only needs to handle BPDUs from a legitimate MAC — err-disabling immediately. This is the strongest evidence for the effectiveness of defense-in-depth.
5. **Identifies the irreplaceable role of Storm Control** on the Catalyst 2960, since the platform does not support CoPP — confirmed directly on the device.
6. **Evaluates the impact of the SDM template on IPv6 security:** the default SDM does not support RA Guard; after switching to dual-stack, RA Guard works correctly in every scenario including Extension-Header evasion. DHCPv6 Guard does not work at all due to an ASIC limitation — the single residual risk of the whole study.
7. **Proposes and validates a temporary mitigation** using switchport protected for the IoT/MAB VLAN to reduce the DHCPv6 risk the ASIC cannot cover — while analyzing the trade-off between security and internal performance.
