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

if [ -z "$CONTAINER_NAME" ]; then
  read -r -p "Enter CONTAINER_NAME (influxdb): " CONTAINER_NAME
   if [ -z "$CONTAINER_NAME" ]; then
      CONTAINER_NAME=influxdb
   fi
fi

DATA_PATH="${DATA_PATH:-$HOME/influxdb/influxdb_data}"
INFLUX_PORT="${INFLUX_PORT:-8086}"
INFLUX_CONF="${INFLUX_CONF:-$PWD/influxdb.conf}"
DOCKER_NETWORK="${DOCKER_NETWORK:-host}"

echo "DATA_PATH=$DATA_PATH"
echo "CONTAINER_NAME=$CONTAINER_NAME"
echo "INFLUX_PORT=$INFLUX_PORT" 
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
        -d \
        --name "${NAME}" \
        influxdb -config /etc/influxdb/influxdb.conf
fi
