#!/bin/bash

# Configuration
SHARED_DIR="/shared"
ADMIN_EMAIL="admin@qu.edu.qa"
LOGFILE="/var/log/quota_monitor.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Quota limits (in KB for setquota compatibility)
# 5GB = 5,242,880 KB, 6GB = 6,291,456 KB
DEV_LEAD1_HARD=$((5 * 1024 * 1024))      # 5GB in KB
DEV_LEAD1_SOFT=$((6 * 1024 * 1024))      # 6GB in KB
# 3GB = 3,145,728 KB, 4GB = 4,194,304 KB
OPS_LEAD1_HARD=$((3 * 1024 * 1024))      # 3GB in KB
OPS_LEAD1_SOFT=$((4 * 1024 * 1024))      # 4GB in KB

# Users
DEV_LEAD1="dev_lead1"
OPS_LEAD1="ops_lead1"

# Ensure log file exists
touch "$LOGFILE" 2>/dev/null || { echo "Error: Cannot create log file"; exit 1; }
[ -w "$LOGFILE" ] || { echo "Error: Cannot write to log file"; exit 1; }

# Function to send email
send_email() {
    local subject="$1"
    local message="$2"
    echo "$message" | mail -s "$subject" "$ADMIN_EMAIL"
}

# Check if quota tools are installed
if ! command -v setquota &> /dev/null; then
    echo "$TIMESTAMP - Error: quota tools not installed" >> "$LOGFILE"
    send_email "Quota Monitoring Error" "Quota tools not installed on $(hostname)"
    exit 1
fi

# Check if /shared exists
if [ ! -d "$SHARED_DIR" ]; then
    echo "$TIMESTAMP - Error: $SHARED_DIR does not exist" >> "$LOGFILE"
    send_email "Quota Monitoring Error" "$SHARED_DIR does not exist on $(hostname)"
    exit 1
fi

# Set quotas (block limits only, no inode limits)
setquota -u "$DEV_LEAD1" $DEV_LEAD1_SOFT $DEV_LEAD1_HARD 0 0 "$SHARED_DIR" 2>>"$LOGFILE"
setquota -u "$OPS_LEAD1" $OPS_LEAD1_SOFT $OPS_LEAD1_HARD 0 0 "$SHARED_DIR" 2>>"$LOGFILE"

# Check disk usage
echo "$TIMESTAMP - Disk Usage Check for $SHARED_DIR" >> "$LOGFILE"
du -sh "$SHARED_DIR" >> "$LOGFILE" 2>/dev/null

# Check quota usage with repquota
echo "Checking quotas..." >> "$LOGFILE"
repquota -u "$SHARED_DIR" > /tmp/quota_report 2>/dev/null

# Function to check user quota
check_quota() {
    local user="$1"
    local soft_limit="$2"  # in KB
    local hard_limit="$3"  # in KB
    
    # Extract usage (in KB) from repquota output
    usage=$(grep "^$user " /tmp/quota_report | awk '{print $3}')
    if [ -z "$usage" ]; then
        echo "$TIMESTAMP - No quota data for $user" >> "$LOGFILE"
        return
    }

    # Convert to GB for readability
    usage_gb=$(echo "scale=2; $usage / 1024 / 1024" | bc)
    soft_gb=$(echo "scale=2; $soft_limit / 1024 / 1024" | bc)
    hard_gb=$(echo "scale=2; $hard_limit / 1024 / 1024" | bc)

    echo "$TIMESTAMP - $user usage: ${usage_gb}GB (Soft: ${soft_gb}GB, Hard: ${hard_gb}GB)" >> "$LOGFILE"

    # Check if soft limit exceeded
    if [ "$usage" -ge "$soft_limit" ]; then
        message="$TIMESTAMP - WARNING: $user exceeded soft limit (${usage_gb}GB > ${soft_gb}GB) on $SHARED_DIR"
        echo "$message" >> "$LOGFILE"
        send_email "Quota Warning: $user" "$message on $(hostname)"
    fi

    # Check if hard limit exceeded (should be enforced by system, but alert anyway)
    if [ "$usage" -ge "$hard_limit" ]; then
        message="$TIMESTAMP - CRITICAL: $user exceeded hard limit (${usage_gb}GB > ${hard_gb}GB) on $SHARED_DIR"
        echo "$message" >> "$LOGFILE"
        send_email "Quota Violation: $user" "$message on $(hostname)"
    fi