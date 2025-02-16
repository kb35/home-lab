# Fleet CI/CS Pipeline Troubleshooting

## Overview
This document details the troubleshooting steps taken to resolve issues encountered during the Fleet CI/CD pipeline setup and deployment process.

---

## Issue 1: SSH Connection Failure in GitHub Actions

### **Symptoms:**
- GitHub Actions workflow failed at the **Set up SSH key** step.
- Error message: `Permission denied (publickey).`

### **Resolution Steps:**
1. **Checked if the correct SSH key was stored in GitHub Secrets:**
   - Verified the private key on Home-Server1:
     ```bash
     cat ~/.ssh/id_rsa
     ```
   - Compared with the key stored in GitHub Secrets (`SSH_PRIVATE_KEY`).
   
2. **Updated SSH key permissions:**
   - Ensured the key had the correct permissions:
     ```bash
     chmod 600 ~/.ssh/id_rsa
     ```
   - Restarted the SSH agent:
     ```bash
     eval $(ssh-agent -s)
     ssh-add ~/.ssh/id_rsa
     ```

3. **Tested SSH authentication from a local machine:**
   ```bash
   ssh -i ~/.ssh/id_rsa user@home-server1
   ```
   - Verified that login was successful.
   - If unsuccessful, re-added the public key to `~/.ssh/authorized_keys`:
     ```bash
     cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
     chmod 600 ~/.ssh/authorized_keys
     ```

4. **Updated the GitHub Actions workflow file:**
   - Replaced incorrect key handling with:
     ```yaml
     - name: Set up SSH key
       run: |
         echo "${{ secrets.SSH_PRIVATE_KEY }}" > private_key
         chmod 600 private_key
         ssh -o StrictHostKeyChecking=no -i private_key user@home-server1 "echo 'SSH connection successful'"
     ```

5. **Re-ran the GitHub Actions workflow** and confirmed the issue was resolved.

---

## Issue 2: Ansible Playbook Not Executing Properly

### **Symptoms:**
- The deployment process triggered successfully, but **no updates were applied**.
- Logs showed: `ansible-playbook command not found`.

### **Resolution Steps:**
1. **Checked Ansible installation on Home-Server1:**
   ```bash
   ansible --version
   ```
   - If Ansible was missing, installed it:
     ```bash
     sudo apt update && sudo apt install ansible -y
     ```

2. **Verified playbook path and execution permissions:**
   - Checked the directory structure:
     ```bash
     ls -l ~/ansible-playbooks/
     ```
   - Ensured the playbook was executable:
     ```bash
     chmod +x ~/ansible-playbooks/update_fleet.yml
     ```

3. **Updated GitHub Actions to use absolute paths for execution:**
   - Modified the workflow file:
     ```yaml
     - name: Run Ansible Playbook
       run: |
         ssh -i private_key user@home-server1 "cd ~/ansible-playbooks && ansible-playbook update_fleet.yml"
     ```

4. **Re-ran the deployment and verified updates were applied.**

---

## Issue 3: GitHub Actions Fails Due to Permissions on Fleet Configuration Files

### **Symptoms:**
- Deployment failed with `Permission denied` when GitHub Actions tried to update fleet configuration files.

### **Resolution Steps:**
1. **Checked file ownership and permissions:**
   ```bash
   ls -l ~/fleet-configs/
   ```
   - Identified that files were **owned by root** but GitHub Actions deployed as a non-root user.

2. **Updated file permissions:**
   ```bash
   sudo chown -R user:user ~/fleet-configs/
   sudo chmod -R 755 ~/fleet-configs/
   ```

3. **Modified the GitHub Actions workflow to use `sudo` where necessary:**
   ```yaml
   - name: Apply Fleet Configuration Updates
     run: |
       ssh -i private_key user@home-server1 "sudo ansible-playbook ~/ansible-playbooks/update_fleet.yml"
   ```

4. **Confirmed deployment was now able to modify configuration files.**

---

## Lessons Learned 

### **Key Takeaways:**
- **SSH authentication** issues often stem from incorrect key permissions or missing public keys in `authorized_keys`.
- **Ansible must be correctly installed and paths configured** to ensure successful execution.
- **Permissions need to be explicitly managed** to allow GitHub Actions to modify fleet configuration files.
