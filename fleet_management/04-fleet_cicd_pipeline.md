# Fleet CI/CD Pipeline

## Implementing Continuous Integration & Deployment 

This section provides step-by-step instructions to set up a **CI/CD pipeline** for fleet automation. The goal is to:

- **Automate software deployments** with GitHub Actions or GitLab CI/CD.
- **Ensure updates are tested and validated** before applying them to the fleet.
- **Trigger deployments automatically** when changes are pushed to a Git repository.
- **Enable rollback mechanisms** in case of deployment failures.

By integrating a CI/CD pipeline, updates are streamlined, reducing the need for manual intervention while ensuring reliability.

---

## Step 1: Set Up Git Repository for CI/CD

The CI/CD pipeline requires a **Git repository** to track configuration changes.

1. **Navigate to the fleet configuration directory**:
   ```bash
   cd ~/fleet-configs
   ```
2. **Initialize a Git repository (if not already initialized)**:
   ```bash
   git init
   ```
3. **Add remote origin (GitHub/GitLab)**:
   ```bash
   git remote add origin git@github.com:your-username/fleet-configs.git
   ```
4. **Commit and push existing Ansible playbooks**:
   ```bash
   git add .
   git commit -m "Initial fleet automation setup"
   git push origin main
   ```

---

## Step 2: Configure GitHub Actions for Automated Deployments

GitHub Actions can automate fleet deployments whenever a change is pushed to the repository.

### 2.1 Create a GitHub Actions Workflow
1. **Navigate to your GitHub repository** (`fleet-configs`).
2. **Create a `.github/workflows` directory**:
   ```bash
   mkdir -p .github/workflows
   ```
3. **Create a new deployment workflow file**:
   ```bash
   nano .github/workflows/deploy.yml
   ```
4. **Add the following GitHub Actions workflow**:
   ```yaml
   name: Fleet Deployment

   on:
     push:
       branches:
         - main

   jobs:
     deploy:
       runs-on: ubuntu-latest

       steps:
         - name: Checkout repository
           uses: actions/checkout@v3

         - name: Set up SSH key
           run: |
             echo "${{ secrets.SSH_PRIVATE_KEY }}" > private_key
             chmod 600 private_key
             ssh -i private_key -o StrictHostKeyChecking=no user@home-server1 "echo 'SSH connection successful'"

         - name: Run Ansible Playbook
           run: |
             ssh -i private_key user@home-server1 "ansible-playbook ~/ansible-playbooks/update_fleet.yml"
   ```
5. **Save and exit** (`CTRL + X`, then `Y`, and `Enter`).
6. **Commit and push the workflow file**:
   ```bash
   git add .github/workflows/deploy.yml
   git commit -m "Add CI/CD deployment workflow"
   git push origin main
   ```

This workflow will automatically trigger **fleet updates** whenever changes are pushed to the repository.

---

## Step 3: Configure Secrets for Secure Deployment

To securely authenticate with **Home-Server1**, store the SSH private key in GitHub Actions secrets. This allows the workflow to establish a connection to Home-Server1 without exposing credentials in the repository.

### 3.1 Generate an SSH Key (If Not Already Created)

1. **On Home-Server1, check if an SSH key exists**:
   ```bash
   ls ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
   ```
   If no key exists, generate one:
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
   ```

2. **Copy the private key**:
   ```bash
   cat ~/.ssh/id_rsa
   ```
   Keep this private key **secure**—do not share it.

3. **Copy the public key to authorized hosts**:
   ```bash
   cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```

### 3.2 Add SSH Key to GitHub Actions Secrets

1. **Go to your GitHub repository.**
2. **Click on** `Settings` (⚙️ icon in the top right of the repository page).
3. **Select** `Secrets and variables` → `Actions` (formerly **Secrets** in older GitHub versions).
4. **Click `New repository secret`**.
5. **Enter the name** as `SSH_PRIVATE_KEY`.
6. **Paste the private key** (from `~/.ssh/id_rsa` on Home-Server1).
7. **Click `Add secret`**.

Now, the GitHub Actions workflow can securely authenticate with Home-Server1 for deployments.

---

## Step 4: Test CI/CD Deployment

1. **Make a change in your repository**:
   ```bash
   nano ~/fleet-configs/update_fleet.yml
   ```
   Modify the playbook (e.g., add an echo statement for testing).
2. **Commit and push changes**:
   ```bash
   git add update_fleet.yml
   git commit -m "Test CI/CD deployment"
   git push origin main
   ```
3. **Check the GitHub Actions tab** in your repository to view the deployment status.
4. **Verify deployment logs** on Home-Server1:
   ```bash
   tail -f ~/ansible-updates.log
   ```

---

## Key Takeaways

- **Automated deployments** ensure fleet nodes receive updates immediately after code changes.
- **GitHub Actions triggers updates** securely using SSH authentication.
- **CI/CD pipelines improve fleet reliability** by reducing manual errors and downtime.
- **Secrets management** keeps credentials secure in deployment workflows.

With a working CI/CD pipeline, fleet automation becomes seamless and reliable.

