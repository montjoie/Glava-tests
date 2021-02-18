#!/bin/sh

# TODO move this in a dedicated test
# assume only one network card
ETH=$(ls /sys/class/net |grep -E 'eth|enp')

if [ -z "$ETH" ];then
	echo "WARN: no network card found"
else
	echo "INFO: configure network card $ETH"
	ln -s /etc/init.d/net.lo /etc/init.d/net.$ETH
	/etc/init.d/net.$ETH start
fi

# TODO move this in rootfs generation
wget http://storage.kernelci.org/images/selftests/x86/kselftest.tar.gz
tar xzf kselftest.tar.gz
cd kselftest
./run_kselftest.sh
