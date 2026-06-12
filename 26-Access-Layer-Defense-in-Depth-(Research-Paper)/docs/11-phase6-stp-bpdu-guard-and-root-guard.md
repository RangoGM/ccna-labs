# Phase 6: Protecting the Spanning Tree — BPDU Guard, Root Guard, and Disabling CDP

Even with the data plane secured by the previous phases, the network can still collapse if an access port accepts an unauthorized BPDU. Phase 6 validates STP topology protection and reveals the interaction between the already-deployed layers (IPSG, Port Security, Storm Control) and control-plane protection (BPDU Guard, Root Guard).

## 4.7.1 Preventing Intelligence Leakage via Cisco Discovery Protocol (CDP)

Before destructive attacks, an attacker usually performs reconnaissance via CDP — a proprietary protocol enabled by default on Cisco devices.

**Risk:** packet capture on Kali shows the switch continuously broadcasting CDP frames containing sensitive information. The attacker easily harvests: device name (`SW1.corp.local`), management IP (192.168.99.100), hardware platform (Catalyst 2960), and IOS version detail (15.0). This is a dangerous precursor for looking up targeted CVEs against the device.

*(Figure 4.70: Wireshark on Kali captures detailed switch information via CDP.)*

**Defense and validation:** disable CDP advertisement locally on the end-user access ports (`no cdp enable`). After applying, the Kali attacker is completely “blinded.” Even when Kali actively sends CDP frames to force the switch to respond, the access port has logically severed the protocol — fully cutting the reconnaissance chain.

```
interface range FastEthernet0/2 - 3
 no cdp enable
```
*(Figure 4.71: Disabling CDP advertisement on the end-user access ports.)* *(Figure 4.72: The attacker continuously sends CDP queries but receives no response.)*

## 4.7.2 Protecting the Control Plane (Root Guard & BPDU Guard)

Even with the data plane secured, the network can still collapse if an access port accepts an unauthorized BPDU. Full STP protection requires a dual deployment: **Root Guard** (a backup to protect the Root Bridge position — a mandatory design principle even though the current lab has only one switch) and **BPDU Guard** (lock the port on receiving any unexpected BPDU).

```
VLAN0010
  Spanning tree enabled protocol ieee
  Root ID    Priority    32867
             Address     2c3f.38a3.xxxx
             This bridge is the root
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec
(output omitted)
Interface           Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- ----
Fa0/2               Desg FWD 19        128.2    P2p
```
*(Figure 4.73: `show spanning-tree vlan 99` — the 2960 is currently the Root.)*

**Scenario 1 — BPDU with a forged MAC, below the Storm Control threshold:** Kali sends a BPDU flood with a forged source MAC (not in the binding table). The IPSG and Port Security from Phase 4 discard the frame at the data layer — the packet never reaches the STP process. BPDU Guard does not trigger because no BPDU got through; CPU stays low; the STP topology is unchanged.

**Scenario 2 — BPDU with a forged MAC, above the Storm Control threshold:** Kali increases the flood beyond 5%. Storm Control (from Phase 1, Section 4.2.4) suppresses the flow and err-disables the port. BPDU Guard still does not need to trigger — Storm Control handled it first.

**Scenario 3 — BPDU with a legitimate MAC, below threshold, no BPDU Guard yet:** the most dangerous scenario. Kali sends a BPDU flood below the Storm Control threshold with source MAC `aa:bb:cc:11:22:33` — which matches the binding table. IPSG and Port Security allow it because the MAC is valid. All BPDUs reach the STP process, forcing a spanning-tree recalculation.

*(Figure 4.74: Kali floods BPDUs below the 5% Storm Control threshold. CPU spikes continuously to ~85%.)*

```
VLAN0010
  Spanning tree enabled protocol ieee
  Root ID    Priority    32867
             Address     aabb.cc11.2233
             Cost        19
             Port        2 (FastEthernet0/2)
(output omitted)
Interface           Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- ----
Fa0/2               Root FWD 19        128.2    P2p
```
*(Figure 4.75: Spanning Tree state after receiving a legitimate BPDU from Kali — the Root Bridge has changed.)* The switch is no longer the Root Bridge. The device with MAC `aa:bb:cc:11:22:33` seized the Root role via Fa0/2. This proves that when IPSG passes the packet (legitimate MAC), the BPDU flood directly attacks the control plane — overloading the CPU and changing the topology.

```
interface range FastEthernet0/2 - 3
 spanning-tree bpduguard enable
 spanning-tree guard root
```
*(Figure 4.76: BPDU Guard and Root Guard backup on the access ports.)*

Kali repeats the below-threshold BPDU flood with a legitimate MAC. IPSG passes it — but BPDU Guard recognizes the BPDU and err-disables the port immediately.

*(Figure 4.77: LogAnalyzer records BPDU Guard blocking successfully.)* *(Figure 4.78: `show process cpu history` — the port is cut before the BPDU flood can load the CPU (~10%).)*

**Takeaway:** the experiment reveals layer interaction in the Defense-in-Depth model. When the attacker sends a BPDU with a forged source MAC, IPSG or Port Security discards the frame before the STP process — BPDU Guard need not trigger because the frame was blocked earlier. When the attacker uses a valid source MAC, Port Security and IPSG pass it — BPDU Guard then recognizes it precisely and err-disables the port immediately. This is the clearest evidence for defense-in-depth: each layer protects a different attack direction, and when a lower layer passes traffic, the upper layer is ready to block.

## 4.7.3 Phase 6 Summary

**Table 4.4: BPDU Guard results across scenarios (Phase 6).**

| Scenario | Source MAC | Switch response | CPU |
|---|---|---|---|
| Forged MAC, below threshold | Not in binding | IPSG/Port Security drop first. BPDU Guard not triggered | Low |
| Forged MAC, above threshold | Not in binding | Storm Control (Phase 1) suppresses | Low |
| Legitimate MAC, no BPDU Guard | In binding | IPSG passes, STP reconverges, Root Bridge changes | ~85% |
| Legitimate MAC, below threshold | In binding | IPSG passes → BPDU Guard err-disables immediately | ~10% |

**Conclusion:** Phase 6 confirms BPDU Guard is an essential protection for the STP topology — especially when the attacker already has a legitimate MAC in the binding table and the lower layers (IPSG, Port Security) cannot distinguish a BPDU from ordinary traffic.
