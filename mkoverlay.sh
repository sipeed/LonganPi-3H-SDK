#!/usr/bin/env bash

mkdir build

set -eux

dpkg-deb --root-owner-group --build overlay
mv overlay.deb ./build/
