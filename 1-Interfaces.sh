#!/bin/bash

# Installation of Tools
echo "Installing Basic Tools"
yum -y install nano net-tools

# Information Gathering for Interface Configuration
read -p "Netmask > " mask
read -p "Prefix (24, 16 or 8) > " prefix
read -p "Default Gateway > " gateway

# Interfaces Configuration
echo "Configuring enp0s3..."
uuid=$(cat /etc/sysconfig/network-scripts/ifcfg-enp0s3 | grep UUID)
echo '
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s3
'$uuid'
DEVICE=enp0s3
ONBOOT=yes
' > /etc/sysconfig/network-scripts/ifcfg-enp0s3

echo "Configuring enp0s8..."
uuid8=$(cat /etc/sysconfig/network-scripts/ifcfg-enp0s8 | grep UUID)
echo '
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s8
'$uuid8'
DEVICE=enp0s8
ONBOOT=yes
IPADDR='$gateway'
NETMASK='$mask'
PREFIX='$prefix'
' > /etc/sysconfig/network-scripts/ifcfg-enp0s8

/sbin/reboot
