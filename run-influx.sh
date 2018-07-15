#!/bin/sh
VERSION=1.0.0
usage() {
        cat <<EOF
$0 v$VERSION
Usage: $0 [setup|--help]
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
  fi
  
  ROOT_DIR="${ROOT_DIR:-$HOME/tick/influxdb}"
  DATA_PATH="${DATA_PATH:-${ROOT_DIR}/data}"
  INFLUX_PORT="${INFLUX_PORT:-8086}"
  INFLUXDB_BIND_ADDRESS="${INFLUXDB_BIND_ADDRESS:-8088}"
  INFLUX_CONF="${INFLUX_CONF:-$ROOT_DIR/influxdb.conf}"
  DOCKER_NETWORK="${DOCKER_NETWORK:-host}"
  
  echo "CONTAINER_NAME=$CONTAINER_NAME"
  echo "ROOT_DIR=$ROOT_DIR"
  echo "DATA_PATH=$DATA_PATH"
  echo "INFLUX_CONF=$INFLUX_CONF"
  echo "INFLUX_PORT=$INFLUX_PORT" 
  echo "INFLUXDB_BIND_ADDRESS=$INFLUXDB_BIND_ADDRESS" 
  echo "DOCKER_NETWORK=$DOCKER_NETWORK"
  
  if confirm ;then
    mkdir -p $DATA_PATH
    echo "data" > "$ROOT_DIR/.gitignore" 
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
          --name "${NAME}" \
          influxdb -config /etc/influxdb/influxdb.conf
  fi
}

case "$1" in
        --setup|setup) setup;;
        --help|help) usage;;
        *) usage;;
esac
