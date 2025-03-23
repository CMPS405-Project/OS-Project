#!/bin/bash

serverIp="192.168.18.15"
maxAttempts=3
LOG_FILE="/home/vm2/invalid_attempts.log"  # Use absolute path
SOURCE_IP="192.168.18.18"  # VM2's IP (assumed)
VM1_USER="dev_lead1"  # Valid user on VM1

logInvalidAttempt() {
    local timestamp=$(date +"%F%H:%M:%S")
    echo "Invalid login attempt by $1 at $timestamp" >> "$LOG_FILE"
}

tryLogin() {
    ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=1 -o PubkeyAuthentication=no $1@$serverIp 2>>/dev/null
    if [[ $? -eq 0 ]]; then
        return 0
    else
        logInvalidAttempt $1
        return 1
    fi
}

# Function to check if an IP is already blocked
is_ip_blocked() {
    local ip=$1
    iptables -L INPUT -v -n | grep -q "$ip"
    return $?
}

# Function to block an IP using iptables
block_ip() {
    local ip=$1
    if ! is_ip_blocked "$ip"; then
        echo "Blocking IP $ip after $maxAttempts failed attempts" >> "$LOG_FILE"
        sudo iptables -A INPUT -s "$ip" -j DROP
        if [[ $? -eq 0 ]]; then
            echo "IP $ip has been blocked" >> "$LOG_FILE"
        else
            echo "Error: Failed to block IP $ip with iptables" >> "$LOG_FILE"
            return 1
        fi
    else
        echo "IP $ip is already blocked" >> "$LOG_FILE"
    fi
    return 0
}


main() {
    # Ensure script is run with sudo for iptables
    if [ "$(id -u)" -ne 0 ]; then
        echo "Error: This script must be run with sudo privileges to use iptables"
        exit 1
    fi

    attempts=0
    rm "$LOG_FILE" 2>>/dev/null
    rm "$TRANSFER_ERROR_LOG" 2>>/dev/null
    while [[ $attempts -lt $maxAttempts ]]; do
        read -p "Username: " username
        tryLogin $username
        if [[ $? -ne 0 ]]; then
            echo "Wrong password/username"
            ((attempts++))
        else
            echo "Access was granted"
            exit 0
        fi
    done
    echo "Unauthorized access!!"
    block_ip "$SOURCE_IP"
    # echo "You will be disconnected in 30 seconds...."
    # sleep 30
    # # Alternative logout method: kill the user's session
    # pkill -u $USER
}

main

