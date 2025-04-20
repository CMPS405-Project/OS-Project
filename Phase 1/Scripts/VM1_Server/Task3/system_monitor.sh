
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
