#!/bin/sh
set -ex

MLATCLIENTVERSION="0.2.10"
MLATCLIENTTAG="v0.2.10"

# Check if the mlat-client git repository already exists.
 if [ -d mlat-client ] && [ -d mlat-client/.git ]; then
  # If the mlat-client repository exists update the source code contained within it.
  cd mlat-client
  git pull
  git checkout tags/$MLATCLIENTTAG
 else
  # Download a copy of the mlat-client repository since the repository does not exist locally.
  git clone https://github.com/mutability/mlat-client.git
  cd mlat-client
  git checkout tags/$MLATCLIENTTAG
fi

dpkg-buildpackage -b -uc
cd ..
dpkg -i mlat-client_${MLATCLIENTVERSION}*.deb


mv adsbexchange.service /etc/systemd/system
mv adsbexchange-feed.service /etc/systemd/system
mv adsbexchange-mlat.service /etc/systemd/system

exit 0
