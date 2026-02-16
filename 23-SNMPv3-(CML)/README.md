<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |


## Lab 23: Full-Stack Enterprise SNMPv3 Monitoring & Control

### Overview

#### 📍 Quick Navigation
* [📖 Overview](#overview)
* [🏗️ Architecture & Security Model](#architecture--security-model)
* [⚙️ Key Configuration](#key-configuration)
* [🚀 Server Services Setup](#server-services-implement-syslog--snmp)
* [🔍 Verification & Packet Analysis](#verification-packet-capture--analysis-read)
* [📝 Human Readable & SCP Files](#change-iso-mib-to-human-readable--scp-files-from-admin-snmpset---write-extra)
* [🛠️ Troubleshooting & Conclusion](#troubleshooting--audit-analysis)

This lab demonstrates the deployment of a **Native SNMPv3** management framework, bypassing legacy insecure protocols. We implemented a complete communication loop between a Cisco Router and an Ubuntu NMS, covering all major SNMP message classes with **AuthPriv** security (SHA/AES-128).

> [!IMPORTANT]
> #### In this Lab, we successfully tested and verified the following message types:

<div align="center">

|Class|Message Types|Lab Applications & Verification|
|-|-|-|
|**Read**|`Get`, `GetNext`, `GetBulk`|Performed full system audits and recursive walks using `snmpwalk` (GetBulk for efficiency).|
|**Write**|`Set`|Remotely modified the Router Hostname and Administratively Shutdown/Up interfaces.|
|**Notification**|`Trap`, `Inform`|Upgraded to **Informs** for reliable, acknowledged alerting from Agent to Manager.|
|**Response**|`Response`|Verified bi-directional flow: Every Get/Set/Inform received a corresponding Response PDU.|

</div>

**📸 Screenshot:**

<img width="1458" height="507" alt="Screenshot 2026-02-16 191603" src="https://github.com/user-attachments/assets/16a0789e-db7c-447d-b121-60daaa745129" />

---

### Architecture & Security Model

- **NMS (Ubuntu 24.04):** `192.168.99.99` (Manager)
- **Managed Agent (Cisco R1):** `192.168.99.1` (Agent)
- **Serurity Level:** `authPriv`
  - **Auth:** SHA (Password: `<Your_password>`) (e.g. `RangoAuthPass99`)
  - **Priv:** AES-128 (Password: `<Your_password>`) (e.g. `RangoAuthPass99`)

[⬆ Back to Top](#-quick-navigation)
 
---

### Key Configuration

#### 1. Cisco Router R1 (Syslog + SNMP)
<details>
<summary><b>⚙️ Click to see Full R1 Running-Config and Explanation</b></summary>

```bash

interface Ethetnet0/0
  no shut

interface Ethernet0/0.10
 encapsulation dot1Q 10
 ip address 192.168.10.1 255.255.255.0

interface Ethernet0/0.99
 encapsulation dot1Q 99
 ip address 192.168.99.1 255.255.255.0

logging trap debugging
logging source-interface Ethernet0/0.99
logging host 192.168.99.99
service timestamps log datetime msec

snmp-server view RANGO_VIEW iso included
snmp-server group RANGO_GROUP v3 priv read RANGO_VIEW write RANGO_VIEW
snmp-server user RangoAdmin RANGO_GROUP v3 auth sha RangoAuthPass99 priv aes 128 RangoAuthPass99
snmp-server host 192.168.99.99 informs version 3 priv RangoAdmin
snmp-server enable traps

```

#### To implement a secure management plane, the configuration follows a hierarchical structure: **View** → **Group** → **User** → **Host**.


**1. MIB View Definition**

- `snmp-server view RANGO_VIEW iso included`: Defines the "visibility" scope for the SNMP manager.

- **Details:** The keyword `iso included` grants access to the entire MIB (Management Information Base) tree, starting from the root `iso` node. Without this, the NMS would be "blind" to the device's internal statistics.

**2. Group & Permission Mapping**

- `snmp-server group RANGO_GROUP v3 priv read RANGO_VIEW write RANGO_VIEW`: Maps security requirements and access rights to a specific group.

- **Details:**

  - `v3 priv`: Enforces the **AuthPriv** (Authentication and Privacy) security level—the highest in SNMPv3.

  - `read/write RANGO_VIEW`: Assigns bi-directional permissions. This enables the Manager to both monitor (Read) and modify (Write/Set) device parameters remotely.

**3. User Authentication & Privacy (USM)**

- `snmp-server user RangoAdmin RANGO_GROUP v3 auth sha RangoAuthPass99 priv aes 128 RangoAuthPass99`: Creates the specific User-based Security Model (USM) credentials.

- **Details:**

  -  `auth sha`: Uses the **Secure Hash Algorithm (SHA)** for identity verification, ensuring the packet originates from a trusted source.

  - `priv aes`: Implements **Advanced Encryption Standard (AES)** with a 128-bit key. This encrypts the payload of every SNMP PDU, making it unreadable to packet sniffers.

 **4. Reliable Notification Delivery (Informs)**

- `snmp-server host 192.168.99.99 informs version 3 priv RangoAdmin`: Designates the NMS destination and upgrades the alerting mechanism.

- **Details:** Unlike standard "Traps" (UDP fire-and-forget), **Informs** require an application-layer acknowledgement (Response) from the NMS. If the Ubuntu server doesn't respond, the Router will retransmit the alert, ensuring **guaranteed delivery** of critical events.

**5. Global Trap/Inform Activation**

- `snmp-server enable traps`: Acts as the "Global Switch" for automated alerting.

- **Details:** This command enables the Agent to proactively generate notifications for various system events (e.g., Interface status changes, Config changes, or Environmental alarms).

</details>

#### 2. Cisco Switch (Syslog + SNMP)
<details>
<summary><b>⚙️ Click to see Full Switch Running-Config</b></summary>

```bash

interface Ethernet0/1
 switchport mode access
 switchport access vlan 10

interface Ethernet0/2
 switchport mode access
 switchport access vlan 99

interface Ethernet0/0
 switchport trunk encapsulation dot1q
 switchport trunk native vlan 1001
 switchport trunk allowed vlan 10,99
 switchport mode trunk

interface Vlan 99
 ip address 192.168.99.100 255.255.255.0
 no shut

ip default-gateway 192.168.99.1

logging trap debugging
logging source-interface vlan 99
logging host 192.168.99.99
service timestamps log datetime msec 

snmp-server view RANGO_VIEW iso included
snmp-server group RANGO_GROUP v3 auth read RANGO_VIEW write RANGO_VIEW
snmp-server user RangoAdmin RANGO_GROUP v3 auth sha RangoAuthPass99
snmp-server host 192.168.99.99 informs version 3 priv RangoAdmin
snmp-server enable traps
```

</details>

>[!WARNING]
> #### Hybrid Security Implementation Note
> In this lab, we intentionally maintain a **Hybrid SNMPv3 Security Model** to reflect real-world heterogeneity:
> - **Edge Router (R1):** Implements **authPriv (SHA/AES-128)**. As the gateway device, full encryption is mandatory to protect management traffic from external interception.
> - **Access Switch (SW1):** Implements **authNoPriv (SHA)**. Despite running an `ADVENTERPRISEK9` image and enabling SSH v2, the IOS parser restricts SNMPv3 security levels to `auth` only. (**But still more Secure than v2c!**)
> - **Conclusion:** This validates our ability to manage a multi-vendor/multi-capability environment. SW1 still benefits from **Data Integrity** and **Origin Authentication** (SHA), preventing unauthorized access even without payload encryption.

#### Security Level Summary 
|Security Level|Authentication|Encryption|Recommendation|
|-|-|-|-|
|**noAuthNoPriv**|Username only|None|**Do Not Use** (Insecure)|
|**authNoPriv**|MD5 or SHA|None|Low security monitoring (**CML Switch Limitation**)|
|**authPriv**|**HMAC-SHA**|**AES-128**|Best Practice (Router)|

[⬆ Back to Top](#-quick-navigation)

---

### Server Services Implement (Syslog + SNMP)

#### 🚀 Syslog 

For **Syslog Automation Implement Code** access [**Lab 22**](./22-NTP-(CML-%2B-PKT)) for more Information.

**📸 Screenshot:**

<img width="1377" height="189" alt="Screenshot 2026-02-16 192436" src="https://github.com/user-attachments/assets/f585a266-4060-4217-83ec-d564f48d267e" />

<img width="1716" height="60" alt="Screenshot 2026-02-16 160458" src="https://github.com/user-attachments/assets/0bcecc63-2fc0-4762-8a82-78a6210375ce" />

#### 🚀 SNMP (Simple Network Management Protocol)

- Download the SNMP service and confirm that the service is **running**: `sudo apt update && sudo apt install snmp snmpd -y` & `sudo systemctl status snmpd`

**📸 Screenshot:**

<img width="958" height="235" alt="Screenshot 2026-02-16 162823" src="https://github.com/user-attachments/assets/0c042395-2cb6-4043-9e17-bf6ec1066cec" />

- Also Check **Port 161** is already appeared: `ss -tulnp | grep :161`

<img width="1148" height="81" alt="image" src="https://github.com/user-attachments/assets/e9f86602-b17c-490f-9564-cc644d14065c" />

[⬆ Back to Top](#-quick-navigation)

---

### Verification Packet Capture & Analysis (READ)

#### 🔍 Router R1

- Use `show snmp user`, `show snmp group` & `show snmp` to verified the configuration on Router:

**📸 Screenshot:**

<div align="left">

<img width="325" height="153" alt="Screenshot 2026-02-16 162511" src="https://github.com/user-attachments/assets/489314cb-96ae-4de3-ba67-6173f8d3d6c3" />

</div>

<img width="562" height="94" alt="Screenshot 2026-02-16 210650" src="https://github.com/user-attachments/assets/e9159329-b9e3-4d30-acb9-533ccc7c80e7" />

<img width="530" height="516" alt="Screenshot 2026-02-16 162600" src="https://github.com/user-attachments/assets/26bba3c2-94d9-4fbc-9415-eebaa8680c2b" />

[⬆ Back to Top](#-quick-navigation)

---

#### 🔍 Ubuntu 

To manage the network from the **Ubuntu NMS**, we use the `snmpwalk` command. This command recursively queries the device's MIB tree using the **SNMPv3 USM (User-based Security Model).**

- Try to type **Wrong** and **Right** password:

#### ❌ Wrong: 

```bash
snmpwalk -v3 -l authPriv -u RangoAdmin -a SHA -A RangoAuthPass99 -x AES -X RangoPrivPass99 192.168.99.1
#                                                                                ^--- Wrong here
```

**📸 Screenshot:**

<img width="1002" height="34" alt="Screenshot 2026-02-16 162929" src="https://github.com/user-attachments/assets/e2b8bd11-fea3-43b6-a3b4-c61342fa8eb8" />

#### ✔️ Right: 

```bash
snmpwalk -v3 -l authPriv -u RangoAdmin -a SHA -A RangoAuthPass99 -x AES -X RangoAuthPass99 192.168.99.1
```

<details>
<summary><b>⚙️ Click to see Full Commands Explanation</b></summary>

|Parameter|Function|Technical Description|
|-|-|-|
|`-v3`|**Version**|Specifies the use of **SNMP Version 3**, enabling advanced security features like authentication and encryption.|
|`-l authPriv`|**Security Level**|	Sets the security level to **Authentication and Privacy**. This is the highest level, requiring both a hash for identity and encryption for the payload.|
|`-u RangoAdmin`|**Username**|The USM **Security Name** (User) created on the Cisco device. The Manager must match this name exactly.|
|`-a SHA`|**Auth Protocol**|Defines **SHA (Secure Hash Algorithm)** as the protocol for data integrity and origin authentication.|
|`-A [Pass]`|**Auth Password**|The pass-phrase used to generate the **Authentication Key**.|
|`-x AES`|**Priv Protocol**|	Defines **AES (Advanced Encryption Standard)** as the privacy/encryption protocol to secure the data payload.|
|`-X [Pass]`|**Priv Password**|The pass-phrase used to generate the **Privacy Key** (Encryption key).|
|`192.168.99.1`|**Target IP**|The destination IP address of the Managed Agent (Cisco Router R1).|

</details>

>[!TIP]
> #### **Why use `snmpwalk` instead of `snmpget`?**
> - `snmpget:` Only retrieves a single, specific OID (Object Identifier). It requires you to know the exact "address" of the data.
> - `snmpwalk:` Uses multiple `GetNext` or `GetBulk` requests to **automatically** navigate through the entire MIB sub-tree.

**📸 Screenshot:**

<img width="1212" height="781" alt="Screenshot 2026-02-16 164003" src="https://github.com/user-attachments/assets/8e9bd9f5-1562-45eb-8285-c5aa272ad471" />

- **There are more informations in the terminal**

<img width="496" height="223" alt="Screenshot 2026-02-16 163615" src="https://github.com/user-attachments/assets/eebf82c5-09ec-457c-b715-9c2e5c4d4fca" />

<img width="928" height="482" alt="Screenshot 2026-02-16 163623" src="https://github.com/user-attachments/assets/0a474b65-a1ff-4e4c-af75-df7fd59f3c3b" />

<img width="1913" height="71" alt="Screenshot 2026-02-16 173121" src="https://github.com/user-attachments/assets/191bf482-75ab-4a14-b2ac-7e9a1919c586" />

- As expected the packets through **CML Packet Capture** has been encrypted and because the `informs` commands you can see the `Request` and `Report` here. **(SNMP is UDP Port 161)**

<img width="556" height="512" alt="Screenshot 2026-02-16 163528" src="https://github.com/user-attachments/assets/041a3ad7-8b14-4f03-a7fe-a892582158a7" />

- You can see the increments of `Encoding errors` because I typed **wrong password** and `Number of requested variables`, `Get-Next PDUs` after executed the **right password** the request has been sent.

[⬆ Back to Top](#-quick-navigation)

---

### Change ISO MIB to Human Readable & SCP Files from Admin, `snmpset` - WRITE (Extra)

#### 📝 Generated a comprehensive system report and securely transferred it to the Admin Host using **SCP**:

```bash
snmpwalk -v3 -l authPriv -u RangoAdmin -a SHA -A RangoAuthPass99 -x AES -X RangoAuthPass99 192.168.99.1 > R1_SNMP_Report.txt
```
**📸 Screenshot:**

<img width="276" height="54" alt="Screenshot 2026-02-16 223246" src="https://github.com/user-attachments/assets/17f4e98a-2b26-48a9-97fb-6b221c235386" />

- At **Kali Admin**: `scp username@ipaddress:/home/username/R1_SNMP_Report.txt /home/kali/Desktop`

<img width="1675" height="246" alt="Screenshot 2026-02-16 164644" src="https://github.com/user-attachments/assets/d36476d1-3f42-4c1d-8519-d53b2164ccc1" />

<img width="1706" height="887" alt="Screenshot 2026-02-16 164711" src="https://github.com/user-attachments/assets/d6c61fcd-fbb3-431e-9e00-de63bdc934a5" />

[⬆ Back to Top](#-quick-navigation)

---

#### 📝 Change to Human Readable Contents

1. Install **MIBs Tool:** `sudo apt update && sudo apt install snmp-mibs-downloader -y`.
2. Then install MIBs from **Cisco & Other brands:** `sudo download-mibs`.
3. By default, Ubuntu **locks out MIBs**; you must **unlock** it: `sudo nano /etc/snmp/snmp.conf` find `mibs :` and add `#` to unlock.

**📸 Screenshot:**

<img width="687" height="171" alt="Screenshot 2026-02-16 165210" src="https://github.com/user-attachments/assets/b690613d-85df-4726-9754-66fe5d378b22" />

- Generated a report files again with a different name (e.g. R1_SNMP_Report) and **SCP** from Kali (Admin) to see the **differences**:

**📸 Screenshot:**

<img width="1717" height="881" alt="Screenshot 2026-02-16 165911" src="https://github.com/user-attachments/assets/3b043965-1a9e-41ad-8db5-9d37acc59ccd" />

[⬆ Back to Top](#-quick-navigation)

---

#### 📝 `snmpset` - WRITE

- Change Router's Name:

<img width="1706" height="280" alt="Screenshot 2026-02-16 164711" src="https://github.com/user-attachments/assets/d90f11d1-63f8-4a08-9ac0-85905815c702" />

- We know that **OID System Name** is `iso.3.6.1.2.1.1.5.0` with `STRING: "R1"`. To change to different name we execute this command:

```bash
snmpset -v3 -l authPriv -u RangoAdmin -a SHA -A RangoAuthPass99 -x AES -X RangoAuthPass99 192.168.99.1 iso.3.6.1.2.1.1.5.0 s RANGO_CORE_ROUTER
```

- `s`: Is **String value**.
- `iso.3.6.1.2.1.1.5.0`: **OID System Name**.

**📸 Screenshot:**

<img width="1327" height="63" alt="Screenshot 2026-02-16 173153" src="https://github.com/user-attachments/assets/4735d6e8-9743-424f-a9c3-57c609311377" />

<img width="718" height="296" alt="Screenshot 2026-02-16 173015" src="https://github.com/user-attachments/assets/056f9eae-d92e-4f00-9295-705c0b3af904" />

- **Syslog** notification.

<img width="183" height="77" alt="Screenshot 2026-02-16 173052" src="https://github.com/user-attachments/assets/f9bbe35a-f9d1-401e-8a1c-97d290ebbe75" />

- **Success** on changing **Router Name**.

- Same as `shutdown` and `no shutdown` an interfaces but this time try with MIB human readable:

**📸 Screenshot:**

<img width="1700" height="79" alt="Screenshot 2026-02-16 175031" src="https://github.com/user-attachments/assets/5ed2c4a4-6515-4008-837b-04d353d31211" />

<img width="1690" height="72" alt="Screenshot 2026-02-16 175049" src="https://github.com/user-attachments/assets/d20f8a29-3cb8-4bb8-a3a7-fd67853cba54" />

- As the picture said that `Ethernet 0/3` - `ifDescr.4`  with `ifAdminStatus.4` is `INTERGER = up(1)`
- Interger:
  - **1**: Up
  - **2**: Down

- Execute the commands to **shutdown Ethernet 0/3**:

```bash
snmpset -v3 -l authPriv -u RangoAdmin -a SHA -A RangoAuthPass99 -x AES -X RangoAuthPass99 192.168.99.1 IF-MIB::ifAdminStatus.4 i 2
```
**📸 Screenshot:**

<img width="1273" height="34" alt="Screenshot 2026-02-16 175249" src="https://github.com/user-attachments/assets/4263f148-8618-4ae7-bd0b-95548582cd3c" />

<img width="1715" height="61" alt="Screenshot 2026-02-16 175321" src="https://github.com/user-attachments/assets/d2298049-dae2-48b2-811c-5eeed476d32c" />

- **Syslog** notification.

<img width="868" height="113" alt="Screenshot 2026-02-16 175423" src="https://github.com/user-attachments/assets/a2f16867-5d71-4ec5-91a9-a3b5b5554976" />

- Confirm on Router and it works on both method.

>[!CAUTION]
> #### Because Switch don't have AES Encryption so you just only need `-a` and `-A` flags:
> ```snmpwalk -v3 -l authNoPriv -u RangoAdmin -a SHA -A RangoAuthPass99 192.168.99.2```
> #### Why Port 162 is not "Listening"?
> - **Port 161 (Agent Side):** Active by default on Router/Switch to listen for your **Queries** (`snmpwalk`/`snmpset`). This is why everything works!
> - **Port 162 (Manager Side)**: Only appears on the Ubuntu NMS when the `snmptrapd` service is started to "catch" incoming Traps/Informs.

- **Conclusion:** Since we are currently Active Polling (Manager asking Agent), only **Port 161** is required for the communication flow. Trap/Inform monitoring is handled via **Syslog** for this phase, with snmptrapd integration reserved for future scalability.

[⬆ Back to Top](#-quick-navigation)

---

### Troubleshooting & Audit Analysis
- **The Encoding Battle:** Identified `Encoding packets errors` caused by initial password mismatches. Resolved by synchronizing SHA/AES keys across the infrastructure.

- **The Audit Trail:** Integrated with **Syslog**. Every SNMP-based configuration change was logged in real-time on the LogAnalyzer Dashboard, providing a "Who/What/When" evidence chain.

- **Wireshark Evidence:** Captured and verified `encryptedPDU` flags, confirming that all management data is invisible to packet sniffers.

---

### 🏁 Conclusion
Lab 22 represents a fully matured Management Plane. By mastering **Native SNMPv3**, the infrastructure is no longer just "monitored"—it is controlled with high-level cryptographic assurance and reliable notification mechanisms.

|Metric|Status|
|-|-|
|**Data Confidentiality**|✅ AES-128 Encrypted|
|**Data Integrity**|✅ SHA Authenticated|
|**Operational Control**|✅ Read/Write Access|
|**Alert Reliability**|✅ Inform Acknowledged|

[⬆ Back to Top](#-quick-navigation)


| [⬅️ Previous Lab](../22-NTP-(CML-%2B-PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️] |
|:--- | :---: | ---: |

