#!/bin/bash
LOGFILE="perm_changes.log" #name of log file
SEARCH_PATH="$HOME" #the path to search is the home directory
touch "$LOGFILE" #create the log file
if [ ! -w "$LOGFILE" ]; then ##this is used to check if we have the permission to write to the logfile
    echo "Error: Cannot write to log file $LOGFILE"
    exit 1
fi
find "$SEARCH_PATH" -type f -perm 777 | while read -r file; do #this iterates over all files and check if their permission is 777
    chmod 700 "$file" #this changes the file permission to 700
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Changed permissions of $file from 777 to 700" >> "$LOGFILE" #this sends the modification details to the log file
done
echo "Permission changes complete. Check $LOGFILE for details." #just a print statement that tells the user that the script has been executed successfully

