#!/bin/bash
ALERT_EMAIL="keithbradyie@icloud.com"
LOG_FILE="sudo journalctl"
ALERT_KEYWORDS=("error" "failed" "critical")

for keyword in "${ALERT_KEYWORDS[@]}"; do
    if grep -qi "$keyword" "$LOG_FILE"; then
        echo "$(date) - Critical log entry detected: $keyword" >> /var/log/alert.log
        echo "Critical log entry detected: $keyword" | mail -s "Log Alert - Home-Server1" "$ALERT_EMAIL"
    fi
done
