# Phase 5: IPv6 Security — RA Guard, DHCPv6, and Hardware Limits

Phases 1–4 comprehensively protect IPv4 traffic. However, most modern OSes (Windows 10/11, Linux, macOS) enable IPv6 by default — creating a parallel attack surface the entire IPv4 defense does not cover (analyzed in Section 1.5).

## 4.6.1 Rogue RA Attack — Before Changing the SDM Template

The default SDM template on the Catalyst 2960 (IOS 15.0(2)SE11, LAN Base) allocates TCAM resources only for IPv4. IPv6 security features such as RA Guard are unavailable in this mode.

Kali uses `atk6-fake_router6` to send a forged Router Advertisement with a malicious IPv6 prefix and gateway into VLAN 10. The Victim auto-configures its IPv6 address and default gateway from the received RA — instantly hijacked for IPv6 routing without any interaction.

*(Figure 4.57: Kali running `atk6-fake_router6` sending the Rogue RA and Kali's link-local address.)* *(Figure 4.58: Victim `ipconfig` showing the IPv6 address and default gateway from the Rogue RA.)*

As with IPv4, the Victim's IPv6 traffic flows through Kali. The switch generates no alert — DAI, DHCP Snooping, and IPSG all control only IPv4. All four deployed defense phases are completely bypassed via the IPv6 vector.

**Takeaway:** This is the most dangerous scenario in the study — the attacker bypasses the entire IPv4 defense without exploiting any configuration flaw. A single Router Advertisement hijacks the IPv6 traffic of every dual-stack device in the VLAN.

## 4.6.2 Changing the SDM Template and Deploying RA Guard

To enable IPv6 security, the SDM template must be switched to dual-stack — reallocating TCAM to support IPv4 and IPv6 simultaneously. This advanced step requires a device reload to apply the new resource allocation table.

```
sdm prefer dual-ipv4-and-ipv6 default
reload
```
*(Figure 4.59: Changing the SDM template to support dual-stack IPv4/IPv6.)*

```
The current template is "dual-ipv4-and-ipv6 default" template.
The selected template optimizes the resources in
the switch to support this level of features for
0 routed interfaces and 255 VLANs.
(output omitted)
```
*(Figure 4.60: `show sdm prefer` confirming the dual-stack template after reload.)*

After reload, RA Guard is deployed:

```
ipv6 nd raguard policy HOST
 device-role host
!
ipv6 nd raguard policy ROUTER
 device-role router
!
interface FastEthernet0/1
 ipv6 nd raguard attach-policy ROUTER
!
interface range FastEthernet0/2 - 3
 ipv6 nd raguard attach-policy HOST
!
vlan configuration 10,99
 ipv6 nd raguard attach-policy HOST
```
*(Figure 4.61: RA Guard on the access ports, allowing RA only from the Router.)*

Kali uses `atk6-fake_router6` to send a Rogue RA. RA Guard recognizes Router Advertisements from a `device-role host` port and blocks them immediately.

*(Figure 4.62: Victim `ipconfig` — no forged IPv6 received.)*

```
(output omitted)
Dropped messages on Fa0/2:
Feature      Protocol  Msg [Total dropped]
RA guard     NDP       RA [57]
             reason: Message unauthorized on port [57]
```
*(Figure 4.63: `show ipv6 snooping counters` — the hardware counter records 57 dropped RA packets.)* *(Figure 4.64: LogAnalyzer records a WARNING-level alert.)*

**Additional validation — Scapy with an Extension Header:** to evaluate defense against an advanced evasion technique (RFC 7113), Scapy sends RAs with an IPv6 Extension Header — with both a forged and a legitimate MAC.

Result: RA Guard still blocks successfully in every case. After switching the SDM template to dual-stack, the Catalyst 2960 ASIC can recognize and drop RA packets regardless of header structure.

**Hardware-log vs received-log cross-check:** sending 120 RAs at 0.5 s/packet, the hardware counter recorded all 120 dropped. However, LogAnalyzer received only 60 — a **50% loss**. Unlike DAI's log-buffer (aggregating many violations into one message, 0% loss), RA Guard logs 1:1 per violation but loses them in transit from switch to server — like Port Security Restrict (Phase 1). This finding is summarized in the log-comparison chart in Section 5.

**Takeaway:** RA Guard works correctly in every scenario after the SDM switch to dual-stack — including Extension-Header evasion. It is the only IPv6 security mechanism on the Catalyst 2960 that works as designed after the SDM change.

## 4.6.3 DHCPv6 Guard — Residual Risk and Access-Layer Control Limits

Alongside RA Guard, the study deploys `ipv6 snooping` with `security-level guard` to filter unauthorized DHCPv6 — because the Catalyst 2960 has no standalone `ipv6 dhcp guard` command:

```
ipv6 snooping policy HOST
 device-role node
 security-level guard
!
ipv6 snooping policy ROUTER
 trusted-port
!
interface range FastEthernet0/2 - 3
 ipv6 snooping attach-policy HOST
!
interface FastEthernet0/1
 ipv6 snooping attach-policy ROUTER
```
*(Figure 4.65: IPv6 Snooping configuration intended to replace DHCPv6 Guard.)*

Although the switch accepts the configuration, Kali runs `atk6-fake_dhcps6` and the Victim still receives a forged IPv6 and DNS.

*(Figure 4.66: Kali running `atk6-fake_dhcps6` to spoof a DHCPv6 server.)* *(Figure 4.67: Victim receives forged IPv6 and DNS servers from Kali.)*

```
Received messages on Fa0/2:
Protocol   Protocol message
NDP        RS[62] RA[57]
DHCPv6
(output omitted)
Dropped messages on Fa0/2:
Feature      Protocol  Msg [Total dropped]
RA guard     NDP       RA [57]
             reason: Message unauthorized on port [57]
```
*(Figure 4.68: `show ipv6 snooping counters interface fa0/2` — RA Guard drops 57, the DHCPv6 line is completely empty.)* *(Figure 4.69: `show process cpu history` — CPU stays ~15%; resources unaffected even though security was breached.)*

**Takeaways:**

1. **Technical cause:** the Catalyst 2960 ASIC cannot parse IPv6 packets at Layer 3/4. VACL only supports `match ip` (IPv4) and `match mac`, with no `match ipv6`. The switch forwards DHCPv6 directly in hardware without punting to the CPU for inspection — this is a hardware limit, not a configuration limit.
2. **“Silent failure” state:** no anomalous performance or log signs, CPU stays low, yet the security layer was actually breached. This is the single, most dangerous residual risk in the entire study.
3. **Storm Control protects bandwidth only, not deep security:** when `atk6-fake_dhcps6` floods above the 5% multicast threshold, Storm Control suppresses the traffic — but that protects only bandwidth and does not stop low-rate, below-threshold rogue DHCPv6.

## 4.6.4 Phase 5 Summary and Proposed Solutions

**Table 4.3: IPv6 security experiment results (Phase 5).**

| Scenario | SDM Template | Defense | Actual result |
|---|---|---|---|
| Rogue RA (default) | default | Unavailable | Success — Victim's IPv6 hijacked |
| Rogue RA (dual-stack) | dual-ipv4-and-ipv6 | RA Guard | Failure — RA dropped |
| Rogue RA (evasion) | dual-ipv4-and-ipv6 | RA Guard | Failure — RA still blocked |
| Rogue DHCPv6 | dual-ipv4-and-ipv6 | IPv6 Snooping Guard | Success — switch cannot filter |

**Takeaway:** RA Guard works correctly in every scenario after the SDM change — including Extension-Header evasion. DHCPv6 Guard is the single residual risk across all 8 phases: the switch is completely “blind” — no block, no log, no sign for the admin.

The study proposes two directions:

- **Direction 1 — Infrastructure upgrade:** replace with a newer switch (Catalyst 2960-X or 9200+) whose ASIC can parse IPv6 and supports real DHCPv6 Guard. Definitive but budget-dependent.
- **Direction 2 — Port Isolation (switchport protected):** absolute Layer 2 isolation between devices in the same segment, neutralizing rogue DHCPv6 and internal attacks. *Important note:* switchport protected generates **no log** when blocking traffic — unlike DAI, IPSG, and BPDU Guard, which provide detailed attack data for localization, Port Isolation works completely silently. The admin has no data for retrospective investigation if an incident occurs. It is also a performance trade-off: internal data flows normally handled by the ASIC at hardware speed are forced toward the gateway (traffic tromboning), increasing latency and creating a router bottleneck. The study therefore proposes Port Isolation only for IoT/MAB segments — where devices follow a client-server model — while keeping a more flexible mechanism for the user VLAN. The MAB combination is implemented in Phase 7.
