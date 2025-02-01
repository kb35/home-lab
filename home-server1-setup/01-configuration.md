# Home Server 1 - Post-Installation Configuration

## Overview
This document outlines the essential **post-installation configurations** for `home-server1` after installing Debian 12. The goal is to enhance security, enable remote access, configure networking, and set up foundational system services.

---

## Step 1: Update the System

Updating ensures the system has the latest security patches and bug fixes.

```bash
sudo apt update && sudo apt upgrade -y
```

This command:
- `apt update`: Refreshes the package index.
- `apt upgrade -y`: Installs all available updates.

---

## Step 2: Configure User Accounts & Permissions

Using a non-root user improves security and prevents accidental system-wide changes.

1. Create a new user (if not already created during installation):
   ```bash
   sudo adduser yourusername
   ```
2. Add the user to the sudo group:
   ```bash
   sudo usermod -aG sudo yourusername
   ```

---

## Step 3: Enable SSH for Remote Access

SSH allows secure remote management of `home-server1`.

1. Ensure SSH is installed:
   ```bash
   sudo apt install -y openssh-server
   ```
2. Start and enable SSH to run at boot:
   ```bash
   sudo systemctl enable ssh
   sudo systemctl start ssh
   ```
3. Find your IP address to connect remotely:
   ```bash
   ip a
   ```
4. Connect from another machine:
   ```bash
   ssh keith@192.168.68.65
   ```

---

## Step 4: Secure SSH Access

By default, SSH can be a security risk. Changing default settings helps prevent brute-force attacks and enhances security. This configuration allows secure ssh from a Mac as the primary means of accessing the server

### 1. Edit the SSH Configuration File
The SSH configuration file contains settings that control how SSH connections are handled.
```bash
sudo nano /etc/ssh/sshd_config
```

### 2. Modify Key Settings
Find and update the following settings:

#### **Disable Root Login**
```ini
PermitRootLogin no
```
- Prevents the root user from logging in remotely via SSH.
- This reduces the risk of brute-force attacks on the root account.

#### **Disable Password Authentication** (Enable Key-Based Access)
```ini
PasswordAuthentication no
```
- Disables logging in with a password.
- Forces users to use **SSH keys**, which are more secure.

#### **Allow Only Specific Users**
```ini
AllowUsers yourusername
```
- Restricts SSH access to the specified user(s), ensuring unauthorized users cannot connect.
- Replace `yourusername` with your actual Mac user account that will be used for SSH access.

### 3. Restart SSH Service
After making changes, restart the SSH service to apply them:
```bash
sudo systemctl restart ssh
```

### 4. Generate SSH Keys on Mac
On your Mac, open **Terminal** and generate an SSH key pair:
```bash
ssh-keygen -t rsa -b 4096
```
- The **private key** is stored on your Mac (`~/.ssh/id_rsa`).
- The **public key** (`~/.ssh/id_rsa.pub`) will be copied to the Debian server.

### 5. Copy the SSH Key to Home-Server1
Run the following command from your Mac:
```bash
ssh-copy-id keith@home-server1
```
- This automatically adds your **public key** to the `~/.ssh/authorized_keys` file on the Debian server.
- If `ssh-copy-id` is not available, manually copy the public key:
  ```bash
  cat ~/.ssh/id_rsa.pub | ssh yourusername@home-server1 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys"
  ```

### 6. Connect from macOS
Now you can SSH into `home-server1` without a password:
```bash
ssh keith@home-server1
```

### 7. Optional: Create an SSH Shortcut on Mac
To simplify SSH access, create a **config file** on your Mac:
```bash
nano ~/.ssh/config
```
Add the following:
```ini
Host home-server1
    HostName 192.168.1.100
    User yourusername
    IdentityFile ~/.ssh/id_rsa
    Port 22
```
Now, you can SSH in just by typing:
```bash
ssh home-server1
```

By default, SSH can be a security risk. Changing default settings helps prevent brute-force attacks and unauthorized access.

1. Edit the SSH configuration file:
   ```bash
   sudo nano /etc/ssh/sshd_config
   ```
   This opens the SSH daemon configuration file, where security settings can be adjusted.

2. Modify or add the following lines:
   ```ini
   PermitRootLogin no  # Disables root SSH login to prevent direct root access over SSH, reducing attack risk.
   PasswordAuthentication no  # Enforces SSH key-based authentication, eliminating password brute-force vulnerabilities.
   AllowUsers yourusername  # Restricts SSH access to only specified users, reducing exposure to unauthorized accounts.
   ```

3. Restart SSH to apply changes:
   ```bash
   sudo systemctl restart ssh
   ```
   This command restarts the SSH service so that the new security settings take effect.

By default, SSH can be a security risk. Changing default settings helps prevent brute-force attacks.

1. Edit the SSH configuration file:
   ```bash
   sudo nano /etc/ssh/sshd_config
   ```
2. Modify or add the following lines:
   ```ini
   PermitRootLogin no  # Disables root SSH login
   PasswordAuthentication no  # Enforces SSH key-based authentication
   AllowUsers yourusername  # Restricts SSH access to specific users
   ```
3. Restart SSH to apply changes:
   ```bash
   sudo systemctl restart ssh
   ```
   
---

## Step 5: Set Up a Firewall with UFW

Uncomplicated Firewall (UFW) is a user-friendly front-end for managing firewall rules on Linux-based systems. It simplifies iptables, making it easier to control network traffic and enhance system security.

1. Install UFW:
   ```bash
   sudo apt install -y ufw
   ```
2. Allow essential services:
   ```bash
   sudo ufw allow OpenSSH
   ```
3. Enable the firewall:
   ```bash
   sudo ufw enable
   ```
4. Check status:
   ```bash
   sudo ufw status verbose
   ```

---

## Step 6: Configure Static IP (Optional)


### Configuration Error & Lessons Learned
During initial attempts to configure the static IP, the interface name was incorrectly assumed to be `eth0`, which caused the networking service to fail upon restart. The correct interface name was determined by running:
```bash
ip link show
```
This revealed the correct interface name as `eno1`. eno1 is commonly used on Lenovo machines. Updating the configuration file resolved the issue.

1. Edit the network configuration:
   ```bash
   sudo nano /etc/network/interfaces
   ```
2. Example static IP configuration:
   ```ini
   auto eno1
   iface eno1 inet static
   address 192.168.1.100
   netmask 255.255.255.0
   gateway 192.168.1.1
   dns-nameservers 8.8.8.8 8.8.4.4
   ```
3. Restart networking:
   ```bash
   sudo systemctl restart networking
   ```

Lessons learned:
- Always verify the network interface name before making changes.
- If networking fails after a configuration change, use `ip a` or `journalctl -xe` to diagnose errors.

---

## Step 7: Install Essential Packages
### **Why?**
These tools enhance system monitoring, package management, and administration.

```bash
sudo apt install -y vim htop curl wget net-tools git
```
- `vim`: A powerful text editor.
- `htop`: A real-time process viewer.
- `curl & wget`: Command-line tools for downloading files.
- `net-tools`: Provides network utilities like `ifconfig`.
- `git`: Enables version control for scripts and configurations.

---

## Conclusion
This post-installation configuration ensures **security, stability, and remote management** of `home-server1`. Future steps will include **monitoring tools, Docker setup, and automation scripting**.



