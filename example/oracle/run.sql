SET SQLFORMAT CSV
SET TERMOUT OFF
WHENEVER OSERROR EXIT FAILURE
WHENEVER SQLERROR EXIT SQL.SQLCODE
-- Passed in via first arg from run.sh
SPOOL &1

SELECT * FROM POST;

SPOOL OFF

EXIT