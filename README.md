# Table of Contents

[TOC]

# LonganPi-3H-SDK
Scripts and blobs for LonganPi 3H image build.
> Tested on Ubuntu 22.04.2 LTS and WSL2 Ubuntu-22.04

## Command Line Build

0. Install some dependencies
```shell
sudo apt update
sudo apt install qemu-user-static gcc-aarch64-linux-gnu mmdebstrap git binfmt-support make build-essential  bison flex make gcc libncurses-dev debian-archive-keyring swig libssl-dev bc python3-setuptools
```

1. Build arm-trusted-firmware
```shell
./mkatf.sh
```

2. Build uboot
```shell
./mkuboot.sh
```

3. Build kernel
```shell
./mklinux.sh
```

4. Build rootfs

```shell
# for Debian desktop
sudo ./mkrootfs-debian-gui.sh

# for Debian without gui
# sudo ./mkrootfs-debian-cli.sh

# for Ubuntu without gui
# sudo ./mkrootfs-ubuntu-cli.sh
```

## Docker build

**Note:** The container to execute the actual image build is run with the `--privileged` flag (due to `quemu` usage). If you cannot run privileged containers in your environment then the docker build will most likely not work for you.

If you have `make` and `docker` installed you can also build the image with docker. The `Makefile` has two utility targets and two main group of targets that you can run. An `out/` folder will be created which is mounted into the container and the output files will be copied in there.

### Utility Targets

```shell
# Just build the build-container
make build

# remove the out/ directory
make clean
```

### Targets to build the root FS and boot files

```shell
# Build Debian desktop root FS
make debian-gui

# Build Debian root FS without gui
make debian-cli

# Build Ubuntu root FS without gui
make ubuntu-cli
```

### Targets to build the full image

```shell
# Build Debian desktop image
make debian-gui-img

# Build Debian image without gui
make debian-cli-img

# Build Ubuntu image without gui
make ubuntu-cli-img
```

From there you can follow https://wiki.sipeed.com/hardware/en/longan/h618/lpi3h/7_develop_mainline.html to create a boot card.