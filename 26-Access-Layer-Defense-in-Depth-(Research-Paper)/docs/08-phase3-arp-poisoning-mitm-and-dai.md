# Phase 3: ARP Poisoning, MITM Stealth, and Dynamic ARP Inspection

Phase 3 tests attack escalation after the attacker has a foothold. The goal is to intercept all traffic between Victim and gateway — both passive (sniff credentials) and active (modify files the Victim downloads) — without being detected. It is split into two stages: (1) MITM Native to establish a baseline, and (2) MITM Stealth to remove all client-side detection signs.

## 4.4.1 MITM Native — Baseline

The attacker scans the internal network (e.g. `net.probe` in bettercap) to identify live hosts (as noted in Section 3.2.2.2, Table 3.2). This generates many ARP packets but is not detected or blocked in an unprotected environment.

*(Figure 4.28: Victim table after the internal network scan.)*

Kali then uses bettercap for basic ARP Poisoning: continuously sending Gratuitous ARP to the Victim, declaring the gateway (192.168.10.1) MAC to be Kali's `aa:bb:cc:11:22:33`. IP forwarding is enabled so traffic still reaches the real destination and the Victim does not lose connectivity.

*(Figure 4.29: ARP table before the attack — legitimate gateway IP-MAC mapping.)* *(Figure 4.30: Ping before the attack — stable TTL (255), direct connection, no interference.)* *(Figure 4.31: Victim ARP table after the ARP spoof.)*

The gateway 192.168.10.1 is mapped to Kali's `aa:bb:cc:11:22:33` — obvious if the Victim already knows the router's legitimate MAC.

*(Figure 4.32: Ping from host to gateway after the ARP spoof.)* TTL drops from 255 to 254, showing the packet traversed one extra intermediary — the attacker forwarding traffic between host and gateway.

*(Figure 4.33: `tracert` from host to gateway after the ARP spoof.)* *(Figure 4.34: Wireshark on Kali captures an HTTP POST containing the Victim's login credentials.)* The credentials are sent in clear text in the HTTP POST and trivially captured. The `Host: portal.corp.local` field shows the Victim accessing the internal system and confirms the traffic passed through Kali.

**Takeaway:** MITM Native lets the attacker intercept and forward traffic successfully. However, it is detectable by ordinary checks — the observed TTL at the Victim drops (e.g. 254 instead of 255), revealing an intermediary. To address this, MITM Stealth adjusts Layer 3 behavior by preserving TTL and limiting ICMP Time Exceeded responses, making ping and tracert harder to use for detection.

These techniques only reduce client-side detectability. At the admin level, the attacker can still be detected via ARP inspection (multiple IPs mapping to one MAC), abnormal ARP traffic analysis, or mechanisms like DHCP Snooping and DAI. So MITM Stealth increases concealment from ordinary checks but cannot fully avoid detection in a monitored network.

## 4.4.2 MITM Stealth — Exploiting the Perception Blind Spot

From the Native result, the core weakness is the changed IP-MAC mapping, which can be detected if inspected. In practice, ordinary users rarely know or verify the gateway's MAC. This creates a “perception blind spot” that lets the attacker sustain the attack without raising user suspicion.

Kali keeps the MAC `aa:bb:cc:11:22:33` (already learned by Port Security, cannot change) and the dynamic IP from the router (192.168.10.x). Kali sends ARP Replies declaring gateway 192.168.10.1 = `aa:bb:cc:11:22:33` — the Victim sees this as correct in `arp -a` with no basis to tell a forged MAC from the router's real one.

**On TTL:** the experiment confirms TTL decreases by 1 when traffic passes through the attacker — normal behavior, since every intermediary decrements TTL by 1 to prevent infinite loops. However, the TTL can be re-adjusted before the packet leaves the attacker, so the Victim receives a TTL equal to the original state. TTL-based detection therefore becomes difficult, especially where the network topology is not widely known.

**On tracert:** when the Victim runs `tracert`, the attacker appears as an intermediate hop exposing its IP, because tracert relies on incrementing TTL and intermediaries responding when TTL expires. However, the attacker can limit detectability by not responding to ICMP Time Exceeded, so tracert does not show all intermediate hops. The path may appear broken (e.g. `*`), making it hard to pinpoint the attacker.

This shows that simple end-user observations are insufficient to detect sophisticated MITM, and relying entirely on route-tracing tools may not reflect the true network state.

*(Figure 4.35: Ping from host to gateway after TTL adjustment.)* *(Figure 4.36: tracert from host to gateway after tracert adjustment.)*

## 4.4.3 Active Attack — HTTP Content Injection

Beyond passive collection, MITM Stealth lets the attacker directly modify HTTP content. Kali uses bettercap's HTTP proxy module to intercept the Victim's file download and modify the content before delivery.

Scenario: the Victim visits `portal.corp.local` and downloads an internal document (e.g. a configuration or password file). The attacker intercepts the HTTP response and replaces the file content before the Victim receives it.

*(Figure 4.37: Victim downloads the file before the attacker modifies it.)* *(Figure 4.38: Victim downloads the file but the content was modified in transit — the connection looks normal; only opening the file reveals it.)* *(Figure 4.39: `show process cpu history`.)* CPU during the attack stays low (~12%), showing the resource cost of MITM is negligible.

**Takeaway:** HTTP Content Injection shows consequences beyond credential theft — the attacker can directly alter HTTP content the Victim downloads without legitimate access to the system. Modified content could include malware injection or file tampering, risking infection when opened. The attacker could also harvest session IDs and hijack the session, accessing the system as the Victim without re-authentication. This underscores the importance of deploying HTTPS for all internal web services, not just the login page.

## 4.4.4 Evaluating Port Security

*(Figure 4.40: Port Security detection capability.)*

**Takeaway:** In the experiment, Port Security violations mainly appear when the attacker *stops* ARP spoofing, due to the sudden MAC-mapping change. While the attack runs steadily, this sign is unclear — forcing the attacker to keep attacking to avoid instant detection, but increasing detectability over time. Restrict mode records only a small number of events (easy to miss); Shutdown blocks more thoroughly but affects connectivity. Overall, defense-in-depth was applied but is not yet tight enough to fully stop the attack — hence the need for stricter ARP-level control, namely **Dynamic ARP Inspection (DAI)**.

## 4.4.5 Deploying Dynamic ARP Inspection (DAI)

DAI is enabled on SW1 for VLAN 10, using the Phase 2 DHCP Snooping binding table for validation. Every ARP packet on an untrusted port whose IP-MAC does not match the binding table is dropped and logged immediately.

```
ip arp inspection vlan 10
ip arp inspection validate src-mac dst-mac ip            ! (1)
! --- Aggregate logs: print 5 lines per 60s --- (2)
ip arp inspection log-buffer entries 64
ip arp inspection log-buffer logs 5 interval 60
!
interface FastEthernet0/1
 ip arp inspection trust
! Fa0/2, Fa0/3 untrusted by default
```
*(Figure 4.41: DAI on SW1 with src-mac, dst-mac, and ip validation.)*

**(1)** Validation checks three independent layers: `src-mac` confirms the ARP-header source MAC matches the Ethernet-frame MAC; `dst-mac` confirms the destination MAC is not broadcast in an ARP reply; `ip` confirms source/destination IPs are not special addresses (0.0.0.0, broadcast). The three are complementary — missing any one lets the attacker craft an ARP packet passing the others.

**(2)** Unlike Port Security — where each violation produces a separate log, flooding Syslog — DAI integrates a **log-buffer**: it stores up to 64 events and writes at most 5 log lines every 60 seconds. This greatly reduces log volume, ensuring other important security events are not masked.

Kali re-runs the MITM after DAI is deployed. During host discovery, the attacker generates a large burst of ARP packets exceeding DAI's rate limit (default 15 packets/second), so the switch treats it as anomalous. Fa0/2 is put into err-disable even though Kali has a valid entry in the binding table from the previous phase.

*(Figure 4.42: LogAnalyzer records the attacker generating excess ARP beyond DAI's rate limit, err-disabling Fa0/2.)*

If the attacker reduces ARP frequency below the rate limit, DAI's rate-limit does not trigger and no err-disable occurs. Detection then depends mainly on IP-MAC validity checking against the DHCP Snooping binding table. DAI is especially effective against high-rate attacks; against carefully rate-tuned attacks, detection depends more on the accuracy of the validation mechanism.

```
Vlan    Forwarded   Dropped   DHCP Drops   ACL Drops
----    ---------   -------   ----------   ---------
  10          132       332          315           0

Vlan   DHCP Permits  ACL Permits  Probe Permits  Source MAC Failures
----   ------------  -----------  -------------  -------------------
  10             89            0              0                    0

Vlan   Dest MAC Failures   IP Validation Failures   Invalid Protocol Data
----   -----------------   ----------------------   ---------------------
  10                   0                       17                       0
```
*(Figure 4.43: DAI statistics record ARP packets dropped from Fa0/2. The Victim's ARP cache is unchanged — MITM fails entirely.)* *(Figure 4.44: SW1 CPU while DAI inspects and drops forged ARP.)* *(Figure 4.45: LogAnalyzer records a WARNING — forged ARP from MAC `aa:bb:cc:11:22:33` declaring IP 192.168.10.139 is dropped.)*

**Takeaway:** DAI stops MITM Stealth at the switch level, independent of the Victim's detection ability. DAI aggregates violations periodically rather than logging each frame, avoiding the log flood of Port Security Restrict (Section 4.2.2) — LogAnalyzer auto-highlights the IP in red, letting the admin localize the attacker on the interface. DAI strictly depends on the Phase 2 DHCP Snooping binding table — if deployed in the wrong order, DAI has no basis to validate and does not work.

## 4.4.6 Results Summary

Based on the experimental data from the physical switch and LogAnalyzer, the DAI layer was evaluated as follows.

**a. ARP filtering capability.** Per Figure 4.42, the system recorded detailed packet classification at Fa0/2:
- *Valid (Forwarded):* 132 ARP packets permitted, of which 89 (DHCP Permits) fully matched the binding table — legitimate traffic uninterrupted.
- *Blocked (Dropped):* 332 malicious packets removed, including 315 not in the binding table (DHCP Drops) and 17 malformed/IP-spoofed.

**b. Resource optimization via log compression.** To compare DAI's log aggregation against Port Security Restrict, a controlled experiment used Scapy to send the same **120 violations** at the same rate (0.5 s/frame) to Fa0/2 and measured logs actually received by the Syslog server.

**Table 4.2: Logging comparison — Port Security Restrict vs DAI.**

| Mechanism | Violations sent | Logs received by server | Lost | Loss rate |
|---|---|---|---|---|
| Port Security Restrict | 120 | 14 (individual) | 106 | 88% |
| DAI (log-buffer) | 120 | 8 lines (all 120) | 0 | 0% |

Port Security Restrict logs 1:1 — one line per violation. Even at just 2 frames/second, the switch could not export all logs in time, and the server lost 88% of monitoring data. DAI aggregates the 120 violations into 8 lines — the server receives a full 100% with no violations lost.

Combined with Phase 1 data (Section 4.2.2), where Restrict under 88,000+ violations exported only ~10–12 logs, the conclusion: Restrict loses logs uncontrollably under load, while DAI always records fully regardless of attack intensity.

Note that DAI stays flexible: for isolated violations (a device booting before getting DHCP, a static IP with no binding) it still logs 1:1 to help the admin trace the offending device. Aggregation only kicks in when violations exceed a threshold in a short time — exactly when the system most needs to protect its resources.

## 4.4.7 DAI's Limitation and a Higher-Layer Attack

Despite stopping ARP Spoofing effectively, DAI only controls the ARP protocol and does not inspect ordinary IP packets.

In the test, the attacker uses Scapy to send raw packets spoofing the Victim's source IP (192.168.10.210) directly to the router, with no ARP resolution step. DAI does not detect this — it is not an ARP packet — and the switch forwards it normally on the data plane with low CPU and no alert. The router, however, must process each packet in software — driving router CPU to **99%**.

*(Figure 4.46: Wireshark on the Victim records ICMP Reply (400,000+ packets) for requests the Victim never sent — confirming the forged packets from Kali were processed by the router.)* *(Figure 4.47: Router CPU peaks at 99% while the attacker continuously sends forged IP packets.)*

Direct consequence: the Victim pinging the gateway during the attack loses **73% of packets (73/100)** — a serious service disruption even though the switch operates normally. This finding came from a real lab observation: the router emitted unusual noise under CPU load, prompting inspection and confirmation of the overload.

This shows DAI protects at the ARP layer but leaves a gap at the IP layer — the attacker can spoof the source IP undetected while severely impacting the router's availability. Hence the need for **IP Source Guard (IPSG)** in the next phase to control source IP on the data plane, covering the gap DAI cannot.
