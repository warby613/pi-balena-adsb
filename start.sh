#!/bin/bash

env > out.txt
env

# Configure Flightaware
#
# See https://flightaware.com/adsb/piaware/claim for new entries
# See https://flightaware.com/adsb/piaware/advanced_configuration for options
[[ ! -z ${PIAWARE_USERNAME} ]] && /usr/bin/piaware-config flightaware-user ${PIAWARE_USERNAME}
[[ ! -z ${PIAWARE_PASSWORD} ]] && /usr/bin/piaware-config flightaware-password ${PIAWARE_PASSWORD}
[[ ! -z ${PIAWARE_MAC} ]]      && /usr/bin/piaware-config force-macaddress ${PIAWARE_MAC}
[[ ! -z ${GAIN} ]]             && /usr/bin/piaware-config rtlsdr-gain ${GAIN} || GAIN="-10"
[[ ! -z ${PPM} ]]              && /usr/bin/piaware-config rtlsdr-ppm ${PPM} || PPM="1"

# Show the Flightaware configuration
/usr/bin/piaware-config -showall

# Unload the driver module to allow access to dongle
rmmod dvb_usb_rtl28xxu

## Run Flightaware dump1090
#if [[ -x /usr/bin/dump1090-fa ]]; then
#    /usr/bin/dump1090-fa --net --gain -10 --ppm 1 --lat ${LAT} --lon ${LONG} --max-range 400 \
#               --net-ro-size 500 --net-ro-interval 1 --net-buffer 2 \
#               --stats-every 3600 --quiet &
#fi



echo "This is where your application would start..."
while : ; do
  echo "waiting"
  #/etc/init.d/piaware start
  sleep 60
done
