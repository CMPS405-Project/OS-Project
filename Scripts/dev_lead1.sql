CREATE USER 'dev_lead1'@'localhost' IDENTIFIED BY '12345678';
GRANT ALL PRIVILEGES ON dev_database.* TO 'dev_lead1'@'localhost';
FLUSH PRIVILEGES;
SELECT user, host FROM mysql.user WHERE user = 'dev_lead1';
\! echo 'User dev_lead1 created and privileges assigned successfully.';
\! echo " "
\! echo " "
\! echo 'Verifying authentication for dev_lead1...';
\! echo " "

