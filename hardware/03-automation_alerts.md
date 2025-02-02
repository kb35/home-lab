
# Automation & Alerts - home-server1

## Overview

The next step is to implement **basic automation and alerting** to enhance system monitoring. This ensures that Home-Server1 can automatically detect issues, notify the administrator, and provide actionable insights for resolution.

This document covers automated health checks, resource monitoring, alerting for critical issues, and automated log management.

---

## 1. Understanding System Automation & Alerts

Automation improves system reliability by:

- Running periodic **health checks** to identify resource issues early.
- Sending **email alerts** when CPU, memory, or disk usage crosses a threshold.
- Automatically **rotating logs** to prevent disk space exhaustion.

By implementing automation, we reduce manual monitoring time and proactively address potential failures.

---

## 2. Setting Up Automated System Health Checks

### **Creating a Health Check Script**

We will create a script that checks **CPU usage, memory consumption, disk space, and system temperature**, then logs findings for analysis.

1. Create a new script file:

```bash
sudo nano /opt/system_health_check.sh
```

2. Add the following script:

```bash
#!/bin/bash

# System Health Check Script
# Logs CPU, memory, disk, and temperature status

LOGFILE="/var/log/system_health.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# CPU Load
CPU_LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs)

# Memory Usage
MEMORY_USAGE=$(free -m | awk 'NR==2{printf "%sMB / %sMB (%.2f%%)\n", $3, $2, $3*100/$2 }')

# Disk Usage
DISK_USAGE=$(df -h | awk '$NF=="/"{printf "%d%%\n", $5}')

# Temperature
TEMP=$(sensors | grep 'Core 0' | awk '{print $3}')

# Log System Health
echo "$DATE - CPU: $CPU_LOAD | Memory: $MEMORY_USAGE | Disk: $DISK_USAGE | Temp: $TEMP" >> $LOGFILE

# Print output for immediate verification
echo "$DATE - CPU: $CPU_LOAD | Memory: $MEMORY_USAGE | Disk: $DISK_USAGE | Temp: $TEMP"
```

3. Save and exit (`CTRL+X`, `Y`, `Enter`).
4. Make the script executable:

```bash
sudo chmod +x /opt/system_health_check.sh
```

5. Run the script manually to verify:

```bash
sudo /opt/system_health_check.sh
```

6. If no output is seen, check the log file:

```bash
sudo cat /var/log/system_health.log
```

7. For debugging, run the script in verbose mode:

```bash
sudo bash -x /opt/system_health_check.sh
```

---

## 3. Scheduling Automated Health Checks

To ensure the health check script runs regularly, we schedule it with **cron**.

1. Open the crontab:

```bash
sudo crontab -e
```

- If this is the first time using `crontab`, you will see:
  ```
  no crontab for root - using an empty one
  Select an editor. To change later, run 'select-editor'.
  ```
- Choose **1 (nano)** by typing:
  ```
  1
  ```
  and pressing **Enter**.

2. Add the following lines at the bottom:

```bash
# Every 30 minutes, run a system health check
*/30 * * * * /opt/system_health_check.sh

# Every 10 minutes, check for system alerts and send notifications if needed
*/10 * * * * /opt/system_alert.sh
```

### **Explanation of Each Field:**
- `*/30` → Runs the script **every 30 minutes**.
- `*/10` → Runs the alert script **every 10 minutes**.
- `*` → Every hour.
- `*` → Every day.
- `*` → Every month.
- `*` → Every weekday.
- `/opt/system_health_check.sh` → Path to the system health check script.
- `/opt/system_alert.sh` → Path to the alert script.

- Adjust the interval as needed.

3. Save and exit (`CTRL+X`, `Y`, `Enter`).

### **Verifying That Crontab is Installed Correctly**

After adding the cron jobs, check if they are scheduled:

```bash
sudo crontab -l
```

This will list all active cron jobs. If the entries appear, the jobs are successfully configured.

To check if cron is running, use:

```bash
sudo systemctl status cron
```

If cron is inactive, start it with:

```bash
sudo systemctl enable --now cron
```

---

## 4. Setting Up Email Alerts for Critical Issues

### **Installing Email Utilities**

To send email alerts, we need to install the **mailutils** package and configure a **Postfix** mail server.

```bash
sudo apt install -y mailutils postfix
```

During installation, choose **“Internet Site”** when prompted and set the system mail name to your server’s hostname.

---

### **Configuring Postfix for Sending Emails**

Postfix is responsible for sending outgoing emails from the server. To configure it properly:

1. Edit the Postfix configuration file:
```bash
sudo nano /etc/postfix/main.cf
```
2. Locate and modify/add the following settings:
```
myhostname = home-server1
relayhost = [smtp.your-email-provider.com]:587
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_mechanism_filter = login
```
### **Understanding Each Line:**
- `myhostname = home-server1` → Defines the hostname of the server to be used in outgoing emails. This should match your system’s actual hostname.
- `relayhost = [smtp.your-email-provider.com]:587` → Specifies the SMTP relay (outgoing mail server). Replace with your email provider’s SMTP settings.
- `smtp_sasl_auth_enable = yes` → Enables authentication when sending emails to prevent unauthorized use of the mail server.
- `smtp_sasl_security_options = noanonymous` → Ensures that only authenticated users can send emails.
- `smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd` → Tells Postfix where to find the credentials for authentication.
- `smtp_sasl_mechanism_filter = login` → Specifies the authentication method to be used when logging into the SMTP server.

3. **Set Up SMTP Authentication**:
```bash
sudo nano /etc/postfix/sasl_passwd
```
Add the following line, replacing it with your email provider’s details:
```
[smtp.your-email-provider.com]:587 your-email@example.com:yourpassword
```

4. **Secure the password file and reload Postfix**:
```bash
sudo chmod 600 /etc/postfix/sasl_passwd
sudo postmap /etc/postfix/sasl_passwd
sudo systemctl restart postfix
```
See below if Postfix Not Logging Messages
1. Check if Postfix is running:
   ```bash
   sudo systemctl status postfix
   ```
   - If inactive, restart it:
     ```bash
     sudo systemctl restart postfix
     ```

2. Verify if logging is enabled in `rsyslog`:
   ```bash
   sudo nano /etc/rsyslog.conf
   ```
   Ensure the following lines are **not commented out**:
   ```
   mail.info  -/var/log/mail.log
   mail.warn  -/var/log/mail.warn
   mail.err   -/var/log/mail.err
   ```
   Restart rsyslog:
   ```bash
   sudo systemctl restart rsyslog
   ```

3. If `/var/log/mail.log` is missing, create it:
   ```bash
   sudo touch /var/log/mail.log
   sudo chmod 640 /var/log/mail.log
   sudo chown root:root /var/log/mail.log
   ```
   Then restart Postfix and rsyslog:
   ```bash
   sudo systemctl restart postfix
   sudo systemctl restart rsyslog
   ```

4. Check mail logs:
   ```bash
   sudo tail -f /var/log/mail.log
   ```


Postfix is now configured to send emails using your SMTP provider.

---

### **Creating the Alert Script**

This script will monitor system health and send an email if any critical thresholds are exceeded.

1. Create the script:
```bash
sudo nano /opt/system_alert.sh
```
2. Add the following script:
```bash
#!/bin/bash

# Define alert email recipient
ALERT_EMAIL="admin@example.com"

# Define thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=90
DISK_THRESHOLD=90

# Get system resource usage
CPU_LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs)
MEMORY_USAGE=$(free -m | awk 'NR==2{printf "%d", $3*100/$2 }')
DISK_USAGE=$(df -h | awk '$NF=="/"{print $5}' | tr -d '%')

# Initialize alert message
ALERT_MSG=""

# Check CPU Load
if [ "$CPU_LOAD" -ge "$CPU_THRESHOLD" ]; then 
    ALERT_MSG+="High CPU Load: $CPU_LOAD\n"
fi

# Check Memory Usage
if [ "$MEMORY_USAGE" -ge "$MEMORY_THRESHOLD" ]; then 
    ALERT_MSG+="High Memory Usage: $MEMORY_USAGE%\n"
fi

# Check Disk Usage
if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then 
    ALERT_MSG+="Low Disk Space: $DISK_USAGE% used\n"
fi

# If any condition is met, send an email alert
if [ "$ALERT_MSG" != "" ]; then
    echo -e "System Alert:\n$ALERT_MSG" | mail -s "System Alert - Home-Server1" $ALERT_EMAIL
fi
```

### **Explanation of the Script**:
- `ALERT_EMAIL="admin@example.com"` → Defines the recipient’s email address.
- `CPU_THRESHOLD=80`, `MEMORY_THRESHOLD=90`, `DISK_THRESHOLD=90` → Sets the resource usage limits that will trigger an alert.
- `CPU_LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs)` → Retrieves the 1-minute CPU load average.
- `MEMORY_USAGE=$(free -m | awk 'NR==2{printf "%d", $3*100/$2 }')` → Calculates memory usage as a percentage.
- `DISK_USAGE=$(df -h | awk '$NF=="/"{print $5}' | tr -d '%')` → Checks the disk usage of the root partition.
- `ALERT_MSG=""` → Initializes an empty message string.
- The script then checks whether CPU, memory, or disk usage exceeds thresholds. If so, it adds a message to `ALERT_MSG`.
- If an alert condition is met, an email is sent using the `mail` command.

3. **Save and exit (`CTRL+X`, `Y`, `Enter`)**.
4. **Make the script executable**:
```bash
sudo chmod +x /opt/system_alert.sh
```

5. **Schedule it in crontab**:
```bash
sudo crontab -e
```
Add:
```bash
# Every 10 minutes, run the alert script
*/10 * * * * /opt/system_alert.sh
```

---

### **Testing Email Alerts**

After setting up Postfix, test if email notifications are functioning correctly.

#### **Send a Test Email**
Run the following command to send a test email to your address:
```bash
echo "Test email from Home-Server1" | mail -s "Test Email" your-email@example.com
```
- Replace `your-email@example.com` with your actual email.
- Check your inbox (and spam folder) to confirm receipt.

#### **Check Email Logs**
If the email does not arrive, check the Postfix logs for errors:
```bash
sudo tail -f /var/log/mail.log
```

#### **Verify the Mail Queue**
If emails are stuck in the queue, run:
```bash
mailq
```
To manually send queued messages:
```bash
sudo postqueue -f
```
If emails fail, confirm SMTP credentials in `/etc/postfix/sasl_passwd`.

If mail is rejected by iCloud SMTP (550 5.7.0 From address not recognized)
If Postfix logs show:
   ```
   550 5.7.0 From address is not one of your addresses (in reply to MAIL FROM command)
   ```
   **Fix:** Ensure that the `From` address matches your iCloud email:

1. Open Postfix configuration:
   ```bash
   sudo nano /etc/postfix/main.cf
   ```
   Add:
   ```
   smtp_generic_maps = hash:/etc/postfix/generic
   ```
   Save and exit.

2. Create the sender rewrite file:
   ```bash
   sudo nano /etc/postfix/generic
   ```
   Add:
   ```
   keith@home-server1 your-icloud-email@icloud.com
   ```
   Save and exit.

3. Apply changes:
   ```bash
   sudo postmap /etc/postfix/generic
   sudo systemctl restart postfix
   ```

4. Test email sending:
   ```bash
   echo "Test email from iCloud SMTP" | mail -s "Postfix Test" your-email@example.com
   ```

### **Final Checks**
- Run:
  ```bash
  sudo tail -f /var/log/mail.log
  ```
- If emails are still not being sent, check journal logs:
  ```bash
  sudo journalctl -u postfix --no-pager | tail -50
  ```


----

## Conclusion

By implementing these automation techniques, we:
- **Automate system health checks** to detect issues early.
- **Send email alerts** for critical resource limits.
- **Ensure email alerts are properly configured with Postfix.**

This setup ensures Home-Server1 remains **efficient, stable, and easy to manage**.
