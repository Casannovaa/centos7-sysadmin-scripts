#!/bin/bash

echo instalando herramientas necesarias
sleep 0.5
yum install nano net-tools
clear



read -p "Netmask > " mask
read -p "Prefix (24, 16 or 8) > " prefix
read -p "Default Gateway > " gateway



echo configuración enp0s3
sleep 1
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
clear
sleep 1



echo configuración enp0s8
sleep 1
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
echo Rebooting...
sleep 1
reboot
