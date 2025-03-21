# #!/bin/bash

MYSQL_ROOT_USER="root"
MYSQL_ROOT_PASSWORD="12345678"  
DEV_USER="dev_lead1"
DEV_PASSWORD="12345678"         
DEV_DB="dev_database"
DEV_SQL="dev_lead1.sql"
DEV_AUTHEN_SQL="dev_lead1_authen.sql"
LOG_FILE="/var/log/mysql_audit.log"

echo "Starting setup for $DEV_USER..."

mysql -u $MYSQL_ROOT_USER "-p$MYSQL_ROOT_PASSWORD" < "$DEV_SQL" 2> /dev/null # log in as root and run the sql script
echo " Logging as $OPS_USER"
echo " "
mysql -u $DEV_USER "-p$DEV_PASSWORD" 2>/dev/null < "$DEV_AUTHEN_SQL" 2> /dev/null # log in as root and run the sql script

# mysql -u $MYSQL_ROOT_USER "-p$MYSQL_ROOT_PASSWORD" -e "
# INSTALL PLUGIN audit_log SONAME 'audit_log.so';
# SET GLOBAL audit_log_policy = 'ALL'; " 2> /dev/null
# sudo bash -c "echo '[mysqld]' >> /etc/mysql/my.cnf"
# sudo bash -c "echo 'audit_log_file=$LOG_FILE' >> /etc/mysql/my.cnf"

# Ensure the LOG_FILE path is correct
sudo touch "$LOG_FILE"
sudo chmod 664 "$LOG_FILE"
sudo chown mysql:mysql "$LOG_FILE"

# Restart MySQL to apply changes
sudo systemctl restart mysql

echo "Logging enabled. Logs will be stored in $LOG_FILE."