#!/bin/bash

## credit to: https://gist.github.com/mtnygard/9cfef214c6942171a578da11741a9d85#file-find_mirrors-sh

# URL of the Launchpad mirror list
MIRROR_LIST=https://launchpad.net/ubuntu/+archivemirrors

# Set to the architecture you're looking for (e.g., amd64, i386, arm64, armhf, armel, powerpc, ...).
# See https://wiki.ubuntu.com/UbuntuDevelopment/PackageArchive#Architectures
ARCH=$1
# Set to the Ubuntu distribution you need (e.g., precise, saucy, trusty, ...)
# See https://wiki.ubuntu.com/DevelopmentCodeNames
DIST=$2
# Set to the repository you're looking for (main, restricted, universe, multiverse)
# See https://help.ubuntu.com/community/Repositories/Ubuntu
REPO=$3

# First, we retrieve the Launchpad mirror list, and massage it to obtain a newline-separated list of HTTP mirrors
for url in $(curl -s $MIRROR_LIST | grep -Po 'http://.*(?=">http</a>)'); do
  # If you like some output while the script is running (feel free to comment out the following line)
  echo "Processing $url..."
  # retrieve the header for the URL $url/dists/$DIST/$REPO/binary-$ARCH/; check if status code is of the form 2.. or 3..
  curl -s --head $url/dists/$DIST/$REPO/binary-$ARCH/ | head -n 1 | grep -q "HTTP/1.[01] [23].."
  # if successful, output the URL
  [ $? -eq "0" ] && echo "FOUND: $url"
done
