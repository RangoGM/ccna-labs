# 4. Lab Design, Topology, and Baseline Configuration

> *Sanitization note:* shared secrets and credentials are shown as placeholders; the internal domain has been genericized to `corp.local`; real device MACs are masked. RFC1918 lab addressing is preserved as in the original.

## 4.1 Hardware

**Table 3.7: Physical hardware.**

| Device | Model / IOS | Role in the lab | Notes |
|---|---|---|---|
| SW1 | Cisco Catalyst 2960-24TT-L, IOS 15.0(2)SE11 | Main Access Layer switch — 802.1X, MAB, Port Security, DHCP Snooping, DAI, IPSG, Storm Control, BPDU Guard | Hardware ASIC required for 802.1X/EAPOL |
| Router | Cisco 2811, IOS 12.4(T) | Default gateway, Inter-VLAN routing (router-on-a-stick), DHCP server for VLAN 10 and VLAN 99 | Sub-interfaces Fa0/1.10 and Fa0/1.99 |
| Ubuntu Server / Desktop | 24.04.4 LTS | Switch administration, Syslog monitoring, LogAnalyzer dashboard | Hosts all services |

## 4.2 Software and Virtual Machines

**Table 3.8: Software and VMs.**

| Software / VM | Version | Role |
|---|---|---|
| FreeRADIUS | 3.x | AAA authentication between switch and client |
| Web Server (Apache2) | — | HTTP server for the MITM experiment |
| LogAnalyzer | — | Web interface to display and analyze logs from the Syslog system |
| rsyslog | — | Collects and stores logs from the switch via Syslog (UDP 514) |
| Kali Linux | 2026.x | Simulates attack scenarios (MITM, ARP spoofing, etc.) |

## 4.3 Attack Tools (Kali Linux)

**Table 3.9: Attack tools on Kali Linux.**

| Tool | Suite / Package | Attack vector | Purpose in the experiment |
|---|---|---|---|
| macof | dsniff | MAC Flooding | Flood SW1's CAM table — test Storm Control and Port Security |
| arpspoof | dsniff | ARP Poisoning | Basic MITM baseline before the stealth demo |
| bettercap | bettercap | ARP + MITM stealth | MITM stealth with MAC clone — demonstrate attack invisibility |
| yersinia | yersinia | Rogue DHCP, STP | Rogue DHCP — test DHCP Snooping; STP root attack — test BPDU Guard |
| fake_router6 | THC-IPv6 | Rogue RA (IPv6) | Send forged Router Advertisements |
| wpa_supplicant | wpasupplicant | 802.1X EAP-MD5 | Simulate a legitimate supplicant — test successful and failed authentication |
| scapy | scapy | Raw IP spoofing, ARP craft, BPDU test | Send forged raw IP packets — test IPSG; controlled DAI vs Port Security logging (120 violations); validate BPDU Guard on bare metal |
| fake_dhcps6 | THC-IPv6 | Rogue DHCPv6 | Send forged DHCPv6 — test DHCPv6 Guard |

## 4.4 Topology and IP/VLAN Plan

The system uses a single Catalyst 2960 switch but fully separates Layer 2 into two network zones (VLAN 10 and VLAN 99). Inter-VLAN routing is performed via router-on-a-stick on the Cisco 2811. This design ensures that an attacker in VLAN 10 cannot directly perform Layer 2 attacks (such as ARP Poisoning) into the management zone — they must traverse the gateway. The router's remaining port is planned for the Internet uplink.

*(Figure 3.6: The layered access network experimental model.)*

**Why the Kali attacker uses a dynamic IP (192.168.10.x/24):** the attacker uses a forged MAC (`aa:bb:cc:11:22:33`) to obtain a DHCP lease instead of the real MAC, avoiding traces that could attribute the device's identity in the router's DHCP binding table. The dynamic IP is then kept for subsequent attack steps.

*Note:* because Kali runs as a VMware VM on a physical host, switch port Fa0/2 learns two MAC addresses simultaneously. In the configuration screenshots and logs, the physical host's MAC was masked for privacy, showing only the Kali attacker MAC (`000c.2976.xxxx`) and the forged `aa:bb:cc:11:22:33`.

## 4.5 Initial Baseline Configuration

The following configurations are the fixed baseline. The 2960 sets up a trunk to the router, while the 2811 uses sub-interfaces to route both VLANs:

```
! ===== SW1 (Catalyst 2960) =====
vlan 10
 name Host
vlan 99
 name Management

interface Vlan99
 ip address 192.168.99.100 255.255.255.0
ip default-gateway 192.168.99.1

! --- Trunk uplink to the router --- (1)
interface FastEthernet0/1
 description ___TRUNK LINK___
 switchport mode trunk
 switchport trunk native vlan 1001
 switchport trunk allowed vlan 1,10,99

! --- Access ports, VLAN 10 (User/Kali) ---
interface range FastEthernet0/2 - 3
 switchport mode access
 switchport access vlan 10
 spanning-tree portfast

! --- Access ports, VLAN 99 (Ubuntu/Admin) ---
interface range FastEthernet0/9 - 10
 switchport mode access
 switchport access vlan 99
 spanning-tree portfast

! --- Disable unused ports --- (2)
interface range FastEthernet0/4 - 8 , FastEthernet0/11 - 24 , GigabitEthernet0/1 - 2
 switchport access vlan 999
 shutdown
```

```
! ===== Router 2811 =====
! --- Sub-interfaces for Inter-VLAN routing ---
interface FastEthernet0/1.10
 encapsulation dot1Q 10
 ip address 192.168.10.1 255.255.255.0
interface FastEthernet0/1.99
 encapsulation dot1Q 99
 ip address 192.168.99.1 255.255.255.0

! --- DHCP server for VLAN 10 and VLAN 99 ---
ip dhcp excluded-address 192.168.10.1 192.168.10.10
ip dhcp excluded-address 192.168.99.1 192.168.99.10
ip dhcp excluded-address 192.168.99.99
ip dhcp pool VLAN10
 network 192.168.10.0 255.255.255.0
 default-router 192.168.10.1
 dns-server 192.168.99.99
ip dhcp pool VLAN99
 network 192.168.99.0 255.255.255.0
 default-router 192.168.99.1
 dns-server 192.168.99.99
```

*(Figure 3.7: Baseline configuration of SW1 and the 2811 router — router-on-a-stick & DHCP.)*

**Notes:**

**(1) Native VLAN set to 1001** instead of the default (VLAN 1), per Cisco's security recommendation. The VLAN Hopping (double-tagging) technique exploits a trunk native VLAN that matches the attacker's VLAN — the frame is double-tagged, the outer tag (native VLAN) is stripped by the switch, and the inner tag lets the attacker hop into the target VLAN without authentication. By assigning the native VLAN to 1001 — a VLAN no device belongs to — the technique is neutralized without any additional mechanism.

**(2)** The Catalyst 2960 has 24 FastEthernet ports but the lab uses only 5 (Fa0/1–Fa0/3, Fa0/9–Fa0/10). Per Cisco best practice, all unused ports are shut down and assigned to an inactive VLAN to stop an attacker from plugging in undetected. VLAN 999 (a “parking VLAN”) is not routed and has no member device — even if an attacker connects to a shutdown port, traffic goes nowhere. This is a basic physical-security measure often overlooked in practice.
