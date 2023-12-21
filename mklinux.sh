#!/usr/bin/env bash

mkdir -p build

if [ -z "$URL" ]
then
	export URL="https://mirrors.bfsu.edu.cn/git/linux.git"
fi

if [ -z "$BRANCH" ]
then
	export BRANCH="master"
fi

if [ -z "$CROSS_COMPILE" ]
then
	export CROSS_COMPILE="aarch64-linux-gnu-"
fi

if [ -z "$CONFIG" ]
then
	export CONFIG="longanpi_3h_defconfig"
fi

set -eux

if [ ! -e build/linux ] 
then
	git clone $URL build/linux --branch=${BRANCH}
	cd build/linux
	git checkout 3b47bc037bd44f142ac09848e8d3ecccc726be99
	find ../../linux/ -name *.patch | sort | while read line
	do
		git am < $line
	done
	cd ../../
fi

cd build/linux
export ARCH=arm64
export INSTALL_PATH=$(pwd)/_install/boot/
export INSTALL_MOD_PATH=$(pwd)/_install/
rm -rf ${INSTALL_PATH}
rm -rf ${INSTALL_MOD_PATH}
mkdir -p ${INSTALL_PATH}
mkdir -p ${INSTALL_MOD_PATH}
make mrproper
make $CONFIG
make -j$(nproc)
make install
make dtbs_install
make modules_install
cd _install/boot
cp vmlinuz* Image
cd dtbs
cp -r $(ls)/* ./
cd ../../
mkdir usr
mv lib usr
cd ../
cp -r _install/* ../../overlay/
