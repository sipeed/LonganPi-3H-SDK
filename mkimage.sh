#!/bin/bash


# Set up variables
BUILD_DIR="./build"
CREATE_IMG="sdcard.img"

export DATE=$(date +"%Y%m%d")
CREATE_IMG="LPI3H_${DATE}.img"

BOOT_SIZE="64M"
ROOTFS_SIZE="2G"
IMAGE_SIZE="3072"
BOOT_PARTITION="${CREATE_IMG}1"
ROOTFS_PARTITION="${CREATE_IMG}2"


# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use 'sudo' or log in as root."
    exit 1
fi

# Function to convert size to megabytes
convert_to_mb() {
    local size=$1
    local number=${size%[GM]}
    local unit=${size: -1}

    case "$unit" in
        G) echo $((number * 1024)) ;;
        M) echo $number ;;
        *) echo "Invalid size: $size" >&2; exit 1 ;;
    esac
}

# Create an empty image file
# Convert sizes to megabytes
BOOT_SIZE_MB=$(convert_to_mb $BOOT_SIZE)
ROOTFS_SIZE_MB=$(convert_to_mb $ROOTFS_SIZE)
# Calculate total size in MB for dd command
TOTAL_SIZE_MB=$((BOOT_SIZE_MB + ROOTFS_SIZE_MB))

dd if=/dev/zero of="$CREATE_IMG" bs=1M count=$IMAGE_SIZE



# Create partitions using sfdisk (script friendly fdisk)
# the 2048 is the allocation so we don't ovewrite uboot
{
echo label: dos
echo start=2048, size=+${BOOT_SIZE_MB}M, type=c, bootable
echo type=83
} | sudo sfdisk "$CREATE_IMG"


# Associate loop devices
LOOP_DEV=$(losetup -fP --show "$CREATE_IMG")
if [ -z "$LOOP_DEV" ]; then
    echo "Failed to associate loop device."
    exit 1
fi


# Format partitions
echo "Formatting partitions..."

sudo mkfs.vfat -F 32 -n "boot" "${LOOP_DEV}p1" || { echo "Failed to format boot partition."; exit 1; }
sudo mkfs.ext4 -t ext4 -F -L "rootfs" "${LOOP_DEV}p2" || { echo "Failed to format rootfs partition."; exit 1; }

echo "flash uboot"
sudo dd if=$BUILD_DIR/u-boot-sunxi-with-spl.bin of="${LOOP_DEV}" bs=1k seek=8 conv=fsync


# Mount partitions
echo "Mounting partitions..."
mkdir -p /tmp/{boot,rootfs}
sudo mount "${LOOP_DEV}p1" /tmp/boot || { echo "Failed to mount boot partition."; exit 1; }
sudo mount "${LOOP_DEV}p2" /tmp/rootfs || { echo "Failed to mount rootfs partition."; exit 1; }



# Proceed with partitioning, formatting, and other steps...
# Copy kernel and device tree files
# -L to copy symlinks, since vfat filesystems don't support those!
sudo cp -Lr ./overlay/boot/. /tmp/boot

# Extract root filesystem
echo "Extracting root filesystem..."
sudo tar -xpf $BUILD_DIR/rootfs.tar -C /tmp/rootfs

# Unmount partitions
sudo umount /tmp/{boot,rootfs}

# Detach loop device
sudo losetup -d "$LOOP_DEV"

echo "finished - copy $CREATE_IMG"


# End of script
