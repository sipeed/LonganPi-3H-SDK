#!/usr/bin/env bash

if [ -z "$MMDEBSTRAP" ]; then
    MMDEBSTRAP=mmdebstrap
fi

if [ -z "$MIRROR" ]; then
    MIRROR="http://ftp.debian.org"
    # MIRROR="http://mirrors.aliyun.com"
fi

if [ -z "$CODENAME" ]; then
    CODENAME=stable
fi

if [ -z "$USER_PACKAGE" ]; then
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
    network-manager exfatprogs cloud-guest-utils xfsprogs rsync neovim \
    xz-utils curl"

if [ -z "$DESKTOP_PACKAGE" ]; then
    DESKTOP_PACKAGE="chromium task-xfce-desktop \
    xfce4-terminal xfce4-screenshooter pulseaudio-module-bluetooth \
    blueman fonts-noto-core fonts-noto-cjk fonts-noto-mono \
    fonts-noto-ui-core tango-icon-theme"
fi

if [ -z "$KVM_PACKAGE" ]; then
    KVM_PACKAGE="nginx bc expect v4l-utils iptables nfs-common dialog \
    iptables dnsmasq git tesseract-ocr tesseract-ocr-eng libasound2-dev \
    libsndfile-dev libspeexdsp-dev libdrm-dev libdbus-1-dev libglib2.0-dev \
    libsystemd-dev libevent-pthreads-2.1-7 libgssdp-1.6-0 libgupnp-1.6-0 \
    libgupnp-igd-1.0-4 liblua5.3-0 libmicrohttpd12 libnanomsg5 libnice10 \
    libpaho-mqtt1.3 librabbitmq4 libsofia-sip-ua0 libsrtp2-1 libusrsctp2 \
    libwebsockets17 libwebsockets-dev libjansson4 libogg0 libopus0 libssl3 \
    libsystemd0 zlib1g libconfig9 libcurl4 libduktape207 libxkbcommon0 \
    xkb-data libevent-2.1-7 libx264-164 libx264-dev libyuv-dev libyuv0 \
    isc-dhcp-server arp-scan hostapd"
fi

case "$1" in
"kvm")
    DESKTOP_PACKAGE=""
    ;;
"nogui")
    DESKTOP_PACKAGE=""
    ;&
*)
    KVM_PACKAGE=""
    ;;
esac

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
        --customize-hook='chroot "$1" systemctl disable avahi-daemon.socket' \
        --customize-hook='chroot "$1" systemctl disable avahi-daemon.service' \
        --customize-hook='cp overlay/etc/systemd/system/prekvm.service "$1/etc/systemd/system/"' \
        --customize-hook='chroot "$1" systemctl enable prekvm' \
        --customize-hook='chroot "$1" mkdir -p --mode=0755 /usr/share/keyrings' \
        --customize-hook='chroot "$1" sh -c "curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null"' \
        --customize-hook='chroot "$1" sh -c "curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list"' \
        --customize-hook='chroot "$1" apt update' \
        --customize-hook='chroot "$1" sh -c "apt install -y tailscale=1.80.3"' \
        --include="${BASE_PACKAGE} ${DESKTOP_PACKAGE} ${KVM_PACKAGE} ${USER_PACKAGE}" >./build/rootfs.tar
}

genrootfs
