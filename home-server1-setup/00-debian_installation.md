# Debian Installation Guide for Home-Server1 (ThinkCentre M920q)

## Overview
This document outlines the steps taken to install **Debian 12** on the **Lenovo ThinkCentre M920q**, ensuring a stable and secure base for the home lab.

---

## Prerequisites
### **Hardware Requirements**
- **Lenovo ThinkCentre M920q** (Intel Core i5-8500T, 32GB RAM, 1TB NVMe SSD)
- USB flash drive (at least **4GB**)
- Stable **internet connection**
- External keyboard, monitor, and USB mouse (for installation)

### **Software Requirements**
- **Debian 12 netinst ISO** ([Download Here](https://www.debian.org/distrib/netinst))
- **Rufus** (Windows) or **balenaEtcher** (Mac/Linux) to create a bootable USB

---

## Step 1: Create a Bootable USB
1. Download the **Debian 12 netinst ISO** from the official Debian site.
2. Use **Rufus (Windows)** or **balenaEtcher (Mac/Linux)** to write the ISO to a USB drive.
3. Insert the USB into the **M920q** and power it on.

---

## Step 2: Boot from USB
1. Press **F12** during boot to open the boot menu.
2. Select the **USB drive** and press **Enter**.
3. Choose **Graphical Install** or **Install**.

---

## Step 3: Installation Process
### **1. Select Installation Preferences**
- Choose **Language**, **Location**, and **Keyboard Layout**.
- Configure **network settings** (DHCP is recommended initially).

### **2. Set Up Users and Passwords**
- Assign a **hostname**: `home-server1`
- Set up a **root password** and a non-root **user account**.

### **3. Partition the Disk**
- Select **Guided - use entire disk**.
- Choose **1TB NVMe SSD** and confirm partitioning.
- Select **All files in one partition (recommended for beginners)**.

### **4. Install the Base System**
- The installer will copy and install system files.

### **5. Software Selection**
- Select **SSH Server** and **Standard System Utilities** and other options as needed.
- **Uncheck** any desktop environment (for server use only).

### **6. Install GRUB Bootloader**
- Select the primary SSD (e.g., `/dev/nvme0n1`).

### **7. Finish Installation & Reboot**
- Remove the USB and reboot the system.

---

This completes the **Debian 12 installation** on **home-server1**.



