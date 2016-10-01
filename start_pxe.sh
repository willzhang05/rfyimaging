#!/bin/bash

mount /root/arch.iso /mnt/arch

ip link set enp0s25 up
ip addr add 198.168.0.1/24 dev enp0s25

systemctl start dnsmasq
darkhttpd /srv/pxe/arch
