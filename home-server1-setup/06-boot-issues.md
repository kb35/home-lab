

# Boot Issues in Debian: Proxmox Removal, GRUB Repair, and Filesystem Fixes

## Overview
The next step was to install **Proxmox VE** on **Debian**,  however after the installation, the system encountered boot issues following a reboot. On the guidance of ChatGPT, Proxmox was removed manually, file by file, but the boot issue persisted.  I proceeded to troubleshoot the bootloader (GRUB), fix filesystem errors, and ensure proper hardware detection, especially the NVMe device. This troubleshooting process aimed to repair the broken system but in the end, I was unable to resolve the underlying issues. The experience was very helpful as it gave content to what I was learning about linux topics including boot up sequence, BIOS, GRUB, filesystem and chroot.  A number of the steps taken are covered here.

---

## **Initial Troubleshooting Steps**

### **1. Initial Diagnostics**
- **Checked Installed Proxmox Packages:**
  ```bash
  dpkg -l | grep proxmox
  ```
  **Result:** Confirmed that all Proxmox-related packages were installed.

- **Attempted Proxmox Package Removal:**
  ```bash
  apt remove --purge proxmox-ve pve-manager pve-cluster
  ```
  **Result:** Encountered dependency errors and unmet package dependencies. Proxmox removal needed more comprehensive steps to resolve the system configuration.

---

### **2. Resolving Initramfs Errors**
- **Updated Initramfs:**
  ```bash
  update-initramfs -u
  ```
  **Result:** Errors related to missing kernel configuration files and unsupported compression formats (e.g., `CONFIG_RD_ZSTD`, `CONFIG_RD_GZIP`) persisted.

- **Reinstalled Kernel Image:**
  ```bash
  apt install --reinstall linux-image-amd64
  ```
  **Result:** Despite reinstalling the kernel, errors related to missing `/boot/config-*` files continued to occur, showing deeper issues with the system configuration.

---

### **3. Filesystem and Device Checks**
- **Verified Disk Partitions and Filesystems:**
  ```bash
  lsblk
  fdisk -l
  parted -l
  ```
  **Result:** NVMe partitions were detected, but inconsistencies in block sizes were noted. The filesystem seemed in need of repair.

- **Checked NVMe Device Status:**
  ```bash
  dmesg | grep -i nvme
  lspci | grep -i nvme
  lsmod | grep nvme
  ```
  **Result:** The NVMe controller was detected but exhibited inconsistent behavior, especially when trying to recognize partitions.

- **Filesystem Repair on NVMe Partition:**
  ```bash
  sudo e2fsck -f /dev/nvme0n1p2
  ```
  **Result:** Minor filesystem errors were corrected, but the system still failed to boot properly.

---

### **4. Bootloader Repair Attempts**
- **Mounted Root Filesystem and Bind Mounted Essential Filesystems:**
  ```bash
  sudo mount /dev/nvme0n1p2 /mnt
  sudo mount --bind /dev /mnt/dev
  sudo mount --bind /proc /mnt/proc
  sudo mount --bind /sys /mnt/sys
  sudo mount --bind /run /mnt/run
  chroot /mnt
  ```

- **Attempted GRUB Installation:**
  ```bash
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=debian
  ```
  **Result:** Encountered the error: "/boot/efi doesn't look like an EFI partition." This error indicated that the EFI partition was either not properly configured or missing the necessary bootloader files.

- **Formatted EFI Partition and Retried GRUB Installation:**
  ```bash
  mkfs.vfat -F32 /dev/nvme0n1p1
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=debian
  ```
  **Result:** Despite reformatting the EFI partition, persistent errors indicated issues with EFI partition recognition.

---

### **5. Live USB Boot for Further Troubleshooting**
- **Booted into Debian Live USB in UEFI Mode:**
  Verified the presence of `/sys/firmware/efi` to confirm UEFI mode and ensure compatibility with the system's UEFI boot settings.

- **Mounted NVMe Partitions from Live USB:**
  ```bash
  sudo mount /dev/nvme0n1p2 /mnt
  sudo mount /dev/nvme0n1p1 /mnt/boot/efi
  ```
  **Result:** Encountered "special device does not exist" errors. This was a sign that either the partitions were not recognized correctly or the system had incorrect mount settings.

- **Attempted NVMe Module Reload:**
  ```bash
  sudo modprobe -r nvme nvme_core
  sudo modprobe nvme nvme_core
  ```
  **Result:** The NVMe device still wasn't fully recognized by the system, showing signs of potential driver issues or module conflicts.

---

### **6. BIOS and Firmware Checks**
- **Verified NVMe Detection in BIOS:**
  Entered BIOS (`F1` during boot) to check if the NVMe device was properly recognized.

- **Checked UEFI/Legacy Boot Mode Settings:**
  Ensured the system was set to **UEFI Only** to ensure compatibility with the NVMe boot.

---

### **7. BIOS Update **
 A Bios update ran when the machine was first rebooted after receiving the machine and assumed this was the latest version. At this point the version was found to not be the latest and subsequently needed to be updated. 
- **Prepared for BIOS Update:**
	
  - Downloaded the latest BIOS update from Lenovo's support site.
  - Created a bootable USB for BIOS flashing.

  **Next Step:** Perform the BIOS update to ensure proper NVMe drive compatibility and firmware stability.

---

## **Detailed Troubleshooting Steps Taken for System Repair**

### **1. Boot into Debian Live USB**
- Initially, I booted into **Debian Live USB** to investigate further without affecting the running system.

### **2. Mount the Installed System**
- Using the `mount` command, I mounted the installed system partition (`/dev/nvme0n1p2`) to `/mnt/myssd` in the live environment to access its files.

### **3. Chroot into the Installed System**
- The next step was to **chroot** into the mounted system, enabling me to perform administrative actions as if I were logged into the installed system:
  ```bash
  chroot /mnt/myssd
  ```

### **4. Filesystem Check**
- I ran `fsck` to check and repair any potential filesystem issues. The tool fixed minor filesystem errors, improving system stability:
  ```bash
  fsck -y /dev/nvme0n1p2
  ```

### **5. Repairing GRUB Bootloader**
- With the system partition mounted and chroot active, I attempted to repair the **GRUB bootloader** to address boot issues. The errors around EFI partition misconfiguration required me to format the EFI partition and retry GRUB installation.

### **6. Reinstall Kernel and Update Initramfs**
- To ensure that no kernel issues were affecting the boot process, I reinstalled the kernel and updated **initramfs**:
  ```bash
  apt reinstall linux-image-amd64
  update-initramfs -u -k all
  ```

### **7. Exit Chroot, Unmount, and Reboot**
- After performing the necessary fixes, I exited the chroot environment, unmounted the partition, and rebooted the system:
  ```bash
  exit
  umount -R /mnt/myssd
  reboot
  ```

### **8. Determined System Experiencing Critical System Files **
- At this point, the troubleshooting got the system to boot up but it kept getting stuck. I repeated a booting from Debian Live and chroot into the system and tried to repair files and install them but the steps that were presented kept repeating and weren't delivering any different results. With only a little experience at this stage, and having spent a number of hours trying to resolve the issue, I determine that it is best to take the troubleshooting experience I gained and move forward with a fresh install of Proxmox instead of on top of Debian.
---

## **Lessons Learned**
This troubleshooting process provided a valuable opportunity to learn and apply several key concepts:

- **GRUB and UEFI Repair:** I gained hands-on experience with **GRUB bootloader repair** and **UEFI partition management**, both critical aspects of system boot processes.
- **Filesystem Integrity:** Running **fsck** to repair filesystems helped me understand the importance of maintaining disk health for system stability.
- **Kernel Reinstallation:** Understanding how to reinstall the **Linux kernel** and **update initramfs** was crucial in ensuring proper boot configurations.
- **Driver and Hardware Compatibility:** Troubleshooting hardware recognition issues, particularly with the **NVMe device** and its drivers, helped deepen my understanding of system hardware and driver management.

---

## **Conclusion**
Through this detailed troubleshooting process, I learned valuable lessons about **system repair**, **bootloader management**, **filesystem health**, and **hardware troubleshooting**. These skills are essential for anyone working in system administration, particularly in environments where booting issues can affect system uptime and stability.

The experience also provided insight into managing hardware compatibility issues (e.g., with NVMe devices) and resolving conflicts between system firmware and the operating system.

