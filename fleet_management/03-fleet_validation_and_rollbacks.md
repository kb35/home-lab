# Fleet Validation & Rollbacks

## Implementing Validation & Rollback Mechanisms

This section provides step-by-step instructions to implement **validation checks** and **rollback strategies** in fleet deployments. The goal is to:

- **Verify system health before deploying updates** to avoid introducing failures.
- **Deploy updates to a test environment first** before rolling out fleet-wide.
- **Automatically detect failed updates** and revert to the last stable version.
- **Log deployment and rollback events** for auditing and troubleshooting.

By integrating these mechanisms, we ensure fleet updates are **safe, reliable, and recoverable in case of issues**.

---

## Step 1: Implement Validation Testing

Before rolling out updates, we need to **validate that fleet nodes are in a healthy state**. This ensures that updates don't break critical system functions.

### 1.1 Create a Validation Playbook

1. **Navigate to the Ansible playbooks directory**:
   ```bash
   cd ~/ansible-playbooks
   ```
2. **Create a validation playbook**:
   ```bash
   nano validate_fleet.yml
   ```
3. **Add the following validation checks**:
   ```yaml
   - name: Validate Fleet Node Health
     hosts: fleet_nodes
     become: yes
     tasks:
       - name: Check disk space
         command: df -h /
         register: disk_space

       - name: Check available memory
         command: free -m
         register: memory_status

       - name: Fail if disk space is below threshold
         fail:
           msg: "Not enough disk space for update."
         when: "'G' in disk_space.stdout and (disk_space.stdout_lines[1].split()[3] | int) < 2"

       - name: Fail if available memory is too low
         fail:
           msg: "Not enough memory for update."
         when: "memory_status.stdout_lines[1].split()[6] | int < 200"
   ```
4. **Save and exit** (`CTRL + X`, then `Y`, and `Enter`).

5. **Run the validation playbook** before deploying updates:
   ```bash
   ansible-playbook validate_fleet.yml
   ```

This will verify disk space and memory availability before proceeding with any updates.

---

## Step 2: Deploy Updates to a Test Node First

Instead of applying updates directly to all fleet nodes, we first **deploy updates to a test node**. If successful, we roll out to the entire fleet.

### 2.1 Modify the Update Playbook to Include Staging

1. **Open the update playbook**:
   ```bash
   nano update_fleet.yml
   ```
2. **Modify the playbook to first apply updates to a test node**:
   ```yaml
   - name: Update Fleet Test Node
     hosts: test_node  # Only applies updates to the test environment first
     become: yes
     tasks:
       - name: Run validation checks
         import_playbook: validate_fleet.yml

       - name: Update package lists
         apt:
           update_cache: yes

       - name: Upgrade all packages
         apt:
           upgrade: dist
   
   - name: Deploy to Full Fleet if Test Node Succeeds
     hosts: fleet_nodes
     become: yes
     tasks:
       - name: Run validation checks again before full deployment
         import_playbook: validate_fleet.yml

       - name: Update package lists
         apt:
           update_cache: yes

       - name: Upgrade all packages
         apt:
           upgrade: dist
   ```
3. **Save and exit** (`CTRL + X`, then `Y`, and `Enter`).

Now, updates are first applied to a **test node**. If no errors occur, they proceed to the rest of the fleet.

---

## Step 3: Implement Automatic Rollbacks

If an update introduces critical failures, we need an **automatic rollback mechanism** to restore the last stable configuration.

### 3.1 Create a Rollback Playbook

1. **Create a rollback playbook**:
   ```bash
   nano rollback.yml
   ```
2. **Add the following rollback tasks**:
   ```yaml
   - name: Rollback Last Deployment
     hosts: fleet_nodes
     become: yes
     tasks:
       - name: Restore backup configuration
         copy:
           src: /etc/system.conf.backup
           dest: /etc/system.conf
           owner: root
           group: root
           mode: 0644
   ```
3. **Save and exit** (`CTRL + X`, then `Y`, and `Enter`).

### 3.2 Modify Update Playbook to Trigger Rollbacks

1. **Open the update playbook**:
   ```bash
   nano update_fleet.yml
   ```
2. **Modify it to include rollback triggers**:
   ```yaml
   - name: Deploy to Full Fleet if Test Node Succeeds
     hosts: fleet_nodes
     become: yes
     tasks:
       - name: Run validation checks
         import_playbook: validate_fleet.yml

       - name: Update package lists
         apt:
           update_cache: yes

       - name: Upgrade all packages
         apt:
           upgrade: dist
         register: update_status
         ignore_errors: yes

       - name: Rollback if update fails
         import_playbook: rollback.yml
         when: update_status.failed > 0
   ```
3. **Save and exit** (`CTRL + X`, then `Y`, and `Enter`).

Now, if any fleet node fails during an update, the system will **automatically trigger a rollback**.

---

## Key Takeaways 

- **Validation testing** prevents updates from being applied to unhealthy systems.
- **Test nodes** allow controlled rollouts before full deployment.
- **Automatic rollbacks** restore previous configurations in case of failures.
- **Logging rollbacks** provides an audit trail for tracking failures and fixes.

This ensures the fleet remains stable and recoverable in case of errors.

