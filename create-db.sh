DB="${USER}db" 
CREATE_USER="CREATE USER \"${USER}\" WITH PASSWORD '${USER}'"
CREATE_DB="CREATE DATABASE \"${DB}\""
GRANT_DB="GRANT WRITE ON \"${DB}\" TO \"${USER}\""

echo $CREATE_USER

INFLUX_ADMIN_USER=admin
INFLUX_ADMIN_PASSWORD=admin

influx -execute "CREATE USER \"${INFLUX_ADMIN_USER}\" WITH PASSWORD '${INFLUX_ADMIN_PASSWORD}' WITH ALL PRIVILEGES"

#influx -execute "${CREATE_USER}" -username 'nat' -password ''
# ${CREATE_DB}; ${GRANT_DB}" -username 'nat' -password ''
