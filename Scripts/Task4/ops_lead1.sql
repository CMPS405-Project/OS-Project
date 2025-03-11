CREATE USER 'ops_lead1'@'localhost' IDENTIFIED BY '12345678';
GRANT ALL PRIVILEGES ON ops_database.* TO 'ops_lead1'@'localhost';
FLUSH PRIVILEGES;
SELECT user, host FROM mysql.user WHERE user = 'ops_lead1';
\! echo 'User ops_lead1 created and privileges assigned successfully.';
\! echo " "
\! echo " "
\! echo 'Verifying authentication for ops_lead1...';
\! echo " "

