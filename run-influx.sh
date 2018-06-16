mkdir -p $HOME/influxdb/influxdb_data
docker run \
      -v $HOME/influxdb/influxdb_data:/var/lib/influxdb \
      -v $PWD/influxdb.conf:/etc/influxdb/influxdb.conf:ro \
      --restart always \
      --net host\
      -p 8086:8086 \
      -p 8083:8083 \
      -d \
      --name influxdb \
      influxdb -config /etc/influxdb/influxdb.conf
