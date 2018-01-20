#!/usr/bin/env bash

source /home/adsbexchange/adsbexchange.cfg

/usr/bin/socat TCP:localhost:30005 TCP:feed.adsbexchange.com:${port}
