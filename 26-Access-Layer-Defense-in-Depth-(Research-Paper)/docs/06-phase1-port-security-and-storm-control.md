# Phase 1: Port Security and Storm Control

Phase 1 deploys two Access Layer protections against MAC Flooding and broadcast storms: **Port Security** (limit valid MACs per port) and **Storm Control** (limit broadcast/multicast traffic rate). The experiment proceeds in four escalating stages: attack with no protection (baseline), Port Security Restrict mode, Shutdown mode, and the addition of Storm Control. Section 4.2.6 analyzes the control-plane protection limits of the Catalyst 2960 and the irreplaceable role of Storm Control.

## 4.2.1 Attack Stage — Baseline (no protection)

Kali uses `macof` to generate thousands of Ethernet frames per second with random source MACs, flooding SW1's CAM table.

*(Figure 4.4: Kali running `macof`, continuously generating random-MAC frames toward SW1.)*

```
MAC Address Table
------------------------------------------
Vlan     Mac Address        Type     Ports
----     -----------       -------   -----
  99     001f.6c95.xxxx    DYNAMIC   Fa0/1
  99     3860.7793.xxxx    DYNAMIC   Fa0/9
  10     001f.6c95.xxxx    DYNAMIC   Fa0/1
  10     000c.2976.xxxx    DYNAMIC   Fa0/2
  10     9a60.af48.c5cd    DYNAMIC   Fa0/2
  10     7879.3b2f.6abc    DYNAMIC   Fa0/2
 --More--
Total Mac Addresses for this criterion: 8144
```
*(Figure 4.5: `show process cpu history` and the switch CAM table during the attack.)*

Observation: CPU spikes to **99–100% for 25 seconds**. The CAM table floods to **8,144 entries** in VLAN 10. The two legitimate VLAN 99 entries (router on Fa0/1 and Ubuntu Server on Fa0/9) remain, being in a separate broadcast domain.

Results:

- CAM table floods to 8,144 entries; the switch enters unicast-flooding mode across VLAN 10. If sustained, legitimate MACs age out, enabling the attacker to sniff all traffic.
- VLAN 99 is unaffected — VLAN segmentation limits the blast radius to a single broadcast domain.
- **No Syslog is generated.** The administrator can only detect the attack by an indirect sign: the 99–100% CPU spike.

**Takeaway:** MAC Flooding produces no Syslog — a CPU spike is the only sign. Without Port Security, the system is completely blind.

## 4.2.2 Port Security — Restrict Mode

Fa0/2 (Kali) is configured with Port Security `violation restrict`, max 2 MACs, learning 2 trusted MACs via Sticky MAC. Kali re-runs `macof`; every frame with a source MAC outside the 2 trusted addresses is dropped, and the violation counter rises to **88,248** events.

```
Port Security                : Enabled
Port Status                  : Secure-up
Violation Mode               : Restrict
(output omitted)
Maximum MAC Addresses        : 2
Total MAC Addresses          : 2
Configured MAC Addresses     : 0
Sticky MAC Addresses         : 2
Last Source Address:Vlan     : 000c.2976.xxxx:10
Security Violation Count     : 0
```
*(Figure 4.6: `show port-security interface fastEthernet 0/2` in Restrict mode before the attack.)*

*(Figure 4.7: `show process cpu history` during the attack and LogAnalyzer in Restrict mode.)*

- **CPU** spikes from 24% and stays ~**99%** continuously for ~60 seconds. The root cause: even though the ASIC drops the violating frames, the switch still triggers CPU interrupts to try to log (Syslog) each individual frame, creating an unbounded overload loop.
- **LogAnalyzer** records continuous CRITICAL logs from SW1, one Syslog per violation (1:1). But with 88,248 violations, the device hit a **control-plane bottleneck** and had to drop most of the log packets it couldn't export in time. The server received only fragmented logs — breaking the monitoring trail and masking other security events.

**Takeaway:** Restrict mode preserves connectivity and the CAM table, but because the device lacks a logging rate-limit, it must process every violating frame → CPU stays ~99% and the violation count climbs from 0 to 88,000+. This is a form of **CPU DoS on the defending device itself**. The log loss from overload also exposes a serious data-integrity risk for digital forensics under high-intensity attacks.

## 4.2.3 Port Security — Shutdown Mode

Fa0/2 switches to `violation shutdown`. Sticky MAC keeps the 2 trusted addresses. On the first untrusted MAC, the switch puts the port into **err-disable** and generates a Syslog — the violation counter stops at **1**.

```
Port Security                  : Enabled
Port Status                    : Secure-up
Violation Mode                 : Shutdown
(output omitted)
Maximum MAC Addresses          : 2
Total MAC Addresses            : 2
Sticky MAC Addresses           : 2
Last Source Address:Vlan       : 000c.2976.xxxx:10
Security Violation Count       : 0
```
*(Figure 4.8: `show port-security interface fastEthernet 0/2` in Shutdown mode before the attack.)*

*(Figure 4.9: `show process cpu history` during the attack and LogAnalyzer in Shutdown mode.)*

- **CPU** only spikes to **15%** at the moment it processes the first violating frame and shuts the port — the whole event ends in one shot; CPU is not held high.
- **LogAnalyzer** records only **4 logs** (1 PSECURE_VIOLATION + 1 ERR_DISABLE + 2 UPDOWN). The admin identifies the attack instantly, with no log flood.

**Takeaway:** Shutdown mode stops the attack at the first violating frame: CPU 15% in one event, clean and easy-to-analyze Syslog. This is the standard setting for production environments with strict security requirements, where device integrity is valued above connectivity convenience.

## 4.2.4 Adding Storm Control

Storm Control is added to the access ports with a **5%** threshold for broadcast and multicast, action shutdown:

```
interface range FastEthernet0/2 - 3
 storm-control broadcast level 5
 storm-control multicast level 5
 storm-control action shutdown
```
*(Figure 4.10: Storm Control configuration — cut the port when the threshold is exceeded.)*

This operates independently at the traffic layer, detecting a packet storm before Port Security inspects individual MACs. Combining Storm Control with Port Security Restrict (not Shutdown): Storm Control detects the storm and puts Fa0/2 into err-disable.

*(Figure 4.11: `show process cpu history` during the attack and LogAnalyzer in Restrict + Storm Control.)*

- Storm Control detects the storm and err-disables Fa0/2. CPU rises to **23%** in the first ~20 seconds — higher than plain Shutdown but far below plain Restrict (99%). Storm Control “rescues” Restrict from a prolonged CPU DoS.
- LogAnalyzer records CRITICAL logs from SW1. Because `macof` continuously sends forged MACs beyond the threshold, Storm Control shut the port to stop the attacker from sending more forged frames.

**Takeaway:** Storm Control detects a storm faster than Port Security Restrict processes individual MACs. Adding it fixes the Restrict weakness by err-disabling the port when violating traffic exceeds the threshold — cutting CPU from 99% to 23%.

## 4.2.5 Results Summary

*(Figure 4.12: Chart comparing protection effectiveness and resource impact across Phase 1 stages.)*

The 88,000+ figure on the Log axis represents the hardware-detected violations. In practice, with CPU peaking at 99%, the device entered control-plane DoS and had to drop most Syslog messages to defend itself — causing monitoring-data loss.

```
MAC Address Table
------------------------------------------
Vlan    Mac Address        Type      Ports
----    -----------       -------    -----
  99    001f.6c95.xxxx    DYNAMIC    Fa0/1
  99    3860.7793.xxxx    DYNAMIC    Fa0/9
  10    001f.6c95.xxxx    DYNAMIC    Fa0/1
  10    000c.2976.xxxx    STICKY     Fa0/2
  10    08bf.b8xx.xxxx    STICKY     Fa0/2
Total Mac Addresses for this criterion: 5
```
*(Figure 4.13: The MAC table is preserved in both Restrict and Shutdown modes: VLAN 10 keeps the correct STICKY MACs on Fa0/2, VLAN 99 is unaffected.)*

## 4.2.6 The Role of CoPP (Control Plane Policing)

On newer switches (Catalyst 2960-X, 2960-XR, 9000, etc.), administrators can configure CoPP via `mls qos copp protocol` to rate-limit each type of control-plane traffic to the CPU. The Catalyst 2960 (2960-24TT-L, IOS 15.0(2)SE11) does not support this.

**Direct consequence:** when MAC Flooding occurs (Section 4.2.1), CPU spikes 99–100% and the administrator has no mechanism to rate-limit traffic to the control plane. On this Catalyst 2960, **Storm Control is the only mechanism** that can mitigate traffic floods — by rate-limiting per-port traffic before it impacts CPU and switching.
