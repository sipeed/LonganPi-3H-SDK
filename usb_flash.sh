#!/bin/sh

echo "not ready, please wait me fix syterkit mmc write"
exit 1

if [ ! -e ./build/xfel-bin ]
then
	echo "please build xfel"
	exit 1
fi

if [ ! -e ./build/u-boot-sunxi-with-spl.bin ]
then
	echo "please build uboot"
	exit 1
fi

if [ ! -e ./build/syter_fel_uboot_fel.elf ]
then
	echo "please build syterkit"
	exit 1
fi

while true
do
	ret=$(./build/xfel-bin version)
	echo $ret
	num=$(echo $ret | grep 'AWUSBFEX' | grep 'H616' | wc -l)
	if [ "$num" = "0" ]
	then
		echo "wait device online"
		sleep 1
		continue
	fi
	echo "device found"
	break
done

dd if=/dev/zero of=./build/zero64KiB bs=1K count=64
./build/xfel-bin write 0x28000 ./build/zero64KiB
dd if=/dev/zero of=./build/zero768KiB bs=1K count=768
./build/xfel-bin write 0x01B40000 ./build/zero768KiB
#./build/xfel-bin write 0x01B40000 ./build/u-boot-sunxi-with-spl.bin
./build/xfel-bin write 0x28000 ./build/syter_fel_uboot_fel.elf
./build/xfel-bin exec  0x28000
