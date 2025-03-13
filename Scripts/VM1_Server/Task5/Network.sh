#!/bin/bash

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DIRECTORY="PingDirectory"
mkdir  ~/"$DIRECTORY"

`ping -c 10 -s 500 -i 10 Client1VM_IP` >> ~/$DIRECTORY/$TIMESTAMP.txt
`ping -c 10 -s 500 -i 10 Client2VM_IP` >> ~/$DIRECTORY/$TIMESTAMP.txt
chmod 600 /$DIRECTORY/$TIMESTAMP.txt