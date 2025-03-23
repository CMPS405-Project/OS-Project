#!/bin/bash
# Log file to monitor
AUTH_LOG="/var/log/auth.log"  
# User to monitor
MONITORED_USER="dev_lead1"
# File to store blocked IPs
BLOCKED_IPS_FILE="/tmp/blocked_ips.txt"
# File to track lock status of user
LOCKED_USER_FILE="/tmp/locked_users.txt"
# Time to unblock IPs (24 hours)
UNBLOCK_TIME=86400  # 24 hours in seconds
# Ensure necessary files exist
touch "$BLOCKED_IPS_FILE" "$LOCKED_USER_FILE"
# Function to unblock IPs after 24 hours
unblock_old_ips() {
    local temp_file="/tmp/temp_ips.txt"
    touch "$temp_file"  # Create a temporary file
    # Handle empty file case
    if [ -s "$BLOCKED_IPS_FILE" ]; then
        while read -r line; do
            ip=$(echo "$line" | awk '{print $1}')
            timestamp=$(echo "$line" | awk '{print $2}')
            current_time=$(date +%s)
            if (( current_time - timestamp >= UNBLOCK_TIME )); then
                echo "Unblocking IP $ip..."
                iptables -D INPUT -s "$ip" -j DROP
            else
                echo "$ip $timestamp" >> "$temp_file"
            fi
        done < "$BLOCKED_IPS_FILE"
    fi
    mv "$temp_file" "$BLOCKED_IPS_FILE"
}
# Function to block an IP
block_ip() {
    local ip=$1
    local current_time=$(date +%s)
    if grep -q "$ip" "$BLOCKED_IPS_FILE"; then
        echo "IP $ip is already blocked."
        return
    fi
    echo -e "\nBlocking IP $ip..."
    iptables -A INPUT -s "$ip" -j DROP
    echo "$ip $current_time" >> "$BLOCKED_IPS_FILE"
}
# Function to lock the user account
lock_user() {
    if grep -q "$MONITORED_USER" "$LOCKED_USER_FILE"; then
        echo "User $MONITORED_USER is already locked."
        return
    fi
    echo "Locking user $MONITORED_USER due to repeated failed attempts..."  
    usermod -L "$MONITORED_USER"
    echo "$MONITORED_USER" >> "$LOCKED_USER_FILE"
}
# Function to monitor failed login attempts
monitor_logins() {
    # Check if log file exists and is readable
    if [ ! -r "$AUTH_LOG" ]; then
        echo "Error: Cannot read $AUTH_LOG. Make sure the file exists and you have permissions to read it."
        exit 1
    fi
    
    echo "Starting to monitor $AUTH_LOG for failed logins..."
    tail -Fn0 "$AUTH_LOG" | while read -r line; do
        echo "Read line: $line"
        if echo "$line" | grep -q "Failed password for $MONITORED_USER"; then
            echo "Detected failed login attempt for $MONITORED_USER"
            ip=$(echo "$line" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
            
            if [ -n "$ip" ]; then
                echo "Extracted IP: $ip"
                block_ip "$ip"
                # Count failed attempts in the last 10 lines
                failed_attempts=$(grep -E "Failed password.*$MONITORED_USER" "$AUTH_LOG" | tail -n 10 | wc -l)
                echo "Failed attempts in last 10 lines: $failed_attempts"
                if [ $failed_attempts -ge 5 ]; then
                    lock_user
                fi
            else
                echo "Could not extract IP from log: $line"
            fi
        fi
    done
}
# Run the functions
unblock_old_ips
monitor_logins