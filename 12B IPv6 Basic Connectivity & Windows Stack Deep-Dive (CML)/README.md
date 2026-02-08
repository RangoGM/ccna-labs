<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |


## Lab 12B: IPv6 Basic Connectivity & Windows Stack Deep-Dive

### Project Overview

This lab establishes fundamental IPv6 connectivity between a **Cisco IOS Router** and a **Windows 10 Host**. While seemingly basic, the project explores the complexities of the Windows IPv6 stack, including Privacy Extensions, PowerShell-based configuration, and Neighbor Discovery Protocol (NDP) verification.

**📸 Screenshot:**

<img width="541" height="108" alt="Screenshot 2026-02-07 213118" src="https://github.com/user-attachments/assets/20426cd4-daf7-4efb-93e3-6c192ac2d604" />


---

### Implementation Details

#### 1. Cisco Router (R1) Configuration

- **Global Unicast Address (GUA):** `2001:DB8:ACAD:1::1/64`.

- **Link-Local Address (LLA):** Manually assigned `FE80::1` to ensure a deterministic and manageable gateway for all hosts on the segment.

**📸 Screenshot:**

<img width="290" height="76" alt="Screenshot 2026-02-07 213053" src="https://github.com/user-attachments/assets/5f105b62-fb98-4f19-99d3-bfcc32d064a6" />

<img width="292" height="83" alt="Screenshot 2026-02-07 202052" src="https://github.com/user-attachments/assets/86bc9628-4b71-4a4e-9b00-1940a341976a" />

*(Router's configuration)*

#### 2. Windows Host Configuration

- **Dual-Method Configuration:** Explored both GUI (Adapter Properties) and PowerShell for IP assignment.
 
- **Manual IP Assignment:** Assigned `2001:DB8:ACAD:1::100/64` by using GUI in Window (Method 1) & `2001:DB8:ACAD:1::20/64` by using Windows PowerShell Commands (Method 2)  as the primary static identifier.
 
- **Gateway Steering:** Directed traffic to the Router's LLA (`FE80::1`) to adhere to IPv6 best practices.

---

### The "Windows Behavior" Challenge (Privacy & Security)

The highlight of this lab was troubleshooting why Windows bypassed the manual IP in favor of randomized addresses:

- **IPv6 Privacy Extensions (RFC 4941):** Discovered that Windows generates multiple **Temporary IPv6 Addresses** for outbound traffic to prevent user tracking.

- **Interface ID Randomization:** By default, Windows ignores EUI-64 (MAC-based) identifiers for Link-Local addresses to enhance security.

- **Transition to EUI-64:** After executing `Set-NetIPv6Protocol -RandomizeIdentifiers Disabled`, the host successfully transitioned to a standard EUI-64 LLA: `FE80::20C:29FF:FEBA:122`.

---

### Method 1 - Assigned IPv6 Addresses by Using Adapter GUI Properties in Window

**📸 Screenshot:**

<img width="1023" height="769" alt="Screenshot 2026-02-07 214122" src="https://github.com/user-attachments/assets/c1b9e853-3301-43d2-ae50-239af1ddaa28" />

*(Manually configured static IPv6 in Windows Adapter GUI)*

<img width="838" height="611" alt="Screenshot 2026-02-07 214132" src="https://github.com/user-attachments/assets/a5e148ba-1c00-4542-96a6-887402a2268d" />

*(The ping works)*

**🛑 Notice:**
- There are multiple IPv6 Address has been assigned and one which is **Temporary IPv6 Address**
- Default Gateway has `%7` after the LLA which called **Interface Index**

**➡️ Explained briefly in Method 2**

---

### Method 2 - Assigned IPv6 Addresses by Using Windows PowerShell Commands (Interface Index)

#### 1. In PowerShell, identifying the ifIndex via `Get-NetIPInterface` is the mandatory first step before applying any L3 configurations to ensure hardware-level accuracy.

- `Get-NetIPInterface -AddressFamily IPv6`

  - *Explanation:* Lists all network adapters and their **ifIndex**

**📸 Screenshot:**

<img width="836" height="96" alt="Screenshot 2026-02-07 214830" src="https://github.com/user-attachments/assets/521cb65b-f3ad-46a2-b94e-21f768af727b" />


- What is the Interface Index (ifIndex)?

Think of the ifIndex as the unique **ID Card Number** assigned to a network adapter by the Windows operating system.

- **Why not use the Name (InterfaceAlias) like "Ethernet0"**? Interface names can be easily **renamed**, **modified**, or even **duplicated**. However, the **Index** is a **unique**, **fixed integer** assigned to each port during an active session. It serves as the "**source of truth**" for the OS to identify hardware.

- **Practical Application:** When you use a parameter like `-InterfaceIndex 7`, you are directing your command to **Hardware ID #7** with 100% precision. This eliminates the risk of accidentally misconfiguring the wrong adapter, such as a WiFi card, a Virtual Switch, or a VPN tunnel.

#### 2. Assigning IPv6 Addresses

- `New-NetIPAddress -InterfaceIndex [ID] -IPAddress [GUA] -PrefixLength 64`
  
  - *Explanation:* Assigns your static IPv6 address to specific adapter
  
**📸 Screenshot:**

<img width="807" height="422" alt="Screenshot 2026-02-07 215528" src="https://github.com/user-attachments/assets/f8a9c7f9-c35a-48ab-b2da-e84c02baed84" />


#### 3. Remove current default route (if any) and force the packets go directly through Router's Default Gateway via LLA by using `NextHop`

- `Remove-NetRoute -InterfaceIndex [ID] -DestinationPrefix "::/0"`
  
  - *Explanation:* Remove old default Route

**📸 Screenshot:**

<img width="834" height="114" alt="Screenshot 2026-02-07 215631" src="https://github.com/user-attachments/assets/bc654f12-27be-49b9-b89b-a38e8bc8f377" />

- `New-NetRoute -InterfaceIndex [ID] -DestinationPrefix "::/0" -NextHop "fe80::1"`

  - *Explanation:* Manually adds the Default Gateway.
 
  - Insight: We use this instead of the `-DefaultGateway` flag to bypass the **Subnet Mismatch** error caused by using a Link-Local Gateway with a Global IP.

**📸 Screenshot:**

<img width="858" height="153" alt="Screenshot 2026-02-07 215759" src="https://github.com/user-attachments/assets/12ace364-c734-4e0d-8c47-17759aca33f4" />

---

### Method 2 - Assigned IPv6 Addresses by Using Windows PowerShell Commands (Temporary IPv6 Address)

**📸 Screenshot:**

<img width="415" height="173" alt="Screenshot 2026-02-07 215951" src="https://github.com/user-attachments/assets/442d27cb-8bf1-494b-a179-4e482ae0d84b" />

*(Ping test: The ping works)*

<img width="1883" height="279" alt="Screenshot 2026-02-07 220414" src="https://github.com/user-attachments/assets/7c366f20-de1a-4334-8460-a8b112b777fe" />

*(Captured the IPv6 Packets from Window to Router: Noticed that the ping is not from **Manually Configured Address** via `2001:db8:acad:1::20/64`)*

<img width="589" height="211" alt="Screenshot 2026-02-07 220750" src="https://github.com/user-attachments/assets/bbbc6946-adda-4783-8c75-19211a76ccbe" />

*(But the ping is from **Temporary Address**)*

<img width="627" height="76" alt="Screenshot 2026-02-07 220615" src="https://github.com/user-attachments/assets/2b4fa2a5-9de6-4be4-a9b6-648432660462" />


*(Routers also has the entries for **Temporary Address** no **Manually Configured Address**)*

#### 4. Forced Window Host to send the **correct manually IPv6 Address**

- `Set-NetIPv6Protocol -RandomizeIdentifiers Disabled`

  - *Explanation*: Disables "Stable Random Identifiers".
 
  - *Result:* Forces Windows to use EUI-64 to generate its Link-Local address (using the MAC address).
 
- `Set-NetIPv6Protocol -UseTemporaryAddresses Disabled`

  - *Explanation*: Turns off **Privacy Extensions (RFC 4941)**.
 
  - *Result*: Stops Windows from creating "Temporary IPv6 Addresses," forcing it to use your **Manual IP** for pings and web traffic.

**📸 Screenshot:**

<img width="592" height="20" alt="Screenshot 2026-02-07 221929" src="https://github.com/user-attachments/assets/88b8f686-3760-442d-8c66-37341e8f9061" />

*(Router now have the entries for **Windows EUI-64 LLA MAC Address**)*

**🔢 Mathmatics of EUI-64 (Quick Ref)**

1. Take the **48-bit MAC address** (e.g., `000C.29BA.0122`).

2. Insert `FF:FE` in the middle.

3. Flip the **7th bit** (Universal/Local bit).

   - $00000000_2 \rightarrow 00000010_2$ (Hex `00` becomes `02`).
  
4. Resulting LLA: `fe80::20c:29ff:feba:122`

- `Disable-NetAdapter -Name "Ethernet0"`

- `Enable-NetAdapter -Name "Ethernet0"`

  - *Explanation:* Flush away all old IP addresses and force Windows to use ::20, reset network card.
 
**📸 Screenshot:**

<img width="635" height="99" alt="Screenshot 2026-02-07 224529" src="https://github.com/user-attachments/assets/9ea2c935-8cb7-4f62-82d8-c84e355ada0c" />

 
<img width="538" height="166" alt="Screenshot 2026-02-07 224547" src="https://github.com/user-attachments/assets/8d713fac-f7c3-4b5a-bd7e-dae1ec5214e2" />

*(Only Manually Configured IPv6 Address and EUI-64 MAC Address)*

<img width="1274" height="289" alt="Screenshot 2026-02-07 224727" src="https://github.com/user-attachments/assets/04b779d9-c5aa-4c96-9055-71516973f464" />

*(Ping again: Now the ping is from correct IPv6 configured address via `2001:db8:acad:1::20/64`)* 

<img width="608" height="37" alt="Screenshot 2026-02-07 224748" src="https://github.com/user-attachments/assets/3e44722f-11ae-453c-9778-a3717347c3d6" />

*(Used `show ipv6 neighbor` to confirm this)*

---

### ⚠️ Important: Security & Privacy Disclaimer

While this lab demonstrates how to disable certain IPv6 features for **educational and troubleshooting purposes**, it is crucial to understand their real-world importance.

**Why we disable them in a LAB:**

- **Deterministic Identification:** By disabling `RandomizeIdentifiers` and `UseTemporaryAddresses`, we force Windows to use a consistent, predictable IP address. This is essential for:

  - Identifying specific hosts in Wireshark captures.

  - Maintaining static Neighbor Discovery entries.

  - Ensuring "Muscle Memory" when calculating EUI-64 addresses.

**Why you should NOT disable them in REAL LIFE:**

In a production or public network environment, these Windows features are your first line of defense for IPv6 privacy:

- **IPv6 Privacy Extensions (RFC 4941):** Temporary addresses prevent websites and advertisers from tracking your device's activity across the internet based on a static Interface ID.

- **Identifier Randomization:** Using a random Interface ID instead of one based on your MAC address (EUI-64) prevents "Device Fingerprinting," making it harder for attackers to identify your hardware type or track your physical movements between networks.

💡 **Best Practice:** Always keep these features **ENABLED** on personal and corporate devices. Only disable them in controlled laboratory environments where specific IP tracking is required for scientific analysis.

#### Final Cheat Sheet Update (The "Safety First" Version)

- `Set-NetIPv6Protocol -RandomizeIdentifiers Enabled`

- `Set-NetIPv6Protocol -UseTemporaryAddresses Enabled`

##### Refresh the adapter

- `Disable-NetAdapter -Name "YourAdapterName"`

- `Enable-NetAdapter -Name "YourAdapterName"`

---

### Final Verification

- **Success Ping:** Confirmed end-to-end connectivity with a source IP of `2001:db8:acad:1::20` reaching the router.

- **Neighbor Table:** The Router successfully mapped the manual GUA and the EUI-64 LLA to the host's MAC address.

**📸 Screenshot:**

<img width="1912" height="37" alt="Screenshot 2026-02-08 024531" src="https://github.com/user-attachments/assets/9e23addb-20e0-4977-a32b-7a8857cb2b71" />

<img width="1574" height="320" alt="Screenshot 2026-02-08 024554" src="https://github.com/user-attachments/assets/5a28066d-2a2c-4ee6-bbcf-a31ee370cbfc" />

- **ICMPv6 Type 135 (Neighbor Solicitation):** Windows find Router's MAC Address.

<img width="1901" height="36" alt="Screenshot 2026-02-08 024244" src="https://github.com/user-attachments/assets/f71be2ed-5bbb-47d9-ac59-627a2d4920cc" />

*(aabb.cc00.0900 is Router's MAC Address)*

<img width="1919" height="416" alt="Screenshot 2026-02-08 024304" src="https://github.com/user-attachments/assets/eabe4402-c0ab-4b16-8f73-728755bace5f" />

- **ICMPv6 Type 136 (Neighbor Advertisement):** Router reply Windows.

**💡 In further labs we will learn how to block rogue RA (Router Advertisements) to avoid MITM attack by using RA Guard**

---

### Troubleshooting Journal

|Issue Encountered|Root Cause|Resolution|
|-|-|-|
|**Subnet Mismatch Error**|PowerShell's `New-NetIPAddress` validates the Gateway prefix against the GUA prefix.|Decoupled the Gateway assignment using the `New-NetRoute` command.|
|**Persistent Temp IPs**|Windows retains Temporary addresses in the `Preferred` state even after disabling the protocol.|Performed a network adapter reset (`Disable/Enable-NetAdapter`) to flush the IP cache.|
|**Source IP Mismatch**|Windows continued using randomized IPs for pings in Wireshark captures.|Disabled Privacy Extensions and randomized identifiers via PowerShell.|

---

### Key Learnings

- **Operating System Bias:** Windows prioritizes security (Temporary IPs) over manual configuration for external communication.

- **PowerShell Granularity:** Learned the strict distinction between managing IP addresses (NetIPAddress) and routing tables (NetRoute).

- **Muscle Memory:** Developed reflexes for EUI-64 address calculation and manual LLA management to simplify troubleshooting in complex environments.

| [⬅️ Previous Lab](../12A%20IPv6%20Addressing%20%26%20Basic%20Connectivity%20(PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../12C%20IPV6%20SLAAC%20(CML%20FOCUSED)) |
|:--- | :---: | ---: |









