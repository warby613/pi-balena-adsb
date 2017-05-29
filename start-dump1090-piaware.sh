#!/bin/bash
#
env > out.txt

if [[ ! -z $PIAWARE_USERNAME ]] && [[ ! -z $PIAWARE_PASSWORD ]]; then
  if [[ -x /usr/bin/piaware-config ]]; then
    /usr/bin/piaware-config flightaware-user ${PIAWARE_USERNAME}
    /usr/bin/piaware-config flightaware-password ${PIAWARE_PASSWORD}
  fi
fi

exit

# Refer to https://hub.docker.com/r/inodes/rtlsdr-dump1090-piaware/
if [[ -x ./dump1090 ]]
then
    ./dump1090 --net --gain -10 --ppm 1 --oversample --fix --lat ${LAT} --lon ${LONG} --max-range 400 \
               --net-ri-port 30001 --net-ro-port 30002 --net-bi-port 30004 --net-bo-port 30005 --net-sbs-port 30003 \
               --net-fatsv-port 10001 --net-heartbeat 60 --net-ro-size 500 --net-ro-interval 1 --net-buffer 2 \
               --stats-every 3600 --write-json /run/dump1090-mutability --write-json-every 1 --json-location-accuracy 2 --quiet &

elif [[ -x /usr/bin/dump1090-fa ]]
then
    /usr/bin/dump1090-fa --net --gain -10 --ppm 1 --lat ${LAT} --lon ${LONG} --max-range 400 \
               --net-ro-size 500 --net-ro-interval 1 --net-buffer 2 \
               --stats-every 3600 --quiet &
     
else
    echo "ERROR: Cannot execute dump1090"
    exit 126
fi

if [[ -x /usr/bin/piaware ]]
then
    if [[ ! -z $PIAWARE_USERNAME ]] && \
       [[ ! -z $PIAWARE_PASSWORD ]] && \
       [[ -w /root/.piaware ]]
    then
        echo "Adding user $PIAWARE_USERNAME and password $PIAWARE_PASSWORD to Flightaware configuration"
        echo user $PIAWARE_USERNAME >> /root/.piaware
        echo password $PIAWARE_PASSWORD >> /root/.piaware
    fi

    service lighttpd stop
    service lighttpd start
    service lighttpd status

    /usr/bin/piaware -v
    /usr/bin/piaware $1
fi
