#!/bin/bash

# Log file location (local)
LOGFILE="/var/log/system_monitor_$(date +%Y%m%d).log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Remote VM1 details
REMOTE_USER="user"              # VM1 username
REMOTE_HOST="192.168.1.100"     # VM1 IP or hostname
REMOTE_PATH="/home/user/reports" # Destination path on VM1

# Create log file if it doesn't exist
touch "$LOGFILE" 2>/dev/null || { echo "Error: Cannot create log file"; exit 1; }

# Check if we can write to log file
[ -w "$LOGFILE" ] || { echo "Error: Cannot write to log file"; exit 1; }

# Function to add section separator
section() {
    echo "==========================================" >> "$LOGFILE"
}

# Header
echo "$TIMESTAMP - System Monitoring Report" >> "$LOGFILE"
section

# 1. Process Tree
echo "Process Tree:" >> "$LOGFILE"
pstree -p >> "$LOGFILE" 2>/dev/null
section

# 2. Zombie Processes
echo "Zombie Processes:" >> "$LOGFILE"
ps aux | awk '$8=="Z" {print "PID:" $2 " - " $11}' >> "$LOGFILE"
echo "Total zombies: $(ps aux | awk '$8=="Z"' | wc -l)" >> "$LOGFILE"
section

# 3. CPU and Memory Usage
echo "CPU and Memory Usage:" >> "$LOGFILE"
echo "CPU Usage:" >> "$LOGFILE"
top -bn1 | grep "Cpu(s)" >> "$LOGFILE"
echo "Memory Usage:" >> "$LOGFILE"
free -h | grep "Mem:" >> "$LOGFILE"
section

# 4. Top 5 Resource-Consuming Processes
echo "Top 5 CPU-Consuming Processes:" >> "$LOGFILE"
ps -eo pid,ppid,user,%cpu,%mem,cmd --sort=-%cpu | head -n 6 >> "$LOGFILE"
section

echo "Top 5 Memory-Consuming Processes:" >> "$LOGFILE"
ps -eo pid,ppid,user,%cpu,%mem,cmd --sort=-%mem | head -n 6 >> "$LOGFILE"
section

# Log completion
echo "Monitoring complete for $TIMESTAMP" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# SCP the file to VM1
scp "$LOGFILE" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}" 2>>"$LOGFILE"
if [ $? -eq 0 ]; then
    echo "$TIMESTAMP - Successfully copied report to $REMOTE_HOST:$REMOTE_PATH" >> "$LOGFILE"
else
    echo "$TIMESTAMP - Failed to copy report to $REMOTE_HOST" >> "$LOGFILE"
fi