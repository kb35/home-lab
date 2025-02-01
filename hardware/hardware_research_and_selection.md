# Home Lab Hardware Research and Selection

## Overview
This document details the research and decision-making process for selecting suitable hardware components for the home lab project. The objective was to identify cost-effective, power-efficient, and capable hardware that supports system administration, DevOps, networking, and fleet management experimentation.

---

## Server Selection
### Considerations
- **Performance vs. Power Consumption:** Needed a balance between computing power and energy efficiency.
- **Expandability:** Support for memory and storage upgrades.
- **Linux Compatibility:** Ability to run a stable Linux server OS.
- **Remote Management:** SSH and VNC support.
- **Cost-effectiveness:** Reasonable budget with good long-term value.

### Options Considered
| Model | CPU | RAM | Storage | Power Usage | Key Features | Verdict |
|--------|---------|-----|----------|------------|--------------|---------|
| **Lenovo ThinkCentre M920q** | Intel Core i5-8500T | 32GB (Upgraded) | 1TB NVMe SSD | ~35W | Small form factor, quiet, upgradeable | ✅ Chosen |
| Dell OptiPlex 3070 Micro | Intel Core i5-9500T | 16GB | 512GB SSD | ~35W | Compact, remote management capable | ❌ Lesser expandability |
| HP EliteDesk 800 G4 Mini | Intel Core i5-8500T | 16GB | 512GB SSD | ~35W | Reliable, good Linux support | ❌ Costlier |
| Raspberry Pi 5 | Broadcom BCM2712 | 8GB LPDDR4X | 256GB microSD | ~5W | ARM-based, extremely low power, GPIO support | ✅ Chosen for IoT and lightweight tasks |

### **Final Choice**
- **Primary Server:** **Lenovo ThinkCentre M920q** with 32GB RAM and 1TB NVMe SSD.
- **Secondary Compute Device:** **Raspberry Pi 5** with 8GB RAM and 256GB microSD card, for IoT and fleet management testing.

---

## Network Equipment Selection
### Considerations
- **VLAN and QoS Support:** Managed switch preferred.
- **Compact Size:** Needed to fit within a small space.
- **Gigabit Performance:** Essential for high-speed internal communication.
- **Cost-effectiveness:** Balance between feature set and affordability.

### Options Considered
| Model | Ports | VLAN Support | Managed | Verdict |
|--------|------|-------------|---------|---------|
| **Netgear GS108** | 8 | No | Unmanaged | ✅ Chosen for basic networking |
| **Netgear GS105** | 5 | No | Unmanaged | ✅ Chosen for secondary connections |
| TP-Link TL-SG108E | 8 | Yes | Smart Managed | ❌ Considered, but not necessary for current scope |
| Ubiquiti UniFi Switch 8 | 8 | Yes | Fully Managed | ❌ Too expensive for initial setup |

### **Final Choice**
- **Netgear GS108 (8-Port Unmanaged Gigabit Switch)** – Chosen for main wired networking.
- **Netgear GS105 (5-Port Unmanaged Gigabit Switch)** – Used for additional connectivity.

---

## Linux OS Research
### Considerations
- **Stability and Security:** Needed an OS with long-term support.
- **Lightweight & Minimal Install Options:** Preferred for a server environment.
- **Community Support:** Large ecosystem with troubleshooting resources.

### Options Considered
| OS | Type | LTS Support | Key Features | Verdict |
|----|------|------------|--------------|---------|
| **Debian 12** | General-Purpose | Yes (5+ Years) | Stable, minimal install, widely used for servers | ✅ Chosen |
| Ubuntu Server 22.04 | General-Purpose | Yes (5 Years) | User-friendly, Debian-based | ❌ More overhead |
| Arch Linux | Rolling Release | No | Latest packages, lightweight | ❌ Not ideal for stability |
| Proxmox VE | Virtualization | Yes | Virtualization-focused | ❌ Not needed for initial setup |

### **Final Choice**
- **Debian 12 Server Edition** installed on **Lenovo ThinkCentre M920q**.
- Debian also planned for **Raspberry Pi 5** for compatibility and flexibility.

---

## Hardware Upgrades & Justification
| Component | Upgrade | Reason |
|-----------|---------|--------|
| **Lenovo ThinkCentre M920q RAM** | 16GB → 32GB Kingston FURY Impact | Needed for running multiple services |
| **Lenovo ThinkCentre M920q Storage** | 256GB → 1TB Kingston NVMe SSD | Increased space for logs, VMs, and software |
| **Raspberry Pi 5 Storage** | 64GB → 256GB SanDisk Extreme Pro microSD | More storage for fleet management experiments |

---

## Conclusion
The final **hardware setup** provides a balance of **performance, power efficiency, and cost-effectiveness** while enabling hands-on learning in **system administration, networking, and fleet management**. Future expansions may include **managed networking switches, additional storage, or cloud integrations**.

