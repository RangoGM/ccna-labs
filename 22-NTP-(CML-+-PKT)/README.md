<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |


## Infrastructure Hardening: Automated Syslog & Secure NTP Orchestration

### Overview

This repository documents the evolution of a management network from decentralized logging to a **Hardened Enterprise Framework.** It features **Bash-based Automation**, **SQL Schema Patching**, and **Cryptographic Time Synchronization**.

#### 📌 Quick Navigation
* [🏗️ Project Architecture](#project-architecture--ip-schema)
* [🤖 Phase 1: Deployment & Automation (Lab 21)](#phase-1-deployment--automation-lab-21)
* [🕒 Phase 2: The NTP Hardening Battle (Lab 22)](#phase-2-the-ntp-hardening-battle-lab-22)
* [⚙️ Cisco Device Configurations](#key-configuration)
* [📡 Packet Capture & Analysis](#verification-packet-capture--analysis)
* [🕵️ The Mystery of the Tilde (~) & Dispersion Issues](#the-mystery-of-the-tilde-)
* [🔐 NTP Authentication Security](#ntp-authentication)
* [🛠️ Troubleshooting Cheat Sheet](#key-troubleshooting-commands-the-cheat-sheet)
* [🏁 Conclusion](#final-conclusion)

---

### Project Architecture & IP Schema

The network is built on a dedicated **Management Segment (VLAN 99)** to isolate administrative traffic from production data.

<div align="center">

|Device|Role|IP Address|VLAN|Primary Services|
|-|-|-|-|-|
|Ubuntu-Srv|Management Master|`192.168.99.99` |VLAN 99|Rsyslog, MariaDB, Apache2, NTPsec|
|R1-Core|L3 Edge|`192.168.99.1`|*N/A*|Syslog Client, NTP Peer|
|SW1-Dist|L2 Distribution|`192.168.99.100` |VLAN 99 |Syslog Client, NTP Peer|
|Admin-Host|Manage Access|`192.168.10.10` |VLAN 10|Web UI (LogAnalyzer 4.1.13)|

</div>

**📸 Screenshot:**

<img width="845" height="323" alt="Screenshot 2026-02-15 234751" src="https://github.com/user-attachments/assets/4e78f951-5eb3-48c0-9e4e-3d244d3bc6bc" />


---

### Phase 1: Deployment & Automation (Lab 21)

#### Scenario 1: The "10-Minute" Infrastructure Setup

To ensure consistency and avoid human error during the LAMP/Rsyslog installation, a custom **Bash Automation Script** was developed. This script transforms a vanilla Ubuntu/Kali instance into a fully functional Log Collector.

- **Automation Logic:**

  1. Dependency injection (Apache, MariaDB, PHP, Rsyslog-MySQL).

  2. Automatic database initialization and privilege granting.

  3. Automated LogAnalyzer source fetching and permission hardening (`chmod 666 -> 444`).

> [!TIP]
> #### Why Automation? In production, a Banking system can generate 100,000 logs/second. Manual setup is not an option; consistency in the SQL backend is the only way to ensure the database doesn't "explode" under load, save times and reduce errors as much as possible.

**📸 Screenshot:**

<img width="1183" height="782" alt="Screenshot 2026-02-15 210243" src="https://github.com/user-attachments/assets/a8b4fbcc-772c-4102-8e14-9a27e699eaea" />

- I built this code to minimize setup time and avoid as many errors as possible. With just one press of the Enter key to run the command, you can have a web UI LogAnalyzer running three services: MariaDB, Rsyslog, and Apache2.

- To download this file on your **Kali/Ubuntu/Debian** execute this command on your terminal:

```bash
wget "https://raw.githubusercontent.com/RangoGM/ccna-labs/refs/heads/main/21-Enterprise-Syslog-(CML-%2B-PKT)/lab21_auto.sh"
```

- Grant permission to run the file: `chmod +x lab21_auto.sh`

- Run the file and wait for less than 10 minutes, and you'll have a complete web UI based on Lab 21 without having to download and set up each component individually: `sudo ./lab21_auto.sh`

**📸 Screenshot:**

<img width="1719" height="888" alt="image" src="https://github.com/user-attachments/assets/f434018c-01ae-40cc-aef6-af63994bfde4" />

- Remember **Internet** access is still require to download services. And the [**Web UI Installation**](./21-Enterprise-Syslog-(CML-%2B-PKT)#phase-2-web-interface-log-analyzer](https://github.com/RangoGM/ccna-labs/tree/main/21-Enterprise-Syslog-(CML-%2B-PKT)#phase-2-web-interface-log-analyzer)) is the same as **Lab 21** but instead of a **blank webpage**, the code now **automatically fixes** the error for you.

- Try to `no shut` and `shutdown` random Interfaces on R1:

 **📸 Screenshot:**

<img width="1720" height="770" alt="Screenshot 2026-02-15 211224" src="https://github.com/user-attachments/assets/77591d80-1f2d-4ee5-9649-d06812caf492" />

- This is the **power of automation**.

- **Success:** Database `Syslog` and `Table SystemEvents` were automatically created and patched to match LogAnalyzer's schema.

[⬆ Back to Top](#-quick-navigation)

---

### Phase 2: The NTP Hardening Battle (Lab 22)

Since VMWare's time is synchronized via Internet NAT, I want to isolate this time within the local network & have Ubuntu act as the primary time server. This is where the real engineering happened. We transitioned from a simple clock to a **Secure Stratum 1 Master** with MD5 Authentication.

- Install NTP Services first through Internet: `sudo apt install ntp -y`

**📸 Screenshot:**

<img width="877" height="370" alt="Screenshot 2026-02-15 210645" src="https://github.com/user-attachments/assets/3c512fff-f433-4668-8ba8-c8078f926817" />


- **After Download and Remove NAT Network Adapter** to make Ubuntu Server act like a **Primary NTP Server**, next step is configuring the files in **NTP Services**: `sudo nano /etc/ntpsec/ntp.conf`

**📸 Screenshot:**

<img width="782" height="740" alt="Screenshot 2026-02-15 211356" src="https://github.com/user-attachments/assets/994ceba7-c9b1-4e0f-9029-6f80b5f62698" />

- Add '`#`' at first every lines start with `pool` or `server` and these command to make Ubuntu as Time Origin (Stratum 1):

```bash
server 127.127.1.0
fudge 127.127.1.0 stratum 1 
```

**📸 Screenshot:**

<img width="650" height="251" alt="Screenshot 2026-02-15 211640" src="https://github.com/user-attachments/assets/232f58bf-0934-4018-96d6-bedfe4d3b1e5" />

- Allow other network to sync:

```bash
restrict <your_subnet_ip> mask <subnet_mask> nomodify notrap
```

**📸 Screenshot:**

<img width="507" height="91" alt="Screenshot 2026-02-15 212040" src="https://github.com/user-attachments/assets/94b906ab-1104-4e93-862a-0d2f6faff630" />

- Save and restart the services: `sudo systemctl restart ntp` and verify if Ubuntu has `LOCAL(0)` which meant it is ready to act as a **Primary NTP Service**: `ntpq -p`

<img width="838" height="105" alt="Screenshot 2026-02-15 212148" src="https://github.com/user-attachments/assets/3445b867-8647-4167-ac6d-7a823deec691" />

- Verify if **NTP - UDP 123** appears (`sudo ss -tulnp | grep :123`) and and adjust the server time to match the current time as closely as possible (`sudo date -s "YYYY-MM-DD hh:mm:ss"`) and then restart the services.

<img width="651" height="116" alt="image" src="https://github.com/user-attachments/assets/4d44d7c2-f0c4-4127-a41e-7d1c446ee07b" />

<img width="474" height="130" alt="Screenshot 2026-02-15 222414" src="https://github.com/user-attachments/assets/62f963bf-3bc8-409c-abdf-cb40aac35d58" />

[⬆ Back to Top](#-quick-navigation)

---

### Key Configuration

#### 1. Cisco Router R1 (Syslog + NTP)
<details>
<summary><b>⚙️ Click to see Full R1 Running-Config</b></summary>

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
service timestamps log datetime msec localtime
service timestamps debug datetime msec localtime

ntp server 192.168.99.99
clock timezone <your_time_zone> <time_difference>
```

</details>

#### 2. Cisco Switch (Syslog + NTP)
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
service timestamps log datetime msec localtime
service timestamps debug datetime msec localtime

ntp server 192.168.99.99
clock timezone <your_time_zone> <time_difference>
```

</details>

[⬆ Back to Top](#-quick-navigation)

--- 

### Verification Packet Capture & Analysis

- Used `sudo tcpdump -i any port 123 -n` to see NTP Packets Exchange:

**📸 Screenshot:**

<img width="760" height="256" alt="Screenshot 2026-02-15 214435" src="https://github.com/user-attachments/assets/c50643fe-1143-449f-bf9b-85be77737fc1" />

<img width="1919" height="145" alt="Screenshot 2026-02-15 224502" src="https://github.com/user-attachments/assets/26a7ca4b-c703-4eb5-95ff-7012af3d31ad" />

<img width="1298" height="544" alt="Screenshot 2026-02-15 224524" src="https://github.com/user-attachments/assets/e1578ed7-8d3e-48c2-97fd-044447a780c2" />

- **NTP is UDP Port 123**

- Try to `shutdown` and `no shutdown` random interfaces on R1:

<img width="1180" height="40" alt="Screenshot 2026-02-15 222345" src="https://github.com/user-attachments/assets/e1549811-b348-4334-9c00-927a32f1f02a" />

- The time between Ubuntu and the router also coincided.

[⬆ Back to Top](#-quick-navigation)

---

>[!CAUTION]
> ### The Mystery of the Tilde (~)
> In **Packet Tracer**, everything works **normally**. This is **verified** by the `show ntp associations` command; you'll see an asterisk (`*`) before the (`~`) indicating that the device has **actually synchronized** its time, and `show clock details` will display `Time source is NTP`, which is **completely correct**. However, in this **virtualized environment**, I'm stuck at the (`~`) mark; the device **continues peering** but **hasn't synchronized** with the server yet, but still receives `Time source is NTP`.
>
> - **The Root Cause: Root Dispersion** exceeded **15,000ms.** In VMware/CML, virtual network jitter causes NTP to perceive the source as "unstable."
>
> - **The Workaround:** Since we couldn't change the physical latency of the VM, we verified the "Source of Truth" through: `show clock details` → **"Time source is NTP".**
>
> **📸 Screenshot:**
>
> <img width="636" height="170" alt="Screenshot 2026-02-16 020050" src="https://github.com/user-attachments/assets/510af1b7-5d2e-4c28-8961-b308fae58b9d" />
>
> - In **Packet Tracer** it should looks like this:
>
> <img width="610" height="218" alt="Screenshot 2026-02-16 020319" src="https://github.com/user-attachments/assets/b6424e28-e88b-4b1b-a987-67c5d7be05f2" />

[⬆ Back to Top](#-quick-navigation)

---

### NTP Authentication

>[!TIP]
> #### To make time synchronization more secure, NTP services use an Authentication Key to verify time synchronization, ensuring the synchronization is secure and protected from attacks and modifications by malicious actors.

**1. Create A Key File:** `sudo nano /etc/ntpsec/ntp.keys`

**2. Add this content to the files:** ```1 M NTPMaster9999``` - `1 is <ID>, M is <MD5>, then <Your_Password>`

**3. Config ntpsec to using the Key:** `sudo nano /etc/ntpsec/ntp.conf`

```diff
+ keys /etc/ntpsec/ntp.keys
+ trustedkey 1
+ controlkey 1
+ requestkey 1
```
**📸 Screenshot:**

<img width="672" height="371" alt="Screenshot 2026-02-16 022631" src="https://github.com/user-attachments/assets/f1706b00-facd-401d-a601-19985a48f9b5" />

4. Restart the services: `sudo systemctl restart ntpsec`.

*(Optional) Add 1 more router to other VLAN (e.g. VLAN 10) to test the Authentication*

**📸 Screenshot:**

<img width="885" height="479" alt="Screenshot 2026-02-15 234728" src="https://github.com/user-attachments/assets/d55d0374-2789-4b6e-9922-ae3d9d37dc50" />

#### 1. Cisco Router R_CLIENT (Syslog + NTP)
<details>
<summary><b>⚙️ Click to see Full R1 Running-Config</b></summary>

```bash

no ip routing

interface Ethernet0/0
  ip ad 192.168.10.100 255.255.255.0
  no shut

ip default-gateway 192.168.10.1

logging trap debugging
logging source-interface Ethernet0/0
logging host 192.168.99.99
service timestamps log datetime msec localtime
service timestamps debug datetime msec localtime

ntp authentication-key 1 md5 NTPMaster9999
ntp trusted-key 1
ntp server 192.168.99.99 key 1
ntp authenticate
clock timezone <your_time_zone> <time_difference>
```
</details>

**📸 Screenshot:**

<img width="1715" height="37" alt="Screenshot 2026-02-15 224303" src="https://github.com/user-attachments/assets/f25afda8-593f-41eb-9315-8875be5536ad" />

- **Syslog** works perfectly fine.

<img width="648" height="96" alt="Screenshot 2026-02-15 224319" src="https://github.com/user-attachments/assets/0bd2904c-bc32-4d97-a6c2-aa350687455d" />

<img width="285" height="58" alt="Screenshot 2026-02-15 224323" src="https://github.com/user-attachments/assets/2f2b0f2e-1620-4d4e-9df9-74fbb82e2a07" />

<img width="918" height="143" alt="Screenshot 2026-02-15 224348" src="https://github.com/user-attachments/assets/72fc0a92-0767-498d-aaaf-f37751ce6fe6" />

<img width="967" height="554" alt="Screenshot 2026-02-15 224721" src="https://github.com/user-attachments/assets/a54a08c4-2fdf-4fe6-b766-da9bb112bbc3" />

>[!WARNING]
> #### *Due to virtualized network jitter in CML/VMware, the NTP process might remain in the peering state (`~`) with high Root Dispersion. However, cryptographic integrity is verified via Wireshark, and the system clock successfully reports 'Time source is NTP'.*

- Don't worry about this I've test in **Packet Tracer** and it is **working normally** for both **default NTP** and **Authentication NTP**. Perhaps working with a **virtualized iOS environment** like this is still a **big challenge** for me.

[⬆ Back to Top](#-quick-navigation)

---

### Key Troubleshooting Commands (The Cheat Sheet)

<div align="center">

|Command|Purpose|
|-|-|
|`show ntp associations detail`|To check if `authenticated` and `sane` flags are present.|
|`ntpq -p`|  To verify the Ubuntu Master is synced to its local clock.|
|`tcpdump -i any port 123 -n`| To confirm NTP packets are flowing In/Out of the server.|
|`clock set ...`|Manual override to bring the offset within the NTP "Panic Threshold."|

</div>

---

### Final Conclusion

The success of this lab is not measured by the presence of an asterisk (`*`), but by the **integrity of the logs**. By the end of the session:

1. **Authentication is Active:** Verified via Wireshark.

2. **Time is Accurate:** Verified by matching Syslog timestamps to real-world time.

3. **Automation is Proven:** Verified by the rapid deployment of the Syslog stack.


[⬆ Back to Top](#-quick-navigation)


| [⬅️ Previous Lab](../21-Enterprise-Syslog-(CML-%2B-PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️] |
|:--- | :---: | ---: |
