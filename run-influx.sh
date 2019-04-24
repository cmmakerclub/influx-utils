#!/bin/bash

VERSION=1.0.4
DEFAULT_INFLUX_ADMIN_USER=admin
DEFAULT_INFLUX_TELEGRAF_USER=telegraf

usage() {
        cat <<EOF
$0 v$VERSION
Usage: $0 [setup|create-db|run-grafana|--help]
EOF
        exit 1
}

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}


setup() {
        cat <<EOF
$0 v$VERSION
EOF
  if [ -z "$CONTAINER_NAME" ]; then
       read -r -p "Enter CONTAINER_NAME (influxdb): " CONTAINER_NAME
       if [ -z "$CONTAINER_NAME" ]; then
          CONTAINER_NAME=influxdb
       fi
       #docker inspect $CONTAINER_NAME 2> /dev/null
       #echo $?
  fi

  ROOT_DIR="${ROOT_DIR:-$HOME/tick/influxdb}"
  DATA_PATH="${DATA_PATH:-${ROOT_DIR}/data}"
  INFLUX_PORT="${INFLUX_PORT:-8086}"
  INFLUXDB_BIND_ADDRESS="${INFLUXDB_BIND_ADDRESS:-8088}"
  INFLUX_CONF="${INFLUX_CONF:-$ROOT_DIR/influxdb.conf}"
  DOCKER_NETWORK="${DOCKER_NETWORK:-host}"

  echo "CONTAINER_NAME=$CONTAINER_NAME" echo "ROOT_DIR=$ROOT_DIR"
  echo "DATA_PATH=$DATA_PATH"
  echo "INFLUX_CONF=$INFLUX_CONF"
  echo "INFLUX_PORT=$INFLUX_PORT"
  echo "INFLUXDB_BIND_ADDRESS=$INFLUXDB_BIND_ADDRESS"
  echo "DOCKER_NETWORK=$DOCKER_NETWORK"

  if confirm ;then
    mkdir -p $DATA_PATH
    echo "data/" > "$ROOT_DIR/.gitignore"
    echo "meta/" >> "$ROOT_DIR/.gitignore"
    docker run --rm influxdb influxd config > $INFLUX_CONF
    sed -Ei "s/auth-enabled = false/auth-enabled = true/g" $INFLUX_CONF
    docker run \
          -v $DATA_PATH:/var/lib/influxdb \
          -v $INFLUX_CONF:/etc/influxdb/influxdb.conf:ro \
          --restart always \
          --net ${DOCKER_NETWORK}\
          -p $INFLUX_PORT:8086 \
          -p $INFLUXDB_BIND_ADDRESS:8088 \
          -d \
          --name "${CONTAINER_NAME}" \
          influxdb -config /etc/influxdb/influxdb.conf

          if [ $? -ne 0 ]; then
            echo "setup failed."
            exit -1
          fi

          hash influx &> /dev/null
          if [ $? -eq 1 ]; then
              sudo apt-get install -y influxdb-client
          fi

          INFLUX_ADMIN_USER=$DEFAULT_INFLUX_ADMIN_USER
          INFLUX_TELEGRAF_USER=$DEFAULT_INFLUX_TELEGRAF_USER

          read -r -p "Enter INFLUX_ADMIN_USER (admin): " INFLUX_ADMIN_USER
          INFLUX_ADMIN_USER="${INFLUX_ADMIN_USER:-admin}"

          unset INFLUX_ADMIN_PASSWORD
          while [ -z ${INFLUX_ADMIN_PASSWORD} ]; do
               read -r -p "Enter INFLUX_ADMIN_PASSWORD: " INFLUX_ADMIN_PASSWORD
          done

          echo "INFLUX_ADMIN_USER=$INFLUX_ADMIN_USER"
          echo "INFLUX_ADMIN_PASSWORD=$INFLUX_ADMIN_PASSWORD" 

          influx -execute "CREATE USER \"${INFLUX_ADMIN_USER}\" WITH PASSWORD '${INFLUX_ADMIN_PASSWORD}' WITH ALL PRIVILEGES"
          if [ $? -eq 0 ]; then
            echo "done create admin user"
          fi
  fi
}

create_user() {
    local dbname=$1
    echo "enter 'q' to 'exit'"
    while true; do
        read -r -p "Enter INFLUX_ADMIN_USER: " INFLUX_ADMIN_USER
        if [[ $INFLUX_ADMIN_USER = 'q' ]]; then
          exit;
        fi

        read -r -p "Enter INFLUX_ADMIN_PASSWORD: " INFLUX_ADMIN_PASSWORD
        if [[ $INFLUX_ADMIN_PASSWORD = 'q' ]]; then
          exit;
        fi

        INFLUX_ACCOUNT="${INFLUX_ACCOUNT:-${dbname}}"
        influx -execute "SHOW DATABASES" -username "${INFLUX_ADMIN_USER}" -password "${INFLUX_ADMIN_PASSWORD}"

        if [ $? -eq 0 ]; then
          break;
        fi
     done;

    INFLUX_ACCOUNT="${INFLUX_ACCOUNT:-${dbname}}"
          # unset INFLUX_ADMIN_USER
          while [ -z ${INFLUX_ADMIN_USER} ]; do
                 read -r -p "Enter admin user ($INFLUX_ACCOUNT): " INFLUX_ADMIN_USER
          done
          while [ -z ${INFLUX_ADMIN_PASSWORD} ]; do
                 read -r -p "Enter admin password: " INFLUX_ADMIN_PASSWORD
          done
          
          influx -execute "CREATE USER \"${INFLUX_ADMIN_USER}\" WITH PASSWORD '${INFLUX_ADMIN_PASSWORD}' WITH ALL PRIVILEGES"
     
          if [ $? -eq 0 ]; then
            echo "create admin user... done"
          else
            echo "create admin user.. failed"
            echo "CREATE USER \"${INFLUX_ADMIN_USER}\" WITH PASSWORD '${INFLUX_ADMIN_PASSWORD}' WITH ALL PRIVILEGES"
          fi
}

createdb() {
    local dbname=$1
    INFLUX_ADMIN_USER=admin
    INFLUX_ADMIN_PASSWORD=admin
#    CREATE RETENTION POLICY <retention_policy_name> ON <database_name> DURATION <duration> REPLICATION <n> [SHARD DURATION <duration>] [DEFAULT]
#    CREATE RETENTION POLICY "one_day_only" ON "NOAA_water_database" DURATION 1d REPLICATION 1

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

        INFLUX_ACCOUNT="${INFLUX_ACCOUNT:-${dbname}}"
        influx -execute "SHOW DATABASES" -username "${INFLUX_ADMIN_USER}" -password "${INFLUX_ADMIN_PASSWORD}"

        if [ $? -eq 0 ]; then
            unset INFLUX_ACCOUNT
            while [ -z ${INFLUX_ACCOUNT} ]; do
                 read -r -p "Enter INFLUX_ACCOUNT DB NAME: (${dbname})" INFLUX_ACCOUNT
            done
            DB="${INFLUX_ACCOUNT}db"
            CREATE_USER="CREATE USER \"${INFLUX_ACCOUNT}\" WITH PASSWORD '${INFLUX_ACCOUNT}'"
            # CREATE DATABASE foo WITH DURATION 45d NAME autogen
            CREATE_DB="CREATE DATABASE \"${DB}\""
            GRANT_DB="GRANT READ ON \"${DB}\" TO \"${INFLUX_ACCOUNT}\""
            influx -execute "${CREATE_USER}; ${CREATE_DB}; ${GRANT_DB}" -username "${INFLUX_ADMIN_USER}" -password "${INFLUX_ADMIN_PASSWORD}"
            influx -execute "SHOW DATABASES" -username "${INFLUX_ADMIN_USER}" -password "${INFLUX_ADMIN_PASSWORD}"
            break;
        fi
    done
}

run_grafana() {
  GRAFANA_PASSWORD="${GRAFANA_PASSWORD:-secret}"
  read -r -p "Enter GRAFANA_PASSWORD: " GRAFANA_PASSWORD
  NAME="grafana"
  docker volume create grafana-storage 
  docker run -d -p 3001:3000 -e "GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}" --name="${NAME}" -v grafana-storage:/var/lib/grafana  grafana/grafana
}

case "$1" in
        --setup|setup) setup;;
        --create-db|create-db) createdb $2;;
        --create-user) create_user $2;;
        --run-grafana|run-grafana) run_grafana;;
        --help|help) usage;;
        *) usage;;
esac
