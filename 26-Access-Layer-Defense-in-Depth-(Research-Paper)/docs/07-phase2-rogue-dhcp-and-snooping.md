# Phase 2: Rogue DHCP and DHCP Snooping

After Phase 1 deployed Port Security and Storm Control, the attacker must escalate to subtler tactics. Instead of using its real MAC to attack directly, the attacker spoofs its MAC to avoid leaving traces in the router's DHCP binding table. Phase 2 tests two attack positions: (1) a Rogue DHCP Server to hand out forged configuration to clients, and (2) DHCP Starvation to drain the pool.

## 4.3.1 MAC Spoofing and Reconnaissance

Kali uses `macchanger` to set the NIC MAC to the forged `aa:bb:cc:11:22:33` before plugging into Fa0/2. Port Security learns the new Sticky MAC and locks the port to it. To map the network without leaving traces in the DHCP log, the attacker uses dynamic DHCP: request an IP with the forged MAC, receive the network configuration from the router (gateway and DNS), then keep the address for subsequent steps.

*(Figure 4.14: Confirming the attacker carries two different MACs, currently using `aa:bb:cc:11:22:33` for the attack.)*

```
Secure Mac Address Table
-----------------------------------------------------------------------------
Vlan    Mac Address       Type            Ports   Remaining Age (mins)
----    -----------       ----            -----   -------------
  10    aabb.cc11.2233    SecureSticky    Fa0/2         -
  10    08bf.b8xx.xxxx    SecureSticky    Fa0/2         -
-----------------------------------------------------------------------------
Total Addresses in System (excluding one mac per port)     : 1
Max Addresses limit in System (excluding one mac per port) : 8192
```
*(Figure 4.15: `show port-security address vlan 10`. The Sticky MAC `aa:bb:cc:11:22:33` is learned after Kali changes its MAC.)*

```
Bindings from all pools not associated with VRF:
IP address       Client-ID/Hardware address/Username   Lease expiration       Type
192.168.10.193   aabb.cc11.2233                         March 19 2026 4:43 AM  Automatic
192.168.10.210   0138.6077.93xx.xx                     March 19 2026 4:42 AM  Automatic
```
*(Figure 4.16: `show ip dhcp binding`. DHCP assigns an IP to the forged MAC `aa:bb:cc:11:22:33`.)*

Note: the Victim's (Windows) MAC field in the binding table shows the DHCP Client Identifier (Option 61) — a 1-byte hardware type (0x01 = Ethernet) prefixing the 6-byte real MAC: `01` + the host MAC.

**Takeaway:** The attacker uses a forged MAC from the start to avoid identification. Port Security learns and locks the forged MAC. This means that if the attacker reconnects after being cut off, the switch recognizes the old MAC and does not relearn.

## 4.3.2 Rogue DHCP Server Attack

The attacker deploys a Rogue DHCP Server to hand out forged configuration. Because the router answers DHCP Offers faster than Kali in a sparsely populated environment, uplink Fa0/1 is temporarily shut down to remove the router from the DHCP race. This simulates a real scenario where the address pool is exhausted or the router is unavailable — in a busier environment, the probability of the rogue answering before the router would be considerably higher.

Using `dnsmasq`, Kali is configured as a Rogue DHCP Server: address range 192.168.10.150–192.168.10.200, default gateway set to the IP Kali received from the legitimate router, DNS likewise. IP forwarding is enabled so the client's traffic still reaches the real destination — a technique analyzed in depth in Phase 3 when combined with ARP Poisoning for greater stealth.

The Victim performs a release/renew (simulating an employee starting their shift) — seeing only Kali's DHCP Offer because the uplink is down.

*(Figure 4.17: Kali configured as Rogue DHCP, handing out 192.168.10.150–200. The Victim sends its DHCP request to the attacker.)*

*(Figure 4.18: `ipconfig` on the Victim.)* *(Figure 4.19: `show process cpu history`.)*

The client receives an IP from Kali's rogue range (192.168.10.190). The default gateway points to Kali (192.168.10.193) instead of the legitimate router (192.168.10.1) — all packets now traverse the attacker. CPU remains low at ~13%.

**Takeaway:** Rogue DHCP succeeds — the client receives a forged gateway with no warning. The simplest detection is `ipconfig`. Employees usually do not know the legitimate gateway IP and the router's real MAC.

## 4.3.3 Deploying DHCP Snooping

DHCP Snooping is enabled on SW1 with Fa0/1 (router uplink) as the trusted port and the other access ports untrusted. The configuration includes a DHCP rate limit and MAC-address verification on untrusted ports:

```
ip dhcp snooping
ip dhcp snooping vlan 10
no ip dhcp snooping information option
!
interface FastEthernet0/1
 ip dhcp snooping trust
!
! --- Fa0/2, Fa0/3 are untrusted by default ---
 ip dhcp snooping limit rate 10
 ip dhcp snooping verify mac-address
```
*(Figure 4.20: DHCP Snooping with limit rate and verify mac-address.)*

Uplink Fa0/1 is still down from the previous step, to validate that DHCP Snooping works independently of the legitimate server's state. The client performs release/renew again. DHCP Snooping detects the DHCP Offer from Fa0/2 (untrusted) and drops it immediately:

```
Packets Forwarded                     = 92
Packets Dropped                       = 4
Packets Dropped From untrusted ports  = 4
```
*(Figure 4.21: `show ip dhcp snooping statistics` during the attack with DHCP Snooping deployed.)* *(Figure 4.22: `show process cpu history`.)*

92 packets forwarded (the client's legitimate DHCP Discover/Request), only 4 dropped (Kali's DHCP Offer on untrusted Fa0/2) — CPU stays low at ~10%.

**Severity 5 (Notice)** in the DHCP Snooping log matters operationally: administrators often configure Syslog to alert only on Severity 0–4 (Emergency to Warning). Severity 5 (Notice) is skipped — the switch silently blocks the Rogue DHCP, but the admin may be unaware unless LogAnalyzer is configured to filter down to Notice.

*(Figure 4.23: LogAnalyzer records DHCP_SNOOPING_UNTRUSTED_PORT at Severity 5 (Notice).)* If the admin only watches Critical/Error, this event is missed entirely.

**Takeaway:** DHCP Snooping works independently of the legitimate server's state — even with the router offline, the Rogue DHCP is blocked. The Severity 5 (Notice) log is a real blind spot: the admin must configure LogAnalyzer to filter down to Notice to detect it.

## 4.3.4 DHCP Starvation — Defeated by DHCP Snooping

After the Rogue DHCP is blocked, the attacker switches to DHCP Starvation — using `yersinia` to blast DHCP Discover with random source MACs to drain the router's 192.168.10.0/24 pool.

*(Figure 4.24: Kali running `yersinia`, blasting DHCP Discover with random source MACs.)*

The DHCP Snooping limit rate (from Section 4.3.3) detects DHCP traffic exceeding the 10 packets/second threshold on Fa0/2 and err-disables the port — cutting only the attacking port, leaving the others unaffected.

*(Figure 4.25 a/b: `show process cpu history` and LogAnalyzer during the attack.)* DHCP Snooping limit rate detects the excess DHCP Discover before Storm Control and err-disables Fa0/2; CPU stays low.

However, because yersinia's packet rate is extremely high, some DHCP Discover reach the router before the port is cut — the router's pool registers a few IPs to forged MACs and is not fully preserved.

Notably, beyond rate-based blocking, the system also records packet-consistency violations. Even if the attacker tunes the rate below the detection threshold to evade err-disable, forging the hardware address (chaddr) in the DHCP payload is still detected and blocked by **verify mac-address**.

*(Figure 4.25c: LogAnalyzer records a “Match MAC Fail” on detecting a mismatch between source MAC and chaddr.)*

**Takeaway:** DHCP Snooping limit rate detects and cuts exactly the attacking port without affecting legitimate ports. The Phase 1 Storm Control shutdown still runs in parallel as a backup for broadcast attacks above threshold. **MAC Address Verification is the most important logical security layer here.** Logs confirm the switch performed deep inspection of the DHCP packet, detecting the Source MAC vs chaddr mismatch. The pool registering a few forged MACs under yersinia is because the router's hardware processing is faster than the switch's err-disable convergence time. However, if the attacker used a manual tool (such as Scapy) to drain the pool stealthily, Verification (as proven by the log) would be the final backstop ensuring the pool is not compromised, whether or not Fa0/2 is cut.

## 4.3.5 Binding Table and Summary

After re-enabling Fa0/1, the client performs release/renew and receives an IP from the legitimate router. DHCP Snooping builds the binding table — the foundation for DAI and IPSG in Phases 3 and 4.

```
MacAddress          IpAddress         Lease(sec)  Type            VLAN  Interface
-----------------   -------------     ----------  -------------   ----  ----------
38:60:77:93:xx:xx   192.168.10.210    86265       dhcp-snooping    10   FastEthernet0/3
Total number of bindings: 1
```
*(Figure 4.27: `show ip dhcp snooping binding` after the Victim performs release/renew.)* The Victim's MAC is bound to the IP issued by the legitimate router, recording VLAN and port. This table is used by DAI and IPSG in Phases 3 and 4.

**Table 4.1: Phase 2 measurement summary across 3 stages.**

| Scenario | Peak CPU | Result | Blocking mechanism |
|---|---|---|---|
| Rogue DHCP (unprotected) | ~13% | Success — hijacked | None |
| Rogue DHCP (DHCP Snooping) | ~10% | Failure — forged packets dropped | DHCP Snooping |
| DHCP Starvation (limit rate) | 13% | Failure — pool not fully preserved | DHCP Snooping limit rate |

Phase 2 shows defense-in-depth working through layer coordination: DHCP Snooping limit rate cuts exactly the attacking port, the Phase 1 Storm Control shutdown acts as a backup for above-threshold broadcast attacks, and DHCP Snooping blocks Rogue DHCP independently of the router's state. A few forged MACs landing in the router pool is a residual risk caused by the attack rate outpacing the response time. The binding table after Phase 2 is the mandatory foundation for DAI and IPSG in Phases 3 and 4 — where the attacker escalates to more sophisticated ARP Poisoning.
