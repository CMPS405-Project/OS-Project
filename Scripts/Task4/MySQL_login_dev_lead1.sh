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

mysql -u $MYSQL_ROOT_USER "-p$MYSQL_ROOT_PASSWORD" < "$DEV_SQL" 2> /dev/null
mysql -u $DEV_USER "-p$DEV_PASSWORD" 2>/dev/null < "$DEV_AUTHEN_SQL" 2> /dev/null


# Ensure the LOG_FILE path is correct
sudo touch "$LOG_FILE"
sudo chmod 664 "$LOG_FILE"
sudo chown mysql:mysql "$LOG_FILE"

# Modify MySQL configuration
sudo sed -i 's/^general_log.*/general_log = 1/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i 's|^general_log_file.*|general_log_file = '"$LOG_FILE"'|' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i 's/^log_output.*/log_output = FILE/' /etc/mysql/mysql.conf.d/mysqld.cnf

# If parameters don't exist, append them
grep -q "general_log" /etc/mysql/mysql.conf.d/mysqld.cnf || echo -e "\ngeneral_log = 1" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
grep -q "general_log_file" /etc/mysql/mysql.conf.d/mysqld.cnf || echo -e "\ngeneral_log_file = $LOG_FILE" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
grep -q "log_output" /etc/mysql/mysql.conf.d/mysqld.cnf || echo -e "\nlog_output = FILE" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf

# Restart MySQL to apply changes
sudo systemctl restart mysql

echo "Logging enabled. Logs will be stored in $LOG_FILE."