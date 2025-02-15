# Fleet Automation

This section provides instructions to set up automated deployments for the fleet. The goal is to:

- **Automate software updates** on all fleet nodes to ensure they are always running the latest security patches and software versions.
- **Deploy configuration changes remotely** using Ansible to manage system settings and application configurations across all devices from a central server.
- **Ensure controlled rollouts** with validation testing and rollback mechanisms to prevent faulty updates from disrupting operations.

By automating these processes, manual intervention in minimised, improve system security, and ensure all devices in your fleet remain consistently configured and up to date.

---

## Step 1: Configure Ansible Inventory

**Home-Server1** is the Ansible controller, and the **fleet nodes** (just Raspberry Pi in this case) is managed by it.

Since Ansible has already been installed and the fleet nodes have been defined in the inventory file (`/etc/ansible/hosts`), we can skip the setup process. However, we need to verify that the fleet nodes are accessible by running the following command:

   ```bash
   ansible -m ping all
   ```
   
This command checks connectivity between the **Ansible controller** and all **fleet nodes**.

Expected output:
   ```json
   raspberrypi | SUCCESS => {
       "changed": false,
       "ping": "pong"
   }
   ```
If you see this output, it means Ansible can successfully communicate with the fleet nodes.

---

## Step 2: Automate System Updates

Automating software updates ensures that all fleet nodes remain secure, stable, and up to date without requiring manual intervention.

### 2.1 Create an Ansible Playbook for Updates

Ansible playbooks define a set of tasks that should be executed on remote nodes. To automate system updates:

1. **Ensure you are in the Ansible playbooks directory** (or create one if necessary):
   ```bash
   mkdir -p ~/ansible-playbooks
   cd ~/ansible-playbooks
   ```
2. **Create a new playbook file**:
   ```bash
   nano update_fleet.yml
   ```
3. **Add the following content** to define an automated update process:
   ```yaml
   - name: Update Fleet Nodes
     hosts: fleet_nodes
     become: yes
     tasks:
       - name: Update package lists
         apt:
           update_cache: yes

       - name: Upgrade all packages
         apt:
           upgrade: dist
   ```
   - `hosts: fleet_nodes`: Tells Ansible to run this playbook on all fleet nodes.
   - `become: yes`: Grants administrator privileges to execute system updates.
   - `update_cache: yes`: Ensures the package list is updated before upgrading.
   - `upgrade: dist`: Upgrades all installed packages to their latest versions.

4. **Save the file and exit** (`CTRL + X`, then `Y`, and `Enter`).

5. **Run the playbook manually to apply updates**:
   ```bash
   ansible-playbook update_fleet.yml
   ```
   This command will execute the update tasks on all fleet nodes.

### 2.2 Schedule Automatic Updates Using Cron

To keep all fleet nodes updated automatically, schedule the update playbook to run at regular intervals using **cron**, a built-in task scheduler in Linux.

1. **Open the crontab editor**:
   ```bash
   crontab -e
   ```
2. **Add the following line** to run the update playbook every Sunday at midnight:
   ```cron
   0 0 * * 0 ansible-playbook ~/ansible-playbooks/update_fleet.yml
   ```
3. **Save and exit** (`CTRL + X`, then `Y`, and `Enter`).

### 2.3 Verify Scheduled Updates

To confirm that the cron job is scheduled correctly:
```bash
crontab -l
```

To manually test if cron jobs are executing correctly, run:
```bash
run-parts --test /etc/cron.weekly
```

### 2.4 Logging Update Actions

To log all update actions, modify the cron job to capture its output in a log file:
```cron
0 0 * * 0 ansible-playbook ~/ansible-playbooks/update_fleet.yml >> ~/ansible-updates.log 2>&1
```
This ensures that every time updates run, the results are stored in `~/ansible-updates.log`, which you can inspect with:
```bash
tail -f ~/ansible-updates.log
```

Logging helps you monitor whether updates are applied successfully or if any errors occur during the process.

---

### Key Takeaways

- **Automated system updates** ensure all fleet nodes remain secure and current.
- **Cron jobs allow updates to run on a fixed schedule** without manual intervention.
- **Logging mechanisms help track update success and troubleshoot failures.**

This ensures a stable and up-to-date fleet environment while reducing manual maintenance efforts.
