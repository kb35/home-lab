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
