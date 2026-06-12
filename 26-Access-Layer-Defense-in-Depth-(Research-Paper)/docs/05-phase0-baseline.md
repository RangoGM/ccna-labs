# Phase 0: Establishing the Baseline Environment

Section 4 presents the full deployment and testing of the Defense-in-Depth model at the Access Layer on the physical lab infrastructure. Each phase follows the same structure: describe the attack, deploy the countermeasure, measure results, and draw conclusions. Phase 0 establishes the shared baseline used by all subsequent phases.

Phase 0 confirms the whole lab works correctly before any experiment begins. The configuration here is the fixed foundation throughout — later phases only add security features, never changing the topology or basic VLAN segmentation.

## 4.1.1 Baseline CPU State

Before any experiment, SW1's CPU is recorded as a reference for all phases. At idle, CPU stays around **4–13%**.

*(Figure 4.1: `show process cpu history` on SW1 at idle.)* Each `*` column represents %CPU at one second. CPU fluctuates 4–13% with no abnormal traffic.

## 4.1.2 Confirming Services on the Ubuntu Server

The Ubuntu Server (192.168.99.99) is pre-configured with the services used throughout the experiment. Detailed per-service configuration belongs to infrastructure deployment and is not repeated here:

- **Apache2 + BIND9:** internal web portal `portal.corp.local` (reachable from VLAN 10 and 99) and LogAnalyzer `loganalyzer.corp.local` (VLAN 99 only).
- **rsyslog:** receives Syslog from SW1 over UDP 514, stores logs, and forwards to LogAnalyzer.
- **FreeRADIUS:** 802.1X/MAB authentication (used from Phase 7).

*(Figure 4.2: Login page of the internal web portal `portal.corp.local` — the HTTP bait service for the Phase 3 credential-sniffing experiment.)*

*(Figure 4.3: LogAnalyzer at baseline — no attack logs from SW1, confirming a clean environment before testing.)*

Once all connectivity is confirmed, CPU is idle, and the Ubuntu services are healthy, the lab is ready for Phase 1.
