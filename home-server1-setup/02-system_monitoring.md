
# System Monitoring & Logging - home-server1

## Overview
Next step is to implement system monitoring and logging. This ensures the server operates efficiently, remains stable, and can provide insights into performance metrics. Monitoring helps detect potential failures early, prevents resource exhaustion, and ensures overall system health.

This document covers manual monitoring, resource tracking, and log management, providing system administrators with real-time and historical data on performance.

---

## 1. Understanding System Monitoring

Monitoring allows system administrators to:
- Track CPU, memory, and disk usage in real time.
- Identify bottlenecks and performance issues before they escalate.
- Diagnose issues using log files and hardware statistics.
- Ensure the system operates within safe temperature thresholds.
- Keep track of network activity and troubleshoot connectivity problems.

By implementing proper monitoring, we can ensure Home-Server1 operates efficiently and securely.

---

## 2. Installing System Monitoring Tools
To effectively monitor system performance, we install essential monitoring utilities that provide real-time and historical data.

### Install Monitoring Packages
Run the following command to install key tools:
```bash
sudo apt install -y htop sysstat glances lm-sensors iftop
```

### Explanation of Installed Tools:
- htop – Real-time interactive process viewer.
- sysstat – Logs CPU, memory, and disk usage over time.
- glances – Comprehensive monitoring tool displaying multiple metrics in one interface.
- lm-sensors – Monitors CPU temperature and system voltages.
- iftop – Network bandwidth usage monitoring.

---

## 3. Configuring System Activity Data Collection
By default, sysstat may not collect system activity data. To enable it, follow these steps:

1. Edit the sysstat configuration file:
```bash
sudo nano /etc/default/sysstat
```
2. Find the following line:
```bash
ENABLED="false"
```
3. Change it to:
```bash
ENABLED="true"
```
4. Save the file and exit the editor.

5. Restart the sysstat service to apply changes:
```bash
sudo systemctl restart sysstat
```
6. Enable sysstat to start on boot:
```bash
sudo systemctl enable sysstat
```

After these steps, sysstat will begin collecting system activity data.

---

## 4. Monitoring System Resources

### Checking CPU Usage
Understanding CPU utilization is key to diagnosing performance slowdowns. To check real-time CPU usage, use:
```bash
htop
```
- Displays active processes sorted by CPU or memory usage.
- Allows killing unresponsive tasks (F9 to terminate a process).
- Use arrow keys to scroll and F5 for tree view.

For a historical report on CPU activity:
```bash
sar -u 5 10
```
- Reports CPU usage every 5 seconds, 10 times.
- Useful for checking spikes in CPU load over time.

To display a daily summary of CPU activity:
```bash
sar -u
```
If you encounter an error such as:
```bash
Cannot open /var/log/sysstat/saXX: No such file or directory
```
Ensure sysstat is enabled and running correctly by following the steps in section 3.

### Checking Memory (RAM) Usage
To monitor memory and swap usage in real time:
```bash
free -m
```
Output explanation:
- Total: Installed RAM.
- Used: Memory currently in use.
- Free: Unused memory.
- Available: Memory available for new processes.

Alternatively, use htop and glances for more detailed analysis.

---

## 5. Monitoring Disk Usage
Understanding disk utilization helps prevent storage overuse and performance degradation.

### Checking Disk Space Usage
```bash
df -h
```
- The -h flag displays output in a human-readable format.
- Shows total, used, and available space on each partition.

Example output:
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1      100G   20G   80G  20% /
```
If a partition is over 90% full, consider cleaning old logs, backups, or expanding storage.

### Checking Disk I/O Performance
To monitor disk read/write activity:
```bash
iostat -dx 5 5
```
- Displays disk usage statistics every 5 seconds, 5 times.
- Helps identify high disk activity processes.

---

## 6. Monitoring Network Traffic
To diagnose network slowdowns and traffic spikes, we use network monitoring tools.

### Checking Active Network Connections
```bash
netstat -tulnp
```
- Displays active listening ports and running services.
- Useful for detecting unauthorized services.

### Monitoring Bandwidth Usage
To monitor real-time bandwidth usage per interface:
```bash
iftop -n
```
- Shows live network activity sorted by highest traffic usage.
- Press Q to exit.

---

## 7. Monitoring System Temperature and Hardware Health
Overheating can degrade performance and damage hardware. To check system temperature:

### Check Available Sensors
```bash
sudo sensors-detect
```
- Detects available temperature sensors.
- Follow on-screen instructions to enable monitoring.

### Monitor CPU Temperature
```bash
sensors
```
Example output:
```
Core 0:       +45.0°C  (high = +90.0°C, crit = +100.0°C)
Core 1:       +43.0°C  (high = +90.0°C, crit = +100.0°C)
```
- +45.0°C is the current temperature.
- high is the recommended max operating temperature.
- crit is the critical shutdown threshold.

If CPU temperature exceeds 80°C, consider improving cooling or cleaning dust from fans.

---

## 8. Checking System Logs
Logs provide insights into system events, errors, and security alerts.

### Viewing System Logs
To check recent logs:
```bash
journalctl -xe
```
- Displays recent system logs, highlighting errors.

To view logs for a specific service (e.g., SSH):
```bash
journalctl -u ssh --no-pager
```

### Checking Authentication Logs
To detect failed login attempts and unauthorized access:
```bash
tail -f /var/log/auth.log
```
- Useful for tracking SSH login attempts.

### Checking System Boot Logs
To analyze boot errors:
```bash
dmesg | less
```
- Displays kernel boot messages.
- Helps troubleshoot hardware detection issues.

---

## Conclusion
By implementing these manual monitoring techniques, we can ensure:
- Real-time tracking of CPU, memory, and disk usage.
- Identification of performance bottlenecks before they cause system crashes.
- Comprehensive logging for auditing and troubleshooting.
- Proactive network traffic and temperature monitoring.


This setup ensures Home-Server1 remains stable and performs optimally for all upcoming projects.

