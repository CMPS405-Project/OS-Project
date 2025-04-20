# #!/bin/bash

MYSQL_ROOT_USER="root"
MYSQL_ROOT_PASSWORD="12345678"  
OPS_USER="ops_lead1"
OPS_PASSWORD="12345678"         
OPS_DB="ops_database"
OPS_SQL="ops_lead1.sql"
OPS_AUTHEN_SQL="ops_lead1_authen.sql"
LOG_FILE="/var/log/mysql_audit.log"
echo " "
echo "Starting setup for $OPS_USER..."

mysql -u $MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD --batch --table -e "CREATE USER '$OPS_USER'@'localhost' IDENTIFIED BY '$OPS_PASSWORD'; 
GRANT ALL PRIVILEGES ON $OPS_DB.* TO '$OPS_USER'@'localhost';
FLUSH PRIVILEGES; 
\! echo 'User $OPS_USER created and privileges assigned successfully.'
\! echo 'Displaying all existing users: '
SELECT user, host FROM mysql.user; 
" 2> /dev/null 
echo " "
echo "Logging as $OPS_USER to verify authentication"
echo " "
mysql -u $OPS_USER -p$OPS_PASSWORD --batch --table -e "SELECT USER(), CURRENT_USER(), SESSION_USER(), @@hostname;" 2> /dev/null
echo "Authentication verified for $OPS_USER."
echo " "
echo "Listing databases and their tables for $OPS_USER..."
mysql -u $OPS_USER -p$OPS_PASSWORD --batch --table -e "select table_schema AS 'Database', table_name AS 'Table' from information_schema.tables;" 2> /dev/null

# Restart MySQL to apply changes
sudo systemctl restart mysql -p123

echo "Logging enabled. Logs will be stored in $LOG_FILE."