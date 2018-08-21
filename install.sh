#!/bin/bash

echo "installing cmmc-influx-utils v1.0.2"

cd ~
curl --silent https://raw.githubusercontent.com/cmmakerclub/influx-utils/master/run-influx.sh > cmmc-influx.sh
chmod +x cmmc-influx.sh
sudo mv cmmc-influx.sh /usr/bin/cmmc-influx
