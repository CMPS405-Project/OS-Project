#!/bin/bash

# Directory to monitor for file changes
MONITOR_DIR="/projects/development/"

# Log file to store detected file change events
LOG_FILE="/var/log/file_changes.log"

# Print a message indicating the monitoring has started and log it
echo "Monitoring $MONITOR_DIR for changes..." | sudo tee -a "$LOG_FILE"

# Use inotifywait to monitor the directory for specific events
# -m: Monitor continuously (keeps running)
# -r: Recursively watch all subdirectories
# -e: Specifies the types of events to watch (create, modify, delete, move)
inotifywait -m -r -e create,modify,delete,move "$MONITOR_DIR" | while read -r event
do
    # Append each detected event to the log file
    echo "$event" >> "$LOG_FILE"
done


