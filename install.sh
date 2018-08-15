#!/bin/bash

cd ~
curl https://github.com/cmmakerclub/influx-utils/blob/master/run-influx.sh > cmmc-influx.sh
chmod +x cmmc-influx.sh
sudo mv cmmc-influx.sh /usr/bin/cmmc-influx
