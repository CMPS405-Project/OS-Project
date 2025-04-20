#!/bin/bash
Client1VM_IP=192.168.83.129 
DIRECTORY="PingDirectory"
OUTPUT_FILE="TimeStamp.txt"
Client2VM_IP=192.168.83.130

mkdir -p ~/"$DIRECTORY"

# Get the current timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Append the timestamp and a header to the output file
echo "Ping results at $TIMESTAMP" >> ~/$DIRECTORY/$OUTPUT_FILE
echo "---------------------------------------------------------" >> ~/$DIRECTORY/$OUTPUT_FILE
# Ping Client1VM and append results
ping -c 10 -s 500 -i 10 $Client1VM_IP >> ~/$DIRECTORY/$OUTPUT_FILE

echo "------------------------" >> ~/$DIRECTORY/$OUTPUT_FILE

# Ping Client2VM and append results
ping -c 10 -s 500 -i 10 $Client2VM_IP >> ~/$DIRECTORY/$OUTPUT_FILE

echo "---------------------------------------------------------" >> ~/$DIRECTORY/$OUTPUT_FILE

# Set permissions to read/write for owner only
chmod 600 ~/$DIRECTORY/$OUTPUT_FILE