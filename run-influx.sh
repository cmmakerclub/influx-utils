if [ -z "$TICK_PATH" ]; then 
  TICK_PATH=$HOME/influxdb/influxdb_data 
fi 

mkdir -p $TICK_PATH

if [ -z "$NAME" ]; then 
  NAME=influxdb
  echo "NAME=$NAME" 
else 
  echo "NAME=$NAME" 
fi

echo "TICK_PATH=$TICK_PATH"


#docker run \
#      -v $HOME/influxdb/influxdb_data:/var/lib/influxdb \
#      -v $PWD/influxdb.conf:/etc/influxdb/influxdb.conf:ro \
#      --restart always \
#      --net host\
#      -p 8086:8086 \
#      -p 8083:8083 \
#      -d \
#      --name "${NAME}" \
#      influxdb -config /etc/influxdb/influxdb.conf
