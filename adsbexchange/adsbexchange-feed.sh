#!/usr/bin/env bash

source /home/adsbexchange/adsbexchange.cfg

while true; do
  /usr/bin/socat TCP:localhost:30005 TCP:feed.adsbexchange.com:${port}
  sleep 5
done
