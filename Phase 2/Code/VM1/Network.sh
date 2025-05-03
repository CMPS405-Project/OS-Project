#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <Client1VM_IP> <Client2VM_IP>"
    exit 1
fi

Client1VM_IP="$1"
Client2VM_IP="$2"
DIRECTORY="PingDirectory"
OUTPUT_FILE="TimeStamp.txt"
BASE_PATH="$HOME/CMPS405_Project/VM1_Server/$DIRECTORY"

mkdir -p "$BASE_PATH"

(
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

    echo "Ping results at $TIMESTAMP" >> "$BASE_PATH/$OUTPUT_FILE"
    echo "---------------------------------------------------------" >> "$BASE_PATH/$OUTPUT_FILE"

    ping -c 10 -s 500 -i 10 "$Client1VM_IP" >> "$BASE_PATH/$OUTPUT_FILE"

    echo "------------------------" >> "$BASE_PATH/$OUTPUT_FILE"

    ping -c 10 -s 500 -i 10 "$Client2VM_IP" >> "$BASE_PATH/$OUTPUT_FILE"

    echo "---------------------------------------------------------" >> "$BASE_PATH/$OUTPUT_FILE"

    chmod 600 "$BASE_PATH/$OUTPUT_FILE"
) &

echo "Script is running in the background. Results will be saved to $BASE_PATH/$OUTPUT_FILE"