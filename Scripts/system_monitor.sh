# #!/bin/bash

# # Log file path
# LOG_FILE="/var/operations/monitoring/metrics_<timestamp>.log"

# # Timestamp
# echo "===== System Monitor Log - $(date) =====" >> "$LOG_FILE"

# # CPU and Memory usage
# echo ">> CPU and Memory Usage:" >> "$LOG_FILE"
# top -b -n 1 | head -n 10 >> "$LOG_FILE"
# echo "" >> "$LOG_FILE"

# # Disk I/O usage
# echo ">> Disk I/O Usage:" >> "$LOG_FILE"
# iostat -dx 1 1 >> "$LOG_FILE"
# echo "" >> "$LOG_FILE"

# # Top 5 resource-heavy processes
# echo ">> Top 5 Resource-Heavy Processes:" >> "$LOG_FILE"
# ps -eo pid,user,%cpu,%mem,cmd --sort=-%cpu | head -n 6 >> "$LOG_FILE"
# echo "" >> "$LOG_FILE"

# # Function to check and restart a service
# check_service() {
#     SERVICE_NAME=$1
#     systemctl is-active --quiet "$SERVICE_NAME"
#     STATUS=$?

#     if [[ $STATUS -ne 0 ]]; then
#         echo "!! ALERT: $SERVICE_NAME is DOWN. Restarting..." >> "$LOG_FILE"
#         systemctl restart "$SERVICE_NAME"
#         sleep 5  # Wait for restart

#         # Recheck status
#         systemctl is-active --quiet "$SERVICE_NAME"
#         if [[ $? -ne 0 ]]; then
#             echo "!! ERROR: Failed to restart $SERVICE_NAME. Manual intervention required." >> "$LOG_FILE"
#         else
#             echo ">> $SERVICE_NAME restarted successfully." >> "$LOG_FILE"
#         fi
#     else
#         echo ">> $SERVICE_NAME is running." >> "$LOG_FILE"
#     fi
#     echo "" >> "$LOG_FILE"
# }

# # Check MySQL
# check_service "mysql"

# # Check Apache (httpd for RHEL-based systems, apache2 for Debian-based)
# if systemctl list-units --type=service | grep -q "apache2.service"; then
#     check_service "apache2"
# elif systemctl list-units --type=service | grep -q "httpd.service"; then
#     check_service "httpd"
# else
#     echo "!! WARNING: Apache service not found." >> "$LOG_FILE"
# fi

# # Check SSH status
# echo ">> SSH Status:" >> "$LOG_FILE"
# systemctl is-active ssh >> "$LOG_FILE"
# echo "" >> "$LOG_FILE"

# echo "======================================" >> "$LOG_FILE"
# echo "" >> "$LOG_FILE"









#!/bin/bash

# Define the log directory where metrics will be stored
LOG_DIR="/var/operations/monitoring"

# Generate a timestamp (format: YYYYMMDD_HHMMSS) to uniquely name each log file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Define the full path for the log file using the timestamp
LOG_FILE="$LOG_DIR/metrics_$TIMESTAMP.log"

# Ensure the log directory exists; if not, create it
mkdir -p "$LOG_DIR"

# Function: collect_metrics
# This function gathers system metrics and writes them to the log file.
collect_metrics() {
    # Write a header with the current date and time
    echo "=== System Metrics - $(date) ===" >> "$LOG_FILE"
    
    # Log CPU and Memory usage:
    # Run 'top' in batch mode (-b) for 1 iteration (-n1) and capture the first 10 lines.
    echo -e "\nCPU & Memory Usage:" >> "$LOG_FILE"
    top -b -n1 | head -10 >> "$LOG_FILE"

    # Log Disk I/O statistics:
    # The 'iostat -x 1 1' command provides extended disk I/O statistics for one second.
    echo -e "\nDisk I/O Stats:" >> "$LOG_FILE"
    iostat -x 1 1 >> "$LOG_FILE"

    # Log the Top 5 resource-heavy processes:
    # List processes sorted by CPU usage and take the top 6 lines (header + top 5 processes).
    echo -e "\nTop 5 Resource-Heavy Processes:" >> "$LOG_FILE"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6 >> "$LOG_FILE"

    # Log the status of critical services: MySQL and SSH.
    echo -e "\nService Status:" >> "$LOG_FILE"
    echo "MySQL status:" >> "$LOG_FILE"
    systemctl is-active mysql >> "$LOG_FILE" 2>&1
    echo "SSH status:" >> "$LOG_FILE"
    systemctl is-active ssh >> "$LOG_FILE" 2>&1
}

# Function: restart_service
# This function checks if a given service is active.
# If the service is not active, it attempts to restart it and logs the outcome.
restart_service() {
    local service="$1"  # The service name is passed as the first argument.
    
    # Check if the service is not active
    if ! systemctl is-active --quiet "$service"; then
        # Log that the service is down and that a restart is being attempted.
        echo "$(date) - ALERT: $service is down. Restarting..." >> "$LOG_FILE"
        systemctl restart "$service"
        sleep 5  # Wait 5 seconds to allow the service time to restart
        
        # Check if the service is active after the restart attempt
        if systemctl is-active --quiet "$service"; then
            echo "$(date) - INFO: $service restarted successfully." >> "$LOG_FILE"
        else
            echo "$(date) - ERROR: Failed to restart $service. Manual intervention required." >> "$LOG_FILE"
        fi
    fi
}

# ----------------- Main Execution -----------------

# Collect and log system metrics
collect_metrics

# Check and, if needed, restart the MySQL service
restart_service mysql

# Check for Apache service:
# This block handles both Debian-based (apache2) and RHEL-based (httpd) systems.
if systemctl list-units --type=service | grep -q "apache2.service"; then
    restart_service apache2
elif systemctl list-units --type=service | grep -q "httpd.service"; then
    restart_service httpd
else
    # If no Apache service is found, log a warning message.
    echo "$(date) - WARNING: Apache service not found." >> "$LOG_FILE"
fi

# Add a final separator line to clearly indicate the end of this log entry
echo "==============================================" >> "$LOG_FILE"
