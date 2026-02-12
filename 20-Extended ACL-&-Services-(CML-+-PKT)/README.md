| [⬅️ Back to Table of Contents](../README.md) |
| :--- |

## Lab 20: Advanced Network Security - Extended ACL & Service Hardening

### Overview

#### 📌 Quick Navigation
* [🏗️ Network Topology & IP Schema](#network-topology--ip-schema)
* [🛡️ Security Policy (Extended ACL 101)](#security-policy-extended-acl-101)
* [⚙️ Key Configurations](#key-configurations)
* [🔍 Windows Before Applying Extended ACL](#windows-before-applying-extended-acl)
* [🛡️ Windows After Applying Extended ACL](#windows-after-applying-extended-acl)
* [📡 Packet Capture & Analysis](#packet-capture--analysis)
* [🚀 Extra Credit: Troubleshooting & Service Hardening (FTP)](#extra-credit-troubleshooting--service-hardening-ftp)
* [🏁 Conclusion](#conclusion)

This lab demonstrates the implementation of **Extended Access Control Lists (ACLs)** on a Cisco Router-on-a-Stick topology. The primary goal is to enforce a Zero Trust-inspired policy where users are granted the "Principle of Least Privilege" (PoLP).

- **Scenario:** A corporate environment where Windows users can only access the Web service via DNS, while IT Administrators have full control. All other services (SSH, FTP, ICMP) are strictly restricted for general users.

**📸 Screenshot:**

<div align="center">

<img width="581" height="244" alt="rsz_1screenshot_2026-02-12_162633" src="https://github.com/user-attachments/assets/686ce8b0-a0b2-410a-bafa-6072e9516610" />

</div>

---

### Network Topology & IP Schema

The network is divided into three distinct VLANs managed by a core router **(R1).**

<div align="center">

|Device|Role|VLAN|IP Address|Gateway|
|-|-|-|-|-|
|**Kali-Admin**|IT Administrator|10|`192.168.10.11`|`192.168.10.1`|
|**Windows-PC**|General User|20|`192.168.20.11`|`192.168.20.1`|
|**Kali-Server**|Service Hub|*N/A*|`172.16.1.1/24`|`172.16.1.254`|

</div>

---

### Security Policy (Extended ACL 101)

<div align="center">
  
|Traffic Type|Source|Destination|Port|Action|
|-|-|-|-|-|
|**DNS**|Windows-PC|Kali-Server|UDP 53|**✔️ Permit**|
|**HTTP (Web)**|Windows-PC|Kali-Server|TCP 80|**✔️ Permit**|
|**ICMP (Ping)**|Windows-PC|Kali-Server|*N/A*|**❌ Deny**|
|**SSH**|Windows-PC|Kali-Server|TCP 22|**❌ Deny**|
|**FTP**|Windows-PC|Kali-Server|TCP 21|**❌ Deny**|
|**All IP**|Kali-Admin|Any|Any|**✔️ Permit**|


</div>

[⬆ Back to Top](#-quick-navigation)

---

### Key Configurations

#### 1. Cisco Router R1 (ACL & Routing)
<details>
<summary><b>⚙️ Click to see Full R1 Running-Config</b></summary>
 
```bash
interface Ethernet0/0.10
 encapsulation dot1Q 10
 ip address 192.168.10.1 255.255.255.0

interface Ethernet0/0.20
 encapsulation dot1Q 20
 ip address 192.168.20.1 255.255.255.0

interface Ethernet0/1
 ip address 172.16.1.254 255.255.255.0
 
ip access-list extended 101
 permit udp 192.168.20.0 0.0.0.255 host 172.16.1.1 eq 53
 permit tcp 192.168.20.0 0.0.0.255 host 172.16.1.1 eq 80
 deny icmp 192.168.20.0 0.0.0.255 host 172.16.1.1
 deny tcp 192.168.20.0 0.0.0.255 host 172.16.1.1 eq 21
 deny tcp 192.168.20.0 0.0.0.255 host 172.16.1.1 eq 22 log
 permit ip any any
 
interface Ethernet0/0.20
   ip access-group 101 in
```
</details>

#### 2. Kali-Server Hardening (FTP, DNS, SSH, Web Server Services)

>[!NOTE]
> - Since **SSH** is already available in **Kali and PowerShell**, I won't be setting it up in this lab. If you want to use **SSH**, just execute the command `username@ipaddress`. 
> - For DNS, please refer to this 👉 [**LAB 17**](../17-Hybrid-DNS-Infrastructure-(CML)) for instructions on setting up Linux DNS; therefore, the focus here will be on setting up FTP and a Web Server.
>

- Install `vsftpd` & `apache2`

`sudo apt update && sudo apt install apache2 vsftpd -y`

<img width="735" height="187" alt="Screenshot 2026-02-12 134132" src="https://github.com/user-attachments/assets/2c7f4765-8491-4cf5-8b67-fe74b757a19f" />

- When both services have installed execute these command to check if the services is enabled:
  - Web Service: `systemctl status apache2.service`
  - FTP Service: `systemctl status vsftpd.service`
- If both are not enabled yet we need to enabled it by excute these command:
  - Web Service: `sudo systemctl start apache2`
  - FTP Service: `sudo systemctl start vsftpd`

>[!IMPORTANT]
> #### Verify if **Port 21 - FTP**, **Port 22 - SSH**, **Port 80 - HTTP** are in **LISTENING** state:
> **📸 Screenshot:**
>
> <img width="1184" height="125" alt="Screenshot 2026-02-12 140125" src="https://github.com/user-attachments/assets/f976183a-6402-48b7-b1ad-dc6c0daf4f19" />

- If you want to change the structure of a Website, this location is where you can adjust the Web Page by execute the command: `sudo nano /var/www/html/index.html`

**📸 Screenshot:**

<img width="1715" height="919" alt="image" src="https://github.com/user-attachments/assets/00d54a39-129d-4ac5-9841-8bd105bb82b8" />


- This is how it looks like in default. But in this lab by focusing on Extended ACL we are not go in depth at HTML so I gonna leave at default.
- If curious this is how the Web Page gonna looks like when we changing the HTML code in `/var/www/html/index.html` *(Im not HTML expert just use AI for support)*

<img width="1717" height="920" alt="Screenshot 2026-02-12 235113" src="https://github.com/user-attachments/assets/a565e9f0-83ed-46ab-a87b-992b8ae6856d" />


> [!IMPORTANT]
> #### Verify if the **FTP** is working
> **📸 Screenshot:**
>
> <img width="511" height="124" alt="Screenshot 2026-02-12 140750" src="https://github.com/user-attachments/assets/33f5be99-097d-4453-aecd-17879297ce9b" />



[⬆ Back to Top](#-quick-navigation)


---

### Windows Before Applying Extended ACL

**📸 Screenshot:**

<img width="840" height="643" alt="Screenshot 2026-02-12 145402" src="https://github.com/user-attachments/assets/17645ca0-4f5c-4cc5-8299-34e33b5ffa6a" />

<img width="1025" height="771" alt="Screenshot 2026-02-13 000236" src="https://github.com/user-attachments/assets/f2b23278-b235-4263-a784-013c6fc57e9e" />

<img width="848" height="316" alt="Screenshot 2026-02-12 145834" src="https://github.com/user-attachments/assets/e632dd9e-111d-41f8-aec2-b888ed9402c3" />

- Windows can sends **ICMP Packets**, **SSH**, **FTP** to server, we only need Windows can **only access** the Web Site through **IP Address** or **DNS**, sends **ICMP Packets** to other VLAN not the **Server**, Only **Admin** have all permission so we needs applying the Extended ACL to perform that.

---

### Windows After Applying Extended ACL

**📸 Screenshot:**

<img width="835" height="195" alt="Screenshot 2026-02-12 151145" src="https://github.com/user-attachments/assets/4f076fc4-5446-42d3-87f3-360aa3be7414" />

<img width="449" height="154" alt="Screenshot 2026-02-12 151151" src="https://github.com/user-attachments/assets/d97b9a6f-514c-454d-8594-c8e303a29276" />

<img width="1023" height="644" alt="Screenshot 2026-02-13 001341" src="https://github.com/user-attachments/assets/0e5ef707-0758-42fc-8b60-96866c4cf1f8" />

>[!WARNING]
> - Don't get tricked by this, I denied **ICMP Packets** to the **Server** not the **Port 53** via **DNS** so that is why the **Ping is drop** when **still maintaining** access to the Web Page.
> - This demonstrated is to see how the powerful of Extended ACL and it diversity.

- Verifiy the increments:

**📸 Screenshot:**

<img width="661" height="153" alt="Screenshot 2026-02-12 171045" src="https://github.com/user-attachments/assets/f3d471e7-bd70-434e-a5df-6912b1eb03c3" />

<img width="904" height="60" alt="Screenshot 2026-02-12 160943" src="https://github.com/user-attachments/assets/c3759094-69e2-4fa9-b98b-4b40e4d8f1d8" />

- The `log` command in `deny tcp 192.168.20.0 0.0.0.255 host 172.16.1.1 eq 22 log` to show log messages every time **Windows** accesses the **Server** via **SSH** without authorization.


--- 

### Packet Capture & Analysis

- **Port 21: FTP (TCP)**

**📸 Screenshot:**
  
<img width="1918" height="440" alt="Screenshot 2026-02-12 151928" src="https://github.com/user-attachments/assets/4d77c2cd-3d33-4c77-b07c-3b010e1d51b5" />

- **Port 22: SSH (TCP)**

**📸 Screenshot:**

<img width="1918" height="408" alt="Screenshot 2026-02-12 152252" src="https://github.com/user-attachments/assets/e82fcb07-5325-4a81-a01e-04349d227090" />

- **Port 53: DNS (UDP) & Port 80: HTTP (TCP)**

**📸 Screenshot:**

<img width="1919" height="507" alt="Screenshot 2026-02-12 152434" src="https://github.com/user-attachments/assets/3f7c06b5-89d4-41f3-9ce2-b2b57114a6a4" />


[⬆ Back to Top](#-quick-navigation)


--- 

>[!NOTE]
> #### This step is optional for those who want to fully set up the FTP service for file transfer instead of just checking if access to the FTP server is working.

### Extra Credit: Troubleshooting & Service Hardening (FTP) 

This section documents the transition from a default restricted environment to a fully functional, secure file transfer system.

#### 1. Initial Setup: The "Shell Expansion" Hurdle

The goal was to create a secret file named `Topsecret.txt` on the **Kali-Admin** node.

- **The Issue:** Using double quotes with an exclamation mark (`echo "..."!`) triggered the Zsh Shell's "History Expansion" feature, resulting in a `dquote>` hang.

```diff
+ Kali@Kali$ echo "SIUUUUUUUU! LAB 20 Extended ACL is successful!" > Topsecret.txt
dquote> // Stuck here can not create file.
``` 

- **The Fix:** Switched to **Single Quotes** (' ') to treat the exclamation mark as literal text, preventing shell interference.

```diff
- Kali@Kali$ echo "SIUUUUUUUU! LAB 20 Extended ACL is successful!" > Topsecret.txt
+ Kali@Kali$ echo 'SIUUUUUUUU! LAB 20 Extended ACL is successful!' > Topsecret.txt
``` 

- **Result:** `File Topsecret.txt` was successfully created with the intended content.

**📸 Screenshot:**

<img width="787" height="146" alt="Screenshot 2026-02-12 154344" src="https://github.com/user-attachments/assets/92a4c97d-ec4b-4ff2-85a7-a0dc31145663" />

#### 2. Phase 1: The "550 Permission Denied" Wall
The first attempt to upload the file to the Kali-Server (172.16.1.1) failed.

- **Symptom:** After logging in via FTP, the command `put Topsecret.txt` returned an **Error 530/550: Permission denied.**

- **Root Cause:** Two layers of protection were active:

1. **Service Level:** The `vsftpd` service was in a default "Read-Only" mode.

2. **OS Level:** The destination directory was owned by the root user, blocking standard users from writing data.

**📸 Screenshot:**

<img width="1246" height="280" alt="Screenshot 2026-02-12 154646" src="https://github.com/user-attachments/assets/ab57aff3-fd6a-40c0-aeeb-a8b77ad9e142" />

#### 3. Phase 2: System Hardening & User Isolation

To resolve this professionally, I implemented a dedicated administration account and hardened the service configuration.

- **Step A (User Management):** Created a dedicated user `Admin2` on the server and transferred directory ownership using `chown Admin2:Admin2 /home/Admin2.`

**📸 Screenshot:**

<img width="527" height="335" alt="Screenshot 2026-02-12 154938" src="https://github.com/user-attachments/assets/e032e93d-b7b4-444b-91e9-00e83308f68c" />


- **Step B (Service Configuration):** Modified `/etc/vsftpd.conf` to enable write permissions:

  - `write_enable=YES`: Unlocked the ability to upload files.

  - `local_umask=022`: Ensured uploaded files have the correct permission bits (644).

>[!TIP]
> #### Find the `write_enable=YES` & `local_umask=022`. There's a '#' before it, just delete it and you're done.

```diff
- #write_enable=YES
+ write_enable=YES

- #local_umask=022
+ local_umask=022
```

**📸 Screenshot:**

<img width="614" height="160" alt="Screenshot 2026-02-12 155130" src="https://github.com/user-attachments/assets/392642cb-2243-4516-8af7-70d027dc2ada" />


- **Step C (Service Restart):** Applied changes using `sudo systemctl restart vsftpd.`

#### 4. Phase 3: Successful Data Transmission
With the permissions corrected, the transfer was re-attempted from Kali-Admin using the new credentials.

- **Verification:** The `put` command was executed, resulting in the legendary **"226 Transfer complete"** message.

- **Proof of Work:** A remote `ls` command confirmed that `Topsecret.txt` (48 bytes) was successfully residing on the server.

**📸 Screenshot:**

<img width="1258" height="471" alt="Screenshot 2026-02-12 155614" src="https://github.com/user-attachments/assets/fb6c07b7-542c-41e2-8723-2dcd8bb95fd9" />


#### 5. Final Audit: Server-Side Integrity Check

The final step involved a physical audit on the Kali-Server to ensure the data was uncorrupted.

- **Command:** `sudo cat /home/Admin2/Topsecret.txt`

- **Validation:** The server successfully outputted the string: **"SIUUUUUUUUUU! Lab 20 Extended ACL is successful!"**

- **Conclusion:** This verifies that the **Extended ACL** on the router correctly permitted the traffic, and the **Server Permissions** correctly processed the data.

<img width="410" height="204" alt="Screenshot 2026-02-12 160027" src="https://github.com/user-attachments/assets/7030a55d-6edf-4462-a24a-2f49001abe79" />


[⬆ Back to Top](#-quick-navigation)


---

### Conclusion

Lab 20 successfully demonstrates the power of Extended ACLs in granular traffic filtering. By blocking ICMP and management protocols (SSH/FTP) while maintaining DNS and Web connectivity, we have created a secure, functional, and hardened network environment.
SIUUUUUU! Lab 20 Completed! 🔥

>[!IMPORTANT]
> #### Port Table and TCP, UDP:

<div align="center">

|**TCP**|**UDP**|**TCP & UDP**|
|-|-|-|
|FTP data (**20**)|DHCP server (**67**)|DNS (**53**)|
|FTP control (**21**)|DHCP client (**68**)||
|SSH (**22**)|TFTP (**69**)||
|Telnet (**23**)|SNMP Agent (**161**)||
|SMTP (**25**)|SNMP Manager (**162**)||
|TACACS (**49**)|NTP (**123**)||
|HTTP (**80**)|Syslog (**514**)||
|POP3 (**110**)|RADIUS (**1812 & 1813**)||
|HTTPS (**443**)|||
|Puppet Master (**8140**)|||
|Chef Server (**10002**)|||

</div>

[⬆ Back to Top](#-quick-navigation)


| [⬅️ Previous Lab](../19-NAT-(CML-+-PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️] |
|:--- | :---: | ---: |

