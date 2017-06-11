#!/bin/bash

# Configure Flightaware
# See https://flightaware.com/adsb/piaware/claim for new entries
# See https://flightaware.com/adsb/piaware/advanced_configuration for options
#
[[ ! -z ${PIAWARE_USERNAME} ]] && /usr/bin/piaware-config flightaware-user ${PIAWARE_USERNAME}
[[ ! -z ${PIAWARE_PASSWORD} ]] && /usr/bin/piaware-config flightaware-password ${PIAWARE_PASSWORD}
[[ ! -z ${PIAWARE_MAC} ]]      && /usr/bin/piaware-config force-macaddress ${PIAWARE_MAC}
[[ ! -z ${GAIN} ]]             && /usr/bin/piaware-config rtlsdr-gain ${GAIN} || GAIN="-10"
[[ ! -z ${PPM} ]]              && /usr/bin/piaware-config rtlsdr-ppm ${PPM} || PPM="1"

# Show the Flightaware configuration
/usr/bin/piaware-config -showall

# Unload the driver module to allow access to dongle
rmmod dvb_usb_rtl28xxu

# Flightaware is started by systemd
# - /lib/systemd/system/dump1090-fa.service
# - /lib/systemd/system/piaware.service

sleep 10

# Configure Planefinder
# See https://planefinder.net/sharing/account
PF_CLIENT="/usr/bin/pfclient"
PF_CLIENT_CFG="/etc/pfclient-config.json"

if [[ -x ${PF_CLIENT} ]] && [[ -w ${PF_CONFIG} ]] && \
   [[ ! -z ${PF_SHARECODE} ]] && \
   [[ ! -z ${LONG} ]] && [[ ! -z ${LAT} ]]; then

	sed -i '' "s/PF_SHARECODE/$PF_SHARECODE/" ${PF_CLIENT_CFG}
	sed -i '' "s/LONG/$LONG/" ${PF_CLIENT_CFG}
    sed -i '' "s/LAT/$LAT/" ${PF_CLIENT_CFG}
    cat ${PF_CLIENT_CFG}
	/etc/init.d/pfclient restart
else
	echo "Error with pfclient configuration"
fi

while true; do
  date
  systemctl status dump1090-fa.service
  systemctl status piaware.service -l
  sleep 60
done
