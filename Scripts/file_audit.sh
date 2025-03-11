# #!/bin/bash

# # Directory to monitor
# WATCH_DIR="/projects/development"

# # Log file
# LOG_FILE="/var/log/file_changes.log"

# # Ensure log file exists
# touch "$LOG_FILE"

# # Monitor changes and log them
# inotifywait -m -r -e create,modify,delete --format '%e %w%f' "$WATCH_DIR" | while read EVENT FILE
# do
#     # Get current user
#     USER=$(whoami)

#     # Log the change
#     echo "$(date '+%Y-%m-%d %H:%M:%S') | User: $USER | Action: $EVENT | File: $FILE" >> "$LOG_FILE"
# done


#!/bin/bash

# Path to the log file where file activity will be recorded
LOG_FILE="/var/log/file_changes.log"

# Directory to monitor for file changes
MONITOR_DIR="/projects/development/"

# Ensure the log file exists (creates an empty file if it doesn't)
touch "$LOG_FILE"

# Start monitoring the directory recursively (-r) for create, modify, and delete events (-e create -e modify -e delete)
# Format: timestamp, watched directory, filename, and event type.
inotifywait -m -r -e create -e modify -e delete --format '%T %w %f %e' --timefmt '%Y-%m-%d %H:%M:%S' "$MONITOR_DIR" | while read TIMESTAMP DIR FILE EVENT; do
    # Construct the full path of the affected file
    FULL_PATH="${DIR}${FILE}"
    
    # Attempt to get the file owner using 'stat'
    if [ -e "$FULL_PATH" ]; then
        OWNER=$(stat -c '%U' "$FULL_PATH")
    else
        OWNER="N/A"
    fi
    
    # Log the event details to the log file
    echo "[$TIMESTAMP] - User: $OWNER, Event: $EVENT, File: $FULL_PATH" >> "$LOG_FILE"
done
