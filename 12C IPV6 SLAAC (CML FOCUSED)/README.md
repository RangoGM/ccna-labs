<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |


## Lab 12C - IPv6 SLAAC (Router Advertisement & Linux Kernel Behavior)

### 1. Topology 

<img width="858" height="143" alt="Screenshot 2026-01-30 185413" src="https://github.com/user-attachments/assets/112c86f7-988f-46b1-b87f-df7bd82a59d9" />

This lab demonstrates **IPv6 SLAAC (Stateless Address Autoconfiguration)** using **real Linux hosts (Kali Linux)** connected to a router in **Cisco Modeling Labs (CML).**

The topology uses:

- **One router (R1)** acting as an IPv6 gateway and RA sender
- **Two Kali Linux hosts:**
  - **KALI_HOST** – receives IPv6 address via SLAAC
  - **KALI_ADMIN** – used to SSH into the router (IPv4 management only)
SLAAC is verified using real Linux kernel behavior, not Packet Tracer simulation
 
---

### 2. Lab Objectives

- Verify that **Linux IPv6 kernel stack is enabled**
- Observe **Router Advertisement (RA) behavior**
- Understand how **SLAAC depends on kernel IPv6 + RA**
- Confirm IPv6 address and default route assignment
- Distinguish **management host vs end host roles**

---

### 3. Devices

|**Device**|**Role**|
|-|-|
|R1|IPv6 Router (RA sender)|
|KALI_ADMIN|IPv4 management host (SSH)|
|KALI_HOST|IPv6 SLAAC end host|

*(Only **KALI_HOST** participates in IPv6 SLAAC
**KALI_ADMIN** does **NOT accept Router Advertisements**)*

---

### 4. IPv6 Addressing Plan

#### Router R1
- Interface **E0/0** → **KALI_HOST**
  - `2001:db8:10::1/64`
  - Sends Router Advertisements

📸 **Screenshot:**

<img width="1268" height="484" alt="Screenshot 2026-01-30 183113" src="https://github.com/user-attachments/assets/cdf9373c-eabb-4ebe-b2bf-fb1b2abbb064" />


#### KALI_HOST
- IPv6 address: **SLAAC (auto-generated)**
- Default gateway: **Link-local address learned via RA**

---

### 5. Key Concepts
- IPv6 kernel stack
- Router Advertisement (ICMPv6)
- SLAAC (RFC 4862)
- Link-local next-hop (`fe80::/10`)
- Linux `accept_ra`
- Kernel-managed IPv6 routing

---

### 6. Configuration & Verification

#### - Step 1 - Verify IPv6 Kernel is Enabled (CRITICAL)

On **KALI_HOST:**
```
cat /proc/sys/net/ipv6/conf/all/disable_ipv6
```
**Exptected output:**
```
0
```
✅ `0` = IPv6 kernel stack is enabled

❌ `1` = IPv6 disabled → SLAAC will never work


📸 **Screenshot:**

<img width="579" height="71" alt="Screenshot 2026-01-30 183957" src="https://github.com/user-attachments/assets/1c74c11c-2838-41e6-a53a-cbe4620308d8" />

---

#### - Step 2 - Verify IPv6 Enabled on Interface
```
cat /proc/sys/net/ipv6/conf/eth0/disable_ipv6
```
**Exptected output:**
```
0
```

📸 **Screenshot:**

<img width="579" height="71" alt="Screenshot 2026-01-30 184105" src="https://github.com/user-attachments/assets/04031667-ca94-48ec-8564-30b3ac06b8c6" />

---

#### - Step 3 - Verify Router Advertisement Acceptance (Before)
```
cat /proc/sys/net/ipv6/conf/eth0/accept_ra
```
**Exptected (initial state):**
```
0
```

📸 **Screenshot:**

<img width="485" height="65" alt="Screenshot 2026-01-30 184135" src="https://github.com/user-attachments/assets/45bb34d5-0018-458e-9082-c76ef6b55f47" />

> [!WARNING]
> #### Linux may ignore RA even if IPv6 kernel is enabled.

---

#### - Step 4 - Enable RA Acceptance (SLAAC)
```
sudo sysctl -w /net/ipv6/conf/eth0/accept_ra=2
```
**Re-check:**
```
cat /proc/sys/net/ipv6/conf/eth0/accept_ra
```
**Exptected:**
```
2
```

📸 **Screenshot:**

<img width="463" height="117" alt="Screenshot 2026-01-30 184222" src="https://github.com/user-attachments/assets/2394b769-a7d4-4ec1-b118-87cc714151e7" />

> [!TIP]
> #### `2` allows RA even if forwarding is enabled (common in lab & VM setups).

---

#### - Step 5 - Verify SLAAC IPv6 Address Assignment
```
ip -6 addr show eth0
```
**Expected output includes:**
```
inet 2001:db8:10:xxxx:xxxx:xxxx:xxxx:xxxx/64
proto kernel_ra
```

📸 **Screenshot:**

<img width="893" height="92" alt="Screenshot 2026-01-30 184423" src="https://github.com/user-attachments/assets/159d5639-fdbb-4702-96e8-b73379fe3056" />

✅ `proto kernel_ra` confirms **true SLAAC**

---

#### - Step 6 - Verify IP Routing Table
```
ip -6 route
```
**Expected output:**
```
2001:db8:10::/64 dev eth0 proto kernel
default via fe80::xxxx:xxxx:xxxx:xxxx dev eth0 proto ra
```

📸 **Screenshot:**

<img width="893" height="77" alt="(1)" src="https://github.com/user-attachments/assets/301e9137-30e2-4250-9267-68fb143676d4" />

✅ Default route learned via RA

✅ Next-hop is **link-local**, not global IPv6

---

#### - Step 7 - Connectivity Test
```
ping 2001:db8:10:1
```
> [!TIP]
> *(You can use `debug ipv6 icmp` to catch the ipv6 icmp packets from **KALI_HOST**)*

📸 **Screenshot:**

<img width="530" height="268" alt="Screenshot 2026-01-30 184554" src="https://github.com/user-attachments/assets/3e8e4e77-93d4-427e-83ff-49cccd73fbcb" />

<img width="1284" height="804" alt="Screenshot 2026-01-30 184800" src="https://github.com/user-attachments/assets/4c23d9a4-efa8-4011-bb85-caa07123cf7d" />


---

### 7. Result
- IPv6 kernel stack is enabled and active
- Router Advertisements are received correctly
- SLAAC assigns IPv6 address automatically
- Default route is learned via RA using link-local next-hop
- No static IPv6 configuration or DHCPv6 is required
- End host successfully communicates with router

---

### 8. Troubleshooting / Common Mistakes
- IPv6 kernel disabled (`disable_ipv6 = 1`)
- `accept_ra = 0` causing host to ignore RA
- Expecting global IPv6 next-hop (IPv6 uses link-local)
- Confusing DHCPv6 with SLAAC
- Assuming Packet Tracer behavior equals Linux kernel behavior

---

### 9. Notes

>[!NOTE]
> - SLAAC depends on **both IPv6 kernel and Router Advertisement**
> - RA alone is useless if IPv6 is disabled at kernel level
> - Linux provides fine-grained control over RA processing
> - This lab cannot be accurately simulated in Packet Tracer
> - Using real Kali Linux provides enterprise-realistic behavior

> [!WARNING]
> ####  SLAAC on Linux may take a few seconds to appear.
> - This is expected behavior. If configuration is correct, wait briefly before troubleshooting.**


📸 **Screenshot:**

<img width="925" height="235" alt="Screenshot 2026-01-30 183920" src="https://github.com/user-attachments/assets/c24158d4-3085-4711-87f2-7228782fff67" />

| [⬅️ Previous Lab](../12B%20IPv6%20Basic%20Connectivity%20%26%20Windows%20Stack%20Deep-Dive%20(CML)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../13%20IPv6%20Static%20Routing%20(CML%20%2B%20PKT)) |
|:--- | :---: | ---: |

