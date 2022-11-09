# CentOS7 Server Automation Scripts (VM)

[Tested on Virtualbox & CentOS7]

Only working with two interfaces (NAT and Internal Network)

Instructions

1. ifup the interface 3 before running anything!!! >> (ifup enp0s3)
2. Set execution permissions to the scripts >> (chmod +x /centos/*)
3. Execute the first script (./1-configure-interfaces.run)
4. First script will reboot your VM
5. execute the second command (./2-dhcp-and-routing.run)
