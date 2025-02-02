#!/bin/bash

# Define alert email recipient
ALERT_EMAIL="keithbradyie@icloud.com"

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
