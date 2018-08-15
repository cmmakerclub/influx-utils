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

    influx -execute "SHOW DATABASES" -username "${INFLUX_ADMIN_USER}" -password "${INFLUX_ADMIN_PASSWORD}"

    if [ $? -eq 0 ]; then
        break
    fi
done
