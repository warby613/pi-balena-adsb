#!/bin/sh
set -ex

mv av-delphi.service /etc/systemd/system/
mv av-delphi-feed.service /etc/systemd/system/
exit 0
