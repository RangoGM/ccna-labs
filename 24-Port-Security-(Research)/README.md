<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |

## Lab 24: Port Security Enforcement & Temporal Authorization Analysis

<div align=center>
 
### 🔍 Research Project

#### Design and Empirical Evaluation of a Layered Access-Control Security Model for Enterprise Access Networks

(IP-Version Agnostic Architecture with Dual-Stack Considerations)

</div>

---

**📝 Core Focus:** MAC Flooding Mitigation & System Resource Optimization.

**🏗️ Environment:** Cisco Modeling Labs (**CML**)

**🌐 Author: RangoGM (2026 Grinding Series)**

---

### I. Objective 

This lab performs a structured behavioral analysis of **Cisco Port Security** under sustained MAC flooding conditions in a **Dual-Stack (IPv4/IPv6) access-layer** environment.

---
#### 📍 Quick Navigation

* [**II. Experimental Context**](#ii-experimental-context)
* [**III. Network Topology**](#iii-network-topology)
* [**IV. Baseline Observation (No Protection)**](#iv-baseline-observation-no-protection)
* **V. Enforcement Mode Comparative Study**
  * [**V.1. Shutdown Mode - Strict Containment**](#-v1-shutdown-mode---strict-containment)
  * [**V.2. Restrict Mode – Logged Enforcement**](#-v2-restrict-mode--logged-enforcement)
  * [**V.3. Protect Mode – Silent Filtering**](#-v3-protect-mode--silent-filtering)
* [**VI. Summary Tables**](#vi-summary-tables)
* [**VII. Temporal Authorization Window (Race Condition)**](#vii-temporal-authorization-window-race-condition)
* [**VIII. Security Recommendations**](#vii-temporal-authorization-window-race-condition)
---

The goal is not merely to **configure Port Security**, but to:

- Evaluate enforcement modes (**Protect, Restrict, Shutdown**)

- Observe **processing behavior under stress**

- **Analyze the temporal authorization window during initial port activation**

- Establish the **foundation for a layered Access-Layer** Defense Model

This experiment represents **Phase 1** of a multi-layer security series.

**📸 Screenshot:**

<img width="1049" height="541" alt="Screenshot 2026-02-17 193457" src="https://github.com/user-attachments/assets/27e20ed3-c92e-42f0-bc6a-f42d24401da6" />


--- 

### II. Experimental Context

> [!WARNING]
> #### ⚠️ All measurements were conducted in Cisco Modeling Labs (CML).
> **Simulation CPU** values represent **virtual node processing statistics** and **do not directly correspond to ASIC-based hardware** forwarding performance on **physical Cisco Catalyst platforms**. The purpose of measurement is **comparative behavioral analysis**, not **hardware benchmarking**.

---

### III. Network Topology

#### VLAN Host (e.g 10, 20..)

- **Attacker (Kali Linux)**: Connected to `Eth0/1` or `Eth1/0` when the interface is in an administrative '`up`' state but remains **unoccupied** - Armed with `macof`.

- **Legitimate Host (2nd Kali Linux)**: Connected to `Eth1/0` - Representing authorized internal traffic.

**📸 Screenshot:**

<img width="810" height="440" alt="Screenshot 2026-02-17 180830" src="https://github.com/user-attachments/assets/189bf8aa-4d50-4d8a-8d8e-cd35b0f9761d" />


#### VLAN Management (e.g 99)
- **Monitoring Station (Ubuntu NMS)**: **Centralized Syslog-ng** & **LogAnalyzer** with **Automation Script built by Me** - `Eth0/3`.
  
- **Admin (Windows)**: Track **Syslog** informations through **LogAnalyzer** - `Eth0/2`.

**📸 Screenshot:**

<img width="1023" height="767" alt="Screenshot 2026-02-17 151642" src="https://github.com/user-attachments/assets/96f9bea3-640b-46a2-a343-bbf583b8c0d4" />


#### Devices

- **Target Switch (SW_Guard)**: Cisco Catalyst running IOS-XE (Physical/CML Hybrid)

- **Router (R1)**: Inter-VLAN Routing for different VLANs can communicated.

#### Assumptions:

- Attacker has **physical-equivalent access** to an access port.

- Attacker can **generate high-rate** Ethernet frames with **randomized** source MAC addresses.

- No **administrative access** to the switch.

- Network operates in **Dual-Stack** mode.

#### Attack Objective:

- **Exhaust CAM-table** learning capacity.

- Force **unknown unicast flooding**.

- **Stress** switching behavior.

- Attempt **unauthorized slot occupation** during initial learning.

[⬆ Back to Top](#-quick-navigation)

---

### IV. Baseline Observation (No Protection)

#### State (Port Security is Disabled)

- **Default dynamic MAC Learning**

- No **per-port MAC limit**

**📸 Screenshot:**

<img width="1716" height="323" alt="Screenshot 2026-02-17 152038" src="https://github.com/user-attachments/assets/232b92a5-ee97-4eb3-a10e-72c28799e96f" />

*(**Legitimate Host Mac Address** `0050.5632.3eea`)*

<img width="429" height="197" alt="Screenshot 2026-02-17 152257" src="https://github.com/user-attachments/assets/82b0fcdd-e5cf-43d4-96b2-1a2f81aaf321" />

*(Switch learned **MAC Address** from Host at **VLAN 10 - Interface Eth1/0**)*

<img width="480" height="320" alt="Screenshot 2026-02-17 152326" src="https://github.com/user-attachments/assets/2b636c79-5a0a-4394-b380-0b431db84872" />

*(Switch **CPU Idle** State ~ **1%**)*

#### Observed

- When Attacker use **Interface Eth1/0** & executes `macof`. CAM entries increased from **~3 to >300+** during flooding.

- Simulation CPU utilization peaked at **~80–95%.**

- Physical interface congestion leads to `%AMDP2_FE-6-EXCESSCOLL` logs on adjacent ports.

**📸 Screenshot:**

<img width="792" height="434" alt="Screenshot 2026-02-17 181433" src="https://github.com/user-attachments/assets/9023cb4a-e1a2-4194-bc43-aa643da83132" />

<img width="1286" height="326" alt="Screenshot 2026-02-17 154623" src="https://github.com/user-attachments/assets/bf084a9e-a3b2-4610-82be-d1bbe728fab6" />

*(Attacker execute `macof`)*

<img width="488" height="330" alt="Screenshot 2026-02-17 210730" src="https://github.com/user-attachments/assets/298c22d3-1668-468f-8c30-5ee4e1c52ead" />

*(CPU Usage has **reached its peaked**)*

<img width="1077" height="80" alt="Screenshot 2026-02-17 212226" src="https://github.com/user-attachments/assets/b7e5fb8c-4547-46fd-9be0-cfaed8d5ebb0" />

<img width="1022" height="415" alt="Screenshot 2026-02-17 212208" src="https://github.com/user-attachments/assets/c2fb0783-7d7b-4060-b0a7-1a0d28cd3870" />

- This is an **Excessive Collisions** error on the `Eth0/1` port. This indicates that the amount of packets injected from the `macof` is **too large**, causing channel congestion and continuous collisions.

<details>
<summary><b>⚙️ Click to see more details about Fail-Open Mode</b></summary>

When you run `macof` on port **Et1/0**, the Switch's CAM table is flooded with tons of junk MAC addresses. When the CAM table is full, the Switch enters **Fail-Open** mode:

1. **Hub mode:** At this point, the Switch no longer knows which MAC address is on which port. It is forced to process all incoming packets by **flooding (pushing)** them out to **ALL** other ports (except the receiving port).

2. **Wide-scale bombardment:** High-rate randomized frames caused rapid CAM-table saturation and increased unknown unicast forwarding.

3. **Why is `EXCESSCOLL` appeard:**

   - The **Eth0/1** were originally receiving normal traffic from the Host.

   - When a massive data stream from Kali was forwarded, it caused congestion on these ports.

   - In the simulated environment (virtual Ethernet), when the packet forwarding rate exceeded the interface's processing capacity, the system recorded it as **Excessive Collisions**.

</details>

> [!IMPORTANT]
> #### VLAN Segmentation: The "Management VLAN 99" Immunity
> While the Attack VLAN was paralyzed, **VLAN 99 (Management/Admin)** remained 100% stable. This demonstrates the critical role of VLAN segmentation in a robust security model.
>
> #### Why VLAN 99 stayed "Immune":
> - **Broadcast Domain Isolation:** VLANs divide the physical switch into multiple logical L2 domains. The MAC flooding process is restricted **only** to the source VLAN (VLAN 10). The Switch never floods frames across different VLAN boundaries.
> - **L3 Gateway Filtering:** Inter-VLAN routing (via SVI or Router) operates at **Layer 3**. When packets move between VLANs, the Router strips the original L2 header (containing the spoofed MACs) and encapsulates it with a new L2 header for the destination VLAN.
> - **Control Plane Protection:** By isolating Management traffic into **VLAN 99**, administrators maintain access to the device (SSH/SNMP) even when the User Plane (VLAN 10) is experiencing a **Denial of Service (DoS)** event.

<div align="center"> 
  
|Metric|Attack VLAN (VLAN 10)|Admin VLAN (VLAN 99)|
|-|-|-|
|Interfaces|`Eth0/1`, `Eth1/0`|`Eth0/2`,`Eth0/3`|
|**MAC Table Status**|**Saturated (Full)**|**Stable (Clean)**|
|**Switching Mode**|Fail-Open (Hub)|Unicast (Standard)|
|**Connectivity**|Disrupted / High Latency|**Normal (High Availiability)**|

</div>

- In the **CML simulation environment**, **excessive collision logs** were generated under **sustained flooding conditions**, indicating **interface-level congestion** behavior within the **virtual switching process**.

- Verify **CPU usage in IOS CLI**: `show processes cpu history` & `show processes cpu sorted | exclude 0.00`

<img width="594" height="369" alt="Screenshot 2026-02-17 153814" src="https://github.com/user-attachments/assets/4cc48f2c-34d0-4a7b-a359-e27e5ce53201" />

<img width="675" height="154" alt="Screenshot 2026-02-17 211106" src="https://github.com/user-attachments/assets/30e84f47-dba7-4f75-b399-0577e4222546" />

> [!WARNING]
> #### ⚠️ Low measures CPU Usage in IOS CLI but 95% peaked in Simulation Statistics
> Again! These values reflect CML virtual processing behavior and should not be interpreted as direct hardware CPU metrics of physical Cisco Catalyst platforms. However, they demonstrate a clear reduction in processing overhead within a controlled stress scenario.

[⬆ Back to Top](#-quick-navigation)

---

### V. Enforcement Mode Comparative Study

#### Port Security was tested under three violations modes.

---

#### ➕ V.1. Shutdown Mode - Strict Containment

**Behavior:**

- Immediate **err-disable**.
- Link protocol **down**.
- **Syslog violation messages** generated.
- **Manual or timed** recovery required.

**📸 Screenshot:**

<img width="810" height="440" alt="Screenshot 2026-02-17 180830" src="https://github.com/user-attachments/assets/0a8a9b45-e05c-45b4-83b4-d46b03025706" />

- Configure **Port Security** for Interface connected to **legitimate** hosts:

```
interface eth1/0
  switchport mode access
  switchport port-security
  switchport port-security maximum 1
  switchport port-security violation shutdown
  switchport port-security mac-address sticky
```

<img width="1297" height="285" alt="Screenshot 2026-02-17 180416" src="https://github.com/user-attachments/assets/7212739c-9aae-4f67-b35e-4ce4becbcd5d" />

In this case I use `maximum 2` because my Kali has 2 **MAC Addresses**:

1. **VMWare MAC Adress**

2. **Eth0 Kali MAC Address**

But **ignore** the **VMWare MAC-Address** because I want to ensured that **all MAC Address from Legitimate Host** is **learned by Switch**. But if I configure `maximum 1` which is my **Legitimate Host** will be seems as an **Attacker** because it contains **2 MAC Address**. 

<img width="623" height="151" alt="Screenshot 2026-02-17 180453" src="https://github.com/user-attachments/assets/3087541f-4827-4edd-a318-82cf2a1a521c" />

*(Use `show port-security` to verify current MAC Addresses has learned by switch assigned along with **maximum Secure Address** - ⚠️ Aware that the current MAC Address must be equal to maximum Secure Address if it larger than this **Legitimate Host** will be seem as an **Attacker** and the Port will **shut down** for **security**)*

<img width="1166" height="254" alt="Screenshot 2026-02-17 180518" src="https://github.com/user-attachments/assets/4b1ee50d-ec63-4397-9525-71c8bfe4e889" />

*(Use `show port security` to verify the Port-Security on Interface)*

<img width="1276" height="795" alt="Screenshot 2026-02-17 181208" src="https://github.com/user-attachments/assets/194df716-3ee3-413e-837a-36b83cf10ba0" />

*(Replace **Legitimate Host** with an **Attacker** and start `macof`)*

<img width="1177" height="176" alt="Screenshot 2026-02-17 181218" src="https://github.com/user-attachments/assets/9562ef3e-697b-467a-94ee-51dc86fe5b9d" />

<img width="1214" height="250" alt="Screenshot 2026-02-17 224238" src="https://github.com/user-attachments/assets/0331ccd6-3b1b-45e3-8a36-2e979bfcf134" />


*(As expected **MAC Flooding has been detected** and the Port **Shut down for Security**, the number of **violations** also **increased**, as did the number of **Syslog messages** generated and sent to the **Syslog Server** under the **Administrator's supervision**)*

<img width="1016" height="353" alt="Screenshot 2026-02-17 181303" src="https://github.com/user-attachments/assets/cd87f67e-fb76-4d4d-ae2a-efe9b3da2e15" />

<img width="1024" height="341" alt="Screenshot 2026-02-17 181323" src="https://github.com/user-attachments/assets/f830622e-37de-445e-a6ae-c05bdc6545a5" />

**Recovery Test:**

- **Errdisable recovery** timer successfully restored interface.

- **Re-violation occurred** if attacker remained active.

- To automatically recovery the interface we need configure `errdisable recovery`:

```bash
errdisable recovery cause psecure-violation
errdisable recovery interval <30-86400 (sec)> 
```

**📸 Screenshot:**

<img width="1251" height="348" alt="Screenshot 2026-02-17 182310" src="https://github.com/user-attachments/assets/010cc465-e127-4e66-b850-afcfc696b33f" />

*(Verify by `show errdisable recovery` command - I set `errdisable recovery interval 30` for faster recovery in lab, but in real life we can not ensure when will **Attacker** stop attacking so it should be left at the appropriate time)*

<img width="930" height="135" alt="Screenshot 2026-02-17 182328" src="https://github.com/user-attachments/assets/a501df74-0a7a-480b-a0e7-b197a9c5adcd" />

*(After **30 seconds** the interface has been recovery but if **Attacker** try to MAC Flooding again the Port will shut down)*

<img width="1005" height="97" alt="Screenshot 2026-02-17 182414" src="https://github.com/user-attachments/assets/4f35e2c3-12e8-4220-b072-b253602981bd" />

*(Syslog Messages generated)*

**Characteristics:**

- Maximum containment

- Reduced availability

- Clear event traceability

[⬆ Back to Top](#-quick-navigation)

---

#### ➕ V.2. Restrict Mode – Logged Enforcement

**Behavior:**

- Excess **frames dropped**.
- Interface **remained operational**.
- Syslog **events generated**.
- Violation **counter incremented (>600k events observed)**.
- Configuring to `Restrict` violation mode and start `macof` on **Attacker**

```bash
interface eth1/0
  switchport port-security violation restrict
```
**📸 Screenshot:**

<img width="1213" height="439" alt="Screenshot 2026-02-17 183206" src="https://github.com/user-attachments/assets/d93d66a2-6c95-4d52-b541-7f140f89d8a1" />

<img width="1193" height="286" alt="Screenshot 2026-02-17 183100" src="https://github.com/user-attachments/assets/3c674414-4896-483a-bad3-4b534ce2f7ce" />

<img width="1018" height="470" alt="Screenshot 2026-02-17 183252" src="https://github.com/user-attachments/assets/4ac20b16-ea10-4798-bad6-a14e70b4191f" />

*(Interface still maintaining `UP` and **Syslog events has generated**)*

<img width="470" height="323" alt="Screenshot 2026-02-17 183718" src="https://github.com/user-attachments/assets/b9b4c3fb-ceb7-4162-b537-0445c75afdbb" />

<img width="479" height="333" alt="Screenshot 2026-02-17 235329" src="https://github.com/user-attachments/assets/0b5c064b-9ff5-4e16-af86-89587aa03cb2" />

**CPU Usage Restrict Mode:** `~20% - ~76%` and the percentage dropped immediately afterward because the switch processed it in time.

>[!WARNING]
> #### ⚠️ These figures represent virtual switching process load within CML and are used for relative comparison only.

**Characteristics:**

- High availability

- Low visibility

- No service interruption

[⬆ Back to Top](#-quick-navigation)

---

#### ➕ V.3. Protect Mode – Silent Filtering

**Behavior:**

- Frames exceeding **MAC limit dropped at ingress**.
- Interface remained operational.
- **No additional counter increments** observed in this lab scenario. (still at 600k after the **Restrict** mode attack).
- **No Syslog Messages** was generated.
- Configuring to `Protect` violation mode and start `macof` on **Attacker**:

```bash
interface eth1/0
  switchport port-security violation protect
```
**📸 Screenshot:**

<img width="423" height="518" alt="Screenshot 2026-02-17 183559" src="https://github.com/user-attachments/assets/58e8e1da-4b0a-45c3-8e22-d5f8d3cc4fa4" />

*(**Violation counts** before and after is the same and no **Syslog Messages** was generated during the attack)*

<img width="471" height="316" alt="Screenshot 2026-02-17 235237" src="https://github.com/user-attachments/assets/2ce13add-eebe-4e92-8199-1add408fe0da" />

<img width="473" height="334" alt="Screenshot 2026-02-17 235323" src="https://github.com/user-attachments/assets/9bb9dbf6-bafe-4950-8dff-1f79e7cf2f4b" />

**CPU Usage Protect Mode:** `~15% - ~70%` and the percentage dropped immediately afterward because the switch processed it in time.

>[!WARNING]
> #### ⚠️ These figures represent virtual switching process load within CML and are used for relative comparison only.

[⬆ Back to Top](#-quick-navigation)

---

### VI. Summary Tables

#### VI.1. Violation Mode 

|Mode|Traffic Dropped|Log/SNMP Alert|Violation Counter|Port Status|Recommendation|
|-|-|-|-|-|-|
|**Shutdown**|✔️|✔️|✔️|**err-disabled**|Maximum security; easy to detect.|
|**Restrict**|✔️|✔️|✔️|**UP**|Best for monitoring; maintains link.|
|**Protect**|✔️|❌|❌|**UP**|"Black Hole" mode; NOT recommended for NMS.|

#### VI.2. CPU Usage

<div align="center">

|System Metric|Unprotected (Flooding)|Protected (Violation Restrict)|
|-|-|-|
|**System CPU Load**| **~95%** (Barely dropped)| **~75%** (Drop after that **~15%**)|
|**CAM Intergrity**|Compromised|Maintained|
|**Audit Visibility**|Zero (Silent Failure)|Real-time (SNMP/Syslog)|

</div>

**Peak CPU (No Security):** 95%

**Stabilized CPU (With Security):** 15%

<div align="center">

$\text{Overall Reduced} = \frac{95 - 15}{95} \times 100 \approx \mathbf{84.21\%}$

</div>

**Conclusion:** In this **simulated environment**, **relative** processing **load decreased** by approximately **84%** after enforcement mechanisms were applied.

[⬆ Back to Top](#-quick-navigation)

---

### VII. Temporal Authorization Window (Race Condition)

#### Scenario (`Ethernet0/1`)

- Port Security **enabled.**

- Sticky learning **active.**

- **No pre-learned authorized MAC**.

- **Attacker transmits before legitimate host**.

**📸 Screenshot:**

<img width="1340" height="513" alt="image" src="https://github.com/user-attachments/assets/eb967311-84c0-423a-8d28-0a1816af36bb" />

<img width="635" height="190" alt="Screenshot 2026-02-17 183846" src="https://github.com/user-attachments/assets/04d030b1-54fc-4513-b65f-62d98fb0f7c5" />

<img width="403" height="252" alt="Screenshot 2026-02-17 183911" src="https://github.com/user-attachments/assets/9c9a4ef2-256f-4481-b5b1-f0928db9b6f0" />

*(No pre-learned authorized MAC)*

#### Observed:

- First learned MAC addresses treated as **authorized**.

- **Authorized slots** occupied by **attacker**.

- **Legitimate device denied access**.

<img width="1193" height="287" alt="Screenshot 2026-02-17 183956" src="https://github.com/user-attachments/assets/69adb4eb-dc21-44dd-8e85-ed7e3b03af4f" />

<img width="424" height="228" alt="Screenshot 2026-02-17 184040" src="https://github.com/user-attachments/assets/705a860b-e1ae-4a05-b475-266e789dec23" />

- Switch learn 2 MAC Addresses treated as **authorized** but due to **high-rate frame injection**, **attacker-originated MAC addresses** were learned **before** legitimate traffic stabilized.

- Even if Switch learned **1 MAC Address from Legitimate Host** but there is still one slot left for **sticky MAC Address** so attacker can use that opportunity to MAC Floods.

- This is expected design behavior and highlights deployment hygiene importance rather than feature weakness.

#### Mitigation

- Keep unused ports administratively shutdown. (**Cisco Best Practice**).
- Keep MAC addresses are **accepted up to the configured limit**.
- **Pre-bind static MAC** for critical devices.
- Transition to **identity-based authentication (802.1X)**.

[⬆ Back to Top](#-quick-navigation)

---

### VIII. Security Recommendations

1. **Administrative Hygiene:** All unused ports must remain in a `shutdown` state regardless of security configuration to prevent **VII** vulnerabilities.

2. **Monitoring Policy:** Utilize `Violation Restrict` to ensure the Security Operations Center (SOC) maintains visibility over attack attempts.

3. **Transition to Identity:** Given MAC spoofing limitations, the model will evolve towards **Identity-based Authentication (IEEE 802.1X)** in the subsequent phase.


[⬆ Back to Top](#-quick-navigation)


| [⬅️ Previous Lab](../23-SNMPv3-(CML)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../25-802.1X-Control-Plane-(Research))|
|:--- | :---: | ---: |

