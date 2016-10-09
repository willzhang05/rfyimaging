#!/bin/bash

# Final hostname of target
HOSTNAME="rfy"

ROOT_PASSWORD="rfy"

USER="rfy"
USER_PASSWORD="rfy"

DISK="/dev/sda"

for i in `seq 1 8`; do pvremove -ff /dev/sda$i; done
for i in `seq 1 8`; do parted /dev/sda rm $i; done

set -e

parted --script $DISK mklabel msdos \
    mkpart primary 2MiB 100MiB \
    mkpart primary 100MiB 2100MiB \
    mkpart primary 2100MiB 100%

parted $DISK set 1 boot on

# Initialize filesystems
yes | mkfs.ext4 "$DISK"3
yes | mkfs.ext2 "$DISK"1
mkswap "$DISK"2
swapon "$DISK"2

mount "$DISK"3 /mnt
mkdir /mnt/boot
mount "$DISK"1 /mnt/boot

dhcpcd

pacstrap -i /mnt base base-devel grub xorg-server gnome gnome-extra gnome-keyring xf86-input-synaptics xf86-video-intel xf86-video-ati xf86-video-nouveau firefox chromium libreoffice network-manager-applet wpa_supplicant wireless_tools --noconfirm

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

    echo "root:$ROOT_PASSWORD" | chpasswd
    groupadd rfy
    groupadd sudo
    useradd "$USER" -d /home/rfy -m -g rfy -G sudo
    echo "$USER:$USER_PASSWORD" | chpasswd

    grub-install --target=i386-pc $DISK
    grub-mkconfig -o /boot/grub/grub.cfg
    systemctl enable gdm
    systemctl enable NetworkManager
    systemctl enable wpa_supplicant
    echo "Ready"
    exit    
"
unmount -R /mnt
reboot
