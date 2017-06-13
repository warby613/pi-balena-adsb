#!/bin/bash

# ==========================================
# FLIGHTAWARE / PIAWARE
# ==========================================
# See https://flightaware.com/adsb/piaware/claim for new entries
# See https://flightaware.com/adsb/piaware/advanced_configuration for options
#
# Feed Status: https://flightaware.com/adsb/stats/user/${PIAWARE_USERNAME}
#
# Flightaware is started by systemd
# - /lib/systemd/system/dump1090-fa.service
# - /lib/systemd/system/piaware.service

echo ------------------------------------------
echo FLIGHTAWARE / PIAWARE
echo ------------------------------------------

[[ ! -z ${PIAWARE_USERNAME} ]] && /usr/bin/piaware-config flightaware-user ${PIAWARE_USERNAME}
[[ ! -z ${PIAWARE_PASSWORD} ]] && /usr/bin/piaware-config flightaware-password ${PIAWARE_PASSWORD}
[[ ! -z ${PIAWARE_MAC} ]]      && /usr/bin/piaware-config force-macaddress ${PIAWARE_MAC}
[[ ! -z ${GAIN} ]]             && /usr/bin/piaware-config rtlsdr-gain ${GAIN} || GAIN="-10"
[[ ! -z ${PPM} ]]              && /usr/bin/piaware-config rtlsdr-ppm ${PPM} || PPM="1"
PIAWARE_CFG="/usr/bin/piaware-config"

if [[ -x ${PIAWARE_CFG} ]] && \
   [[ ! -z ${PIAWARE_USERNAME} ]] && \
   [[ ! -z ${PIAWARE_PASSWORD} ]]; then
	# Show the Flightaware configuration
	echo "CONFIG: Flightaware"
	/usr/bin/piaware-config -showall
else
	echo "Missing Flightaware"
fi

# Unload the driver module to allow access to dongle
rmmod dvb_usb_rtl28xxu

# ==========================================
# PLANEFINDER
# ==========================================
# See https://planefinder.net/sharing/client
#
# Feed Status: https://planefinder.net/sharing/account
#
# Planefinder is started by systemd
# - /run/systemd/generator.late/pfclient.service

echo ------------------------------------------
echo PLANEFINDER
echo ------------------------------------------

PF_CLIENT="/usr/bin/pfclient"
PF_CLIENT_CFG="/etc/pfclient-config.json"

if [[ -x ${PF_CLIENT} ]] && [[ -w ${PF_CLIENT_CFG} ]]; then
	if [[ ! -z ${PF_SHARECODE} ]] && \
	   [[ ! -z ${LONG} ]] && \
	   [[ ! -z ${LAT} ]]; then
		sed -i "s/PF_SHARECODE/$PF_SHARECODE/" ${PF_CLIENT_CFG}
		sed -i "s/LONG/$LONG/" ${PF_CLIENT_CFG}
	    sed -i "s/LAT/$LAT/" ${PF_CLIENT_CFG}
	else
		echo "Missing required Planefinder variables - \$PF_SHARECODE \$LAT \$LONG"
		echo "Connect to http://<your_rpi_ip>:30053 to config and claim a sharecode"
		echo "Add variable PF_SHARECODE to Resin.io device variables once claimed."
	fi
	# Show the Planefinder configuration
	echo "CONFIG: Planefinder"
	cat ${PF_CLIENT_CFG}
	service pfclient restart
fi

# ==========================================
# FLIGHTRADAR24
# ==========================================
# See https://feed.flightradar24.com/fr24feed-manual.pdf
#
# Feed Status: https://www.flightradar24.com/account/data-sharing

FR24_CLIENT="/usr/bin/fr24feed"
FR24_CLIENT_CFG="/etc/fr24feed.ini"

echo ------------------------------------------
echo FLIGHTRADAR24
echo ------------------------------------------

if [[ -x ${FR24_CLIENT} ]] && [[ -w ${FR24_CLIENT_CFG} ]]; then
	if [[ ! -z ${FR24_KEY} ]] && \
	   [[ ! -z ${LONG} ]] && \
	   [[ ! -z ${LAT} ]]; then
		echo fr24key=\"$FR24_KEY\" >> ${FR24_CLIENT_CFG}
	else
		echo "Missing required Flightradar24 variables - \$FR24_KEY \$LAT \$LONG"
		echo "Connect Resin.io terminal and run /usr/bin/fr24feed --signup to get a sharecode"
		echo "Add variable FR24_KEY to Resin.io device variables once signed up."
	fi
	# Show the Planefinder configuration
	echo "CONFIG: Flightradar24"
	cat ${FR24_CLIENT_CFG}
	service fr24feed restart
fi

# Allow everything to start before querying
sleep 60

while true; do
  date
  systemctl status dump1090-fa.service -l
  systemctl status piaware.service -l
  systemctl status pfclient -l
  systemctl status fr24feed -l
  sleep 60
done
