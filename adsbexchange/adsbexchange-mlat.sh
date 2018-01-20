#!/bin/bash

set -e
/usr/bin/socat TCP:localhost:30005 TCP:feed.adsbexchange.com:${ADSBEXCHANGE_PORT:=30005}

if [ -z "$ADSBEXCHANGE_NAME"  ]; then
  name="${ADSBEXCHANGE_NAME}"
else
  name="${RESIN_DEVICE_UUID}"
fi

echo "Running with name "${name}

/usr/bin/mlat-client --input-type dump1090 --input-connect localhost:30005 --lat $LAT --lon $LONG --alt $ALT --user "${name}"--server feed.adsbexchange.com:31090 --no-udp --results beast,connect,localhost:30104
