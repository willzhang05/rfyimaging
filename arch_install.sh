#!/bin/bash

set -e

# Final hostname of target
HOSTNAME="rfy"

ROOT_PASSWORD="rfy"

USER="rfy"
USER_PASSWORD="password"

DISK="/dev/sda"
BOOT_PARTITION="$DISK1"
SWAP_PARTITION="$DISK2"
ROOT_PARTITION="$DISK3"


for i in `seq 1 8`; do pvremove -ff /dev/sda$i; done
for i in `seq 1 8`; do parted /dev/sda rm $i; done

parted --script $DISK mklabel gpt \
    mkpart primary 1MiB 100MiB \
    mkpart primary 100MiB 2100MiB \
    mkpart primary 2100MiB 100%

parted $DISK set 1 boot on

# Initialize filesystems
mkfs.ext4 $ROOT_PARTITION
mkfs.ext4 $BOOT_PARTITION
mkswap $SWAP_PARTITION
swapon $SWAP_PARTITION

mount $ROOT_PARTITION /mnt
mount $BOOT_PARTITION /mnt/boot
pacstrap -i /mnt base base-devel

# Generated fstab subject for review
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash -c "
    set -e

    ln -s /usr/share/zoneinfo/America/New_York /etc/localtime
    hwclock --systohc --utc

    locale-gen
    echo LANG=en_US.UTF-8 > /etc/locale.conf

    echo $HOSTNAME > /etc/hostname
    echo 127.0.0.1 $HOSTNAME.localdomain $HOSTNAME > /etc/hosts

    mkinitcpio -p linux

    echo $ROOT_PASSWORD | passwd --stdin

    adduser "$USER"
    echo $USER_PASSWORD | passwd $USER --stdin
"
