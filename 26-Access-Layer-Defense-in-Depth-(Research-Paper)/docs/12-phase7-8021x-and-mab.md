# Phase 7: Comprehensive Access Control (802.1X & MAB)

After deploying the traffic-protection mechanisms (Phases 1–4), IPv6 security (Phase 5), and STP protection (Phase 6), Phase 7 shifts from a traffic-control model to an **identity-based access-control** model. IEEE 802.1X establishes control at the physical port — only authenticated entities may join the network, significantly reducing the attack surface at the point of entry.

*Note:* **Cisco does not recommend deploying Port Security together with 802.1X** — since 802.1X already controls MAC per port, Port Security becomes redundant and can conflict in some cases. In Phase 7, Port Security is disabled on ports running 802.1X.

## 4.8.1 802.1X and MAB Experiments

The FreeRADIUS system (192.168.99.99) is pre-configured with a user database (a test user account) and a MAC allow-list for IoT devices.

> *Sanitization note:* the RADIUS shared secret and the test user credentials below are redacted with placeholders.

```
aaa new-model
aaa group server radius RADIUS_GROUP
 server name RADIUS_UBUNTU
!
aaa authentication dot1x default group RADIUS_GROUP
aaa authorization network default group RADIUS_GROUP
dot1x system-auth-control
ip radius source-interface Vlan99
radius server RADIUS_UBUNTU
 address ipv4 192.168.99.99 auth-port 1812 acct-port 1813
 key <RADIUS_SHARED_SECRET>
```
*(Figure 4.79: Initial 802.1X/MAB configuration for the Ubuntu server.)*

### Scenario 1: Strict authentication for the User group (VLAN 10)

To reduce MAC-spoofing risk, the user zone uses **802.1X only**. Removing MAB ensures that spoofing a MAC is not enough to gain access without valid credentials.

```
interface range FastEthernet0/2 - 3
 authentication order dot1x
 authentication priority dot1x
 authentication port-control auto
 authentication periodic
 authentication host-mode single-host
 authentication violation restrict
 authentication timer reauthenticate server
 authentication timer inactivity 600
 dot1x pae authenticator
 dot1x timeout tx-period 10
```
*(Figure 4.80: 802.1X configuration for the user access ports.)*

Using Windows Wired AutoConfig to send the authentication request, the switch acts as Authenticator forwarding EAP to RADIUS.

**Result:** with correct credentials → Fa0/3 becomes Authorized, normal access. When the attacker clones the Windows MAC but has no identity, the port stays Unauthorized. All traffic from Kali is fully blocked. This effectively prevents MAC spoofing in the absence of valid credentials.

*(Figure 4.81: Windows authenticates successfully and gains network access.)* *(Figure 4.82: Kali plugged into the port, spoofing the Windows MAC, fails authentication — recorded by LogAnalyzer.)*

### Scenario 2: Authentication and isolation for the IoT group

For devices that do not support a supplicant (emulated by Kali or Windows with 802.1X off). Because MAB (MAC-based) is inherently weaker, **Port Isolation** is deployed to control only east-west traffic; a separate VLAN or a gateway ACL is also needed to control northbound traffic.

```
interface FastEthernet0/2
 authentication order mab
 authentication priority mab
 authentication port-control auto
 mab
 authentication violation restrict
 switchport protected
```
*(Figure 4.83: MAB configuration for IoT device ports.)*

*(Figure 4.84: Kali plugged into an IoT port with 802.1X off, spoofing the device MAC. MAB passes it.)* *(Figure 4.85: Kali attempts the Phase 1–6 attacks.)*

Thanks to **switchport protected**, traffic between protected ports is fully blocked — Kali cannot attack east-west toward other devices in the same VLAN (ARP Poisoning, Rogue RA, Rogue DHCPv6). However, traffic from a protected port still reaches the router via the uplink — the attacker can still flood unicast with a legitimate IP toward the router, the residual risk recorded in Phase 4 (Section 4.5.2), requiring CoPP at Layer 3.

## 4.8.2 Summary and Technical Rationale

**Table 4.5: Defense-in-Depth design in Phase 7 (802.1X + MAB + Isolation).**

| Target | Authentication | Added protection | Objective |
|---|---|---|---|
| Users (VLAN 10) | 802.1X | No isolation | Identity-based authentication. Preserve large-transfer performance (50GB+). |
| IoT devices (separate VLAN) | MAB | Port Isolation (Protected) | Accept MAB for non-802.1X devices but fully isolate to neutralize internal and IPv6-evasion attacks. |

**Takeaway:** separating the two mechanisms balances security and feasibility: (1) 802.1X provides strong identity-based authentication; (2) MAB supports incompatible devices; (3) Port Isolation reduces blast radius if a compromise occurs. Phase 7 marks the shift from traffic-control security to identity-based access control, proactively blocking unauthorized access at the network entry point.
