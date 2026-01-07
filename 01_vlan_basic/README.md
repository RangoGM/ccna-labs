## Lab 01 - Basic VLAN Configuration

### Topology
- One Layer 2 Switch
- 6 PC
- 3 VLANs

### Goal 
- Understanding the VLAN concept
- Verify traffic isolation between different VLANs
- Observe communication behavior within the same VLAN

### VLAN Design 
- VLAN ID: 10, Name: SALES, Devices: PC1, PC2.
- VLAN ID: 20, Name: IT, Devices: PC3, PC4.
- VLAN ID: 30, Name: HR, Devices: PC5, PC6.

### Assign IP Adress for PCs
- VLAN 10: 192.168.1.0 /24
- VLAN 20: 192.168.2.0 /24
- VLAN 30: 192.168.3.0 /24

(No default gateway configured)

### Key Configuration
- Create VLAN: 10, 20, 30.
- Assign access ports to the correct VLAN
- Configure end devices with static IP addresses

### Verification 
- Verify VLAN assignment:
  - *show vlan brief*
- Ping test results:
  - Same VLAN communication: **Success**
  - Different VLAN communication: **Fail**
 
### Result 
- Devices within the same VLAN can communicate
- Devices in different VLANs can not communicate without Layer 3 routing (Inter-VLAN Routing)

### Troubleshooting / Common Mistakes
- Ports assigned to the wrong VLAN
- Verify using *show vlan brief*

- VLAN not created before assigning ports
- Ports remain in default VLAN 1

- Expecting inter-VLAN communication
- Inter-VLAN Routing is not configured in this lab

### Notes 
Each VLAN respresents a seperate broadcast domain.
Inter-VLAN communication requires a Layer 3 device such as router or Layer 3 switch.
