# Fleet Rollback & Disaster Recovery

## Overview

Implementing rollback and disaster recovery mechanisms ensures the fleet remains operational and resilient in the event of deployment failures or unexpected system issues. This section provides structured methods to:

- **Rollback failed deployments** using Git versioning and Ansible.
- **Create automated snapshots** for system recovery.
- **Backup fleet configurations** securely.
- **Implement disaster recovery plans** to minimize downtime.
- **Maintain multiple deployment versions** to facilitate rollback and stability.

---

## Step 1: Implementing Rollback Strategies

### 1.1 Creating Multiple Versions Before Rollback

To ensure smooth rollbacks, maintain multiple versions of your fleet configurations.

1. **Tagging releases in Git:**
   ```bash
   git tag -a v1.0 -m "Stable version 1.0"
   git push origin v1.0
   ```
   Before deploying changes, always create a new tag to preserve previous versions.

2. **Maintaining multiple branches:**
   ```bash
   git checkout -b stable-release
   git push origin stable-release
   ```
   The `stable-release` branch serves as a rollback point if `main` encounters issues.

3. **Archiving previous configurations:**
   ```bash
   cp -r ~/fleet-configs ~/fleet-configs-backup-$(date +%F)
   ```
   This ensures fleet configurations can be restored outside of Git.

### 1.2 Using Git for Rollback

Git provides a straightforward way to revert fleet automation changes if a deployment introduces issues.

1. **Check the commit history:**
   ```bash
   git log --oneline
   ```
   Identify the commit hash of the last known working state.

2. **Revert to a previous version:**
   ```bash
   git revert <commit-hash>
   ```
   Alternatively, hard reset if necessary:
   ```bash
   git reset --hard <commit-hash>
   git push --force origin main
   ```

3. **Re-run the Ansible playbook** to apply the rollback:
   ```bash
   ansible-playbook ~/ansible-playbooks/update_fleet.yml
   ```

### 1.3 Automating Rollbacks in CI/CD

#### **Implementing Rollback in GitHub Actions**

To automate rollbacks using **GitHub Actions**, follow these steps:

1. **Create a workflow file for rollback automation**
   Navigate to your repository and create a new file under `.github/workflows/rollback.yml`:
   ```bash
   mkdir -p .github/workflows
   nano .github/workflows/rollback.yml
   ```

2. **Define the rollback workflow**
   Add the following YAML code to `rollback.yml`:
   ```yaml
   name: Fleet Rollback on Failure

   on:
     workflow_run:
       workflows: [Fleet Deployment]
       types:
         - completed

   jobs:
     rollback:
       if: ${{ github.event.workflow_run.conclusion == 'failure' }}
       runs-on: self-hosted

       steps:
         - name: Checkout previous stable commit
           run: |
             git checkout HEAD~1
             git push --force origin main
         
         - name: Re-run Ansible playbook
           run: |
             ansible-playbook ~/ansible-playbooks/update_fleet.yml
   ```

3. **Commit and push the rollback workflow**
   ```bash
   git add .github/workflows/rollback.yml
   git commit -m "Add automated rollback workflow"
   git push origin main
   ```

4. **Ensure self-hosted runner is configured**
   Since the rollback job runs on `self-hosted`, ensure your server has a GitHub Actions runner installed and configured:
   ```bash
   cd ~/actions-runner
   ./svc.sh install
   ./svc.sh start
   ```

#### **Implementing Rollback in GitLab CI/CD**

To enable automated rollbacks in **GitLab CI/CD**, follow these steps:

1. **Create the GitLab CI/CD configuration file**
   The `.gitlab-ci.yml` file is placed at the root of your **fleet-configs** GitLab repository. Navigate to your repository and create the file:
   ```bash
   cd ~/fleet-configs
   nano .gitlab-ci.yml
   ```

2. **Define the rollback stage in `.gitlab-ci.yml`**
   Add the following content to implement automatic rollback:
   ```yaml
   stages:
     - deploy
     - rollback

   deploy:
     stage: deploy
     script:
       - ansible-playbook ~/ansible-playbooks/update_fleet.yml
     only:
       - main

   rollback:
     stage: rollback
     only:
       - failure
     script:
       - echo "Deployment failed, rolling back..."
       - git checkout HEAD~1
       - git push --force origin main
       - ansible-playbook ~/ansible-playbooks/update_fleet.yml
   ```

3. **Commit and push the GitLab CI/CD configuration**
   ```bash
   git add .gitlab-ci.yml
   git commit -m "Add GitLab rollback automation"
   git push origin main
   ```

4. **Enable GitLab CI/CD for the repository**
   - Navigate to your GitLab project.
   - Go to **Settings** > **CI/CD**.
   - Expand **Runners** and ensure a runner is available for executing the jobs.

5. **Verify rollback execution**
   - Push a failing deployment to trigger the rollback.
   - Check the **CI/CD Pipelines** section in GitLab to confirm rollback execution.

This setup ensures that if a deployment fails, GitLab CI/CD will automatically revert to the last successful state and re-run the Ansible playbook to restore stability.

---

## Key Takeaways

- **Rollback strategies** ensure fleet automation can recover from faulty deployments.
- **System snapshots and backups** allow quick restoration of fleet nodes.
- **Maintaining multiple deployment versions** prevents unintended loss of stable configurations.
- **Automating rollbacks in CI/CD** ensures fleet stability without manual intervention.
- **Disaster recovery planning and drills** prepare for real-world failures.

By integrating these practices, fleet automation remains **resilient and recoverable**, reducing downtime and ensuring stability.

