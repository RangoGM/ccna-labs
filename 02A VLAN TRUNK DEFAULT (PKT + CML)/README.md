<br>

| [⬅️ Back to Table of Contents](../README.md) |
| :--- |
---

## Lab 02A - VLAN Trunking (Default Allow All)

### Topology
This lab reuses the access-layer topology from **Lab 01 - Basic VLAN Configuration**.

The same VLAN and access port configuration is appllied on both switches. A second switch is added, and the two switches are connected using an IEEE 802.1Q trunk link.

**📸 Screenshot:**

<img width="1015" height="250" alt="Screenshot 2026-02-01 125402" src="https://github.com/user-attachments/assets/b66cc69a-9559-45fc-af99-78ad32d01381" />

*(Example Topology)*

---

### Goal 
- Understand IEEE 802.1Q trunking
- Verify VLAN communication across multiple switches
- Observe default trunk behavior (all VLANs allowed)

---

### VLAN Design

**Switch 1**
- VLAN 10 - SALES
- VLAN 20 - IT
- VLAN 30 - HR

**Switch 2**
- VLAN 10 - SALES
- VLAN 20 - IT
- VLAN 30 - HR

**📸 Screenshot:**

<img width="491" height="194" alt="Screenshot 2026-02-01 125448" src="https://github.com/user-attachments/assets/07c694b8-45f7-4a64-b47b-bda5991c910e" />

*(Both switches are configured the same)*

---

### Key Configuration 
- Reuse VLAN and access port configuration from Lab 01
- Create the same VLANs on both switches
- Configure a trunk link between the switches
- Do not restrict allowed VLANs on the trunk (This will be covered in lab 02B)

---

### Example Configuration (Trunk Port)

```bash
SW-CORE(config)#interface <trunk-interface>
SW-CORE(config-if)#switchport mode trunk
```

**📸 Screenshot:**

<img width="604" height="252" alt="Screenshot 2026-02-01 131642" src="https://github.com/user-attachments/assets/5c797c68-b3ae-45fa-9953-188401ca4514" />

*(Access port configuration is omited for brevity)*

---

### Verification
- Verify VLAN database by using *```show vlan brief```* command
- Verify trunk status by using *```show interfaces trunk```* command
- Test connectivity using ping:
  - Same VLAN, different switch
     - VLAN 10:

     **📸 Screenshot:**
       
     <img width="608" height="165" alt="Screenshot 2026-02-01 125558" src="https://github.com/user-attachments/assets/db035b27-6232-4f60-976e-41b195c230f8" />

     *(Kali_IT VLAN 10)*

     <img width="569" height="99" alt="Screenshot 2026-02-01 125714" src="https://github.com/user-attachments/assets/4b2996d8-2e87-4bef-8031-c51fac8d3842" />

     *(Router act like a Client in VLAN 10)*

     <img width="1271" height="351" alt="Screenshot 2026-02-01 125742" src="https://github.com/user-attachments/assets/5eef2e75-dda0-4413-b34c-346597614a0a" />

     *(Use Wireshark to capture the packet from eth0 in Linux) - Optional*

  - Different VLAN
    - Vlan 20 -> 10:
   
    **📸 Screenshot:**

    <img width="483" height="132" alt="Screenshot 2026-02-01 125832" src="https://github.com/user-attachments/assets/d0d7fd99-e8d6-444d-aec0-2950707a6f38" />

    <img width="620" height="158" alt="Screenshot 2026-02-01 125851" src="https://github.com/user-attachments/assets/278de681-64d2-40e4-bdf4-05729ba446d7" />

    *(As expected VLAN 20 can not communicate with VLAN 10 in different switch via a trunk link)*

---

### Result 
- Devices in VLAN 10, VLAN 20, and VLAN 30 can communicate across switches
- Trunk operates with default settings, allowing all VLANs

--- 

### Troubleshooting / Common Mistakes

- Devices within the same VLAN are configured with different IP subnets  
  - Verify IP addressing on end devices

- Interface is administratively down  
  - Check interface status and enable it using *`no shutdown`*

- Trunk link is not formed between switches  
  - Verify trunk configuration and cable type

- Link does not come up due to incorrect cable type  
  - Ensure correct cable is used if auto-MDIX is not available
 
---

### Notes
This lab builds directly on Lab 01 and serves as a foundation for VLAN trunk
restriction and inter-VLAN routing.

By default, an IEEE 802.1Q trunk allows all VLANs. Since the same VLANs exist
on both switches and no restrictions are applied, traffic is successfully
forwarded across the trunk.

VLAN 1 is used as the native VLAN by default. Native VLAN configuration and
mismatch scenarios are not covered in this lab.

---

| [⬅️ Previous Lab](../01%20VLAN%20BASIC%20(PKT)) | [🏠 Main Menu](../README.md) | [Next Lab ➡️](../02B%20VLAN%20Trunking%20(Allowed%20VLAN%20Restriction)%20(PKT)) |
|:--- | :---: | ---: |

