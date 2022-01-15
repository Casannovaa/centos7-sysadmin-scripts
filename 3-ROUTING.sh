#!/bin/bash

#Routing

echo Routing...
sleep 1

echo firewall-cmd --get-active-zone
firewall-cmd --get-active-zone
sleep 1



# Assignation of Interfaces Rol
echo nmcli c mod $ifint connection.zone internal
nmcli c mod $ifint connection.zone internal
sleep 1

echo nmcli c mod $ifext connection.zone external
nmcli c mod $ifint connection.zone external
sleep 1

# Assignation Confirmation
echo firewall-cmd --get-active-zone
firewall-cmd --get-active-zone

sleep 1

# It's all alright?
read -p "¿¿internal=$ifint & external=$ifext?? (S / N)" confirmacio
if [ "$confirmacio" == "S"  ]
then
	echo Nice!
	sleep 1
else
	exit
fi

echo firewall-cmd --zone=external --add-masquerade --permanent
firewall-cmd --zone=external --add-masquerade --permanent
sleep 1

echo firewall-cmd --reload
firewall-cmd --reload
sleep 1

echo firewall-cmd --zone=external --query-masquerade
firewall-cmd --zone=external --query-masquerade

aver=$(cat /proc/sys/net/ipv4/ip_forward)
if [ "$aver" == "1" ]
then
	cat /proc/sys/net/ipv4/ip_forward
	echo It seems ok...
    sleep 1
fi

echo firewall-cmd --zone=internal --add-masquerade --permanent
firewall-cmd --zone=internal --add-masquerade --permanent
sleep 1

echo firewall-cmd --reload
firewall-cmd --reload
sleep 1

echo firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -o "$ifext" -j MASQUERADE
firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -o "$ifext" -j MASQUERADE
sleep 1

echo firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i "$ifint" -o "$ifext" -j ACCEPT
firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i "$ifint" -o "$ifext" -j ACCEPT
sleep 1

echo firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i "$ifext" -o "$ifint" -m state --state RELATED,ESTABLISHED -j ACCEPT
firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i "$ifext" -o "$ifint" -m state --state RELATED,ESTABLISHED -j ACCEPT
sleep 1

echo firewall-cmd --reload
firewall-cmd --reload
sleep 1


echo It should have been succesfully activated! :D
sleep 1

read -p 'Do you want to reboot to confirm the configuration (JIC) [Y / N]' bye
if [ "$bye" == "Y" ]
then
    echo Rebooting...
    reboot
else
    clear
    echo Enjoy!
    sleep 1
    clear
fi