SELECT USER(), CURRENT_USER(), SESSION_USER(), @@hostname; -- retrieves information about the current session and MySQL server instance
\! echo " "
\! echo "Authentication verified for dev_lead1."
\! echo " "
\! echo "Listing databases for dev_lead1..."
\! echo " "

SHOW databases;     -- display all the databases that is accessed to this user

\! echo " "
\! echo "Listing Tables for dev_lead1..."
\! echo " "

select table_schema AS "Database", table_name AS "Table" from information_schema.tables;    --display all the databases and their tables that is accessed to this user

