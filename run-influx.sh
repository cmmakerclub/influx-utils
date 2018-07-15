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

if [ -z "$DATA_PATH" ]; then
  DATA_PATH=$HOME/influxdb/influxdb_data
fi


if [ -z "$CONTAINER_NAME" ]; then
  read -r -p "Enter CONTAINER_NAME (influxdb): " CONTAINER_NAME
   if [ -z "$CONTAINER_NAME" ]; then
      CONTAINER_NAME=influxdb
   fi
fi

echo "DATA_PATH=$DATA_PATH"
echo "CONTAINER_NAME=$CONTAINER_NAME"
echo "PORT=$INFLUX_PORT"
echo "INFLUX_CONF=$INFLUX_CONF"
INFLUX_CONFIG=$PWD/influxdb.conf

if confirm ;then
  mkdir -p $DATA_PATH
  docker run \
        -v $HOME/influxdb/influxdb_data:/var/lib/influxdb \
        -v $PWD/influxdb.conf:/etc/influxdb/influxdb.conf:ro \
        --restart always \
        --net host\
        -p $INFLUX_PORT:8086 \
        -d \
        --name "${NAME}" \
        influxdb -config /etc/influxdb/influxdb.conf
fi

