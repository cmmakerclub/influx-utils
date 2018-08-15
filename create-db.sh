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

    influx -execute "SHOW DATABASES" -username "${INFLUX_ADMIN_USER}" -password "${INFLUX_ADMIN_PASSWORD}"
    if [ $? -eq 0 ]; then
        unset INFLUX_ACCOUNT
        while [ -z ${INFLUX_ACCOUNT} ]; do
             read -r -p "Enter INFLUX_ACCOUNT DB NAME : " INFLUX_ACCOUNT
        done
        DB="${INFLUX_ACCOUNT}db"
        CREATE_USER="CREATE USER \"${INFLUX_ACCOUNT}\" WITH PASSWORD '${INFLUX_ACCOUNT}'"
        CREATE_DB="CREATE DATABASE \"${DB}\""
        GRANT_DB="GRANT READ ON \"${DB}\" TO \"${INFLUX_ACCOUNT}\""
    	influx -execute "${CREATE_USER}; ${CREATE_DB}; ${GRANT_DB}" -username "${INFLUX_ADMIN_USER}" -password "${INFLUX_ADMIN_PASSWORD}"
        influx -execute "SHOW DATABASES" -username "${INFLUX_ADMIN_USER}" -password "${INFLUX_ADMIN_PASSWORD}"
        break;
    fi
    
  
done
