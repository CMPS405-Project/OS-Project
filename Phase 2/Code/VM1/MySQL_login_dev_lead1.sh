# #!/bin/bash

MYSQL_ROOT_USER="root"
MYSQL_ROOT_PASSWORD="12345678"  
DEV_USER="dev_lead1"
DEV_PASSWORD="12345678"         
DEV_DB="dev_database"
DEV_SQL="dev_lead1.sql"
DEV_AUTHEN_SQL="dev_lead1_authen.sql"
LOG_FILE="/var/log/mysql_audit.log"
echo " "
echo "Starting setup for $DEV_USER..."

mysql -u $MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD --batch --table -e "CREATE USER '$DEV_USER'@'localhost' IDENTIFIED BY '$DEV_PASSWORD'; 
GRANT ALL PRIVILEGES ON $DEV_DB.* TO '$DEV_USER'@'localhost';
FLUSH PRIVILEGES; 
\! echo 'User $DEV_USER created and privileges assigned successfully.'
\! echo 'Displaying all existing users: '
SELECT user, host FROM mysql.user; 
" 2> /dev/null 
echo " "
echo "Logging as $DEV_USER to verify authentication"
echo " "
mysql -u $DEV_USER -p$DEV_PASSWORD --batch --table -e "SELECT USER(), CURRENT_USER(), SESSION_USER(), @@hostname;" 2> /dev/null
echo "Authentication verified for $DEV_USER."
echo " "
echo "Listing databases and their tables for $DEV_USER..."
mysql -u $DEV_USER -p$DEV_PASSWORD --batch --table -e "select table_schema AS 'Database', table_name AS 'Table' from information_schema.tables;" 2> /dev/null

# Restart MySQL to apply changes
sudo systemctl restart mysql -p123

echo "Logging enabled for dev_lead1. Logs will be stored in $LOG_FILE."