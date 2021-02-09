  
#!/bin/bash

# Ansi color code variables
red="\e[0;91m"
blue="\e[0;94m"
expand_bg="\e[K"
blue_bg="\e[0;104m${expand_bg}"
red_bg="\e[0;101m${expand_bg}"
green_bg="\e[0;102m${expand_bg}"
green="\e[0;92m"
white="\e[0;97m"
bold="\e[1m"
uline="\e[4m"
reset="\e[0m"

#local DNS resolver
sudo apt install avahi-daemon libnss-mdns avahi-utils --yes

#dbus is missing for hostnamectl
sudo apt install dbus --yes
echo -e
echo -e
echo -e "${red}##############################################################"
echo "  The machine will be restarted ,"
echo "  after the new hostname is assigned"
echo -e "##############################################################${reset}"
echo -e
read -p "Please choose your new Hostname: "  newhostname
echo -e
read -p "Press [Enter] key to continue..."
sudo hostnamectl set-hostname $newhostname
sudo shutdown -r now
