#!/bin/bash

# Directory to store logs
LOG_DIR="/var/operations/monitoring"
mkdir -p "$LOG_DIR"  # Ensure directory exists

# Generate log file with timestamp
LOG_FILE="$LOG_DIR/metrics_$(date +"%Y%m%d_%H%M%S").log"

# Start logging system metrics
{
    echo "===== System Metrics Report ====="
    
    # CPU & Memory Usage
    echo -e "\n[CPU & Memory Usage]"
    top -b -n1 | head -n 10

    # Disk I/O Usage
    echo -e "\n[Disk I/O Usage]"
    iostat -dx 1 1  # Requires 'sysstat' package

    # Top 5 resource-heavy processes
    echo -e "\n[Top 5 Resource-Heavy Processes]"
    ps -eo pid,cmd,%mem,%cpu --sort=-%mem | head -6

    Check MySQL & SSH status
    # Collect MySQL and SSH status
    mysql_status=$(systemctl is-active mysql)
    ssh_status=$(systemctl is-active ssh)

# Check if MySQL or SSH is inactive and restart if necessary
if [ "$mysql_status" != "active" ]; then
    echo "$(date): MySQL is down. Restarting MySQL..." >> $log_file
    systemctl restart mysql
    mysql_status="restarted"
fi

if [ "$ssh_status" != "active" ]; then
    echo "$(date): SSH is down. Restarting SSH..." >> $log_file
    systemctl restart ssh
    ssh_status="restarted"
fi

    echo -e "\nMonitoring Completed.\n"
}>"$LOG_FILE"