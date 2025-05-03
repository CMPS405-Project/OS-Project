#!/bin/bash

# Script to clear previous runs of monitor_auth.sh

# Define variables
AUTH_LOG="/var/log/auth.log"
BLOCKED_IPS_FILE="/tmp/blocked_ips.txt"
LOCKED_USER_FILE="/tmp/locked_users.txt"
RECENT_FAILS_FILE="/tmp/recent_fails.txt"
TEMP_IPS_FILE="/tmp/temp_ips.txt"
TEMP_FAILS_FILE="/tmp/temp_fails.txt"
MONITORED_USER="dev_lead1"

# Function to check status
check_status() {
    if [ $? -ne 0 ]; then
        echo "❌ Error: $1 failed."
        exit 1
    else
        echo "✅ $1 succeeded."
    fi
}

echo "🚨 Starting cleanup of monitor_auth.sh state..."

# Step 1: Prompt user to stop script
echo "Please stop any running monitor_auth.sh script (Ctrl+C if in terminal)."
read -rp "Press Enter to continue once the script is stopped..."

# Step 2: Remove temporary state files
echo "🧹 Removing temporary files..."
rm -f "$BLOCKED_IPS_FILE" "$LOCKED_USER_FILE" "$RECENT_FAILS_FILE" "$TEMP_IPS_FILE" "$TEMP_FAILS_FILE"
check_status "Temporary file removal"

# Step 3: Clear iptables INPUT rules (only DROP rules for safety)
echo "🛡️ Clearing DROP rules in iptables INPUT chain..."
sudo iptables -D INPUT -s 192.168.6.129 -j DROP
check_status "iptables DROP rules removal"
sudo truncate -s 0 /var/log/auth.log
# Optional: Flush entire INPUT chain (uncomment if needed)
# iptables -F INPUT
# check_status "iptables INPUT chain flush"

# Step 4: Unlock the user if locked
echo "🔓 Unlocking user $MONITORED_USER..."
if passwd -S "$MONITORED_USER" | grep -q 'L'; then
    usermod -U "$MONITORED_USER"
    check_status "User unlock"
else
    echo "ℹ️ User $MONITORED_USER is already unlocked."
fi

echo "✅ Cleanup complete. Ready for a fresh run."
