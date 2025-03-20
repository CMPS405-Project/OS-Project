CREATE USER 'dev_lead1'@'localhost' IDENTIFIED BY '12345678';       -- Creating dev_lead1 user with password 12345678
GRANT ALL PRIVILEGES ON dev_database.* TO 'dev_lead1'@'localhost';  -- Give all Privileges on dev_database to dev_lead1 user
FLUSH PRIVILEGES;                                                   -- reload the privileges granted to users without restarting the database server.
\! echo " "
\! echo 'Displaying all existing users: '
SELECT user, host FROM mysql.user;                                  -- retrieve the username (user) and host (host) for the user 'dev_lead1'.
\! echo " "
\! echo 'User dev_lead1 created and privileges assigned successfully.'; -- just printing message
\! echo " "
\! echo " "
\! echo 'Verifying authentication for dev_lead1...';
\! echo " "

