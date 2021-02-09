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

#https://techstop.github.io/bash-script-colors/#:~:text=Colors%20in%20bash%20scripts%20can%20be%20used%20to,Background%20colors%20can%20be%20used%20for%20section%20separation.
#https://www.ssh-audit.com/hardening_guides.html

#Re-generate the RSA and ED25519 keys
sudo su -c "rm /etc/ssh/ssh_host_*" 
sudo su -c ' ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N "" '
sudo su -c ' ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N "" '

read -p "Press [Enter] key to continue..."

#Remove small Diffie-Hellman moduli
sudo su -c ' awk '$5 >= 3071' /etc/ssh/moduli > /etc/ssh/moduli.safe '
sudo su -c " mv /etc/ssh/moduli.safe /etc/ssh/moduli "

read -p "Press [Enter] key to continue..."

#download sshd_config templates
sudo su -c ' wget https://raw.githubusercontent.com/urbanswelt/bitnami/main/sshd_config.template '
sudo su -c ' wget https://raw.githubusercontent.com/urbanswelt/bitnami/main/sshd_config_w_pw_enabled '

read -p "Press [Enter] key to continue..."

#backup original sshd_config
sudo su -c " mv /etc/ssh/sshd_config /etc/ssh/sshd_config.original "
sudo su -c " mv sshd_config_w_pw_enabled /etc/ssh/sshd_config "

read -p "Press [Enter] key to continue..."

#enable ssh
sudo systemctl enable ssh
sudo systemctl start ssh

echo -e
echo -e
echo -e "${red}##############################################################"
echo "  temporarily ssh with password login is allowed,"
echo "  please add your key to ~/.ssh/authorized_keys"
echo -e "##############################################################${reset}"
echo -e
echo -e
read -p "Press [Enter] key to continue..."

