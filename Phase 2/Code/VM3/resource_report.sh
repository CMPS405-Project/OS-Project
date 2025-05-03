#!/bin/bash

# Script: resource_report.sh
# Purpose: Collect system resource metrics on VM3 and copy the report to VM1 hourly
# Author: [Your Name/Group Name]
# Date: March 2025

# Define variables
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")  # Format: YYYYMMDD_HHMMSS (e.g., 20250321_143022)
REPORT_FILE="/tmp/resource_report_${TIMESTAMP}.txt"  # Temporary file for the report
VM1_IP="192.168.6.128"  # Replace with VM1's actual IP address
VM1_USER="dev_lead1"  # User on VM1 with SCP access
VM1_DEST_PATH="/var/operations/reports"  # Destination path on VM1
DEST_PATH="${VM1_USER}@${VM1_IP}:${VM1_DEST_PATH}/"

# Create the report file
touch "$REPORT_FILE" 2>/dev/null || { echo "Error: Cannot create report file"; exit 1; }
chmod 640 "$REPORT_FILE"  # Read/write for owner, read for group, none for others

# Start the report
echo "===== Resource Report for VM3 (Operations Team) - $TIMESTAMP =====" > "$REPORT_FILE"

# 1. Process Tree
echo -e "\n[Process Tree]" >> "$REPORT_FILE"
pstree -p >> "$REPORT_FILE" 2>/dev/null  # -p includes process IDs
if [ $? -ne 0 ]; then
    echo "Error: Failed to collect process tree" >> "$REPORT_FILE"
fi

# 2. Zombie Processes
echo -e "\n[Zombie Processes]" >> "$REPORT_FILE"
ps aux | awk '$8=="Z" {print "PID: " $2 " - " $11}' >> "$REPORT_FILE" 2>/dev/null
ZOMBIE_COUNT=$(ps aux | awk '$8=="Z"' | wc -l)
echo "Total zombies: $ZOMBIE_COUNT" >> "$REPORT_FILE"
if [ "$ZOMBIE_COUNT" -eq 0 ]; then
    echo "No zombie processes found." >> "$REPORT_FILE"
fi

# 3. CPU and Memory Usage
echo -e "\n[CPU and Memory Usage]" >> "$REPORT_FILE"
# CPU usage (using top, capturing a single snapshot)
echo "CPU Usage:" >> "$REPORT_FILE"
top -bn1 | head -n 3 >> "$REPORT_FILE" 2>/dev/null  # First 3 lines show CPU usage
# Memory usage (using free)
echo -e "\nMemory Usage:" >> "$REPORT_FILE"
free -h >> "$REPORT_FILE" 2>/dev/null  # -h for human-readable format

# 4. Top 5 Resource-Consuming Processes (by CPU and memory)
echo -e "\n[Top 5 Resource-Consuming Processes]" >> "$REPORT_FILE"
# Sort by CPU usage
echo "By CPU Usage:" >> "$REPORT_FILE"
ps -eo pid,ppid,user,%cpu,%mem,cmd --sort=-%cpu | head -n 6 >> "$REPORT_FILE" 2>/dev/null  # Top 5 + header
# Sort by Memory usage
echo -e "\nBy Memory Usage:" >> "$REPORT_FILE"
ps -eo pid,ppid,user,%cpu,%mem,cmd --sort=-%mem | head -n 6 >> "$REPORT_FILE" 2>/dev/null  # Top 5 + header

# Copy the report to VM1 using SCP
scp -o "StrictHostKeyChecking=no" "$REPORT_FILE" "$DEST_PATH" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "$TIMESTAMP - Successfully copied report to $VM1_IP:$VM1_DEST_PATH" | logger -t resource_report
# Clean up the temporary file
rm "$REPORT_FILE"
else
    echo "$TIMESTAMP - Failed to copy report to $VM1_IP" | logger -t resource_report
    exit 1
fi

exit 0