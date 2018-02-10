#!/usr/bin/env bash

set -e

source /home/adsbexchange/adsbexchange.cfg

/usr/bin/mlat-client --input-type dump1090 --input-connect localhost:30005 --lat "${lat}" --lon "${long}" --alt "${alt}" --user "${name}" --server feed.adsbexchange.com:31090 --no-udp --results beast,connect,localhost:30104
