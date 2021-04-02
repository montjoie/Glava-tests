#!/bin/sh

. ./common

check_config BLK_DEV_LOOP || echo "DEBUG: Missing CONFIG_BLK_DEV_LOOP"
check_config DM_CRYPT || echo "DEBUG: Missing CONFIG_DM_CRYPT"
check_config CRYPTO_XTS || echo "DEBUG: Missing CONFIG_CRYTPO_XTS"
check_config CRYPTO_USER_API_SKCIPHER || echo "DEBUG: Missing CONFIG_CRYPTO_USER_API_SKCIPHER"
check_config CRYPTO_USER_API_HASH || echo "DEBUG: Missing CONFIG_CRYPTO_USER_API_HASH"

emerge --quiet --color n --nospinner -Kv cryptsetup || exit $?

start_test "Check presence of cryptsetup"
cryptsetup --version
RET=$?
if [ $RET -ne 0 ];then
	result "SKIP" "test-luks-cryptsetup"
	exit 0
fi

start_test "cryptsetup benchmark"
try_run cryptsetup benchmark > "$OUTPUT_DIR/cryptsetup-benchmark"
result $RET "test-luks-cryptsetup-benchmark"
echo "DEBUG: output ============================"
cat "$OUTPUT_DIR/cryptsetup-benchmark"
echo "DEBUG: endout ============================"
#TODO analysis of output


do_cryptsetup_luks1() {
start_test "Generate fake image"
# create a fake volume
dd if=/dev/zero of="$OUTPUT_DIR/fake.img" bs=1M count=100
RET=$?
result $RET "test-luks-generate-img"
if [ $RET -ne 0 ];then
	return 1
fi

echo 'toto' >"$OUTPUT_DIR/fake.key"

start_test "crytpsetup format"
cryptsetup --verbose --key-file="$OUTPUT_DIR/fake.key" --batch-mode luksFormat "$OUTPUT_DIR/fake.img"
RET=$?
result $RET "test-luks-format-img"
if [ $RET -ne 0 ];then
	return 1
fi

start_test "crytpsetup open"
cryptsetup --verbose --key-file="$OUTPUT_DIR/fake.key" --batch-mode luksOpen "$OUTPUT_DIR/fake.img" fake
RET=$?
result $RET "test-luks-open"
if [ $RET -ne 0 ];then
	return 1
fi

if [ ! -e /dev/mapper/fake ];then
	echo "DEBUG: no fake mapper, exiting"
	return 1
fi

start_test "crytpsetup status"
cryptsetup status /dev/mapper/fake
result $RET "test-luks-status"

start_test "mkfs"
mkfs.ext4 /dev/mapper/fake
RET=$?
result $RET "test-luks-mkfs"
if [ $RET -ne 0 ];then
	return 1
fi

mkdir /mnt/luks
start_test "crytpsetup mount"
mount /dev/mapper/fake /mnt/luks
RET=$?
result $RET "test-luks-mount"
if [ $RET -ne 0 ];then
	return 1
fi

start_test "cryptsetup bench the disk"
dd if=/dev/zero of=/mnt/luks/test oflag=sync bs=1M count=50
result $RET "test-luks-bench"

start_test "crytpsetup umount"
umount /mnt/luks
RET=$?
result $RET "test-luks-umount"
if [ $RET -ne 0 ];then
	return 1
fi

start_test "crytpsetup close"
cryptsetup luksClose fake
RET=$?
result $RET "test-luks-format-close"
if [ $RET -ne 0 ];then
	return 1
fi

rm "$OUTPUT_DIR/fake.img"
return 0
}


do_cryptsetup_luks2() {
PREFIX="LUKS2:"
TNAME="luks2"
CREATE_OPTS="--type luks2"
start_test "$PREFIX Generate fake image"
# create a fake volume
dd if=/dev/zero of="$OUTPUT_DIR/fake.img" bs=1M count=100
RET=$?
result $RET "test-$TNAME-generate-img"
if [ $RET -ne 0 ];then
	return 1
fi

echo 'toto' >"$OUTPUT_DIR/fake.key"

start_test "$PREFIX crytpsetup format with $CREATE_OPTS"
cryptsetup --verbose --key-file="$OUTPUT_DIR/fake.key" "$CREATE_OPTS" --batch-mode luksFormat "$OUTPUT_DIR/fake.img"
RET=$?
result $RET "test-$TNAME-format-img"
if [ $RET -ne 0 ];then
	return 1
fi

start_test "$PREFIX crytpsetup open"
cryptsetup --verbose --key-file="$OUTPUT_DIR/fake.key" --batch-mode luksOpen "$OUTPUT_DIR/fake.img fake"
RET=$?
result $RET "test-$TNAME-open"
if [ $RET -ne 0 ];then
	return 1
fi

if [ ! -e /dev/mapper/fake ];then
	echo "DEBUG: no fake mapper, exiting"
	return 1
fi

start_test "$PREFIX crytpsetup status"
cryptsetup status /dev/mapper/fake
result $RET "test-$TNAME-status"

start_test "mkfs"
mkfs.ext4 /dev/mapper/fake
RET=$?
result $RET "test-$TNAME-mkfs"
if [ $RET -ne 0 ];then
	return 1
fi

mkdir /mnt/luks
start_test "$PREFIX crytpsetup mount"
mount /dev/mapper/fake /mnt/luks
RET=$?
result $RET "test-$TNAME-mount"
if [ $RET -ne 0 ];then
	return 1
fi

start_test "$PREFIX cryptsetup bench the disk"
dd if=/dev/zero of=/mnt/luks/test oflag=sync bs=1M count=50
result $RET "test-$TNAME-bench"

start_test "$PREFIX crytpsetup umount"
umount /mnt/luks
RET=$?
result $RET "test-$TNAME-umount"
if [ $RET -ne 0 ];then
	return 1
fi

start_test "$PREFIX crytpsetup close"
cryptsetup luksClose fake
RET=$?
result $RET "test-$TNAME-format-close"
if [ $RET -ne 0 ];then
	return 1
fi

rm "$OUTPUT_DIR/fake.img"
}


do_cryptsetup_luks1
do_cryptsetup_luks2
