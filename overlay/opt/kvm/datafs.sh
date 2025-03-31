#!/bin/bash

# Disk operations require root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with root privileges" >&2
    exit 1
fi

if id "kvmd" &>/dev/null; then
    _UID=$(id -u kvmd)
    _GID=$(id -g kvmd)
else
    _UID=0
    _GID=0
fi

# Define the target disk (modify according to actual situation)
DISK=$(ls /dev/mmcblk* | grep boot | head -n 1 | sed -e 's/boot0//g')
TARGET_PARTITION="" # Store the detected target partition
TARGET_DIR="/data"

# Detect the suitable end partition
detect_target_partition() {
    # Get all partition information and sort by end sector
    local last_part_info=$(fdisk -l $DISK | awk '/^\/dev/ {print $1,$3}' | sort -k2 -n | tail -1)
    TARGET_PARTITION=$(echo "$last_part_info" | awk '{print $1}')
    local part_size_mb=$(($(echo "$last_part_info" | awk '{print $2}') / 2048)) # Convert to MB

    if [ "$part_size_mb" -le 64 ]; then
        echo "No suitable <64MB end partition found" >&2
        exit 2
    fi
}

# Unmount partition
umount_partition() {
    if mount | grep -q "$TARGET_PARTITION"; then
        echo "Unmounting partition $TARGET_PARTITION..."
        umount "$TARGET_PARTITION" || {
            echo "Unmount failed, please close related processes" >&2
            exit 3
        }
    fi
}

# Use growpart to expand partition (with dry-run check)
resize_partition() {
    local part_num=$(echo "$TARGET_PARTITION" | grep -oE '[0-9]+$')
    echo "Checking if partition $TARGET_PARTITION needs resizing..."

    if growpart --dry-run "$DISK" "$part_num" >/dev/null 2>&1; then
        echo "Expanding partition to maximum available space..."
        growpart "$DISK" "$part_num" || {
            echo "Partition expansion failed" >&2
            exit 4
        }
        return 0 # succ status
    else
        echo "Partition $TARGET_PARTITION does not need resizing, skipping."
        return 1 # skip status
    fi
}

# Adjust file system only if partition was resized
resize_filesystem() {
    echo "Adjusting file system..."
    # mkfs
    mkfs.exfat -n "EXPANDED" "$TARGET_PARTITION" || {
        echo "File system adjustment failed" >&2
        exit 5
    }
}

mount_datafs() {
    if [ ! -d "$TARGET_DIR" ]; then
        mkdir -p "$TARGET_DIR"
        echo "The directory has been created: $TARGET_DIR"
    else
        echo "The directory already exists: $TARGET_DIR"
    fi

    if ! mountpoint -q "$TARGET_DIR"; then
        echo "Trying to mount partition $TARGET_PARTITION to $TARGET_DIR..."
        mount -o uid=$_UID,gid=$_GID "$TARGET_PARTITION" "$TARGET_DIR"
        if [ $? -eq 0 ]; then
            echo "Mounting was successful!"
            df -h | grep "$TARGET_DIR"
        else
            echo "Mounting failed. Please check if the device exists or if there are permission issues!"
            exit 6
        fi
    else
        echo "The partition is already mounted to $TARGET_DIR"
    fi
}

# Main process
main() {
    detect_target_partition
    echo "Target partition: $TARGET_PARTITION"
    umount_partition

    if resize_partition; then
        resize_filesystem
    fi

    fdisk -l "$DISK" | grep "$TARGET_PARTITION"
    mount_datafs
    echo "$TARGET_PARTITION" >/boot/datafs.txt
}

main
