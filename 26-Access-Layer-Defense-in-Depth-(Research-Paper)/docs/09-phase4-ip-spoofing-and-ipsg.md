# Phase 4: IP Spoofing, IPSG, and Residual Availability Risk

Phase 4 tests the next layer after DAI — **IP Source Guard (IPSG)** — to control source IP on the data plane. It also evaluates the residual risk when the attacker uses *legitimate* traffic to attack system availability.

## 4.5.1 Deploying IP Source Guard

IPSG is enabled on Fa0/2 with `ip verify source port-security`, using the Phase 2 DHCP Snooping binding table for validation. With the `port-security` option, IPSG checks **both** source IP and source MAC — only traffic matching the binding is allowed; the rest is dropped. This option requires Port Security to be deployed on the port (Phase 1).

*Note:* when 802.1X/MAB replaces Port Security (Phase 7), the equivalent command is `ip verify source` — which checks only the source IP, not the MAC.

```
interface FastEthernet0/2
 ip verify source port-security
!
interface FastEthernet0/3
 ip verify source port-security
```
*(Figure 4.48: IPSG on Fa0/2 and Fa0/3 with the port-security option.)*

```
Interface   Filter-type   Filter-mode   IP-address       Mac-address          Vlan
---------   -----------   -----------   --------------   ------------------   ----
Fa0/2       ip-mac        active        192.168.10.139   AA:BB:CC:11:22:33    10
Fa0/3       ip-mac        active        192.168.10.210   38:60:77:93:xx:xx    10
```
*(Figure 4.49: `show ip verify source`.)*

Kali uses Scapy to send raw IP packets spoofing the Victim's source IP (192.168.10.210) to the router — the same attack that succeeded in Section 4.4.7. IPSG checks: the binding records Fa0/2 + MAC `aa:bb:cc:11:22:33` = 192.168.10.139, so the source IP does not match and the packet is dropped.

*(Figure 4.50: Wireshark on the Victim — no abnormal ICMP Reply as in Figure 4.45, confirming IPSG blocked it.)* *(Figure 4.51: Router CPU low — it does not have to process forged packets.)*

**Takeaway:** Compared directly with Section 4.4.7, same Scapy attack: without IPSG, router CPU hit 99% and the Victim lost 73/100 packets; after deploying IPSG, the forged packet is dropped at the switch, router CPU stays low, and the Victim receives a full 100/100 packets.

## 4.5.2 Unicast Flood with a Legitimate IP, and Storm Control Unicast

IPSG blocks IP spoofing but does not control traffic from a legitimate IP. Kali pings the gateway using its own legitimate IP (192.168.10.139) — IPSG allows it because IP and MAC match the binding. Normal connectivity confirms IPSG does not affect legitimate traffic.

However, when the attacker switches to IP flooding with the same legitimate IP, both IPSG and DAI allow it, and all traffic is aimed straight at the router. The Phase 1 Storm Control only limits broadcast and multicast — unicast is out of scope, so a unicast flood is entirely unmitigated. The switch operates normally at low CPU (data-plane forwarding only) — the admin gets no alert from the switch.

*(Figure 4.52: Router CPU rises to ~70% continuously while Kali floods unicast with a legitimate IP. Switch CPU low, no alert generated.)*

**Evaluating Storm Control Unicast.** A test of unicast Storm Control at a 1.5% threshold:

```
interface range FastEthernet0/2 - 3
 storm-control unicast level 1.5
```
*(Figure 4.53: Adding Storm Control unicast 1.5%.)*

```
Interface   Filter State   Upper    Lower    Current
---------   ------------   ------   ------   -------
Fa0/2       Forwarding     1.50%    1.50%    0.73%
Fa0/2       Blocking       1.50%    1.50%    2.19%
```
*(Figure 4.54: `show storm-control unicast`.)* Fa0/2 (Kali flood) traffic 0.73% — Forwarding. Fa0/3 (Victim browsing) traffic 2.91% — Blocking.

The result is an **unsolvable paradox**: the attacker at 0.73%, aimed straight at the router, sustains ~70% router CPU but stays Forwarding — undetected. Meanwhile the Victim browsing normally at 2.91% is switched to Blocking — all legitimate unicast on the port is blocked. The difference: the Victim's traffic *passes through* the router (forwarded, low CPU), while Kali's traffic goes *into* the router (processed, high CPU) — the same below/above a threshold but with completely different CPU impact. Storm Control measures traffic without distinguishing packet intent.

*(Figure 4.55: LogAnalyzer records Storm Control exceeding the threshold on Fa0/3.)* *(Figure 4.56: Router CPU spikes briefly then drops as Storm Control filters the Victim's traffic.)*

Based on these results, the study **does not deploy Storm Control unicast** in the final configuration, keeping the Phase 1 strategy — controlling only broadcast and multicast with action shutdown:

- **Broadcast/Multicast:** legitimate traffic stays very low (1–5%). Any sudden spike is a clear attack sign (MAC Flooding, DHCP Starvation, BPDU Flood). Action shutdown cuts the port immediately with no fear of blocking legitimate users.
- **Unicast:** legitimate traffic varies widely — 2.91% while browsing, up to 60% during heavy downloads. No universal safe threshold exists for unicast at the Access Layer. Controlling unicast flood aimed at the router is a Layer 3 problem — it needs control-plane protection (CoPP) directly on the router, where the device can distinguish transit traffic (forwarded, low CPU) from inbound traffic (processed, high CPU).

**Multi-vector validation:** with all layers deployed, IPSG removes macof's forged MACs before they reach Port Security — completely fixing the Port Security CPU-DoS seen in Phase 1 (Section 4.2.2). DHCP Snooping limit rate detects yersinia broadcast and cuts exactly the attacking port. In short, once all spoofing and broadcast-flood vectors are blocked, an attacker with a valid binding entry has only one option left: flood unicast with a legitimate IP straight at the router — the **residual risk** at the Access Layer, an inherent limit of intent-blind traffic measurement. The definitive solution is CoPP directly on the router — outside the Access Layer scope of this project and proposed in the future work (Section 5).
