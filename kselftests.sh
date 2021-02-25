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

if [ ! -e /root/kselftest.tar.gz ];then
	case $(uname -m) in
	aarch64)
		KSARCH=arm64
	;;
	x86_64)
		KSARCH=x86
	;;
	armv7l)
		KSARCH=arm
		echo "SKIP: kselftests are disabled on ARM"
		exit 0
	;;
	*)
		echo "SKIP: no kselftests for $(uname -m) arch"
		exit 0
	;;
	esac
	# TODO move this in rootfs generation
	wget http://storage.kernelci.org/images/selftests/$KSARCH/kselftest.tar.gz
fi
tar xzf kselftest.tar.gz || exit $?
cd kselftest
./run_kselftest.sh
