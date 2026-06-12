# Phase 8: Centralized Monitoring and Blind-Spot Detection

After deploying all defense layers from Phase 1 to Phase 7, Phase 8 evaluates the system's overall monitoring capability via LogAnalyzer and verifies whether the administrator has enough information to detect and respond to every attack scenario.

## 4.9.1 Multi-Vector Attack — Monitoring Validation

Kali simultaneously runs multiple validated attack scenarios from earlier phases: macof (MAC Flooding), yersinia (DHCP Starvation, BPDU), arpspoof (MITM), atk6-fake_router6 (Rogue RA), atk6-fake_dhcps6 (Rogue DHCPv6).

*(Figure 4.86: LogAnalyzer during the multi-vector attack — a sea of red logs from multiple defense mechanisms.)*

Each mechanism generates logs with its own severity and content, letting the administrator identify the exact attack type, targeted port, and time of occurrence.

## 4.9.2 The Blind Spot — DHCPv6 “Silence”

Among the flood of alerts from the IPv4 mechanisms, RA Guard, and BPDU Guard, the Rogue DHCPv6 operates completely undetected. The Victim's IPv6 is hijacked and DNS changed, yet LogAnalyzer records no alert line — there is no illustrating figure because there is no log to capture. This is the essence of “silent failure”: the strongest evidence is the complete absence of data.

**Takeaway:** centralized monitoring is only as strong as the data the network device provides. The Catalyst 2960 ASIC cannot parse DHCPv6 packets (confirmed in Phase 5, Section 4.6.3), so it generates no log — LogAnalyzer, even correctly configured, cannot detect what the switch never sees. This is the single, most dangerous residual risk in the entire study.

## 4.9.3 LogAnalyzer Limitations and Extensions

LogAnalyzer displays logs by severity (RFC 5424) with intuitive colors — well-suited to retrospective investigation and security-event detection. However, it cannot monitor device performance (CPU, bandwidth), does not support real-time charts, and lacks proactive alerting.

*(Figure 4.87: LogAnalyzer color coding by RFC 5424 severity.)*

The study additionally deployed **Grafana** (Loki + Promtail for logs, Prometheus + SNMP Exporter for performance) on the same Ubuntu Server as a modern monitoring complement to LogAnalyzer. Detailed deployment and evaluation are outside the Access-Layer scope and are proposed in the future work (Section 5).

## 4.9.4 Secure Remote Administration

The monitoring system is not exposed directly to the Internet. The administrator accesses LogAnalyzer and configures devices over a VPN combined with SSH tunneling — ensuring the management channel is encrypted end-to-end. Telnet is disabled on all devices. Even with Layer 2 adjacency, the attacker cannot sniff or interfere with the encrypted management traffic.

*(Figure 4.88: The administrator accesses LogAnalyzer remotely via VPN + SSH tunnel.)* Top-left: Router 2811 via SSH. Top-right: Ubuntu Server (rsyslog, FreeRADIUS, LogAnalyzer). Bottom-left: Switch 2960 via SSH jump from the router. Bottom-right: LogAnalyzer via port mapping 80→8080 to the admin machine. The entire management channel is encrypted — an attacker with Layer 2 adjacency cannot sniff or interfere.

## 4.9.5 Phase 8 Summary

**Table 4.6: Logs generated across attack scenarios.**

| Attack source | Log generated | Detected |
|---|---|---|
| macof (MAC Flooding) | Port Security violation | Yes |
| yersinia (DHCP Starvation) | DHCP Snooping limit rate | Yes |
| arpspoof (MITM) | DAI drop | Yes |
| Broadcast flood | Storm Control | Yes |
| BPDU (forged MAC) | IPSG/Port Security drop first | Yes — IPSG/Port Security log |
| BPDU (legitimate MAC) | BPDU Guard err-disable | Yes |
| Rogue RA | RA Guard drop | Yes |
| 802.1X failure | AUTHMGR / DOT1X | Yes |
| Rogue DHCPv6 | None | **No — the single residual risk** |
