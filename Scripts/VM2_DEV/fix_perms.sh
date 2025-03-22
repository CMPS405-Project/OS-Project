#!/bin/bash

# Script: fix_perms.sh
# Purpose: Find files with 777 permissions, change to 700, and log actions

# Define log file for permission changes
LOG_FILE="/var/log/perm_changes.log"

# Ensure log file exists and has secure permissions
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
    chmod 600 "$LOG_FILE"  # Owner-only read/write
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Log file created" >> "$LOG_FILE"
fi

# Check if log file is writable
if [ ! -w "$LOG_FILE" ]; then
    echo "Error: Cannot write to log file $LOG_FILE"
    exit 1
fi

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Check if find and chmod commands are available
if ! command -v find &> /dev/null || ! command -v chmod &> /dev/null; then
    log_message "ERROR: Required commands (find or chmod) not found."
    echo "Error: Required commands (find or chmod) not found."
    exit 1
fi

# Find files with 777 permissions
# -type f ensures we only match files (not directories)
log_message "Starting permission cleanup..."
find / -type f -perm 777 2>/dev/null | while read -r file; do
    # Change permissions to 700
    if chmod 700 "$file"; then
        log_message "Changed permissions of $file from 777 to 700"
    else
        log_message "ERROR: Failed to change permissions of $file"
    fi
done

# Log and display completion
log_message "Permission cleanup completed."
echo "Permission changes complete. Check $LOG_FILE for details."

# Exit cleanly
exit 0