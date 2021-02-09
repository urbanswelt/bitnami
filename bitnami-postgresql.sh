#!/bin/bash

#always up to date
sudo apt update && sudo apt upgrade --yes

#enable ssh
wget https://raw.githubusercontent.com/urbanswelt/bitnami/main/bitnami-ssh-setup.sh
bash bitnami-ssh-setup.sh
#ssh audit overview
read -p "Press [Enter] key to continue..."

#dns setup - restart script !!!
wget https://raw.githubusercontent.com/urbanswelt/bitnami/main/bitnami-local_dns-setup.sh
bash bitnami-local_dns-setup.sh
