#!/bin/bash
#Routing
echo "Routing..."
firewall-cmd --get-active-zone
read -p "External network interface ¿enp0s3? > " ifext
read -p "Internal network interface ¿enp0s8? > " ifint 

# Assignation of Interfaces Rol
nmcli c mod $ifint connection.zone internal
nmcli c mod $ifext connection.zone external

# Assignation Confirmation
firewall-cmd --get-active-zone

# It's all alright?
read -p "¿¿internal=$ifint & external=$ifext?? [Y / N]" confir
if [ "$confir" == "Y"  ]
then
	echo Nice!
	sleep 1
else
	exit
fi

firewall-cmd --zone=external --add-masquerade --permanent
firewall-cmd --reload
firewall-cmd --zone=external --query-masquerade

confi=$(cat /proc/sys/net/ipv4/ip_forward)
if [ "$confi" == "1" ]
then
	cat /proc/sys/net/ipv4/ip_forward
	echo "It seems ok..."
fi

firewall-cmd --zone=internal --add-masquerade --permanent
firewall-cmd --reload
firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -o $ifext -j MASQUERADE
firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i $ifint -o $ifext -j ACCEPT
firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i $ifext -o $ifint -m state --state RELATED,ESTABLISHED -j ACCEPT
firewall-cmd --reload

clear
echo "Succesfully Configured, Restart needed"
