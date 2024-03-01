# LonganPi-3H-SDK
Scripts and blobs for LonganPi 3H image build.

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

4. Build rootfs debian

In Ubuntu, you need
```shell
sudo apt install debian-archive-keyring
```

```shell
sudo ./mkrootfs.sh
# or ./mkrootfs-ubuntu.sh
```

