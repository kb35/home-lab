# Security Hardening - home-server1

## Overview

This document builds upon previous configuration to further secure `home-server1`. It focuses on **intrusion prevention, monitoring, and access control** to enhance system security beyond the initial configuration steps.

---

## Step 1: Strengthen SSH Security

### **What is SSH?**

Secure Shell (SSH) is a cryptographic network protocol used for secure remote login and command execution. It provides encrypted communication between a client and a server, protecting against eavesdropping and credential theft.

### 1. Enforce Key-Based Authentication

Key-based authentication enhances security by replacing password authentication with cryptographic key pairs, which are significantly harder to brute-force.

#### **Process:**

1. Open the SSH configuration file:
   ```bash
   sudo nano /etc/ssh/sshd_config
   ```
2. Add or modify the following lines:
   ```ini
   PermitRootLogin no  # Prevents root login
   PasswordAuthentication no  # Enforces SSH key-based authentication
   AllowUsers yourusername  # Restricts SSH access to specific users
   MaxAuthTries 3  # Limits the number of authentication attempts per session
   ```  
3. Restart SSH to apply changes:
   ```bash
   sudo systemctl restart ssh
   ```
4. **If SSH fails to restart**, check for errors:
   ```bash
   systemctl status ssh.service
   journalctl -xeu ssh.service
   ```
   Common causes include syntax errors in `sshd_config` or missing SSH keys. Use:
   ```bash
   sudo sshd -t
   ```
   to test configuration before restarting.

5. **Fix Missing Library Issue**
   If `sshd -t` returns an error about `libcrypt.so.1`, reinstall the missing library:
   ```bash
   sudo apt install --reinstall libcrypt1
   ```
   Then restart SSH:
   ```bash
   sudo systemctl restart ssh
   ```

### 2. Implement SSH Rate Limiting with UFW

UFW (Uncomplicated Firewall) is a front-end for iptables that simplifies firewall management. Limiting SSH connection attempts reduces the risk of brute-force attacks.

#### **Process:**

1. Use UFW to limit SSH connections:
   ```bash
   sudo ufw limit OpenSSH
   ```

---

## Step 2: Harden User Account Security

### **What is PAM?**

Pluggable Authentication Module (PAM) provides flexible authentication mechanisms. `libpam-pwquality` enforces password complexity rules to improve account security.

### 1. Enforce Strong Password Policies

Using strong passwords reduces the likelihood of unauthorized access due to weak credentials.

#### **Process:**

1. Install password quality control package:
   ```bash
   sudo apt install -y libpam-pwquality
   ```
2. Modify `/etc/security/pwquality.conf`:
   ```ini
   minlen = 12  # Minimum password length
   retry = 3  # Maximum retry attempts before failure
   ucredit = -1  # Require at least one uppercase letter
   lcredit = -1  # Require at least one lowercase letter
   dcredit = -1  # Require at least one digit
   ocredit = -1  # Require at least one special character
   ```  

### 2. Disable Unused User Accounts

Inactive accounts can become security risks if left enabled.

#### **Process:**

1. List all users:
   ```bash
   cut -d: -f1 /etc/passwd
   ```
2. Disable any unnecessary accounts:
   ```bash
   sudo usermod -L username
   ```

---

## Step 3: Enable Automatic Security Updates

### **What is Unattended Upgrades?**

`unattended-upgrades` automatically installs security updates without user intervention, reducing exposure to vulnerabilities.

#### **Process:**

1. Edit the Unattended Upgrades configuration file:
   ```bash
   sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
   ```
2. Ensure the `Origins-Pattern` section is correctly formatted:
   ```ini
   Unattended-Upgrade::Origins-Pattern {
       "origin=Debian,codename=${distro_codename},label=Debian";
       "origin=Debian,codename=${distro_codename},label=Debian-Security";
       "origin=Debian,codename=${distro_codename}-security,label=Debian-Security";
   };
   ```
3. Enable automatic reboots after security updates:
   ```ini
   Unattended-Upgrade::Automatic-Reboot "true";
   ```
4. Restart unattended-upgrades service:
   ```bash
   sudo systemctl restart unattended-upgrades
   ```
5. Test the configuration:
   ```bash
   sudo unattended-upgrade --dry-run --debug
   ```

---

## Conclusion

Further hardening steps will include **intrusion detection systems, system integrity monitoring, and container security**.

