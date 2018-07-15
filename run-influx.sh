#!/bin/sh
VERSION=1.0.0
usage() {
        cat <<EOF
influxdb.sh v$VERSION
Usage: $0 [start|--help]
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

start() {
  if [ -z "$CONTAINER_NAME" ]; then
    read -r -p "Enter CONTAINER_NAME (influxdb): " CONTAINER_NAME
     if [ -z "$CONTAINER_NAME" ]; then
        CONTAINER_NAME=influxdb
     fi
  fi
  
  DATA_PATH="${DATA_PATH:-$HOME/influxdb/influxdb_data}"
  INFLUX_PORT="${INFLUX_PORT:-8086}"
  INFLUXDB_BIND_ADDRESS="${INFLUXDB_BIND_ADDRESS:-8088}"
  INFLUX_CONF="${INFLUX_CONF:-$PWD/influxdb.conf}"
  DOCKER_NETWORK="${DOCKER_NETWORK:-host}"
  
  echo "DATA_PATH=$DATA_PATH"
  echo "CONTAINER_NAME=$CONTAINER_NAME"
  echo "INFLUX_PORT=$INFLUX_PORT" 
  echo "INFLUXDB_BIND_ADDRESS=$INFLUXDB_BIND_ADDRESS" 
  echo "INFLUX_CONF=$INFLUX_CONF"
  echo "DOCKER_NETWORK=$DOCKER_NETWORK"
  
  if confirm ;then
    mkdir -p $DATA_PATH
    docker run \
          -v $HOME/influxdb/influxdb_data:/var/lib/influxdb \
          -v $PWD/influxdb.conf:/etc/influxdb/influxdb.conf:ro \
          --restart always \
          --net ${DOCKER_NETWORK}\
          -p $INFLUX_PORT:8086 \
          -p $INFLUXDB_BIND_ADDRESS:8088 \
          -d \
          --name "${NAME}" \
          influxdb -config /etc/influxdb/influxdb.conf
  fi
}

#docker run --rm influxdb influxd config > influxdb.conf
#sed -Ei "s/auth-enabled = false/auth-enabled = true/g" influxdb.conf

case "$1" in
        --start|start) start;;
        --help|help) usage;;
        *) usage;;
esac
