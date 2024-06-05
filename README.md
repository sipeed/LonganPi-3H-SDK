# LonganPi-3H-SDK

# Prebuild Download

latest build: https://github.com/sipeed/LonganPi-3H-SDK/actions

Scripts and blobs for LonganPi 3H image build.
> Tested on Ubuntu 22.04.2 LTS and WSL2 Ubuntu-22.04

0. Install some dependencies
```shell
sudo apt update
sudo apt install qemu-user-static gcc-aarch64-linux-gnu mmdebstrap git binfmt-support make build-essential  bison flex make gcc libncurses-dev debian-archive-keyring swig libssl-dev bc python3-setuptools python3-dev genimage debhelper fuse2fs rsync kmod cpio debian-keyring fuse
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

4. add extra files for longanpi3h

```shell
./mkoverlay.sh
```

5. Build debian rootfs

```shell
./mkrootfs.sh
```

6. Build sdcard image

```shell
./mkimage.sh
```
