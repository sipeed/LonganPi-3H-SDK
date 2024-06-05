#!/usr/bin/env bash

mkdir -p build

if [ -z "$URL" ]
then
	export URL="https://github.com/xboot/xfel"
fi

if [ -z "$BRANCH" ]
then
	export BRANCH="master"
fi

set -eux

if [ ! -e build/xfel ] 
then
	git clone $URL build/xfel --branch=${BRANCH}
	cd build/xfel
	find ../../xfel/ -name *.patch | sort | while read line
	do
		git am < $line
	done
	cd ../../
fi

cd build/xfel
make clean
make -j$(nproc)
cp xfel ../xfel-bin
