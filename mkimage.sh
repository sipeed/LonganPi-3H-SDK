#!/bin/bash

if [ ! -e ./build/rootfs.tar ]
then
    echo "./build/rootfs.tar not found"
    exit 1
fi

set -eux

rm -rf build/rootfs
rm -rf build/input/
rm -rf build/root/
rm -rf build/tmp/
rm -rf build/images/
rm -rf build/sdcard.img
mkdir -pv build/rootfs
mkdir -pv build/input/
mkdir -pv build/tmp/
mkdir -pv build/root/
mkdir -pv build/images/

cp -v ./build/u-boot-sunxi-with-spl.bin ./build/input/
dd if=/dev/zero of=./build/input/rootfs.ext4 bs=1M count=3000

mkfs.ext4 -L lpi3h-root ./build/input/rootfs.ext4
mkdir -pv ./build/rootfs

if [ `id -u` -ne 0 ]
then
	fuse2fs -o fakeroot ./build/input/rootfs.ext4 ./build/rootfs
	fakeroot -- tar --numeric-owner -xpf build/rootfs.tar -C ./build/rootfs/
	sudo umount ./build/rootfs
else
	mount ./build/input/rootfs.ext4 ./build/rootfs/
	tar --numeric-owner -xpf build/rootfs.tar -C ./build/rootfs/
	umount ./build/rootfs
fi

cp -v genimage.cfg ./build/
cd ./build
genimage
cd ..

rm -rf ./build/rootfs
