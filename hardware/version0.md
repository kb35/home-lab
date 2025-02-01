# Home Lab Hardware - Version 0

## Overview
This document outlines the initial hardware setup (**Version 0**) of the home lab. This first iteration focuses on establishing a foundational environment for system administration, networking, and experimentation with fleet management concepts.

---

## Initial Hardware Setup

### **Compute Devices**
| Device | OS | Specs | Purpose |
|--------|----|-------|---------|
| **Lenovo ThinkCentre M920q** | Debian 12 | Intel Core i5-8500T, 32GB RAM, 1TB NVMe SSD | Primary server for system administration and networking |
| **Raspberry Pi 5** | Debian 12 / Raspberry Pi OS | Broadcom BCM2712, 8GB RAM, 256GB microSD | IoT, fleet management testing, and lightweight services |

### **Network Equipment**
| Device | Type | Ports | VLAN Support | Purpose |
|--------|------|-------|--------------|---------|
| **Netgear GS108** | Unmanaged Switch | 8 | No | Main wired networking backbone |
| **Netgear GS105** | Unmanaged Switch | 5 | No | Additional wired connectivity |

### **Storage & Peripherals**
| Component | Device | Capacity | Purpose |
|-----------|--------|----------|---------|
| **Primary Storage** | Lenovo ThinkCentre M920q | 1TB NVMe SSD | OS, applications, and logging |
| **Secondary Storage** | Raspberry Pi 5 | 256GB microSD | Lightweight services, experimentation |
| **Networking** | TP-Link AC600 USB Wi-Fi Adapter | - | Wireless connectivity for Raspberry Pi |

---

This **Version 0 setup** provides a simple yet functional foundation for further expansion and learning. As the home lab evolves, additional documentation will track upgrades, configurations, and new experiments.

