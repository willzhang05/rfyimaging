#!/bin/bash

mount /root/ubuntu/ubuntu-16.04.1-desktop-i386.iso /mnt/ubuntu/i386
mount /root/ubuntu/ubuntu-16.04.1-desktop-amd64.iso /mnt/ubuntu/amd64
mount /root/arch.iso /mnt/arch

ip link set enp0s25 up
ip addr add 198.168.0.1/24 dev enp0s25

systemctl start dnsmasq
darkhttpd /srv/pxe/arch --port 8081
