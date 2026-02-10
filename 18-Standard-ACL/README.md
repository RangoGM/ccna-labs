<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |
---

## Lab 18: Standard ACL - Enterprise Traffic Engineering & Security Baseline 

### Objective

This lab demonstrates the implementation of **Standard Access Control Lists (ACLs)** to regulate traffic in a multi-zone Enterprise environment. We focus on the **"Specific Deny -> Global Permit"** strategy and analyze why **Outbound placement at the destination** is the optimal choice for Standard ACLs.

### Topology & Network Design

The infrastructure is devided into three distinct zones to simulate a corporate hierarchy. Traffic must traverse the OSPF-enabled backbone to reach the protected Server Farm.

|Zone|Subnet|Key Devices|Permitted|Denied|
|-|-|-|-|-|
|VLAN 10 (IT)| `192.168.1.0/24`| Kali | Server | VLAN 30 |
|VLAN 20 (HR)| `192.168.2.0/24`| Window | VLAN 30 | Server |
|VLAN 30 (CLIENT)| `192.168.100.0/24`| Router | Server | VLAN 10 |
|Server| `1.1.1.0/24`| Kali | VLAN 10, 30 | VLAN 20 |

**📸 Screenshot**

<img width="882" height="330" alt="Screenshot 2026-02-10 211339" src="https://github.com/user-attachments/assets/a71529a3-2582-48ab-8fa0-d1334f64bc3b" />

- To understanding the concept more briefly this is the picture how the packet will be permitted or denied:

**📸 Screenshot**

<img width="882" height="330" alt="Screenshot 2026-02-10 211339" src="https://github.com/user-attachments/assets/0dd8a082-3501-474d-b6b4-6607bfef8634" />

##### *(Windows Traffic)*

<img width="1040" height="391" alt="Screenshot 2026-02-10 224657" src="https://github.com/user-attachments/assets/aedae5af-244e-4d8c-84b2-a3d8794c4f6f" />

##### *(Kali IT Traffic)*

<img width="1215" height="464" alt="Screenshot 2026-02-10 225001" src="https://github.com/user-attachments/assets/7ef208da-c485-43ce-a710-c45520e12e66" />

#### *(Client Traffic)*


<img width="1230" height="480" alt="Screenshot 2026-02-10 225252" src="https://github.com/user-attachments/assets/2ece0842-75b0-4783-beea-46324c3fa866" />

#### *(Server Traffic)*

> [!IMPORTANT]
> ##### Make sure that all devices has fully reachability
> **📸 Screenshot**
>
> <img width="572" height="306" alt="Screenshot 2026-02-10 200346" src="https://github.com/user-attachments/assets/8b557413-cda6-486e-b2a2-b2d3ad6c78e8" />
>
> <img width="844" height="505" alt="Screenshot 2026-02-10 201543" src="https://github.com/user-attachments/assets/de0684d9-72cd-4a8f-9e2c-5ca3bb0e53cd" />
>
> <img width="1268" height="586" alt="Screenshot 2026-02-10 201640" src="https://github.com/user-attachments/assets/081e7739-5787-4bdd-9699-821ba26681dd" />

---

### Execution Phase: The "Smart" Standard ACL (Cisco Best Practice)

To protect the Server, and VLAN 30 without causing a "Blackhole" for Internet traffic, we apply the ACL **Outbound** on the interface closest to the destination.

**1. Wildcard Mask Calculation**

For a `/24` subnet, we calculate the wildcard mask as follows:

$$Wildcard = 255.255.255.255 - 255.255.255.0 = 0.0.0.255$$

**2. Router Configuration (ISP - The Gateway to Server and VLAN 30)**

- **VLAN 30**
```bash
ISP(config)# access-list 1 deny 192.168.1.0 0.0.0.255
ISP(config)# access-list 1 permit any
ISP(config)# interface e0/2
ISP(config-if)# ip access-group 1 out
```
- **Server**
```bash
ISP(config)# access-list 2 deny 192.168.2.0 0.0.0.255
ISP(config)# access-list 2 permit any
ISP(config)# interface e0/1
ISP(config-if)# ip access-group 2 out
```
**📸 Screenshot**

<img width="258" height="115" alt="Screenshot 2026-02-10 231639" src="https://github.com/user-attachments/assets/dbd99753-aa6d-4639-ac54-427d6d62a470" />
<img width="320" height="150" alt="Screenshot 2026-02-10 231633" src="https://github.com/user-attachments/assets/40c24c41-abc2-4998-b7f6-6baa5cd71dd5" />

---

### Verification & Packet Walk Analysis

#### Scenario A: Permitted Access (VLAN 20) - Denied Access (VLAN 10) to VLAN 30

**📸 Screenshot**

<img width="767" height="250" alt="Screenshot 2026-02-10 201810" src="https://github.com/user-attachments/assets/744c89e7-0600-4f71-9525-66ec6e4d9e44" />

*(**Kali IT → Client:** As expected in the outputs the packets has been filtered)*

- **Result:** **Destination Host Unreachable. / Packet Filtered.** 
- **Mechanism:** The Router identifies the source IP `192.168.1.x`, matches the first line of the ACL, and drops the packet before it exits the `e0/2` interface.

<img width="854" height="221" alt="Screenshot 2026-02-10 201836" src="https://github.com/user-attachments/assets/c7f8630a-dc54-4aa2-87c4-046d8c914b53" />

*(**Windows → Client:** **Windows** can still ping the **Client**)*

<img width="591" height="193" alt="Screenshot 2026-02-10 201938" src="https://github.com/user-attachments/assets/19183208-72dd-4b53-9028-3d3f846c6828" />

*(and vice versa)*

- **Result: Success.** Traffic matches the `permit any` rule.

- **Observation:** `show ip access-lists 1` indicates incrementing hit counts for the permit statement.

<img width="530" height="77" alt="Screenshot 2026-02-10 230332" src="https://github.com/user-attachments/assets/97335d07-375e-4906-bc2d-fd3cea7c4461" />

#### Scenario B:  Permitted Access (VLAN 10, 30) - Denied Access (VLAN 20) to Server

**📸 Screenshot**

<img width="409" height="298" alt="Screenshot 2026-02-10 205139" src="https://github.com/user-attachments/assets/32dec0dd-4c84-4b57-9891-e1e8e5d02fdb" />

*(Same as **Scenario A**)*

<img width="562" height="94" alt="Screenshot 2026-02-10 210731" src="https://github.com/user-attachments/assets/46ec23e3-1590-48b6-8448-7ac0d46bc670" />

<img width="525" height="374" alt="Screenshot 2026-02-10 205445" src="https://github.com/user-attachments/assets/d2fe765f-14e1-4f63-ba27-541608bd0e97" />

*(Both **VLAN 10, 30** can still ping the **Server** and vice versa)*

- **Observation:** `show ip access-lists 2` indicates incrementing hit counts for the permit statement.

<img width="523" height="54" alt="Screenshot 2026-02-10 233502" src="https://github.com/user-attachments/assets/e5ceae11-d4b9-4d1f-b81c-44b5215ed844" />

---

>[!CAUTION]
> ### 🛑 The "Implicit Deny" Trap: Analysis of a Failed Configuration
> A common pitfall in ACL design is forgetting the **Implicit Deny All** rule. Even when attempting to "permit normally," as seen in our initial configuration, the lack of a final catch-all statement can paralyze external connectivity.

**📸 Screenshot**

<img width="522" height="75" alt="Screenshot 2026-02-10 202701" src="https://github.com/user-attachments/assets/c45b7453-54ae-423a-9bda-26c42acbaa87" />

*(**Manually permitted** both VLAN 10, 30 to access the **Server** and **denied** VLAN 20 as normal but with no `permit any` command)*

<img width="488" height="67" alt="Screenshot 2026-02-10 202811" src="https://github.com/user-attachments/assets/26629d1e-2fbe-46de-aec9-92aad10c51f6" />

<img width="561" height="114" alt="Screenshot 2026-02-10 202816" src="https://github.com/user-attachments/assets/d4111abd-bcec-4170-bad8-4a14b1e1f25c" />

*(Even the name resolution and ping does not work for both VLAN 10, 30 & you can see the encounters increment `show access-list` command but the ping sill not works)*


#### 1. The Invisible Rule
Every Cisco ACL ends with an invisible `deny any` command. If a packet does not match an explicit `permit` statement, it is discarded immediately.

#### 2. Evidence from the Lab
As shown in our setup, ACL 2 only permits traffic from source subnets `192.168.1.0` and `192.168.100.0`:

- **DNS Resolution Failure:** When a client sends a DNS query to `1.1.1.1`, the return packet (Reply) has a source IP of `1.1.1.1`. Since this IP is not explicitly permitted in ACL 2, the Router drops the reply. This results in the error: `Temporary failure in name resolution`.

- **Total Internet Loss:** Similarly, pings to `1.1.1.1` show `100% packet loss`. The outbound request succeeds, but the **return traffic** is "murdered" by the implicit deny rule before it can reach the client.

#### 3. The Golden Rule
**"To block specific hosts while maintaining global connectivity, you MUST end the ACL with permit any."**

Without this final statement, your Router acts as a total blackhole for any traffic originating from outside your defined internal subnets.

- **The Fix**: 

**📸 Screenshot**

<img width="282" height="93" alt="Screenshot 2026-02-11 001303" src="https://github.com/user-attachments/assets/48079be6-579a-455d-8534-7b5011682572" />


>[!NOTE]
> #### Key Takeaways:
> - **Placement Logic:** Standard ACLs should be placed **Outbound at the Destination**. Placing them at the Source would indiscriminately block the user from accessing any network resource, not just the target server.
> - **Stateless Nature:** Standard ACLs are "dumb"—they only look at the Source IP. They cannot distinguish between an "Echo Request" and an "Echo Reply."
> - **The Golden Rule:** Always end a "Deny" list with a `permit any` to ensure return traffic (like DNS 1.1.1.1 or Web replies) isn't accidentally dropped.

>[!TIP]
> - Instead of **manually permitted** just specify the subnet or host you want to **denied** then configure the `ip deny` and after that is the `permit any` command to reduce errors when writing code.
> - Because ACL have many different way to write so try to configure it with most efficient.

**📸 Screenshot**

<img width="253" height="57" alt="Screenshot 2026-02-11 002803" src="https://github.com/user-attachments/assets/8a364419-3421-4b1e-9b4c-8df60ccd3c3f" />

*(Configured 1)*

<img width="285" height="96" alt="Screenshot 2026-02-11 002602" src="https://github.com/user-attachments/assets/9cefdb0c-2673-4e96-92f3-c2ee2a448947" />

*(Configured 2)*

- Both are corrects but 1 is more fewer than 2.

--- 

### Efficiency: The "Single Gatekeeper" Principle
In professional networking, we only need one ACL at the right place to secure a connection.

**📸 Screenshot**

<img width="883" height="125" alt="image" src="https://github.com/user-attachments/assets/e3ff6d5a-fe0d-4d2b-84bf-0af7751b3e43" />

*(Example topology)*

#### Why one Outbound ACL at the Destination is enough:

- **Kill the Request:** If you place an **Outbound** ACL on **R2** (near PC2) to block **PC1**, the "Ping Request" is dropped before it reaches PC2.

- **No Reply Needed:** Since PC2 never receives the request, it never sends a "Reply." The conversation is dead.

- **No Redundancy:** You don't need a second ACL on R1 to block PC2. Placing a single ACL at the destination gate is 100% effective.

#### The Benefits:
1. **Saves CPU:** Routers only have to check the packet once, not twice.

2. **Clean Config:** Easier to manage and troubleshoot.

3. **Flexibility:** PC1 is only blocked from PC2, but can still reach the Internet or other departments via R1.

---

### Rules of ACL Processing
To wrap up Lab 18, we must respect the internal logic of the Cisco IOS:

> [!IMPORTANT]
> #### 1. Top-to-Bottom: The "First Match" Rule
> ACLs are processed sequentially. Once a packet matches a line, the search **stops** immediately.
> - **The Trap:** If you have deny `192.168.1.1` at **Line 10** and `permit 192.168.1.1` at **Line 20**, the packet is **DROPPED.**
> - **The Lesson:** Always place your most specific rules (Host/Subnet) at the top and general rules (`permit any`) at the bottom.
> #### 2. Packet Flow: Inbound vs. Outbound
> The Router follows a strict order of operations when a packet arrives at an interface:
> - **INBOUND ACL**: 1. Packet arrives. 2. **Check ACL first.** (If denied, drop now to save CPU). 3. If permitted, look at the **Routing Table.**
> - **OUTBOUND ACL**: 1. Router finds the destination in the **Routing Table.** 2. Pushes packet toward the exit interface. 3. **Check ACL last.** (If denied, drop before it hits the wire).

---

### Final Verdict
Lab 18 successfully validates that while Standard ACLs are a blunt instrument, they are highly effective when deployed with **Strategic Placement** and **Implicit Deny Awareness.**

Understanding this sequence allows you to troubleshoot exactly where a packet is being killed. In this lab, we successfully utilized **Routing first, Filtering last** by using an **Outbound ACL** at the destination.

| [⬅️ Previous Lab](../17-Hybrid-DNS-Infrastructure-(CML)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️]|
|:--- | :---: | ---: |
