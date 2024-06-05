#!/usr/bin/env bash

mkdir -p build

if [ -z "$URL" ]
then
	export URL="https://github.com/YuzukiHD/SyterKit"
fi

if [ -z "$BRANCH" ]
then
	export BRANCH="main"
fi

set -eux

if [ ! -e build/syterkit ] 
then
	git clone $URL build/syterkit --branch=${BRANCH}
	cd build/syterkit
	find ../../syterkit/ -name *.patch | sort | while read line
	do
		git am < $line
	done
	cd ../../
fi

rm -rf build/syterkit/build
cd build/syterkit
mkdir build
cd build
cmake .. -DCMAKE_BOARD_FILE=longanpi-3h.cmake
make -j$(nproc)
find board/longanpi-3h/ -name *.elf | while read line 
do
	cp -v $line ../../
done
