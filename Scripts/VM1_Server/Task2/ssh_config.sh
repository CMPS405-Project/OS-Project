

# # Log file to monitor (adjust based on your system)
# AUTH_LOG="/var/log/auth.log"

# # User to monitor
# MONITORED_USER="dev_lead1"

# # Temporary file to store already blocked IPs
# BLOCKED_IPS_FILE="/tmp/blocked_ips.txt"

# # Ensure the blocked IPs file exists
# touch "$BLOCKED_IPS_FILE"

# # Function to block an IP
# block_ip() {
#     local ip=$1

#     # Check if IP is already blocked
#     if grep -q "$ip" "$BLOCKED_IPS_FILE"; then
#         echo "IP $ip is already blocked."
#         return
#     fi

#     # Add a firewall rule to block the IP
#     echo "Blocking IP $ip..."
#     iptables -A INPUT -s "$ip" -j DROP

#     # Record the blocked IP
#     echo "$ip" >> "$BLOCKED_IPS_FILE"
# }

# # Monitor the log file for failed login attempts
# tail -Fn0 "$AUTH_LOG" | while read -r line; do
#     # Check for failed password attempts for the monitored user
#     if echo "$line" | grep -q "Failed password for $MONITORED_USER"; then
#         # Extract the IP address from the log line
#         ip=$(echo "$line" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")

#         # Block the IP
#         if [ -n "$ip" ]; then
#             block_ip "$ip"
#         else
#             echo "Could not extract IP from the log line: $line"
#         fi
#     fi
# done



# ---------------------------------------------------------------------------------------------------------------------------   



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
    > "$temp_file"  # Create a temporary file
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

    echo "Blocking IP $ip..."
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
    sudo usermod -L "$MONITORED_USER"
    echo "$MONITORED_USER" >> "$LOCKED_USER_FILE"
}
# Function to monitor failed login attempts
monitor_logins() {
    tail -Fn0 "$AUTH_LOG" | while read -r line; do
        if echo "$line" | grep -q "Failed password for $MONITORED_USER"; then
            ip=$(echo "$line" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
            
            if [ -n "$ip" ]; then
                block_ip "$ip"

                # Count failed attempts in the last 10 lines
                failed_attempts=$(grep -E "Failed password.*$MONITORED_USER" "$AUTH_LOG" | tail -n 10 | wc -l)

                if (( failed_attempts >= 5 )); then
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
