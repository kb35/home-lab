# Fleet Monitoring & Alerts

## Implementing Fleet Monitoring & Alerts

This section provides detailed step-by-step instructions to set up a fleet monitoring system. The goal of this section is to:

- **Monitor system health** of fleet devices using Prometheus and Node Exporter as an alternative to Telegraf.
- **Automate alerts** for system failures and resource spikes.
- **Visualize fleet performance metrics** using Grafana.

---

## Step 1: Install Monitoring Tools on Home-Server1

### 1.1 Install InfluxDB (Time-Series Database)
If you still prefer to use InfluxDB for storing metrics:

1. Install InfluxDB:
   ```bash
   sudo apt update
   sudo apt install -y influxdb
   ```
2. Enable and start the InfluxDB service:
   ```bash
   sudo systemctl enable influxdb
   sudo systemctl start influxdb
   ```
3. Verify that InfluxDB is running:
   ```bash
   systemctl status influxdb
   ```

### 1.2 Install Prometheus (Alternative to Telegraf)
Prometheus is a powerful monitoring and alerting system that can be used instead of Telegraf.

1. Download and install Prometheus:
   ```bash
   sudo apt install -y prometheus
   ```
2. Enable and start Prometheus:
   ```bash
   sudo systemctl enable prometheus
   sudo systemctl start prometheus
   ```
3. Verify that Prometheus is running:
   ```bash
   systemctl status prometheus
   ```

### 1.3 Install Grafana
Grafana provides visual dashboards for monitoring fleet performance.

1. Remove any previous Grafana installation (if applicable):
   ```bash
   sudo apt remove --purge grafana
   sudo apt autoremove
   ```

2. Download and install Grafana manually using the `.deb` package:
   ```bash
   wget https://dl.grafana.com/oss/release/grafana_10.0.0_amd64.deb
   sudo dpkg -i grafana_10.0.0_amd64.deb
   ```

3. Enable and start Grafana:
   ```bash
   sudo systemctl enable grafana-server
   sudo systemctl start grafana-server
   ```

4. Verify the installation:
   ```bash
   /usr/sbin/grafana-server --version
   ```

5. Access Grafana via a web browser at `http://<HOME-SERVER1_IP>:3000`
   - Default username: `admin`
   - Default password: `admin` (Change this immediately)

---

## Step 2: Set Up Fleet Node Monitoring

### 2.1 Install Node Exporter on Raspberry Pi (Fleet Nodes)
Instead of Telegraf, we use Node Exporter, which is optimized for Prometheus.

1. SSH into the Raspberry Pi fleet node:
   ```bash
   ssh <USERNAME>@<RASPBERRY_PI_IP>
   ```
2. Install Node Exporter:
   ```bash
   sudo apt install -y prometheus-node-exporter
   ```
3. Enable and start Node Exporter:
   ```bash
   sudo systemctl enable prometheus-node-exporter
   sudo systemctl start prometheus-node-exporter
   ```

---

## Step 3: Configure Alerting System

### 3.1 Set Up Grafana Alerts

#### Configure SMTP for Email Alerts
To send email alerts, configure SMTP in Grafana and test its functionality. In this case we will use iCloud. 

### **Step 1: Generate an App Password for iCloud Mail**
Since iCloud requires an **App-Specific Password** for third-party applications, follow these steps to generate one:

1. Go to **Apple ID Security Settings**:  
   👉 [https://appleid.apple.com/](https://appleid.apple.com/)
2. Sign in with your **iCloud email and password**.
3. Scroll down to the **Security** section.
4. Click **Generate Password** under **App-Specific Passwords**.
5. Enter a name like `"Grafana SMTP"` and click **Create**.
6. Apple will generate a **16-character password** (e.g., `abcd-efgh-ijkl-mnop`).
   - **Copy and save this password**—you won’t be able to see it again!

### **Step 2: Configure Grafana SMTP for iCloud**
1. Open the Grafana configuration file:
   ```bash
   sudo nano /etc/grafana/grafana.ini
   ```
2. Find the `[smtp]` section and modify it as follows:
   ```ini
   [smtp]
   enabled = true
   host = smtp.mail.me.com:587
   user = your-icloud-email@icloud.com
   password = abcd-efgh-ijkl-mnop  # Use the App Password generated from iCloud
   from_address = your-icloud-email@icloud.com  # Must match your iCloud email
   from_name = Grafana Alerts
   skip_verify = true
   startTLS_policy = "MandatoryStartTLS"
   ```
   **Important Notes:**
   - `user = your-icloud-email@icloud.com` must match `from_address = your-icloud-email@icloud.com`.
   - **You cannot use a custom domain (e.g., `@kthbrdy.com`) for the "From" address with iCloud SMTP.**
   - Use the **App-Specific Password** you generated from iCloud.

3. Save and exit (`CTRL + X`, then `Y`, and `Enter`).

### **Step 3: Restart Grafana**
```bash
sudo systemctl restart grafana-server
```

### **Step 4: Test SMTP in Grafana**
1. Open **Grafana Web UI** (`http://<HOME-SERVER1_IP>:3000`).
2. Go to **Alerting > Notification Channels**.
3. Click **New Channel**.
4. Select **Email** as the notification type.
5. Set the "From Address" to **your iCloud email** (`your-icloud-email@icloud.com`).
6. Enter the recipient email (`your-email@example.com`).
7. Click **Test Notification**.
8. If successful, you will receive a test email from **Grafana Alerts**.




### 3.2 Create a Python Script for Custom Alerts
For advanced alerting, use a Python script to send alerts when a fleet node goes offline.

1. Create a script to check system availability:
   ```bash
   sudo vim /opt/fleet_monitor/alert.py
   ```
2. Add the following Python code:
   ```python
   import os
   import smtplib

   FLEET_NODES = ["<RASPBERRY_PI_IP>"]
   ALERT_EMAIL = "admin@example.com"

   def check_node(ip):
       response = os.system(f"ping -c 1 {ip} > /dev/null 2>&1")
       return response == 0

   for node in FLEET_NODES:
       if not check_node(node):
           server = smtplib.SMTP("smtp.example.com", 587)
           server.starttls()
           server.login("your-email@example.com", "password")
           message = f"Subject: Fleet Alert\n\nFleet node {node} is offline."
           server.sendmail("your-email@example.com", ALERT_EMAIL, message)
           server.quit()
   ```
3. Make the script executable:
   ```bash
   sudo chmod +x /opt/fleet_monitor/alert.py
   ```
4. Add a cron job to run the script every 5 minutes:
   ```bash
   crontab -e
   ```
   Add the following line:
   ```cron
   */5 * * * * python3 /opt/fleet_monitor/alert.py
   ```
---

###  Key Takeaways 

- **Real-time monitoring** with Prometheus and Node Exporter instead of Telegraf.
- **Fleet-wide alerting** using Grafana, Prometheus Alertmanager, or Python scripts.
- **Alternative alerting options** via Slack, Microsoft Teams, or Email instead of Telegram.
- **Secure and centralized logging** to track system performance.


