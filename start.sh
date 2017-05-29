#!/bin/bash

env > out.txt
env

if [[ ! -z $PIAWARE_USERNAME ]] && [[ ! -z $PIAWARE_PASSWORD ]]; then
  if [[ -x /usr/bin/piaware-config ]]; then
    /usr/bin/piaware-config flightaware-user ${PIAWARE_USERNAME}
    /usr/bin/piaware-config flightaware-password ${PIAWARE_PASSWORD}
  fi
fi

echo "This is where your application would start..."
while : ; do
  echo "waiting"
  sleep 60
done
