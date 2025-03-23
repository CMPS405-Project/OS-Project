#!/bin/bash

# Script: login_audit.sh
# Purpose: Monitor invalid SSH login attempts to VM1, log them, and block IPs after 3 failed attempts using iptables

# Define variables
LOG_FILE="/var/log/invalid_attempts.log"  # As per project requirement
VM1_IP="192.168.x.x"  # Replace with VM1's IP address
PRIVATE_KEY="/path/to/private_key"  # Replace with path to dev_lead1's private key
THRESHOLD=3  # Number of failed attempts before blocking

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

# Check if iptables is installed
if ! command -v iptables &> /dev/null; then
    log_message "ERROR: iptables not found. Please install iptables."
    exit 1
fi

# Check if ssh is installed
if ! command -v ssh &> /dev/null; then
    log_message "ERROR: ssh not found. Please install openssh-client."
    exit 1
fi

# Set up iptables rules
log_message "Setting up iptables rules..."
# 1. Allow established and related connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# 2. Track SSH attempts using the 'recent' module
iptables -A INPUT -p tcp --dport 22 -m recent --set --name sshblock --rsource
# 3. Block IPs that exceed 3 attempts in 60 seconds (hitcount 4 means block on 4th attempt)
iptables -A INPUT -p tcp --dport 22 -m recent --update --seconds 60 --hitcount 4 --name sshblock --rsource -j DROP
# 4. Allow other SSH traffic
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
# 5. (Optional) Drop all other incoming traffic not explicitly allowed
iptables -P INPUT DROP
# Save rules for persistence
iptables-save > /etc/iptables/rules.v4
log_message "iptables rules configured and saved."

# Monitor SSH logs from VM1
log_message "Starting SSH login attempt monitoring..."
ssh -i "$PRIVATE_KEY" dev_lead1@"$VM1_IP" "sudo tail -Fn0 /var/log/auth.log" 2>>"$LOG_FILE" | while read -r line; do
    if echo "$line" | grep -qi "invalid\|failed"; then
        # Extract IP address from the log line
        IP=$(echo "$line" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
        if [ -n "$IP" ]; then
            log_message "Invalid SSH attempt from IP: $IP"
            # Note: Blocking is handled by iptables 'recent' module
        fi
    fi
done

# Exit cleanly
exit 0