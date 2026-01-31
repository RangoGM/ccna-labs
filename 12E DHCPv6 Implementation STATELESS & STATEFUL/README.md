## Lab 12E: DHCPv6 Implementation - Stateless vs. Stateful (12E.1 + 12E.2)

### Objective
The goal of this lab is to move beyond simple IPv6 addressing and master the two primary methods of dynamic configuration in a dual-stack or IPv6-only environment. We focus on the interaction between a **Cisco IOSv Router (CML)** and a **Real Linux Host (VMware).**

### Environment
- **Router:** Cisco IOSv (Running on CML).
- **Host:** Linux (Ubuntu/Kali on VMware Workstation).
- **Analysis Tool:** Wireshark (via CML External Connector) - *Optional*.

---

### Core Concepts: The Flags
The behavior of the host is determined by the **M (Managed Address)** and O **Other Configuration)** flags within the ICMPv6 Router Advertisement (RA) sent by the router.

|Method|M-Flag|O-Flag|Description|
|-|--|--|-|
|**SLAAC (Default)**|0|0|"Host gets Prefix from RA, generates its own Interface ID."|
|**Stateless DHCPv6**|0|1|"Host uses SLAAC for IP, but asks DHCPv6 for DNS/Domain."|
|**Stateful DHCPv6**|1|1|Host ignores SLAAC and gets everything from the DHCPv6 server.|

---

### 📂 12E.1: Stateless DHCPv6 (SLAAC + DNS)

#### Objective
Configure a Cisco IOSv Router to provide IPv6 addresses via **SLAAC** while using **Stateless DHCPv6** to hand out "Other" information like DNS servers to a Linux host.

---
#### 1. Cisco IOS Configuration (CML)
The router is configured with an IPv6 DHCP pool and the `other-config-flag` to tell hosts that additional information is available via DHCPv6.
- **Key Commands:**
  - `ipv6 unicast-routing`
  - `ipv6 nd other-config-flag` (Sets the O-flag in RAs)
  - `ipv6 dhcp server STATELESS_POOL`

**📸 Screenshot:**

<img width="262" height="91" alt="Screenshot 2026-01-30 221321" src="https://github.com/user-attachments/assets/b21220e3-fd8d-4f2f-8d1e-dc274d90b5b1" />      <img width="294" height="95" alt="Screenshot 2026-01-30 221344" src="https://github.com/user-attachments/assets/a04d754b-a9c8-478b-87d7-69a54db82b31" />

---
#### 2. Initial Verification on Linux (VMware)
By default, the Linux host (Kali) uses SLAAC to generate its own Global Unicast Address and learn the Default Gateway from the Router Advertisement (RA).

- **IP Address:** The output shows `proto kernel_ra`, confirming SLAAC success.
- **Routing:** The default route is learned via `proto ra`.

**📸 Screenshot:**

<img width="871" height="183" alt="Screenshot 2026-01-30 222304" src="https://github.com/user-attachments/assets/0a612d5f-0175-4adf-ba0c-5f4f73cefbf3" />

---

#### 3. Troubleshooting: Forcing DNS Update
In this lab, the Linux host initially ignored the RA's DNS information due to Kernel restrictions or internal DNS settings (`8.8.8.8`). I applied the following fixes to force the update:

- **Kernel Tuning:** Forced the interface to accept RAs regardless of the forwarding state.
- **Manual DHCPv6 Request:** Used `dhclient` with the `-S` flag to request "Information-only" (Stateless) from the DHCP server.

**📸 Screenshot:**

<img width="441" height="124" alt="Screenshot 2026-01-30 222204" src="https://github.com/user-attachments/assets/67497b2c-51fb-4448-859f-332b6c8058a1" />

<img width="505" height="255" alt="Screenshot 2026-01-30 222653" src="https://github.com/user-attachments/assets/c7d84800-b0ae-4409-96a7-a4b6a12ba354" />

---

#### 4. Final Verification
After the manual force, the Linux host correctly updated its DNS settings and established connectivity to the router.
- **DNS Check:** `cat /etc/resolv.conf` now shows the DNS from the Cisco Pool (`2001:4860:4860::8888`).
- **Connectivity:** Successful ping to the router gateway without CIDR notation.

**📸 Screenshot:**

<img width="272" height="75" alt="Screenshot 2026-01-30 222728" src="https://github.com/user-attachments/assets/486cf466-5a2d-4cff-8c70-1f676bb888ac" />

<img width="542" height="134" alt="Screenshot 2026-01-30 223025" src="https://github.com/user-attachments/assets/f82ae46f-4e8b-42ea-acae-fb9f110c072a" />

---

### Key Takeaway
Stateless DHCPv6 is a hybrid approach. This lab demonstrated that configuring the network infrastructure (Cisco) is only half the battle; the End-Device (Linux) must be properly tuned to interpret and act on the ICMPv6 flags (M/O bits) correctly.

----

### 📂 Lab 12E.2: Stateful DHCPv6 Implementation (Full Managed Mode)

#### Objective

The goal of this lab is to implement a Stateful DHCPv6 environment where the Cisco Router acts as the central authority for IP address assignment, DNS, and Domain information. Unlike Stateless mode, the host (Linux VM) is prohibited from using SLAAC and must request a managed lease from the server.

---

#### 1. Cisco IOS Configuration (CML)
The router is configured to set the **M-flag (Managed)** and specifically disable **Autoconfiguration** on the prefix to ensure hosts do not generate their own addresses.

- **Key Commands:**
  - `ipv6 nd managed-config-flag`: Tells the host to use a stateful DHCPv6 server.
  - `ipv6 nd prefix [Prefix] no-autoconfig`: Instructs the host not to use the prefix for SLAAC.
  - `ipv6 dhcp pool STATEFULL_POOL`: Defines the managed address range and DNS.
 
**📸 Screenshot:**

<img width="294" height="97" alt="Screenshot 2026-01-30 234228" src="https://github.com/user-attachments/assets/1c793adb-4a8f-4cb4-9dd4-e46dc9cef949" />    <img width="532" height="118" alt="Screenshot 2026-01-30 234244" src="https://github.com/user-attachments/assets/767d2543-a6b2-4a65-8522-c9dab7025cbd" />


---

#### 2. Linux Host Configuration & Troubleshooting
Interfacing a real Linux Kernel with Stateful DHCPv6 requires specific tuning to handle Router Advertisements (RA) and address conflicts.

- **Kernel Tuning:** To ensure the Linux node listens to the Router's M-flag, the accept_ra parameter must be forced to 2.
- **The Link-Local Crisis:** During the lab, the interface lost its Link-Local address (FE80::) after multiple configuration resets. Without an FE80 address, DHCPv6 communication is impossible.
- **The Fix:** A full system reboot was performed to re-initialize the IPv6 stack and regenerate the Link-Local address from the MAC address.

**📸 Screenshot:**

<img width="828" height="90" alt="Screenshot 2026-01-31 000336" src="https://github.com/user-attachments/assets/de92ebb9-2eaf-41ca-90f1-7eb280abae66" />

---
  
#### Verification & Results

##### Host-Side Verification (Linux)

After the reboot and running sudo `dhclient -6 -v eth0`, the host successfully obtained a lease.
- **Address Format:** The Global Unicast Address now has a /128 mask, confirming it is a stateful lease rather than a /64 SLAAC prefix.
- **DNS & Domain:** The /etc/resolv.conf file correctly reflects the parameters from the Cisco Pool.

*(Example: `2001:db8:acad:2:.../128` and search `stateful.lab`)*

**📸 Screenshot:**

<img width="276" height="77" alt="Screenshot 2026-01-30 234654" src="https://github.com/user-attachments/assets/2bb2bd15-6fcf-40e0-b428-b35663dae147" />

<img width="799" height="72" alt="Screenshot 2026-01-31 000502" src="https://github.com/user-attachments/assets/8a786322-a9fb-4b4e-8f98-48cea2818299" />

---

### Professional Insight
This lab demonstrates the "stubborn" nature of real-world operating systems compared to simulators. While Packet Tracer handles flag changes instantly, a real Linux Kernel requires manual intervention (Kernel tuning and IPv6 stack resets) to correctly transition from SLAAC to Stateful DHCPv6.

