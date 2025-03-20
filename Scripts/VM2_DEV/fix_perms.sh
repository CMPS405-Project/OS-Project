#!/bin/bash

LOGFILE="perm_changes.log"
SEARCH_PATH="/home/user"

# Create log file if it doesn't exist
touch "$LOGFILE"

# Check if we have write permission to log file
if [ ! -w "$LOGFILE" ]; then
    echo "Error: Cannot write to log file $LOGFILE"
    exit 1
fi

# Find files and pipe to while loop
find "$SEARCH_PATH" -type f -perm 777 | while read -r file; do
    chmod 700 "$file"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Changed permissions of $file from 777 to 700" >> "$LOGFILE"
done

echo "Permission changes complete. Check $LOGFILE for details."