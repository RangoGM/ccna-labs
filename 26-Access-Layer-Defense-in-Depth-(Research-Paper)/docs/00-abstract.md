# Abstract

**Title:** Building and evaluating a layered security model at the enterprise network access layer on the Cisco Catalyst 2960.

**Objective:** Validate a Defense-in-Depth model at the Access Layer, identify residual risk, and propose a deployment plan for SMEs.

**Method:** Experimentation on a Cisco Catalyst 2960-24TT-L (IOS 15.0(2)SE11), a Cisco 2811 router, an Ubuntu Server (bare-metal), and Kali Linux (VMware), carried out over 8 phases of attack, defense, measurement, and evaluation.

**Results:** An 8-layer model (Port Security, DHCP Snooping, DAI, IPSG, Storm Control, RA Guard, BPDU Guard, 802.1X/MAB) was successfully validated on physical hardware. Experimental evidence confirms that **DAI alone is bypassed by a forged raw IP packet** (router CPU 99%, victim loses 73% of packets) — adding **IPSG blocks it completely** (victim receives a full 100%). **MITM Stealth** neutralizes every client-side detection method; only DAI at the switch level is effective. A controlled comparison confirms that DAI preserves 100% of log data thanks to its aggregation mechanism, whereas **Port Security Restrict loses 88%** and **RA Guard loses 50%** — the loss rate rising with attack speed. The Catalyst 2960 does not support CoPP, so Storm Control is the only flood-mitigation mechanism. The experiments reveal interaction between defense layers: IPSG/Port Security drop BPDUs from a spoofed MAC before they reach the STP process, so BPDU Guard only needs to handle BPDUs from a legitimate MAC — err-disabling immediately. **DHCPv6 Guard does not function** because the ASIC does not parse IPv6 at L3/L4 — the single residual risk. RA Guard works correctly in every scenario including Extension Headers once the SDM template is switched to dual-stack. An 802.1X architecture for the user VLAN combined with MAB and switchport protected for the IoT VLAN solves multi-platform authentication while limiting lateral attacks.

**Recommendation:** A proposed deployment order for the 8 layers in an SME. Future directions: CoPP on the router, switch upgrades, modern monitoring, and advanced IPv6 security.

**Keywords:** Defense-in-Depth, Access Layer, Catalyst 2960, DAI, IPSG, 802.1X, MITM Stealth, IPv6, residual risk.
