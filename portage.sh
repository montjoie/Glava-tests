#!/bin/sh

GARCH=$(uname -m)

echo "DEBUG: GARCH=$GARCH"

case $GARCH in
armv7l)
	GARCH=arm
;;
x86_64)
	GARCH=amd64
;;
esac
echo "DEBUG: GARCH=$GARCH"

echo "PORTAGE_BINHOST=\"http://10.1.1.45:8090/$GARCH\"" >> /etc/portage/make.conf
echo 'FEATURES="getbinpkg"' >> /etc/portage/make.conf

emerge --info

emerge --quiet --color n --nospinner -pv cryptsetup
