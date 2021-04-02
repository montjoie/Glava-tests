#!/bin/sh

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
