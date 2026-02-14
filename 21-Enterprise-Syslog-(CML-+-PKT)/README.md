<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |

## Lab 21: Enterprise Centralized Logging - Rsyslog, MariaDB & Web UI Hardening

### Overview

#### 📌 Quick Navigation

* [🏗️ Network Topology & IP Schema](#network-topology--ip-schema)
* [⚙️ Key Configurations](#key-configurations)
  * [Phase 1 Configuration (Kali-Server Syslog Implementation](#phase-1-kali-server-syslog-implementation-rsyslog-mariadb-apache2)
  * [Phase 2 Configuration (Log Analyzer)](#phase-2-web-interface-log-analyzer)
* [💎 The "Golden" SQL Schema (Fixing Web UI)](#-the-golden-sql-schema-fixing-web-ui)
  * [Phase 1 Explanation](#phase-1-case-sensitivity-normalization-the-translator)
  * [Phase 2 Explanation](#phase-2-structural-enhancement-the-fixing-spinning-circle)
  * [Phase 3 Explanation](#phase-3-a-common-bug-in-syslog-systems-is-the-display-of-_gateway-instead-of-the-actual-ip-address-this-occurs-due-to-reverse-dns-lookups-on-the-local-management-network)
  * [Phase 4 Explanation](#phase-4-verify-desc-systemevents)
  * [Local Logging (The Black Box)](#local-logging-the-black-box)
* [📡 Packet Capture & Analysis](#verification-packet-capture--analysis)
* [🔍 Verification & Troubleshooting](#-verification--troubleshooting)
* [🏁 Conclusion](#conclusion)



This lab focuses on the transition from traditional file-based logging to a **Centralized Database-Driven Logging System**. The objective is to manage high-volume logs from Cisco infrastructure (Router/Switch) using a scalable, searchable, and professional Web Dashboard.

- **Scenario:** A corporate network where all security events from R1 and SW1 must be stored in a central MariaDB database on Kali Linux. The logs must be accessible via a hardened Web UI, bypassing DNS issues and resolving legacy schema conflicts.

**📸 Screenshot:**

<div align="center">

<img width="806" height="262" alt="Screenshot 2026-02-15 035038" src="https://github.com/user-attachments/assets/8387c7a7-6533-4559-bca9-58670d5fc8d2" />


</div>

---

### Network Topology & IP Schema

The infrastructure relies on the management network to transport Syslog messages **(UDP 514)**.

<div align="center">

|Device|Role|IP Address|Service|
|-|-|-|-|
|**R1**|Log Source|`10.0.99.1`|Syslog Client|
|**SW1**|Log Source|`10.0.99.2` (VLAN 99)|Syslog Client|
|**Kali-Server**|Log Collector|`10.0.99.100`|MariaDB + Rsyslog|
|**Web Portal**|Visualization|`http://10.0.99.100/syslog` or `http://localhost/syslog`|LogAnalyzer 4.1.13|

</div>

---

### Key Configurations

#### 1. Cisco Router R1 (Syslog)
<details>
<summary><b>⚙️ Click to see Full R1 Running-Config</b></summary>

```bash
interface Ethernet0/2.10
 encapsulation dot1Q 10
 ip address 10.0.10.1 255.255.255.0

interface Ethernet0/2.99
 encapsulation dot1Q 99
 ip address 10.0.99.1 255.255.255.0

logging trap debugging
logging source-interface Ethernet0/2.99
logging host 10.0.99.100
service timestamps log datetime msec
```

</details>

#### 2. Cisco Switch (Syslog)
<details>
<summary><b>⚙️ Click to see Full Switch Running-Config</b></summary>

```bash

interface Ethernet0/0
 switchport mode access
 switchport access vlan 10

interface Ethernet0/1
 switchport mode access
 switchport access vlan 99

interface Ethernet0/2
 switchport trunk encapsulation dot1q
 switchport trunk native vlan 1001
 switchport trunk allowed vlan 10,99
 switchport mode trunk

interface Vlan 99
 ip address 10.0.99.2 255.255.255.0
 no shut

ip default-gateway 10.0.99.1

logging trap debugging
logging source-interface vlan 99
logging host 10.0.99.100
service timestamps log datetime msec
```

</details>

[⬆ Back to Top](#-quick-navigation)

---

### Phase 1: Kali-Server Syslog Implementation (Rsyslog, MariaDB, Apache2)

```bash
sudo apt update && sudo apt install apache2 mariadb-server php libapache2-mod-php php-mysql rsyslog-mysql wget -y
```

- When downloading you will see this small blue screen:

**📸 Screenshot:**

<img width="1244" height="631" alt="Screenshot 2026-02-14 174335" src="https://github.com/user-attachments/assets/27a563f9-531a-4078-a688-9e6775160662" />

- Enter `Yes` and type in the `Password`.

<img width="1243" height="609" alt="Screenshot 2026-02-14 174350" src="https://github.com/user-attachments/assets/89322232-3022-49e5-add1-bd34d89728c4" />

>[!WARNING]
> #### If error occured enter the `Abort` and this issue happens when the service is being downloaded simultaneously but has not yet been enabled so we need to enable it first and check if it in `Active` mode by excute the command:

```bash
sudo systemctl start mariadb
sudo systemctl status mariadb
```

**📸 Screenshot:**

<img width="1691" height="560" alt="Screenshot 2026-02-14 225923" src="https://github.com/user-attachments/assets/e14f088d-24d5-4be9-89f3-bb7c8eafdccf" />


- Besides that check if other services are in `Active` mode:

```bash
sudo systemctl start apache2
sudo systemctl status apache2
sudo systemctl start rsyslog
sudo systemctl status rsyslog
```

- Last but not least check if `Port 514` - **Syslog UDP protocol** appears:

**📸 Screenshot:**

<div align="center">

<img width="508" height="77" alt="Screenshot 2026-02-14 230644" src="https://github.com/user-attachments/assets/33be3d86-7307-4826-9650-39927c03856a" />

</div>

- If it is not appeared yet, deletete '`#`' before `module(load="imudp")` & `input(type="imudp" port="514")` in (`etc/rsyslog.conf`)

<div align="center">

<img width="565" height="299" alt="Screenshot 2026-02-14 231753" src="https://github.com/user-attachments/assets/6d9e3bd7-72a8-4c86-9ef9-fc065fada0a6" />


</div>

>[!IMPORTANT]
> #### For this lab to function perfectly, the above conditions must be met: `apache2`, `rsyslog`, `mariadb` & **Port 514**

- Excecute the command to fixing occurs after enable `mariadb`: `sudo apt --fix-broken install -y`

**📸 Screenshot:**


<img width="766" height="81" alt="Screenshot 2026-02-14 174721" src="https://github.com/user-attachments/assets/e66757c7-8a24-4707-8d83-dc93d2409491" />


- Reconfigured the last blue screen: `sudo dpkg-reconfigure rsyslog-mysql`


<img width="1120" height="285" alt="Screenshot 2026-02-14 175010" src="https://github.com/user-attachments/assets/ee5382f7-9011-4ef7-ae9d-0b8ce9ea84b8" />


<img width="1233" height="401" alt="Screenshot 2026-02-14 174828" src="https://github.com/user-attachments/assets/26385d14-0ad6-41ba-9b9c-af280c49787e" />

- Enter `Yes`

<img width="1211" height="305" alt="Screenshot 2026-02-14 174834" src="https://github.com/user-attachments/assets/8628a7ea-6428-46bd-8453-3ec96fc5a856" />

- Enter `Unix socket`

<img width="1204" height="499" alt="Screenshot 2026-02-14 174846" src="https://github.com/user-attachments/assets/60d23abd-87b9-4f0e-b234-70b09affacbf" />

- Enter `default`
- **Reason:** This is the safest and most compatible option for MariaDB on Kali Linux currently. It will help LogAnalyzer connect to the database without encountering complex password encryption errors.

<div align="center">

<img width="927" height="282" alt="Screenshot 2026-02-14 174908" src="https://github.com/user-attachments/assets/678ca64d-e1d9-4c88-b099-ab59ae405762" />

<img width="1195" height="388" alt="Screenshot 2026-02-14 174918" src="https://github.com/user-attachments/assets/1de33ea2-1989-4ad6-aba2-51df043daa71" />


<img width="1207" height="237" alt="Screenshot 2026-02-14 174947" src="https://github.com/user-attachments/assets/e853c306-dbe0-4731-9f00-61fa3447aa76" />

<img width="543" height="249" alt="Screenshot 2026-02-14 174952" src="https://github.com/user-attachments/assets/606cdc92-746e-46c1-9781-eaf51d756be3" />

<img width="1232" height="290" alt="Screenshot 2026-02-14 175000" src="https://github.com/user-attachments/assets/f7988259-2006-4360-b410-f8584ea9a575" />

</div>

- Enter `OK`, type and re-type to confirm your `password`.

- Check module file in (`etc/rsyslog.d/mysql.conf`) by execute `sudo nano /etc/rsyslog.d/mysql.conf`

<img width="1247" height="136" alt="Screenshot 2026-02-14 175053" src="https://github.com/user-attachments/assets/ffddb7b9-ed8c-4b83-9d27-e9d6a6280acb" />

- Restart the services: `sudo systemctl restart rsyslog mariadb apache2`

[⬆ Back to Top](#-quick-navigation)

---

### Phase 2: Web Interface (Log Analyzer)

<details>
<summary><b>⚙️ Click to see Full Configuration</b></summary>

```bash
# Move to web root and fetch LogAnalyzer source
cd /var/www/html/
sudo wget https://download.adiscon.com/loganalyzer/loganalyzer-4.1.13.tar.gz

# Extract and rename directory for a cleaner URL path
sudo tar -xzvf loganalyzer-4.1.13.tar.gz
sudo mv loganalyzer-4.1.13/src syslog
sudo rm -rf loganalyzer-4.1.13*

# Initialize configuration file and set write permissions for the web-installer
cd /var/www/html/syslog
sudo touch config.php
sudo chmod 666 config.php

# Assign ownership to the web server user (Apache/www-data)
sudo chown -R www-data:www-data /var/www/html/syslog
```
</details>

- Open Web Browser and access `http://localhost/syslog/install.php` or `http://<Your_Server_IP>/syslog/install.php`

> [!CAUTION]
> #### Keep Click `Next` to Step 7 and Configure exactly like Picture
> **📸 Screenshot**
> <img width="701" height="280" alt="Screenshot 2026-02-14 180101" src="https://github.com/user-attachments/assets/ea3da858-202a-44a5-bfdd-644d45ff9d9f" />
> - About the **Database Name** & **Database Tablename** you must **type exactly** the name in **MySQL/MariaDB identifiers** because they correspond to actual directories and files on the disk.

<img width="1146" height="753" alt="Screenshot 2026-02-14 180024" src="https://github.com/user-attachments/assets/09fa28c0-c963-44f9-b37d-a04557c35241" />

<details>
<summary><b>⚙️ Click to see Full Explanation</b></summary>
  
#### 1. The Importance of Case Sensitivity

- **Database Name:** In this lab, the database is explicitly named `Syslog` (with a capital **S**). You must type it exactly as shown in `SHOW DATABASES;`.

- **Table Name:** The primary data table is `SystemEvents` (capital **S** and **E**). If you type `systemevents`(default) in your SQL commands or Web configuration, the system will return a "Table does not exist" error.

- **Best Practice:** Always run `SHOW TABLES;` after selecting your database to verify the exact casing before running `ALTER` or `SELECT` queries.

#### 2. Understanding the Access Command: `sudo mysql -u root`

This command is your "Master Key" to the database engine. Here is the breakdown:

- `mysql`: The client program used to interact with the MariaDB/MySQL server.

- `-u`: The **User flag.** It tells the database which account you are trying to log in with.

- `root`: The **Administrative user** for the database. Note that the "Database root" is different from the "Linux root," though they often work together in Kali Linux via socket authentication.

- `SHOW DATABASES;`: Identify the correct Database casing
- `USE Syslog;`: Select the database
- `SHOW TABLES;`: Identify the correct Table casing


</details>

**📸 Screenshot**

<img width="1720" height="882" alt="Screenshot 2026-02-15 011149" src="https://github.com/user-attachments/assets/79f0d02d-b3ee-435f-afe1-26a054ac6cb6" />

- The WebPage is **Blank**: Because the **database** and **web UI** were not **synchronized** and **some columns were missing**, we had to **"patch"** it up.

[⬆ Back to Top](#-quick-navigation)

---

#### 💎 The "Golden" SQL Schema (Fixing Web UI)

>[!IMPORTANT]
> #### Standard `rsyslog-mysql` installations use PascalCase columns (e.g., `ProcessID`), while LogAnalyzer 4.1.13 expects `lowercase` (e.g., `processid`). Failing to sync these causes Error 500 (Blank Page) or the Infinite Loading Circle.

<details>
<summary><b>⚙️ Click to see Full Configurations</b></summary>


```SQL
USE Syslog;

-- Phase 1: Case-Sensitivity Normalization
ALTER TABLE SystemEvents CHANGE NTSeverity ntseverity int;
ALTER TABLE SystemEvents CHANGE Importance importance int;
ALTER TABLE SystemEvents CHANGE EventSource eventsource varchar(60);
ALTER TABLE SystemEvents CHANGE EventCategory eventcategory int;
ALTER TABLE SystemEvents CHANGE EventLogType eventlogtype varchar(60);

-- Phase 2: Structural Enhancement (Fixing Spinning Circle)
ALTER TABLE SystemEvents ADD COLUMN processid varchar(60) DEFAULT '' AFTER SysLogTag;
ALTER TABLE SystemEvents ADD COLUMN messagetype varchar(60) DEFAULT '' AFTER processid;
ALTER TABLE SystemEvents ADD COLUMN fromip varchar(60) DEFAULT '' AFTER Message;
ALTER TABLE SystemEvents ADD COLUMN eventid int DEFAULT 0 AFTER messagetype;
ALTER TABLE SystemEvents ADD COLUMN checksum int DEFAULT 0;

-- Phase 3: Force '_gateway' to exactly Router IP Address
UPDATE SystemEvents SET FromHost = '10.0.99.1' WHERE FromHost = '_gateway';

-- Phase 4: Final Check
DESC SystemEvents;

```

</details>

[⬆ Back to Top](#-quick-navigation)

#### 🧠 The Logic Behind the SQL Hardening

<details>
<summary><b>⚙️ Click to see Full Phase 1 Explanation</b></summary>

##### Phase 1: Case-Sensitivity Normalization (The "Translator")
In Linux, `NTSeverity` and `ntseverity` are seen as two different things.

- **The Problem:** Rsyslog creates the table using PascalCase (e.g., `EventSource`). However, LogAnalyzer's PHP code looks for lowercase (e.g., `eventsource`). When the names don't match, the Web UI crashes or shows a "Blank Page" (Error 500).

- **The Fix:** The `CHANGE` command renames the column while keeping the data type.

  - *Syntax:* `ALTER TABLE [Table] CHANGE [Old_Name] [New_Name] [Data_Type];`
 
**📸 Screenshot**

<img width="1719" height="889" alt="image" src="https://github.com/user-attachments/assets/f98fdbee-956f-4f20-89fa-6c36852b628b" />

- Great! The **LogAnalyzer WebPage** now is **Active** try to execute `no shutdown` and `shutdown` on Router:

<img width="1182" height="42" alt="Screenshot 2026-02-14 181539" src="https://github.com/user-attachments/assets/aaecbbbd-5ab0-425c-8cdc-c84fe599e0d2" />

<img width="725" height="299" alt="Screenshot 2026-02-14 181545" src="https://github.com/user-attachments/assets/b6c8532e-646d-4eb9-a3b0-21bd09f1ab6a" />

- The `details` of the **Syslog Messages** is frozen and host name is appeared as `_gateway`. Because the **router's IP address** matches the **default gateway** of the Syslog Server (Kali), **DNS** automatically resolves the IP address to a **name**. In reality, using the **IP address** helps us **identify the device more accurately** than resolving it to a name. Let fix it.

[⬆ Back to Top](#-quick-navigation)

</details>


<details>
<summary><b>⚙️ Click to see Full Phase 2 Explanation</b></summary>

##### Phase 2: Structural Enhancement (The "Fixing Spinning Circle")
LogAnalyzer 4.1.13 is "picky." It performs a `SELECT` query that expects specific columns to exist. If a column is missing, the PHP script hangs, causing the **Infinite Spinning Circle.**

- `processid` & `messagetype`: These identify which program sent the log. LogAnalyzer uses these to categorize the data.

- `fromip`: This is crucial for security. It stores the raw IP address of the Router/Switch, ensuring you know exactly where the log came from even if DNS fails.

- `checksum` **(The Most Important)**: This is used for data integrity. Without this column, LogAnalyzer cannot "verify" the log entry, so it just stays on the loading screen forever.

- `AFTER SysLogTag`: This is just "housekeeping." It tells SQL where to put the new column so the table stays organized and easy to read.

- `int` **(Integer)**: Used for status codes (Severity 0-7). It is mathematically indexed, making log filtering ultra-fast.

- `varchar(60)` **(Variable Character)**: Used for strings (Service names/IPs). The **60-character limit** is the industry standard—balancing enough space for data while optimizing disk storage.

- `DEFAULT ''`: If a log arrives without a specific value for these new columns, SQL will automatically insert an **Empty String** (`''`) instead of a `NULL` value. This prevents PHP errors in the Web UI, as LogAnalyzer expects a string value to render the dashboard properly.

 
#### 💡 Pro-Tip for the Future:
If you ever encounter a **newer version** of LogAnalyzer or a different tool (like Graylog) and it doesn't show data:
1. Check the **Web Error Log**: `tail -f /var/log/apache2/error.log`.
2. It will usually say something like: `PHP Fatal error: Unknown column 'xyz' in 'field list'`.
3. **The Solution:** You simply use the `ALTER TABLE SystemEvents ADD COLUMN xyz ...` command you just learned to add that missing piece!

[⬆ Back to Top](#-quick-navigation)

</details>

<details>
<summary><b>⚙️ Click to see Full Phase 3 Explanation</b></summary>

##### Phase 3: A common "bug" in Syslog systems is the display of `_gateway` instead of the actual IP address. This occurs due to Reverse DNS lookups on the local management network.

- `UPDATE SystemEvents SET FromHost = '10.0.99.1' WHERE FromHost = '_gateway';` : This will force SQL Database updates the `_gateway` to IP Address but that is not enough.

**1. Rsyslog Global Hardening**

Modify `/etc/rsyslog.conf` to disable DNS resolution:

```diff
# Add this to the top of the file
+ global(net.enableDNS="off")
```

**📸 Screenshot**

<img width="487" height="107" alt="image" src="https://github.com/user-attachments/assets/21ef5b82-bc52-4d08-8ed0-b760dcde580a" />


**2 Disable Web DNS Lookup:**
- In `/var/www/html/syslog/config.php`, set: `$CFG['Sources']['Source1']['ViewDNSNames'] = false`;

```diff
$CFG['DefaultSourceID'] = 'Source1';

$CFG['Sources']['Source1']['ID'] = 'Source1';
$CFG['Sources']['Source1']['Name'] = 'Cisco_Network_Logs';
$CFG['Sources']['Source1']['ViewID'] = 'SYSLOG';
$CFG['Sources']['Source1']['SourceType'] = SOURCE_DB;
$CFG['Sources']['Source1']['DBTableType'] = 'monitorware';
$CFG['Sources']['Source1']['DBType'] = DB_MYSQL;
$CFG['Sources']['Source1']['DBServer'] = 'localhost';
$CFG['Sources']['Source1']['DBName'] = 'Syslog';
$CFG['Sources']['Source1']['DBUser'] = 'rsyslog';
$CFG['Sources']['Source1']['DBPassword'] = '123456';
$CFG['Sources']['Source1']['DBTableName'] = 'SystemEvents';
$CFG['Sources']['Source1']['DBEnableRowCounting'] = false;
+ $CFG['Sources']['Source1']['ViewDNSNames'] = false;

// --- 

?>
```

**📸 Screenshot**

<img width="879" height="279" alt="Screenshot 2026-02-15 021119" src="https://github.com/user-attachments/assets/d632af12-152c-47ad-bef8-7f8996a5b061" />

#### 💡 Remember to Save `Ctrl + O` + `Enter`. Then `Ctrl + X` to confirm and exit.

[⬆ Back to Top](#-quick-navigation)

</details>

#### Phase 4: Verify `DESC SystemEvents;`

**📸 Screenshot**

<img width="834" height="696" alt="Screenshot 2026-02-14 190222" src="https://github.com/user-attachments/assets/eeabf1cd-927a-4dda-9725-e95ce91f3d73" />

>[!CAUTION]
> #### Security Hardening: Once the web installation is complete, you must run `sudo chmod 444 /var/www/html/syslog/config.php` to switch the file to Read-Only mode. This prevents unauthorized modification of your database credentials.

- Restart the services: `sudo systemctl restart rsyslog mariadb apache2`

--- 
### Verification Packet Capture & Analysis

- Execute `shutdown` & `no shutdown` on random interfaces of both Router and Switch.

**📸 Screenshot**

<img width="1714" height="89" alt="Screenshot 2026-02-14 185917" src="https://github.com/user-attachments/assets/4689b9ab-e380-4240-ac28-103df45d3a1e" />

<img width="721" height="295" alt="image" src="https://github.com/user-attachments/assets/e06441ff-22f3-4646-993d-5db8f5baf0dc" />

- **Great! Everything working normally and perfect**

<img width="1910" height="74" alt="Screenshot 2026-02-15 024851" src="https://github.com/user-attachments/assets/dde7388a-ba9e-4bf3-9833-397cd9d9fac4" />

<img width="1133" height="376" alt="Screenshot 2026-02-15 024907" src="https://github.com/user-attachments/assets/efc20b39-5e7a-493f-907e-1ffca3dcbef0" />

<img width="1718" height="675" alt="Screenshot 2026-02-15 025009" src="https://github.com/user-attachments/assets/e9204d25-e029-4c90-9493-a4c7a042fe51" />

As demonstrated in the packet capture, the **Syslog message payload** is transmitted in **unencrypted plain text**. 
* **Finding:** Every event, including interface status changes (e.g., `Ethernet0/3 changed state to down`), is fully readable by anyone with access to the network segment.
* **Risk:** High exposure to eavesdropping and sensitive information disclosure.

#### 2. Protocol Limitations (UDP 514)
* **Transport:** The system utilizes **UDP 514**, a connectionless protocol.
* **Implication:** There is no "handshake" or delivery confirmation. If the network is congested, logs may be silently dropped, creating "blind spots" in the security audit trail.

#### 3. Forensics Detail
The packet clearly identifies:
* **Source IP (10.0.99.1):** The Router.
* **Destination IP (10.0.99.100):** The Kali Collector.
* **Facility/Level:** `LOCAL7.NOTICE` (Level 5), providing categorized metadata for the MariaDB backend.

> [!TIP]
> #### Moving to Production Grade Security:
> While this lab successfully demonstrates centralized logging using standard **UDP 514**, it exposes logs in **Clear Text**. For a production environment, the following hardening steps are recommended:
> 1. **Syslog-over-TLS (TCP 6514):** Encrypting the log transport layer to prevent eavesdropping (as seen in the Wireshark analysis).
> 2. **Authentication:** Implementing certificate-based authentication to ensure only authorized network devices can send logs to the MariaDB collector.
> 3. **Reliability:** Transitioning from UDP to **TCP** to guarantee log delivery via a 3-way handshake.

[⬆ Back to Top](#-quick-navigation)

---

### Local Logging (The Black Box)

Ensure the Router/Switch maintains a local backup in case of network failure:

```bash
R1(config)# logging buffered 8192
R1(config)# logging trap debugging
R1(config)# logging 10.0.99.100
```
**📸 Screenshot**

<img width="1096" height="686" alt="Screenshot 2026-02-14 200008" src="https://github.com/user-attachments/assets/3da3a539-02f4-4ef0-8e79-3e28a26e90e9" />


[⬆ Back to Top](#-quick-navigation)

---

### 🔍 Verification & Troubleshooting

🕵️ **Troubleshooting Case Study: The "Spinning Circle"**
- **Symptom:** Selecting a log entry resulted in a permanent loading icon.
- **Diagnosis:** Database lacked the `checksum` column required by the Web UI's detail-view engine.
- **Solution:** Successfully added `checksum` column via `ALTER TABLE`.

✅ Final Audit Checklist
- [x] Logs from R1/SW1 visible in SystemEvents table.
- [x] Host column displays IP 10.0.99.1 (DNS Suppressed).
- [x] Details page opens instantly (Checksum/ProcessID verified).
- [x] Config file locked with 444 permissions.

[⬆ Back to Top](#-quick-navigation)

---

### Conclusion
Lab 21 successfully transitions from basic logging to an **Enterprise-grade Centralized Log Management system**. By overcoming SQL schema mismatches and DNS display bugs, we have built a robust environment capable of scaling to thousands of devices.

>[!IMPORTANT]
> ### Syslog Severity Levels
> These values are stored in the `ntseverity` (or `priority`) column in our database.

<div align="center">
  
|Level|Keyword|Description|Impact|
|-|-|-|-|
|0|Emergency|System is unusable|🔥 Total Shutdown|
|1|Alert|Action must be taken immediately|⚠️ Critical failure|
|2|Critical|Critical conditions|🔴 Hard drive/Interface failure|
|3|Error|Error conditions|❌ Non-critical errors|
|4|Warning|Warning conditions|🟠 Potential issues|
|5|Notice|Normal but significant condition|🔵 Config changes/Interface Up-Down|
|6|Informational|Informational messages|ℹ️ Standard operations|
|7|Debug|Debug-level messages|🛠️ Troubleshooting data|

</div>

- Why don't they just use an **ON/OFF** button like **Packet Tracer** for convenience?

- **Scalability:** Packet Tracer can only handle a few dozen logs. In reality, a banking system can generate **100,000 logs per second**. A simple "ON" button in Packet Tracer would explode immediately. You need MariaDB and Rsyslog to handle that volume.

- **Customization:** In Packet Tracer, you can't filter: *"Show me error logs from Router 1 between 2 AM and 4 AM."* In real life, thanks to the SQL `CHANGE/ADD` commands we've discussed, you can query anything you want.

- **Security:** In practice, logs are evidence in court (forensics). You must configure permissions (`chmod 444`), lock the configuration file, and ensure logs cannot be modified or deleted.

[⬆ Back to Top](#-quick-navigation)


| [⬅️ Previous Lab](../20-Extended-ACL-&-Services-(CML-+-PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️] |
|:--- | :---: | ---: |





