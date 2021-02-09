#!/bin/bash
#local DNS resolver
sudo apt install avahi-daemon libnss-mdns avahi-utils --yes

#dbus is missing for hostnamectl
sudo apt install dbus --yes
read -p "Please choose your new Hostname: "  newhostname
sudo hostnamectl set-hostname $newhostname
sudo shutdown -r now
