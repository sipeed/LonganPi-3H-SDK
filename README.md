# LonganPi-3H-SDK
Scripts and blobs for LonganPi 3H image build.
> Tested on Ubuntu 22.04.2 LTS and WSL2 Ubuntu-22.04

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

