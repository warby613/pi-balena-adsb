#!/usr/bin/env bash

source /home/av-delphi/av-delphi.cfg

while true; do
  /usr/bin/socat -u TCP:localhost:30005 TCP:data.avdelphi.com:24999
  sleep 30
done
