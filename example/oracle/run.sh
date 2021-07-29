SQL_FILENAME=run.sql
CSV_PATH=/usr/local/sqlcl/
CSV_FILENAME=export12321.csv
URI=orcl_user/password1@oracledb-ee/ORCLPDB1

echo "Connecting and loading SQL script"

# sqlcl <connection-uri> <path-to-sql-script> <path-to-exported-file>
sqlcl $URI @$SQLPATH/$SQL_FILENAME $SQLPATH/$CSV_FILENAME

# Capture the exit code from the sql script above
EXITCODE=$?

echo "Completing with exit code $EXITCODE"

if [ $EXITCODE -ne 0 ]; then
    rm $SQLPATH/$CSV_FILENAME;
    exit $EXITCODE;
fi