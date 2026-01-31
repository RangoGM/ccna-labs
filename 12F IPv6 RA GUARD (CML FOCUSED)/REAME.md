## Lab 12F: IPv6 RA GUARD - Defeating Rogue Router Advertisement Attacks

### Objective
The objective of this lab is to mitigate **Rogue Router Advertisement (RA)** attacks by implementing the **IPv6 RA Guard feature** on a Cisco Switch. We simulate an attacker impersonating a default gateway to hijack network traffic (Man-in-the-Middle) and demonstrate how the defense system drops these malicious packets at the ingress port.

### Topology & Infrastructure Design
To ensure technical accuracy and eliminate "Bridge Shortcuts" (where traffic bypasses the virtual switch via the host driver), this lab uses a strictly isolated 3-adapter setup:

|Device|Role|Bridge / Connection|Interface|
|-|-|-|-|
|**Router R1**|Legitimate Gateway|CML Internal|`E0/0` (Trusted)|
|**Kali 1 (Attacker)**|Rouge Router|(Host-only)|`E0/1` (Untrusted)|
|**Kali 1 (Victim)**|Endhost|(Host-only)|`E0/2` (Untrusted)|


**📸 Screenshot:**


<img width="793" height="386" alt="Screenshot 2026-01-31 130101" src="https://github.com/user-attachments/assets/89af9fd4-685a-4929-a4cd-ec062723c4f6" />


<img width="547" height="400" alt="Screenshot 2026-01-31 021551" src="https://github.com/user-attachments/assets/9a5bccec-5a0b-49f6-8e2f-ec17bb35ac8b" />

**(R1 E0/0 Interface)**

**DevOps Insight:** Using separate virtual bridges forces every packet from the Attacker to traverse the Switch's **Data Plane (IOL)**, preventing the host machine from automatically bridging the traffic at the software layer.

---

### Excution Phase

#### Phase 1: The Attack (Before Defense)

We use the `atk6` toolkit on **Kali 1** to broadcast a malicious IPv6 prefix.

**1. Manual Link-Local Recovery:** Since the NAT was disconnected for isolation, we manually restore the link-local address required for ICMPv6:

 ```bash
   sudo ip addr add fe80::1/64 dev eth0 scope link
```
**2. Launching the Rogue RA Attack:**
```
sudo atk6-fake_router6 eth0 2001:db8:dead:beef::/64
```
**Result:** The Victim receives two global IPv6 addresses, leading to gateway conflicts and potential traffic interception.

**📸 Screenshot:**

<img width="902" height="172" alt="Screenshot 2026-01-31 022131" src="https://github.com/user-attachments/assets/98a3aaa1-da73-4e1c-a178-66d036ff6fc0" />

**(Victim: normal state accept RA from Router R1)**

<img width="1010" height="370" alt="Screenshot 2026-01-31 123801" src="https://github.com/user-attachments/assets/3f5e147a-9940-45bd-82f1-1f1604795648" />

**(Start Attack)**

<img width="816" height="128" alt="Screenshot 2026-01-31 023438" src="https://github.com/user-attachments/assets/85a13f5b-a42a-419b-b480-30753944406e" />

**(Victim: After Attacked)**

<img width="1027" height="38" alt="Screenshot 2026-01-31 0235593" src="https://github.com/user-attachments/assets/0ef36e93-b822-4105-9ce7-757960240bdb" />

**(Router Conflict Dettected)**

---

#### Phase 2: The Defense (Applying RA Guard)

**We configure the Cisco Switch to define device roles and attach the security policies:**

```
RA_GUARD(config)# ipv6 nd raguard policy TRUSTED
RA_GUARD(config-nd-raguard)#device-role router

RA_GUARD(config)# ipv6 nd raguard policy UNTRUSTED
RA_GUARD(config-nd-raguard)# device-role host

RA_GUARD(config)# interface e0/0
RA_GUARD(config-if)# ipv6 nd raguard attach-policy TRUSTED

RA_GUARD(config)# interface range e0/0 - 1
RA_GUARD(config-if)# ipv6 nd raguard attach-policy UNTRUSTED

```

**📸 Screenshot:**

<img width="341" height="151" alt="Screenshot 2026-01-31 121937" src="https://github.com/user-attachments/assets/c6168ec8-1ea7-41be-9b38-99654c697c46" />

**(Interfaces has been attached policy)**

<img width="615" height="233" alt="Screenshot 2026-01-31 122010" src="https://github.com/user-attachments/assets/8c7a0191-a7cf-4229-aaf8-cdc2348b0c2d" />

---

### Verification & Results
**🔴 Scenario: Under Attack**
- **Router R1:** Logs Neighbor Discovery conflicts: `%IPV6_ND-3-CONFLICT`.
- **Victim (Kali 2):** Receives the malicious `dead:beef` prefix in a `tentative` state.

**🟢 Scenario: Protected**
- **Switch:** Actively filters packets based on the device-role host configuration.
- **Victim (Kali 2):** After flushing the interface, the node only receives the legitimate prefix from R1 (`2001:db8:acad:1::/64`).

```
sudo ip -6 addr flush dev eth0
ip -6 addr show eth0
```
   
- **Traffic Integrity:** `tcpdump` confirms ICMPv6 packets from the attacker are dropped, while legitimate traffic maintains a stable RTT (~5ms).

<img width="842" height="285" alt="Screenshot 2026-01-31 124123" src="https://github.com/user-attachments/assets/5390aa0c-6016-4d4c-8fdd-d1bdda9f0759" />

---
### Troubleshooting & Lessons Learned
- **Link-Local Recovery:** Disconnecting NAT bridges often drops the `fe80::` address. Manually assigning a `scope link` address is essential for maintaining Layer 2 reachability in isolated labs.
- **Simulation Limitations:** Testing revealed that `device-role` monitor may fail to drop packets in some virtual IOL images; switching to `device-role host` ensured 100% enforcement.
- **Bridge Shortcut Mitigation:** Successfully implemented `Network Segmentation` by using separate virtual adapters to force traffic through the security control layer.



