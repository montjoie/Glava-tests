#!/bin/sh

# assume only one network card
ETH=$(ls /sys/class/net |grep -E 'eth|enp')

if [ -z "$ETH" ];then
	echo "WARN: no network card found"
else
	echo "INFO: configure network card $ETH"
	ln -s /etc/init.d/net.lo /etc/init.d/net.$ETH
	/etc/init.d/net.$ETH start
fi
