#!/usr/bin/env bash

if [ -z "$MMDEBSTRAP" ]
then
        MMDEBSTRAP=mmdebstrap
fi

mkdir -p build

set -eux

genrootfs() {
echo "
deb http://ports.ubuntu.com/ubuntu-ports/ jammy main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ jammy-updates main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ jammy-backports main restricted universe multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ jammy-security main restricted universe multiverse

" | $MMDEBSTRAP --architectures=arm64 -v -d \
        --include="ca-certificates locales dosfstools binutils file \
        tree sudo bash-completion memtester openssh-server wireless-regdb \
        wpasupplicant systemd-timesyncd usbutils parted systemd-sysv \
        iperf3 stress-ng avahi-daemon tmux screen i2c-tools net-tools \
        ethtool ckermit lrzsz minicom picocom btop neofetch iotop htop \
        bmon e2fsprogs nvi tcpdump alsa-utils squashfs-tools evtest \
        bluez bluez-hcidump bluez-tools btscanner bluez-alsa-utils \
        device-tree-compiler ubuntu-keyring connman-gtk chromium-browser \
        xfce4 xfce4-terminal xfce4-screenshooter \
        pulseaudio-module-bluetooth blueman fonts-noto-core fonts-noto-cjk \
        fonts-noto-mono fonts-noto-ui-core tango-icon-theme" > ./build/rootfs-ubuntu.tar
}

# if you want skip Ubuntu rootfs build, please comment this line:
genrootfs
cd overlay
for i in *
do
tar --append --file=../build/rootfs-ubuntu.tar $i
done
cd ..
