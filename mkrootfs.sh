#!/usr/bin/env bash

if [ -z "$MMDEBSTRAP" ]
then
    MMDEBSTRAP=mmdebstrap
fi

if [ -z "$MIRROR" ]
then
    MIRROR="http://ftp.debian.org"
fi

if [ -z "$CODENAME" ]
then
    CODENAME=stable
fi

if [ -z "$USER_PACKAGE" ]
then
    USER_PACKAGE=""
fi

BASE_PACKAGE="ca-certificates locales dosfstools binutils file \
	tree sudo bash-completion memtester openssh-server wireless-regdb \
	wpasupplicant systemd-timesyncd usbutils parted systemd-sysv \
	iperf3 stress-ng avahi-daemon tmux screen i2c-tools net-tools \
	ethtool ckermit lrzsz minicom picocom btop neofetch iotop htop \
	bmon e2fsprogs nvi tcpdump alsa-utils squashfs-tools evtest \
	pssh tcl-expect tcl atftp udpcast u-boot-menu initramfs-tools \
	bluez bluez-hcidump bluez-tools btscanner bluez-alsa-utils \
	device-tree-compiler debian-archive-keyring linux-cpupower \
        network-manager"

if [ -z "$DESKTOP_PACKAGE" ]
then
    DESKTOP_PACKAGE="chromium task-xfce-desktop \
    xfce4-terminal xfce4-screenshooter pulseaudio-module-bluetooth \
    blueman fonts-noto-core fonts-noto-cjk fonts-noto-mono \
    fonts-noto-ui-core tango-icon-theme"
fi

NOGUI=0
if [ "${NOGUI}" -eq 1 ]
then
    DESKTOP_PACKAGE=""
fi

mkdir build

set -eux


genrootfs() {
    echo "
deb ${MIRROR}/debian/ ${CODENAME} main contrib non-free non-free-firmware
deb ${MIRROR}/debian/ ${CODENAME}-updates main contrib non-free non-free-firmware
" | $MMDEBSTRAP --aptopt='Dir::Etc::Trusted "/usr/share/keyrings/debian-archive-keyring.gpg"' --architectures=arm64 -v -d \
		--customize-hook='chroot "$1" useradd --home-dir /home/sipeed --create-home sipeed --shell /bin/bash' \
		--customize-hook='echo sipeed:licheepi | chroot "$1" chpasswd' \
		--customize-hook='chroot "$1" usermod -a -G dialout sipeed' \
		--customize-hook='chroot "$1" usermod -a -G cdrom sipeed' \
		--customize-hook='chroot "$1" usermod -a -G audio sipeed' \
		--customize-hook='chroot "$1" usermod -a -G video sipeed' \
		--customize-hook='chroot "$1" usermod -a -G plugdev sipeed' \
		--customize-hook='chroot "$1" usermod -a -G users sipeed' \
		--customize-hook='chroot "$1" usermod -a -G netdev sipeed' \
		--customize-hook='chroot "$1" usermod -a -G input sipeed' \
		--customize-hook='chroot "$1" usermod -a -G sudo sipeed' \
		--customize-hook='echo root:root | chroot "$1" chpasswd' \
		--customize-hook='sed -i -e s/workstation=no/workstation=yes/g "$1"/etc/avahi/avahi-daemon.conf' \
		--customize-hook='echo U_BOOT_PARAMETERS=\"console=tty0 console=ttyS0,115200 rootwait earlycon clk_ignore_unused rw\" >> "$1"/etc/default/u-boot' \
		--customize-hook='echo U_BOOT_ROOT=\"root=LABEL=lpi3h-root\" >> "$1"/etc/default/u-boot' \
		--customize-hook='cat "$1"/etc/default/u-boot' \
		--customize-hook='cp ./build/*.deb "$1/opt/" ' \
		--customize-hook='chroot "$1" sh -c "dpkg -i /opt/*.deb"' \
		--include="${BASE_PACKAGE} ${DESKTOP_PACKAGE} ${USER_PACKAGE}" > ./build/rootfs.tar
}

genrootfs
