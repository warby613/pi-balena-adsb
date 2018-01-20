#!/bin/bash

set -e

name=${ADSBEXCHANGE_NAME:-$RESIN_DEVICE_UUID}
echo "Running with name "${name}

/usr/bin/mlat-client --input-type dump1090 --input-connect localhost:30005 --lat $LAT --lon $LONG --alt $ALT --user "${name}" --server feed.adsbexchange.com:31090 --no-udp --results beast,connect,localhost:30104
