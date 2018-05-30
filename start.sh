#!/bin/bash


# ==========================================
# ADSB Resin Dockerfile script
#
# Author: Glenn Stewart <gstewart@atlassian.com>
# Reference: https://bitbucket.org/inodes/resin-docker-rtlsdr
#
# This script should be used in conjunction with Resin.io and Raspberry Pi + RTL_SDR Dongles
# ==========================================


# ==========================================
# ERROR FUNCTIONS
# ==========================================

missing()
{
    echo "------------------------------------------"
    echo "MISSING VARIABLES:"
    echo "ERROR: Check the following variables are set in Resin:"
    echo "LAT: Your lattitude"
    echo "LONG: Your longitude"
    echo "Use https://mycurrentlocation.net/ to find your location then set in Resin"
    echo "------------------------------------------"
}

deprecated()
{
    echo "------------------------------------------"
    echo "DEPRECATED:"
    echo "Flightaware has deprecated user credentials and forced MAC address with feeder-id"
    echo "For a first time installation connect your device to your local network without PIAWARE variables in Resin.io"
    echo "Then look for new device on https://flightaware.com/adsb/piaware/claim"
    echo "Once a device has been claimed insert this into device variable PIAWARE_ID"
    echo "------------------------------------------"
}

planefinder_error()
{
    echo "------------------------------------------"
    echo "PLANEFINDER ERROR"
    echo "Missing required Planefinder variables - \$PF_SHARECODE \$LAT \$LONG"
    echo "Connect to http://<your_rpi_ip>:30053 to config and claim a sharecode"
    echo "Add variable PF_SHARECODE to Resin.io device variables once claimed."
    echo "------------------------------------------"
}

flightradar24_error()
{
    echo "------------------------------------------"
    echo "FLIGHTRADAR24 ERROR"
    echo "Missing required Flightradar24 variables - \$FR24_KEY \$LAT \$LONG"
    echo "Connect Resin.io terminal and run /usr/bin/fr24feed --signup to get a sharecode"
    echo "Add variable FR24_KEY to Resin.io device variables once signed up."
    echo "------------------------------------------"
}

adsbexchange_error()
{
    echo "------------------------------------------"
    echo "ADSBEXCHANGE ERROR"
    echo "Missing required ADSB Exchange variables - \$LAT \$LONG \$ALT"
    echo "------------------------------------------"
}

# ==========================================
# GENERIC
# ==========================================

echo ------------------------------------------
echo GENERIC VARIABLES
echo ------------------------------------------
env

if [[ -z ${LAT} ]] || \
   [[ -z {LONG} ]]; then
    MISSING=1
fi

(( $MISSING )) && missing

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

echo
echo ------------------------------------------
echo FLIGHTAWARE / PIAWARE
echo ------------------------------------------



[[ ! -z ${GAIN} ]]             && /usr/bin/piaware-config rtlsdr-gain ${GAIN} || GAIN="-10"
[[ ! -z ${PPM} ]]              && /usr/bin/piaware-config rtlsdr-ppm ${PPM} || PPM="1"
[[ ! -z ${PIAWARE_ID} ]]       && /usr/bin/piaware-config feeder-id ${PIAWARE_ID}

if [[ ! -z ${PIAWARE_USERNAME} ]] && [[ -z ${PIAWARE_ID} ]]; then
    echo "WARNING: flightaware-user has been deprecated."
    /usr/bin/piaware-config flightaware-user ${PIAWARE_USERNAME}
    DEPRECATED=1
fi

if [[ ! -z ${PIAWARE_PASSWORD} ]] && [[ -z ${PIAWARE_ID} ]]; then
    echo "WARNING: flightaware-password has been deprecated."
    /usr/bin/piaware-config flightaware-password ${PIAWARE_PASSWORD}
    DEPRECATED=1
fi

if [[ ! -z ${PIAWARE_MAC} ]]; then
    echo "WARNING: force-macaddress has been deprecated."
    /usr/bin/piaware-config force-macaddress ${PIAWARE_MAC}
    DEPRECATED=1
fi

(( $DEPRECATED )) && deprecated

PIAWARE_CFG="/usr/bin/piaware-config"
if [[ -x ${PIAWARE_CFG} ]]; then
    # Show the Flightaware configuration
    echo "CONFIG: Flightaware"
    /usr/bin/piaware-config -showall
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

echo
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

        # Show the Planefinder configuration and start
        echo "CONFIG: Planefinder"
        cat ${PF_CLIENT_CFG}
        service pfclient restart
    else
        planefinder_error
    fi
fi

# ==========================================
# FLIGHTRADAR24
# ==========================================
# See https://feed.flightradar24.com/fr24feed-manual.pdf
#
# Feed Status: https://www.flightradar24.com/account/data-sharing

FR24_CLIENT="/usr/bin/fr24feed"
FR24_CLIENT_CFG="/etc/fr24feed.ini"

echo
echo ------------------------------------------
echo FLIGHTRADAR24
echo ------------------------------------------

if [[ -x ${FR24_CLIENT} ]] && [[ -w ${FR24_CLIENT_CFG} ]]; then
    if [[ ! -z ${FR24_KEY} ]] && \
       [[ ! -z ${LONG} ]] && \
       [[ ! -z ${LAT} ]]; then
        echo fr24key=\"$FR24_KEY\" >> ${FR24_CLIENT_CFG}

        # Show the Planefinder configuration and start
        echo "CONFIG: Flightradar24"
        cat ${FR24_CLIENT_CFG}
        service fr24feed stop
        service fr24feed start
    else
        flightradar24_error
    fi
fi

# ==========================================
# ADSBEXCHANGE
# ==========================================
# See https://www.adsbexchange.com/how-to-feed/ 
#

ADSBEXCHANGE_CLIENT="/home/adsbexchange/adsbexchange-feed.sh"
ADSBEXCHANGE_MLAT_CLIENT="/home/adsbexchange/adsbexchange-mlat.sh"
ADSBEXCHANGE_CLIENT_CFG="/home/adsbexchange/adsbexchange.cfg"

echo
echo ------------------------------------------
echo ADSBEXCHANGE
echo ------------------------------------------

if [[ -x ${ADSBEXCHANGE_CLIENT} ]] && [[ -x ${ADSBEXCHANGE_MLAT_CLIENT} ]]; then
    if [[ ! -z ${ALT} ]] then

        echo port=\"${ADSBEXCHANGE_PORT:=30004}\" > ${ADSBEXCHANGE_CLIENT_CFG}
        echo name=\"${ADSBEXCHANGE_NAME:-$RESIN_DEVICE_UUID}\" >> ${ADSBEXCHANGE_CLIENT_CFG}
        echo lat=\"$LAT\" >> ${ADSBEXCHANGE_CLIENT_CFG}
        echo long=\"$LONG\" >> ${ADSBEXCHANGE_CLIENT_CFG}
        echo alt=\"$ALT\" >> ${ADSBEXCHANGE_CLIENT_CFG}

        # Show the ADSB Exchange configuration and start
        echo "CONFIG: ADSBExchange"
        cat ${ADSBEXCHANGE_CLIENT_CFG}
        systemctl enable adsbexchange-feed
        systemctl enable adsbexchange-mlat
        service adsbexchange stop
        service adsbexchange start
    else
        adsbexchange_error
    fi
fi

# Allow everything to start before querying
sleep 60

while true; do
  date
  echo "------------------------------------------"
  echo "STATUS"
  echo "------------------------------------------"
  systemctl status dump1090-fa.service -l
  systemctl status piaware.service -l
  systemctl status pfclient -l
  systemctl status fr24feed -l
  systemctl status adsbexchange -l
  systemctl status adsbexchange-feed -l
  systemctl status adsbexchange-mlat -l
  
  (( $DEPRECATED )) && deprecated
  (( $MISSING )) && missing
  echo "------------------------------------------"
  echo "Repository: https://bitbucket.org/inodes/resin-docker-rtlsdr"
  echo "Log issues: https://bitbucket.org/inodes/resin-docker-rtlsdr/issues/new"
  echo "------------------------------------------"
  sleep 60
done
