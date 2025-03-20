# #!/bin/bash

# # Define the log directory where metrics will be stored
# LOG_DIR="/var/operations/monitoring"

# # Generate a timestamp (format: YYYYMMDD_HHMMSS) to uniquely name each log file
# TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# # Define the full path for the log file using the timestamp
# LOG_FILE="$LOG_DIR/metrics_$TIMESTAMP.log"

# # Ensure the log directory exists; if not, create it
# mkdir -p "$LOG_DIR"

# # Function: collect_metrics
# # This function gathers system metrics and writes them to the log file.
# collect_metrics() {
#     # Write a header with the current date and time
#     echo "=== System Metrics - $(date) ===" >> "$LOG_FILE"
    
#     # Log CPU and Memory usage:
#     # Run 'top' in batch mode (-b) for 1 iteration (-n1) and capture the first 10 lines.
#     echo -e "\nCPU & Memory Usage:" >>  "$LOG_FILE"
#     top -b -n1 | head -10 >> "$LOG_FILE"

#     # Log Disk I/O statistics:
#     # The 'iostat -x 1 1' command provides extended disk I/O statistics for one second.
#     echo -e "\nDisk I/O Stats:" >> "$LOG_FILE"
#     iostat -x 1 1 >> "$LOG_FILE"

#     # Log the Top 5 resource-heavy processes:
#     # List processes sorted by CPU usage and take the top 6 lines (header + top 5 processes).
#     echo -e "\nTop 5 Resource-Heavy Processes:" >> "$LOG_FILE"
#     ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6 >> "$LOG_FILE"

#     # Log the status of critical services: MySQL and SSH.
#     echo -e "\nService Status:" >> "$LOG_FILE"
#     echo "MySQL status:" >> "$LOG_FILE"
#     systemctl is-active mysql >> "$LOG_FILE" 2>&1
#     echo "SSH status:" >> "$LOG_FILE"
#     systemctl is-active ssh >> "$LOG_FILE" 2>&1
# }

# # Function: restart_service
# # This function checks if a given service is active.
# # If the service is not active, it attempts to restart it and logs the outcome.
# restart_service() {
#     local service="$1"  # The service name is passed as the first argument.
    
#     # Check if the service is not active
#     if ! systemctl is-active --quiet "$service"; then
#         # Log that the service is down and that a restart is being attempted.
#         echo "$(date) - ALERT: $service is down. Restarting..." >> "$LOG_FILE"
#         systemctl restart "$service"
#         sleep 5  # Wait 5 seconds to allow the service time to restart
        
#         # Check if the service is active after the restart attempt
#         if systemctl is-active --quiet "$service"; then
#             echo "$(date) - INFO: $service restarted successfully." >> "$LOG_FILE"
#         else
#             echo "$(date) - ERROR: Failed to restart $service. Manual intervention required." >> "$LOG_FILE"
#         fi
#     fi
# }

# # ----------------- Main Execution -----------------

# # Collect and log system metrics
# collect_metrics

# # Check and, if needed, restart the MySQL service
# restart_service mysql

# # Check for Apache service:
# # This block handles both Debian-based (apache2) and RHEL-based (httpd) systems.
# if systemctl list-units --type=service | grep -q "apache2.service"; then
#     restart_service apache2
# elif systemctl list-units --type=service | grep -q "httpd.service"; then
#     restart_service httpd
# else
#     # If no Apache service is found, log a warning message.
#     echo "$(date) - WARNING: Apache service not found." >> "$LOG_FILE"
# fi

# # Add a final separator line to clearly indicate the end of this log entry
# echo "==============================================" >> "$LOG_FILE"

















# # # Directory to store logs
# # LOG_DIR="/var/operations/monitoring"
# # mkdir -p "$LOG_DIR"  # Ensure directory exists

# # # Generate log file with timestamp
# # LOG_FILE="$LOG_DIR/metrics_$(date +"%Y%m%d_%H%M%S").log"

# # # Start logging system metrics
# # {
# #     echo "===== System Metrics Report ====="
    
# #     # CPU & Memory Usage
# #     echo -e "\n[CPU & Memory Usage]"
# #     top -b -n1 | head -n 10

# #     # Disk I/O Usage
# #     echo -e "\n[Disk I/O Usage]"
# #     iostat -dx 1 1  # Requires 'sysstat' package

# #     # Top 5 resource-heavy processes
# #     echo -e "\n[Top 5 Resource-Heavy Processes]"
# #     ps -eo pid,cmd,%mem,%cpu --sort=-%mem | head -6

# #     Check MySQL & SSH status
# #     # Collect MySQL and SSH status
# #     mysql_status=$(systemctl is-active mysql)
# #     ssh_status=$(systemctl is-active ssh)

# # # Check if MySQL or SSH is inactive and restart if necessary
# # if [ "$mysql_status" != "active" ]; then
# #     echo "$(date): MySQL is down. Restarting MySQL..." >> $log_file
# #     systemctl restart mysql
# #     mysql_status="restarted"
# # fi

# # if [ "$ssh_status" != "active" ]; then
# #     echo "$(date): SSH is down. Restarting SSH..." >> $log_file
# #     systemctl restart ssh
# #     ssh_status="restarted"
# # fi

# #     echo -e "\nMonitoring Completed.\n"
# # }>"$LOG_FILE"














#!/bin/bash

# Define the log directory where metrics will be stored
LOG_DIR="/var/operations/monitoring"

# Generate a timestamp (format: YYYYMMDD_HHMMSS) to uniquely name each log file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Define the full path for the log file using the timestamp
LOG_FILE="$LOG_DIR/metrics_$TIMESTAMP.log"

# Ensure the log directory exists; if not, create it
sudo mkdir -p "$LOG_DIR"

# Function: collect_metrics
# This function gathers system metrics and writes them to the log file.
collect_metrics() {
    # Write a header with the current date and time
    echo "=== System Metrics - $(date) ===" | sudo tee -a "$LOG_FILE" > /dev/null
    
    # Log CPU and Memory usage:
    echo -e "\nCPU & Memory Usage:" | sudo tee -a "$LOG_FILE" > /dev/null
    top -b -n1 | head -10 | sudo tee -a "$LOG_FILE" > /dev/null

    # Log Disk I/O statistics:
    echo -e "\nDisk I/O Stats:" | sudo tee -a "$LOG_FILE" > /dev/null
    sudo iostat -x 1 1 | sudo tee -a "$LOG_FILE" > /dev/null

    # Log the Top 5 resource-heavy processes:
    echo -e "\nTop 5 Resource-Heavy Processes:" | sudo tee -a "$LOG_FILE" > /dev/null
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6 | sudo tee -a "$LOG_FILE" > /dev/null

    # Log the status of critical services: MySQL and SSH.
    echo -e "\nService Status:" | sudo tee -a "$LOG_FILE" > /dev/null
    echo "MySQL status:" | sudo tee -a "$LOG_FILE" > /dev/null
    sudo systemctl is-active mysql | sudo tee -a "$LOG_FILE" > /dev/null 2>&1
    echo "SSH status:" | sudo tee -a "$LOG_FILE" > /dev/null
    sudo systemctl is-active ssh | sudo tee -a "$LOG_FILE" > /dev/null 2>&1
}

# Function: restart_service
# This function checks if a given service is active.
# If the service is not active, it attempts to restart it and logs the outcome.
restart_service() {
    local service="$1"  # The service name is passed as the first argument.
    
    # Check if the service is not active
    if ! sudo systemctl is-active --quiet "$service"; then
        echo "$(date) - ALERT: $service is down. Restarting..." | sudo tee -a "$LOG_FILE" > /dev/null
        sudo systemctl restart "$service"
        sleep 5  # Wait 5 seconds to allow the service time to restart
        
        # Check if the service is active after the restart attempt
        if sudo systemctl is-active --quiet "$service"; then
            echo "$(date) - INFO: $service restarted successfully." | sudo tee -a "$LOG_FILE" > /dev/null
        else
            echo "$(date) - ERROR: Failed to restart $service. Manual intervention required." | sudo tee -a "$LOG_FILE" > /dev/null
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
if sudo systemctl list-units --type=service | grep -q "apache2.service"; then
    restart_service apache2
elif sudo systemctl list-units --type=service | grep -q "httpd.service"; then
    restart_service httpd
else
    # If no Apache service is found, log a warning message.
    echo "$(date) - WARNING: Apache service not found." | sudo tee -a "$LOG_FILE" > /dev/null
fi

# Add a final separator line to clearly indicate the end of this log entry
echo "==============================================" | sudo tee -a "$LOG_FILE" > /dev/null
