DB="${USER}_db" 
CREATE_USER="CREATE USER \"${USER}\" WITH PASSWORD '${USER}'"
CREATE_DB="CREATE DATABASE \"${DB}\""
GRANT_DB="GRANT WRITE ON \"${DB}\" TO \"${USER}\""
echo $CREATE_USER

influx -execute "${CREATE_USER}; ${CREATE_DB}; ${GRANT_DB}" -username 'nat' -password ''
#influx -execute "${CREATE_USER}" -username 'nat' -password ''
# ${CREATE_DB}; ${GRANT_DB}" -username 'nat' -password ''
