DB="${USER}db" 
CREATE_USER="CREATE USER \"${USER}\" WITH PASSWORD '${USER}'"
CREATE_DB="CREATE DATABASE \"${DB}\""
GRANT_DB="GRANT WRITE ON \"${DB}\" TO \"${USER}\"" 
echo $CREATE_USER

INFLUX_ADMIN_USER=admin
INFLUX_ADMIN_PASSWORD=admin

echo "enter 'q' to 'exit'"
while true; do
    read -r -p "Enter INFLUX_ADMIN_USER: " INFLUX_ADMIN_USER
    if [[ $INFLUX_ADMIN_USER = 'q' ]]; then
      break;
    fi 

    read -r -p "Enter INFLUX_ADMIN_PASSWORD: " INFLUX_ADMIN_PASSWORD
    if [[ $INFLUX_ADMIN_PASSWORD = 'q' ]]; then
      break;
    fi 

    #declare -r INFLUX_ADMIN_USER="${INFLUX_ADMIN_USER:-""}"
    #declare -r INFLUX_ADMIN_PASSWO="${INFLUX_ADMIN_USER:-""}"
    influx -execute "SHOW DATABASES" -username "${INFLUX_ADMIN_USER}" -password "${INFLUX_PASSWORD}"
    # -execute "CREATE USER \"${INFLUX_ADMIN_USER}\" WITH PASSWORD '${INFLUX_ADMIN_PASSWORD}' WITH ALL PRIVILEGES"
    if [ $? -eq 0 ]; then
        break
    fi
done
#influx -execute "${CREATE_USER}" -username 'nat' -password ''
# ${CREATE_DB}; ${GRANT_DB}" -username 'nat' -password ''
