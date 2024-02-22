#!/usr/bin/env bash

if [ -z "$MMDEBSTRAP" ]
then
	MMDEBSTRAP=mmdebstrap
fi

mkdir build

set -eux

genrootfs() {
echo "
deb https://mirrors.bfsu.edu.cn/debian/ testing main contrib non-free non-free-firmware
deb https://mirrors.bfsu.edu.cn/debian/ testing-updates main contrib non-free non-free-firmware
deb https://mirrors.bfsu.edu.cn/debian/ testing-backports main contrib non-free non-free-firmware
deb https://mirrors.bfsu.edu.cn/debian-security/ testing-security main contrib non-free non-free-firmware
" | $MMDEBSTRAP  unstable sid \
  --aptopt='Dir::Etc::Trusted "/usr/share/keyrings/debian-archive-keyring.gpg"' --architectures=arm64 -v -d \
	--include="ca-certificates locales dosfstools binutils file \
	tree sudo bash-completion memtester openssh-server wireless-regdb \
	wpasupplicant systemd-timesyncd usbutils parted systemd-sysv \
	iperf3 stress-ng avahi-daemon tmux screen i2c-tools net-tools \
	ethtool ckermit lrzsz minicom picocom btop neofetch iotop htop \
	bmon e2fsprogs nvi tcpdump alsa-utils squashfs-tools evtest \
	bluez bluez-hcidump bluez-tools btscanner bluez-alsa-utils \
	device-tree-compiler debian-archive-keyring connman-gtk chromium\
	linux-cpupower task-xfce-desktop xfce4-terminal xfce4-screenshooter \
	pulseaudio-module-bluetooth blueman fonts-noto-core fonts-noto-cjk \
	fonts-noto-mono fonts-noto-ui-core tango-icon-theme" > ./build/rootfs.tar
}

# if you want skip debian rootfs build, please comment this line:
genrootfs
cd overlay
for i in *
do
tar --append --file=../build/rootfs.tar $i
done
cd ..
