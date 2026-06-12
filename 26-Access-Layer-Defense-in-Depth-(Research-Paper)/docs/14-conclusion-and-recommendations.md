# 5. Conclusion and Recommendations

*(Figure 5.1: Peak-CPU summary across 7 phases, before vs after deploying protections.)*
*(Figure 5.2: Hardware-violation vs received-log summary across 3 phases — DAI vs Port Security Restrict vs RA Guard.)*

## 5.1 Conclusion

The study built, deployed, and evaluated a Defense-in-Depth model at the Access Layer on a Cisco Catalyst 2960 (IOS 15.0(2)SE11, LAN Base) across 8 controlled experimental phases. Key results:

**(1) Effectiveness of the multi-layer model.** Each mechanism solves one specific attack vector — no single mechanism covers the whole attack surface. Port Security blocks MAC Flooding, DHCP Snooping blocks Rogue DHCP, DAI blocks ARP Spoofing/MITM Stealth, IPSG blocks IP Spoofing, Storm Control blocks broadcast/multicast flood, RA Guard blocks Rogue RA, BPDU Guard protects the STP topology, and 802.1X/MAB controls identity-based access. Deployed fully, the layers reinforce each other: IPSG removes forged traffic before it reaches Port Security — completely fixing the CPU DoS that Port Security Restrict causes in isolation.

**(2) DAI and IPSG — two irreplaceable layers.** Experiments confirm DAI controls only ARP — a raw IP packet spoofing the source IP bypasses DAI entirely with no switch alert, router CPU 99%, Victim losing 73% of packets. After deploying IPSG, the same attack is blocked at the switch, router CPU stays low, and the Victim receives a full 100%. This is the experimental evidence explaining *why* Cisco recommends deploying both — something the documentation only states generally without proof.

**(3) MITM Stealth neutralizes client-side detection.** Using a forged MAC from the start, combined with TTL adjustment and traceroute hiding, every Victim-side check (`arp -a`, ping TTL, tracert) fails to detect the attack. DAI at the switch level is the only effective mechanism, independent of end-user detection ability.

**(4) DAI's log aggregation outperforms Port Security Restrict and RA Guard.** A controlled experiment with the same 120 violations at the same rate shows three completely different logging behaviors:

- **Port Security Restrict:** logs 1:1. The server received only 14/120 logs (88% loss). Under 88,000+ violations, almost all monitoring data is lost due to 99% CPU. Loss rises with attack speed.
- **RA Guard:** logs 1:1, like Port Security. The server received only 60/120 logs (50% loss). Loss also depends on attack speed — RA Guard cannot aggregate multiple violations into one message.
- **DAI:** aggregates all violations in a 5-second window into one message. 120 violations fully recorded in 8 lines (0% loss), CPU 13%. If the attack rate exceeds the rate limit, DAI err-disables the port — ending the attack decisively rather than letting the CPU overload.

DAI's rate-limited log aggregation reflects a superior design philosophy: prioritize hardware filtering, reduce CPU load, and preserve 100% of monitoring data. Port Security Restrict and RA Guard log 1:1 but do not protect the CPU — losing logs under flood, with loss proportional to attack intensity.

**(5) Hardware limits on legacy equipment.** The original Catalyst 2960 does not support CoPP in any form — confirmed by `mls qos` having no `copp` option. Storm Control is the only flood protection. The ASIC cannot parse IPv6 at L3/L4 — DHCPv6 Guard does not work even though the switch accepts the configuration. RA Guard works correctly in every scenario after the SDM switch to dual-stack, including Extension-Header evasion.

**(6) Defense layers interact and reinforce.** IPSG/Port Security not only block forged IP/MAC but also indirectly protect the STP topology: when the attacker sends a BPDU with a forged MAC, IPSG/Port Security drop the frame before the STP process — CPU stays low, Root Bridge unchanged. When the attacker uses a legitimate MAC without BPDU Guard, CPU spikes to ~85% and the topology changes. After deploying BPDU Guard, the same scenario is err-disabled immediately, CPU back to ~10%. This is the strongest evidence for Defense-in-Depth: each layer not only solves its own attack direction but also protects another layer.

**(7) Residual risks at the Access Layer:**

- **Unicast flood with a legitimate IP aimed at the router:** just 0.73% of bandwidth is enough to drive router CPU to 70% — Storm Control cannot set a threshold below the user's legitimate traffic (~2.91%). The definitive solution is CoPP directly on the router — outside the Access-Layer scope.
- **Rogue DHCPv6 — the single security residual risk:** the switch is completely “blind” — no block, no log, no admin sign. However, in real enterprise operation, an attacker cannot rely on DHCPv6 alone to reach their final objective: data exfiltration, persistence, and privilege escalation all traverse the IPv4 infrastructure — where all 7 defense layers are active. A single misstep when interacting with IPv4 (an anomalous ARP packet, a MAC not matching the binding, an unexpected DHCP Discover) immediately generates an alert. Detecting an attacker who uses DHCPv6 together with IPv4 exploitation is therefore a matter of time, not capability — unless the attacker is skilled enough to operate entirely in IPv6 without causing any IPv4 disturbance, a scenario far beyond the typical SME threat level.

## 5.2 Deployment Recommendations for SMEs

Based on the results, the study proposes a priority-ordered deployment for SMEs using the Catalyst 2960 or equivalent:

**Table 5.1: Recommended deployment order by priority for SMEs.**

| Order | Mechanism | Note |
|---|---|---|
| 1 | DHCP Snooping + limit rate + verify mac | Mandatory foundation for DAI and IPSG |
| 2 | DAI + log-buffer | Block MITM — the most dangerous threat to internal data |
| 3 | IPSG (`ip verify source port-security`) | Close the IP-spoofing gap DAI does not cover |
| 4 | Port Security Sticky + Storm Control shutdown (broadcast/multicast) | Block MAC Flooding and broadcast storm |
| 5 | BPDU Guard + Root Guard + disable CDP | Protect the STP topology and prevent info leakage |
| 6 | SDM dual-stack + RA Guard | IPv6 security — requires a switch reload |
| 7 | 802.1X (user VLAN) / MAB + switchport protected (IoT VLAN) | Identity-based access control |
| 8 | LogAnalyzer + VPN/SSH | Centralized monitoring and secure administration |

**Table 5.2: Recommended configuration parameters for SMEs.**

| Parameter | Recommended value | Note |
|---|---|---|
| Storm Control broadcast/multicast | 5%, action shutdown | Legitimate traffic usually below 1–2% |
| Storm Control unicast | Do not deploy | Defer to CoPP at Layer 3 |
| DHCP Snooping limit rate | 10–15 pps | Balance flood blocking vs normal DHCP |
| DAI rate limit | 15 pps, burst interval 1 | Default suits most environments |
| DAI log-buffer | 64–128 entries | 64 is enough for 100–200 devices |
| Port Security | Sticky, max 1 MAC, violation restrict | Restrict + IPSG — CPU safe |
| err-disable recovery | interval 300, enabled for psecure/storm-control/bpduguard/dhcp-rate-limit | SMEs lack 24/7 IT; ports self-recover after 5 minutes |

*Note:* Cisco does not recommend deploying Port Security together with 802.1X — since 802.1X already controls MAC per port, Port Security is redundant and can conflict. When deploying 802.1X, disable Port Security and switch IPSG to `ip verify source` (IP only, not MAC), as noted in Sections 4.5.1 and 4.8.

## 5.3 Limitations

1. The lab uses only one switch and one router — it does not fully reflect a multi-switch enterprise topology (Root Guard has no validation scenario).
2. The Catalyst 2960 is a legacy, end-of-sale platform — the hardware-limit results (CoPP, DHCPv6 Guard, bare-metal RA Guard) apply only to this specific platform.
3. Advanced IPv6 attack scenarios (NDP exhaustion, SLAAC abuse, redirect) are not evaluated.
4. System performance under all mechanisms deployed simultaneously on a real 100–200-device production network is not evaluated.
5. Grafana/Prometheus was deployed as proof-of-concept but not evaluated in detail within this project's scope.

## 5.4 Future Work

1. **CoPP on the router:** deploy Control Plane Policing directly on the router to solve the legitimate-IP unicast flood — a problem with no solution at the Access Layer.
2. **Hardware upgrade:** evaluate newer switches (Catalyst 2960-X, 9200) with DHCPv6 Guard, CoPP, and full IPv6 parsing.
3. **Modern monitoring:** complete the Grafana pipeline (Loki + Promtail + Prometheus + SNMP Exporter) to add performance monitoring and proactive alerting that LogAnalyzer lacks.
4. **Advanced IPv6 security:** research NDP exhaustion, redirect, and SLAAC abuse vectors and their defenses.
5. **Endpoint Detection & Response (EDR):** integrate endpoint monitoring to detect attacks the network device cannot see (rogue DHCPv6, RA bypass).
6. **Multi-switch model:** expand the lab to a Core-Distribution-Access topology to validate Root Guard, inter-switch DAI trust, and DHCP Snooping database synchronization.
