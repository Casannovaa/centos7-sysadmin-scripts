#!/bin/bash
# 
# DNS configuration on CentoOS7
# Tools used: bind & bind-utils
# Daemons used: named

# Hostname Domain Change
read -p "Declare new hostname (With Domain included [whatever.whatever.whatever]) > " hst
echo "$hst" > /etc/hostname

# Installing DNS tools (bind)
yum install -y bind bind-utils

#Enabling Daemon
systemctl enable named

# Firewall rules for DNS passthrough
firewall-cmd --permanent --zone=public --add-service=dns
firewall-cmd --permanent --zone=internal --add-service=dns
firewall-cmd --reload

# DNS Configuration
read -p "Internal network interface? (enp0s8??) > " intif
servip=$(ip a | grep "inet" | grep $intif | awk '{print $2}' | awk -F / '{print $1}')
ddom=$(cat /etc/dhcp/dhcpd.conf | grep "option domain-name " | awk -F \" '{print $2}')


echo '
options {
	listen-on port 53 { 127.0.0.1; '$servip'; };
	# listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	recursing-file  "/var/named/data/named.recursing";
	secroots-file   "/var/named/data/named.secroots";
	allow-query     { any; };
	recursion yes;
	dnssec-enable yes;
	dnssec-validation yes;

	/* Path to ISC DLV key */
	bindkeys-file "/etc/named.root.key";
	managed-keys-directory "/var/named/dynamic";
	pid-file "/run/named/named.pid";
	session-keyfile "/run/named/session.key";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
	type hint;
	file "named.ca";
};

zone "'"$ddom"'" IN {
    type master;
    file "named.'"$ddom"'";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";' > /etc/named.conf

echo "Domain used for DNS server configuration --> $ddom"
echo "If don't want that, change manually in /etc/named.conf"

read -p "Bind named process option [Recommended: -4] --> " bind
echo '
# BIND named process options
# ~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# OPTIONS="'"$bind"'"     --  These additional options will be passed to named
#                            at startup. Dont add -t here, enable proper
#                            -chroot.service unit file.
#                            Use of parameter -c is not supported here. Extend
#                            systemd named*.service instead. For more
#                            information please read the following KB article:
#                            https://access.redhat.com/articles/2986001
#
# DISABLE_ZONE_CHECKING  --  By default, service file calls named-checkzone
#                            utility for every zone to ensure all zones are
#                            valid before named starts. If you set this option
#                            to *yes* then service file doesnt perform those
#                            checks.' > /etc/sysconfig/named

hst=$(cat /etc/hostname)
name=$(cat /etc/hostname | awk -F . '{print $1}')

echo "
\$TTL    1D
@       IN      SOA     $hst. root.$ddom. (
                            202107101   ; serial
                            604800  ; refresh
                            86400   ; retry
                            2419200 ; expiration
                            604800  ; TTL negative cache
);

; NameServers
@               IN      NS      $hst.

; Registers
$name       IN      A       $servip" > /var/named/named."$ddom"

echo "DNS should be configured successfully"
systemctl start named
systemctl enable named
echo "You might need to reboot the PC"
