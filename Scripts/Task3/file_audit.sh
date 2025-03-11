#!/bin/bash

MONITOR_DIR="/projects/development/"
LOG_FILE="/var/log/file_changes.log"

echo "Monitoring $MONITOR_DIR for changes..." | tee -a "$LOG_FILE"

inotifywait -m -r -e create,modify,delete,move "$MONITOR_DIR" | while read event
do
    echo "$event" >> "$LOG_FILE"
done