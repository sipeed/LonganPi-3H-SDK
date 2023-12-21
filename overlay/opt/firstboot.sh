#!/bin/bash

PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
export PATH

# resize root filesystem
parted -s /dev/mmcblk0 "resizepart 2 -0"
resize2fs /dev/mmcblk0p2

# generate locale data
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen

# add normal user
useradd -s /bin/bash -m -k /etc/skel sipeed
echo 'sipeed:licheepi' | chpasswd
echo 'root:root' | chpasswd
usermod -a -G dialout sipeed
usermod -a -G cdrom sipeed
usermod -a -G sudo sipeed
usermod -a -G audio sipeed
usermod -a -G video sipeed
usermod -a -G plugdev sipeed
usermod -a -G users sipeed
usermod -a -G netdev sipeed

# change hostname
NEW_HOSTNAME="lpi3h-$(cat /sys/class/net/end0/address | tr -d ':\n' | tail -c 4)"
echo "NEW HOSTNAME: $NEW_HOSTNAME"
echo "$NEW_HOSTNAME" > /etc/hostname
echo "127.0.0.1	$NEW_HOSTNAME" > /etc/hosts
hostname "$NEW_HOSTNAME"
nmcli general hostname "$NEW_HOSTNAME"
systemctl enable avahi-daemon

# regenerate openssh host keys
dpkg-reconfigure openssh-server

# enable rc-local service
systemctl enable rc-local

# change the timezone
timedatectl set-timezone Asia/Shanghai

# enable wifi/bt/eth
connmanctl enable bluetooth
connmanctl enable wifi
connmanctl enable ethernet

