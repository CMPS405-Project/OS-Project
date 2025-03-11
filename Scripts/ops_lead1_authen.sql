SELECT USER(), CURRENT_USER(), SESSION_USER(), @@hostname;
\! echo " "
\! echo "Authentication verified for ops_lead1."
\! echo " "
\! echo "Listing databases for ops_lead1..."
\! echo " "

SHOW databases;

\! echo " "
\! echo "Listing Tables for ops_lead1..."
\! echo " "

select table_schema AS "Database", table_name AS "Table" from information_schema.tables
WHERE table_schema not in("information_schema","performance_schema");


