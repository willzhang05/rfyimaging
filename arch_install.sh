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

for i in `seq 1 8`; do pvremove -ff /dev/sdb$i; done
for i in `seq 1 8`; do parted /dev/sdb rm $i; done

parted --script /dev/sda mklabel msdos
parted /dev/sda unit cyl mkpart primary 1 15
parted /dev/sda unit cyl mkpart primary 15 1216
parted /dev/sda unit cyl mkpart primary 1216 -- -0
parted /dev/sda set 1 boot on
sfdisk --change-id /dev/sda 3 8e

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
