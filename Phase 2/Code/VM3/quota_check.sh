#!/bin/bash


# Hostname or IP address of VM1
VM1_HOST="192.168.6.128"  # Replace with actual IP or hostname if needed

# Username on VM1 that VM3 can SSH into
VM1_USER="dev_lead1"  # Replace with correct SSH user

# Quota limits for dev_lead1
DEV_SOFT_LIMIT=$((5 * 1024 * 1024))  # 5 GB in KB
DEV_HARD_LIMIT=$((6 * 1024 * 1024))  # 6 GB in KB

# Quota limits for ops_lead1
OPS_SOFT_LIMIT=$((3 * 1024 * 1024))  # 3 GB in KB
OPS_HARD_LIMIT=$((4 * 1024 * 1024))  # 4 GB in KB

# Admin email to receive alerts
ADMIN_EMAIL="admin@qu.edu.qa"

# ----------------------------
# Function: Get disk usage in KB for a user on /shared (VM1)
# ----------------------------
get_usage_kb() {
    local user=$1
    echo "[+] Checking disk usage for $user on VM1..."
    ssh "$VM1_USER@$VM1_HOST" "find /shared -user $user -type f -exec du -k {} + 2>/dev/null | awk '{sum+=\$1} END {print sum}'"
}

# ----------------------------
# Function: Send email alert using local mail system
# ----------------------------
send_alert() {
    local user=$1
    local usage_kb=$2
    local soft_limit=$3
    local hard_limit=$4
    local alert_type=$5

    echo "[!] Sending $alert_type limit alert for $user..."

    mail -s "[Quota $alert_type Limit] $user exceeded $alert_type limit" "$ADMIN_EMAIL" <<EOF
User: $user
Usage: $((usage_kb / 1024)) MB
Soft Limit: $((soft_limit / 1024)) MB
Hard Limit: $((hard_limit / 1024)) MB
Alert Type: $alert_type
Checked from VM3 on: $(date)
EOF
}

# ----------------------------
# Simulated Quota Monitoring Logic
# ----------------------------

# Check usage for dev_lead1
usage_dev=$(get_usage_kb dev_lead1)
usage_dev=$(echo "$usage_dev" | grep -Eo '^[0-9]+' || echo 0)

if [[ $usage_dev -gt $DEV_SOFT_LIMIT && $usage_dev -le $DEV_HARD_LIMIT ]]; then
    echo "[!] WARNING: dev_lead1 has exceeded the soft limit of 5GB (usage: $((usage_dev / 1024)) MB)"
    send_alert dev_lead1 "$usage_dev" $DEV_SOFT_LIMIT $DEV_HARD_LIMIT "Soft"
elif [[ $usage_dev -gt $DEV_HARD_LIMIT ]]; then
    echo "[!] CRITICAL: dev_lead1 has exceeded the hard limit of 6GB (usage: $((usage_dev / 1024)) MB)"
    send_alert dev_lead1 "$usage_dev" $DEV_SOFT_LIMIT $DEV_HARD_LIMIT "Hard"
fi

# Check usage for ops_lead1
usage_ops=$(get_usage_kb ops_lead1)
usage_ops=$(echo "$usage_ops" | grep -Eo '^[0-9]+' || echo 0)

if [[ $usage_ops -gt $OPS_SOFT_LIMIT && $usage_ops -le $OPS_HARD_LIMIT ]]; then
    echo "[!] WARNING: ops_lead1 has exceeded the soft limit of 3GB (usage: $((usage_ops / 1024)) MB)"
    send_alert ops_lead1 "$usage_ops" $OPS_SOFT_LIMIT $OPS_HARD_LIMIT "Soft"
elif [[ $usage_ops -gt $OPS_HARD_LIMIT ]]; then
    echo "[!] CRITICAL: ops_lead1 has exceeded the hard limit of 4GB (usage: $((usage_ops / 1024)) MB)"
    send_alert ops_lead1 "$usage_ops" $OPS_SOFT_LIMIT $OPS_HARD_LIMIT "Hard"
fi

echo "[✓] Simulated quota check completed."

