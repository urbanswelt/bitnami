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

#Remove small Diffie-Hellman moduli
awk '$5 >= 3071' /etc/ssh/moduli > "${HOME}/moduli.safe"
sudo su -c " chown root:root "${HOME}/moduli.safe" "
sudo su -c " mv ${HOME}/moduli.safe /etc/ssh/moduli "

#download sshd_config templates
sudo su -c ' wget https://raw.githubusercontent.com/urbanswelt/bitnami/main/sshd_config.template '
sudo su -c ' wget https://raw.githubusercontent.com/urbanswelt/bitnami/main/sshd_config.PasswordAuthentication '

#backup original sshd_config
sudo su -c " mv /etc/ssh/sshd_config /etc/ssh/sshd_config.original "
sudo su -c " mv ${HOME}/sshd_config.PasswordAuthentication /etc/ssh/sshd_config "

#enable ssh
sudo rm -f /etc/ssh/sshd_not_to_be_run
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

sudo su -c " mv ${HOME}/sshd_config.template /etc/ssh/sshd_config "
sudo systemctl restart ssh

#show status of ssh-audit
sudo apt install ssh-audit
clear
ssh-audit localhost

