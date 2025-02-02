
# Log Management - home-server1

## Overview

Effective log management is essential for monitoring system performance, troubleshooting issues, and ensuring security. This section covers log rotation, centralized logging, automated log analysis, and alerting based on log data.

By implementing a structured logging system, we can efficiently store, analyze, and respond to critical events on Home-Server1.

---

## 1. Setting Up Log Rotation

Log files can grow quickly, consuming disk space and making log analysis difficult. **logrotate** automates log file management by rotating and compressing logs periodically.

### **What is logrotate?**

`logrotate` is a system utility designed to manage and automate the rotation and compression of log files. This prevents logs from consuming excessive disk space while keeping historical data for troubleshooting.

### **Configuring logrotate**

1. Open the logrotate configuration file for system logs:

   ```bash
   sudo nano /etc/logrotate.conf
   ```

2. Ensure the following settings are included:

   ```conf
   weekly          # Rotates logs every week
   rotate 4        # Keeps four weeks of logs before deleting old ones
   create         # Creates new empty logs after rotation
   compress       # Compresses old logs to save space
   notifempty     # Skips rotation if the log file is empty
   ```

3. To configure rotation for a specific log (e.g., `/var/log/custom.log`), create a new configuration file:

   ```bash
   sudo nano /etc/logrotate.d/custom_log
   ```

   Add:

   ```conf
   /var/log/custom.log {
       weekly
       rotate 5
       compress
       missingok  # Prevents errors if the log file is missing
       notifempty
   }
   ```

4. Test logrotate to ensure the configuration works correctly:

   ```bash
   sudo logrotate -d /etc/logrotate.conf
   ```

5. To manually force a log rotation for testing:
   ```bash
   sudo logrotate -f /etc/logrotate.conf
   ```

6. If logs are not rotating properly, check the logrotate status:
   ```bash
   sudo journalctl -u logrotate --no-pager
   ```

---

## 2. Setting Up Centralized Logging with Rsyslog

### **What is Rsyslog?**

Rsyslog is a powerful and versatile logging utility that allows system logs to be forwarded to a central server for analysis and storage. This is useful for monitoring multiple systems from a single location.

### **Enabling Rsyslog on Home-Server1**

1. Install Rsyslog if not already installed:

   ```bash
   sudo apt install -y rsyslog
   ```

2. Edit the Rsyslog configuration file:

   ```bash
   sudo nano /etc/rsyslog.conf
   ```

3. Uncomment or add the following lines to enable remote logging:

   ```conf
   module(load="imudp")
   input(type="imudp" port="514")
   module(load="imtcp")
   input(type="imtcp" port="514")
   ```

4. Restart Rsyslog to apply changes:

   ```bash
   sudo systemctl restart rsyslog
   ```

### **Forwarding Logs to a Central Server**

1. On each client machine, configure log forwarding:

   ```bash
   sudo nano /etc/rsyslog.d/50-forwarding.conf
   ```

2. Add the following line to send logs to the central server (replace `logserver` with the actual server IP):

   ```conf
   *.* @logserver:514
   ```

3. Restart Rsyslog:

   ```bash
   sudo systemctl restart rsyslog
   ```

4. Test log forwarding by sending a test log:
   ```bash
   logger -t TEST "This is a test log entry"
   ```
   Then check on the central log server:
   ```bash
   sudo tail -f sudo journalctl
   ```

---

## 3. Automated Log Analysis with Fail2Ban

### **What is Fail2Ban?**

Fail2Ban is a security tool that monitors log files for repeated failed authentication attempts and bans the offending IP addresses to prevent brute-force attacks.

### **Installing Fail2Ban**

1. Install Fail2Ban:

   ```bash
   sudo apt install -y fail2ban
   ```

2. Create a custom jail for SSH monitoring:

   ```bash
   sudo nano /etc/fail2ban/jail.local
   ```

3. Add the following configuration:

   ```conf
   [sshd]
   enabled = true
   backend = systemd
   filter = sshd
   banaction = iptables-multiport
   logpath = %(journal)s
   maxretry = 5  # Number of failed attempts before banning
   bantime = 600 # Ban duration in seconds
   ```

4. Save and exit (`CTRL+X`, `Y`, `Enter`).

5. Restart Fail2Ban:

   ```bash
   sudo systemctl restart fail2ban
   ```

6. Verify if Fail2Ban is banning correctly:
   ```bash
   sudo fail2ban-client status sshd
   ```

7. Manually ban and unban an IP for testing:
   ```bash
   sudo fail2ban-client set sshd banip 192.168.1.100
   sudo fail2ban-client set sshd unbanip 192.168.1.100
   ```

8. If Fail2Ban still fails, reset the database:
   ```bash
   sudo rm -f /var/lib/fail2ban/fail2ban.sqlite3
   sudo systemctl restart fail2ban
   ```

---

## 4. Setting Up Log-Based Alerts

### **Email Alerts for Critical Log Entries**

1. Create an alert script:

   ```bash
   sudo nano /opt/log_alert.sh
   ```

2. Add the following script:

   ```bash
   #!/bin/bash
   ALERT_EMAIL="admin@example.com"
   LOG_FILE="sudo journalctl"
   ALERT_KEYWORDS=("error" "failed" "critical")

   for keyword in "${ALERT_KEYWORDS[@]}"; do
       if grep -qi "$keyword" "$LOG_FILE"; then
           echo "$(date) - Critical log entry detected: $keyword" >> /var/log/alert.log
           echo "Critical log entry detected: $keyword" | mail -s "Log Alert - Home-Server1" "$ALERT_EMAIL"
       fi
   done
   ```

3. Make the script executable:
   ```bash
   sudo chmod +x /opt/log_alert.sh
   ```

4. Schedule it in cron to run every 15 minutes:
   ```bash
   sudo crontab -e
   ```
   Add:
   ```bash
   */15 * * * * /opt/log_alert.sh
   ```

5. Test the alert system:
   ```bash
   logger -t TEST "$(date) - CRITICAL ERROR DETECTED"
   sudo journalctl -t TEST --no-pager --since "5 minutes ago"
   ```

---

## Conclusion

By implementing structured log management, we:

- **Rotate logs** to prevent excessive growth.
- **Centralize logs** for easier monitoring.
- **Analyze logs** using automated tools like `grep`, `awk`, and `Fail2Ban`.
- **Set up alerts** to notify administrators of critical issues.

This setup ensures Home-Server1 remains secure, monitored, and easy to troubleshoot.
