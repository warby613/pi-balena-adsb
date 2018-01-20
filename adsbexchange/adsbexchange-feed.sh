#!/bin/bash

/usr/bin/socat TCP:localhost:30005 TCP:feed.adsbexchange.com:${ADSBEXCHANGE_PORT:=30005}
