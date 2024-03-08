# LonganPi-3H-SDK
Scripts and blobs for LonganPi 3H image build.
> Tested on Ubuntu 22.04.2 LTS

0. Install some dependencies
```shell
sudo apt install gcc-aarch64-linux-gnu mmdebstrap git debian-archive-keyring
```

2. Build arm-trusted-firmware
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

4. Build rootfs debian

```shell
sudo ./mkrootfs.sh
# or ./mkrootfs-ubuntu.sh
```

