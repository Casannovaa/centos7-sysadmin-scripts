#!/bin/bash

#DHCP Deamon Installation
echo "Installing DHCP..."
sleep 1
yum -y install dhcp
clear

# Variables Gathering & Assignation
read -p "Domain > " domain
read -p "Network IP (.0) > " ipp
read -p "Netmask > " mask
read -p "Initial IP Range > " initial
read -p "End IP Range > " end
read -p "DNS > " dns
read -p "Broadcast Address > " broadcast
read -p "Default Gateway > " gateway


# /etc/dhcp/dhcpd.conf Configuration
echo 'option domain-name "'$domain'";
option domain-name-servers '$ipp';
default-lease-time 86400;
max-lease-time 172800;
authoritative;
subnet '$ip' netmask '$mask' {
	range dynamic-bootp '$initial' '$end';
	option domain-name-servers '$gateway', '$dns';
	option broadcast-address '$broadcast';
	option routers '$gateway';
	option domain-name-servers '$gateway';
}' > /etc/dhcp/dhcpd.conf


# DHCP Daemon Initialization
echo Starting Service
systemctl start dhcpd
echo "If nothing appeared, it's all ok"
sleep 2

echo Activating Service
systemctl enable dhcpd
