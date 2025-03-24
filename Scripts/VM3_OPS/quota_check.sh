#!/bin/bash

# Script: quota_check.sh
# Purpose: Monitor disk usage in /shared on VM3 and enforce quotas for users
# Author: [Your Name/Group Name]
# Date: March 2025

# Configuration
SHARED_DIR="/shared"
ADMIN_EMAIL="admin@qu.edu.qa"
LOG_FILE="/var/log/quota_check.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Quota limits (in KB for comparison, as per PDF requirements)
DEV_LEAD1_HARD=$((5 * 1024 * 1024))  # 5GB = 5,242,880 KB (hard limit)
DEV_LEAD1_SOFT=$((6 * 1024 * 1024))  # 6GB = 6,291,456 KB (warning)
OPS_LEAD1_HARD=$((3 * 1024 * 1024))  # 3GB = 3,145,728 KB (hard limit)
OPS_LEAD1_SOFT=$((4 * 1024 * 1024))  # 4GB = 4,194,304 KB (warning)

# Users
DEV_LEAD1="dev_lead1"
OPS_LEAD1="ops_lead1"

# Ensure log file exists
touch "$LOG_FILE" 2>/dev/null || { echo "Error: Cannot create log file"; exit 1; }
[ -w "$LOG_FILE" ] || { echo "Error: Cannot write to log file"; exit 1; }
chmod 640 "$LOG_FILE"

# Ensure /shared exists
if [ ! -d "$SHARED_DIR" ]; then
    mkdir -p "$SHARED_DIR"
    chmod 755 "$SHARED_DIR"
    echo "$TIMESTAMP - Created $SHARED_DIR" >> "$LOG_FILE"
fi

# Check if mail command is available
if ! command -v mail >/dev/null; then
    echo "$TIMESTAMP - Error: mail command not found. Please install mailutils." >> "$LOG_FILE"
    exit 1
fi

# Function to send email
send_email() {
    local subject="$1"
    local message="$2"
    echo "$message" | mail -s "$subject" "$ADMIN_EMAIL" 2>>"$LOG_FILE"
    if [ $? -ne 0 ]; then
        echo "$TIMESTAMP - Failed to send email: $subject" >> "$LOG_FILE"
    else
        echo "$TIMESTAMP - Email sent: $subject" >> "$LOG_FILE"
    fi
}

# Function to check user quota
check_quota() {
    local user="$1"
    local soft_limit="$2"
    local hard_limit="$3"

    # Calculate usage in /shared for the user (in KB)
    usage=$(find "$SHARED_DIR" -user "$user" -type f -exec du -k {} + 2>/dev/null | awk '{total += $1} END {print total}')
    if [ -z "$usage" ]; then
        usage=0
    fi

    # Convert to GB for readability
    usage_gb=$(echo "scale=2; $usage / 1024 / 1024" | bc)
    soft_gb=$(echo "scale=2; $soft_limit / 1024 / 1024" | bc)
    hard_gb=$(echo "scale=2; $hard_limit / 1024 / 1024" | bc)

    # Log usage to file and display in terminal
    echo "$TIMESTAMP - $user usage: ${usage_gb}GB (Soft: ${soft_gb}GB, Hard: ${hard_gb}GB)" >> "$LOG_FILE"
    echo "$TIMESTAMP - $user usage: ${usage_gb}GB (Soft: ${soft_gb}GB, Hard: ${hard_gb}GB)"

    # Check limits
    if [ "$usage" -ge "$hard_limit" ]; then
        message="$TIMESTAMP - CRITICAL: $user exceeded hard limit (${usage_gb}GB > ${hard_gb}GB) on $SHARED_DIR"
        echo "$message" >> "$LOG_FILE"
        echo "$message"
        send_email "Quota Violation: $user" "$message on $(hostname)"
    elif [ "$usage" -ge "$soft_limit" ]; then
        message="$TIMESTAMP - WARNING: $user exceeded soft limit (${usage_gb}GB > ${soft_gb}GB) on $SHARED_DIR"
        echo "$message" >> "$LOG_FILE"
        echo "$message"
        send_email "Quota Warning: $user" "$message on $(hostname)"
    fi
}

# Check quotas for each user
check_quota "$DEV_LEAD1" $DEV_LEAD1_SOFT $DEV_LEAD1_HARD
check_quota "$OPS_LEAD1" $OPS_LEAD1_SOFT $OPS_LEAD1_HARD

exit 0