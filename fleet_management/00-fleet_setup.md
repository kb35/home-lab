
# Fleet Monitoring, Deployment & Validation

## Setting Up the Fleet Environment

This section provides detailed step-by-step instructions to set up a fleet management environment. The aim of this section is to set up:

- A **Fleet Controller** (Home-Server1 - Lenovo M920q) acting as the main server to manage other devices.
- A **Fleet Node** (Raspberry Pi 5) that will be remotely controlled and monitored.
- Secure remote management using **SSH** (Secure Shell) and **VPN** (Virtual Private Network) for safe access.
- Centralized automation with **Ansible**, a tool for automating IT processes.
- Version-controlled configurations with **Git**, a version control system for tracking changes in configuration files.

---


## Step 1: Install the Operating System on Fleet Nodes

### 1.1 Install Raspberry Pi OS

1. Download the latest **Raspberry Pi OS Lite** from the official [Raspberry Pi website](https://www.raspberrypi.com/software/operating-systems/). This is a lightweight operating system suitable for headless operation (without a monitor).
2. Use [Raspberry Pi Imager](https://www.raspberrypi.com/software/) to write the OS image to a microSD card. The imager provides an easy way to install the OS.
3. Before flashing, configure the **Advanced Settings** (gear icon):
   - **Enable SSH** (Secure Shell) to allow remote login.
   - **Set Username and Password** to create secure login credentials.
   - **Configure Wi-Fi (optional)** for network connectivity if not using Ethernet.
4. Insert the microSD card into the Raspberry Pi and power it on.

### 1.2 Set Up SSH Access

1. Find the Raspberry Pi’s IP address on the network:
   ```bash
   arp -a | grep -i raspberry  # (On Linux/macOS)
   ```
   This command lists all devices on the local network and filters for "raspberry".
2. Connect via SSH using the credentials set up in the Raspberry Pi Imager:
   ```bash
   ssh <USERNAME>@<RASPBERRY_PI_IP>
   ```
   This command establishes a remote session with the Raspberry Pi.
3. Change the default password (if necessary) to enhance security:
   ```bash
   passwd
   ```
4. Update the system to ensure it has the latest security patches:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

---

## Step 2: Configure Secure Remote Management

### 2.1 Install & Configure Tailscale (VPN for Secure Access)

Tailscale is a simple and secure VPN that allows remote access to devices over the internet.

1. Install Tailscale on **Home-Server1 (Fleet Controller)**:
   ```bash
   curl -fsSL https://tailscale.com/install.sh | sh
   sudo tailscale up --ssh
   ```
2. Install Tailscale on **Raspberry Pi**:
   ```bash
   curl -fsSL https://tailscale.com/install.sh | sh
   sudo tailscale up --ssh
   ```
3. Verify that both devices are visible in your Tailscale network:
   ```bash
   tailscale status
   ```

### 2.2 Set Up SSH Key-Based Authentication (Recommended for Automation)

SSH keys enable secure and password-less login between devices.


1. Copy the public key to the Raspberry Pi:
   ```bash
   ssh-copy-id <USERNAME>@<RASPBERRY_PI_IP>
   ```
2. Test SSH login without requiring a password:
   ```bash
   ssh <USERNAME>@<RASPBERRY_PI_IP>
   ```

---

## Step 3: Install & Configure Ansible for Fleet Management

Ansible is an automation tool that allows you to configure multiple machines remotely.

### 3.1 Install Ansible on Home-Server1 (Fleet Controller)

```bash
sudo apt update
sudo apt install -y ansible
```

### 3.2 Configure Ansible Inventory

1. Create an Ansible inventory file:
   ```bash
   sudo mkdir -p /etc/ansible
   sudo touch /etc/ansible/hosts
   sudo vim /etc/ansible/hosts
   ```
   This file defines which devices Ansible manages.
2. Add the Raspberry Pi’s details:
   ```ini
   [fleet_nodes]
   raspberrypi ansible_host=<RASPBERRY_PI_IP> ansible_user=<USERNAME>
   ```
3. Test Ansible connectivity to ensure communication with the Raspberry Pi:
   ```bash
   ansible -m ping all
   ```
   Expected output:
   ```json
   raspberrypi | SUCCESS => {
       "changed": false,
       "ping": "pong"
   }
   ```


---

## Step 4: Set Up Git for Configuration Management

Git allows version control of system configurations, making it easy to track changes and revert if necessary.

### 4.1 Install Git

```bash
sudo apt install -y git
```

### 4.2 Configure Git and Set Up a Repository on GitHub

Git is a version control system that allows you to track changes in files and collaborate with others efficiently. Below are the steps to set up Git and create a new repository on GitHub.

#### Step 1: Set Your Git Username and Email

Before using Git, you need to configure your identity so that your commits are properly attributed.
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your-email@example.com"
   ```
Copy the public key to GitHub:
   ```bash
   cat ~/.ssh/id_rsa.pub
   ```
   - Add this key to **GitHub** under **Settings > SSH and GPG keys**.

#### Step 2: Create a New Git Repository on GitHub

1. Log in to [GitHub](https://github.com/).
2. Click on the **+** icon in the top-right corner and select **New repository**.
3. Enter a repository name, e.g., `fleet-configs`.
4. Choose **Public** or **Private** visibility based on your preference.
5. Check **Add a README file** (optional but recommended for documentation).
6. Click **Create repository**.

#### Step 3: Clone a Git Repository for Fleet Configurations

Now that the repository is created, clone it onto your Home-Server1:

1. Create a repository on GitHub (e.g., `fleet-configs`).
2. Clone it to **Home-Server1**:
   ```bash
   git clone git@github.com:your-username/fleet-configs.git ~/fleet-configs
   ```

---

###  Key Takeaways 

- Set up **Home-Server1 as a Fleet Controller** and **Raspberry Pi as a Fleet Node**.
- Enabled **secure remote access** via **SSH & Tailscale VPN**.
- Installed and configured **Ansible** for automation.
- Set up **Git** for centralized configuration management.


