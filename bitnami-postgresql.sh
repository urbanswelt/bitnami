#!/bin/bash

#always up to date
sudo apt update && sudo apt upgrade --yes

#enable ssh
wget https://raw.githubusercontent.com/urbanswelt/bitnami/main/bitnami-ssh-setup.sh
bash bitnami-ssh-setup.sh

#dns setup - restart script !!!
wget https://raw.githubusercontent.com/urbanswelt/bitnami/main/bitnami-local_dns-setup.sh
bash bitnami-local_dns-setup.sh
