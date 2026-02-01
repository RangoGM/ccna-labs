## Lab 02C - Native VLAN Mismatch (Extra)

### Topology

This lab reuses the same topology from **Lab 02B - VLAN Trunking (Allowed VLAN Restriction)**.

The VLAN design and access port configuration remain unchanged.
The only modification is the native VLAN configuration on the trunk link
between the two switches.

**📸 Screenshot:**

<img width="1015" height="250" alt="Screenshot 2026-02-01 125402" src="https://github.com/user-attachments/assets/14c64aff-56a9-4b7a-8613-37b449462f6d" />

*(Example topology)*

---

### Goal

- Understand the concept of the native VLAN on an IEEE 802.1Q trunk
- Observe the behavior and warnings caused by native VLAN mismatch
- Recognize why native VLAN mismatches are considered a best-practice risk

---

### VLAN Design

**Switch 1**
- VLAN 10 - SALES
- VLAN 20 - IT
- VLAN 30 - HR
- Native VLAN: VLAN 1 (default)

**📸 Screenshot:**

<img width="600" height="141" alt="Screenshot 2026-02-01 133830" src="https://github.com/user-attachments/assets/655aa631-657f-4489-9a54-6261d4390fff" />


**Switch 2**
- VLAN 10 - SALES
- VLAN 20 - IT
- VLAN 30 - HR
- Native VLAN: VLAN 99 (non-default)

**📸 Screenshot:**

<img width="591" height="140" alt="Screenshot 2026-02-01 133813" src="https://github.com/user-attachments/assets/ff072e78-46ed-40ba-840f-54f5f05a125c" />


---

### Key Configuration

- Reuse VLAN, access port, and trunk configuration from Lab 02B
- Change the native VLAN on the trunk on one switch only
- Do not modify allowed VLAN settings

---

### Example Configuration (Native VLAN)

```bash
SWITCH(config)# interface <trunk-interface>
SWITCH(config-if)# switchport mode trunk
SWITCH(config-if)# switchport trunk native vlan 99
```

*(Native VLAN is left unchanged on the other switch)*

---

### Verification

- Verify trunk status:
  - *```show interfaces trunk```*
- Observe console messages or warnings related to native VLAN mismatch
- Verify connectivity for allowed VLANs (behavior may vary depending on traffic)

---

### Result 

- Trunk link remains up
- A native VLAN mismatch condition exists between the switches
- Warning messages indicate a native VLAN mismatch

**📸 Screenshot:**

<img width="1034" height="38" alt="image" src="https://github.com/user-attachments/assets/d6bd3a12-b6be-4507-af42-55986bdd333b" />

- Tagged VLAN traffic (VLAN 10, 20, 30) continues to function normally

**📸 Screenshot:**

<img width="811" height="500" alt="image" src="https://github.com/user-attachments/assets/f5546a20-2920-49e3-ba32-c09bb467584f" />

 *(Kali_IT VLAN 10 can ping SALES in the same VLAN but can not ping VLAN 20)*

---

### Common Misconfiguration / Critical Exception

- But if we change native VLAN exactly like VLAN in access ports switch, this is what will gonna happen:

#### Topology

**📸 Screenshot:**


<img width="1130" height="253" alt="Screenshot 2026-02-01 135256" src="https://github.com/user-attachments/assets/91f0f1f2-ab21-44e6-a622-fa68bd28e0fa" />


<img width="600" height="137" alt="image" src="https://github.com/user-attachments/assets/4767c6b1-7eb0-41df-ab2c-35602d0679a0" />



<img width="588" height="142" alt="image" src="https://github.com/user-attachments/assets/42ef4f12-c1e9-4ed6-ab21-b87f3722d088" />

*(I changed the Kali_HR in VLAN 20 to the otherside of switch and configured the switch 2 change native vlan to 20 from 99, switch 1 on the other hand i changed it to native vlan 10 to do not tagged VLAN when trunking)*

#### Result

- VLAN 10 can reach VLAN 20 due to the missmatch VLAN

<img width="649" height="62" alt="Screenshot 2026-02-01 143645" src="https://github.com/user-attachments/assets/8a1a71a2-cc83-4ade-b0ad-6892c76adefb" />

*(Kali_IT VLAN 10 IP Adress)*

<img width="543" height="61" alt="Screenshot 2026-02-01 143653" src="https://github.com/user-attachments/assets/3c74f427-ffb7-4186-8c72-ef6e0d022060" />

*(Kali_HR VLAN 20 IP Adress)*

- *(Theres no default gateway configured on both hosts because theres no Inter-VLAN Routing (Next Lab), so hosts can send ARP request to reach other hosts in the same subnet)*
- *(Typically, different VLANs are assigned to different subnets. To enable communication between hosts in mismatched VLANs for this lab, we must manually override this by placing both hosts into the same subnet.)*
- *(By default, Cisco switches employ **PVID Consistency Check** via **STP**. When a Native VLAN mismatch is detected, STP places the port into a **'broken' (root-inconsistent) state** to prevent potential **Layer 2 loops** and traffic leaking between different broadcast domains.)*

-> By disabling all this features (*NOT RECOMMEND IN REALIFE*) this will allowed different VLAN can reach each other.

<img width="520" height="183" alt="Screenshot 2026-02-01 144101" src="https://github.com/user-attachments/assets/f6a64a10-940c-4c68-a6fc-3f9ccedb059d" />

<img width="591" height="146" alt="Screenshot 2026-02-01 144113" src="https://github.com/user-attachments/assets/019a83c5-d531-4712-956e-91d93738be66" />


---

### Troubleshooting / Common Mistakes

- Assuming a trunk is fully healthy just because the link is up
- Forgetting to match native VLANs on both ends of a trunk
- Using the native VLAN for user traffic
- Ignoring console warnings related to native VLAN mismatch

---

### Notes

This lab intentionally introduces a native VLAN mismatch on an IEEE 802.1Q
trunk to demonstrate a common configuration issue.

By default, the native VLAN carries untagged frames on a trunk. When the native
VLAN is different on each side of the trunk, untagged traffic may be
misinterpreted, leading to potential security and stability risks.

In this lab, a dedicated VLAN (VLAN 99) is used as the native VLAN on one switch.
No end devices are assigned to this VLAN, which helps avoid unintended traffic
leakage and misleading connectivity results.

Although the trunk link remains operational, a native VLAN mismatch condition
exists and warning messages may be observed.

Best practice is to avoid using a user VLAN as the native VLAN and to explicitly
configure and match the native VLAN on both ends of a trunk.


