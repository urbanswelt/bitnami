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

if [ $(id -u) -ne 0 ]; then
  printf "Script must be run as root. Try 'sudo ./$0'\n"
  exit 1
fi

apt -qq update
apt -qq install -y dialog

main_hostname_setup ()
{
#dbus is missing for hostnamectl
apt -qq install dbus --yes

echo -e
echo -e
echo -e "${red}##############################################################"
echo "  The machine must be restarted ,"
echo "  after the new hostname is assigned"
echo -e "##############################################################${reset}"
echo -e
unset newhostname
while [ -z ${newhostname} ]; do
     read -p "Please choose your new Hostname: "  newhostname
done
echo -e
hostnamectl set-hostname $newhostname
state1=!!!RESTART!!!
}

main_dns_setup ()
{
#local DNS resolver
apt -qq install avahi-daemon libnss-mdns avahi-utils --yes
state2=!!!DONE!!!
}

main_ssh_setup ()
{

#Re-generate the RSA and ED25519 keys
#su -c "rm /etc/ssh/ssh_host_*" 
#su -c ' ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N "" '
#su -c ' ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N "" '
rm /etc/ssh/ssh_host_* 
ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""

#Remove small Diffie-Hellman moduli
awk '$5 >= 3071' /etc/ssh/moduli > "${HOME}/moduli.safe"
#su -c " chown root:root "${HOME}/moduli.safe" "
#su -c " mv ${HOME}/moduli.safe /etc/ssh/moduli "
chown root:root "${HOME}/moduli.safe"
mv ${HOME}/moduli.safe /etc/ssh/moduli

#download sshd_config templates
su -c ' wget https://raw.githubusercontent.com/urbanswelt/bitnami/main/sshd_config.template '
su -c ' wget https://raw.githubusercontent.com/urbanswelt/bitnami/main/sshd_config.PasswordAuthentication '

#backup original sshd_config
#su -c " mv /etc/ssh/sshd_config /etc/ssh/sshd_config.original "
#su -c " mv ${HOME}/sshd_config.PasswordAuthentication /etc/ssh/sshd_config "
mv /etc/ssh/sshd_config /etc/ssh/sshd_config.original
mv ${HOME}/sshd_config.PasswordAuthentication /etc/ssh/sshd_config

#enable ssh
rm -f /etc/ssh/sshd_not_to_be_run
systemctl enable ssh
systemctl start ssh

#create user folder and file
mkdir ${HOME}/.ssh &>/dev/null
touch ${HOME}/.ssh/authorized_keys

echo -e
echo -e
echo -e "${red}##############################################################"
echo "  temporarily ssh with password login is allowed,"
echo "  please add your key to ~/.ssh/authorized_keys"
echo -e "##############################################################${reset}"
echo -e
echo -e
read -p "Press [Enter] key to continue..."

#move sshd_config template file
#su -c " mv ${HOME}/sshd_config.template /etc/ssh/sshd_config "
mv ${HOME}/sshd_config.template /etc/ssh/sshd_config
systemctl restart ssh

#show status of ssh-audit
apt -qq install ssh-audit

ssh-audit localhost
read -p "Press [Enter] key to continue..."
state3=!!!DONE!!!
}

main_pgadmin4_setup ()
{
#install pgadmin4
read -p "Please choose your PGAdmin email adress: "  pg_admin_email
read -s -p "Please choose your PGAdmin password: "  pg_admin_pwd

if [[ ! -d "$PGADMIN_SETUP_EMAIL" ]]; then 
    export PGADMIN_SETUP_EMAIL="${pg_admin_email}"
    export PGADMIN_SETUP_PASSWORD="${pg_admin_pwd}"
    echo 'export PGADMIN_SETUP_EMAIL="${pg_admin_email}"' >> ~/.bashrc
    echo 'export PGADMIN_SETUP_PASSWORD="${pg_admin_pwd}"' >> ~/.bashrc
fi

apt -qq install gnupg --yes
curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | apt-key add
sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt -qq update'
apt install pgadmin4-web --yes
vim /usr/pgadmin4/bin/setup-web.sh &&
# silently install the below --yes indicate auto install
/usr/pgadmin4/bin/setup-web.sh --yes
ufw allow http
ufw allow https
state4=!!!DONE!!!
}

main_5 ()
{
state5=!!!FULL!!!
}

main_6 ()
{
state6=!!!FULL!!!
}

while true; do
    cmd=(dialog --backtitle "urbanswelt.de - Debian System Setup." --menu "Choose task." 22 76 16)
    options=(1 "Set New hostname	$state1"
             2 "mDNS Setup, Bonjour protocol	$state2"
             3 "SSH System Setup	$state3"
             4 "Pgadmin4 Setup	$state4"
             5 "empty	$state5"
             6 "empty	$state6"
             7 "Update and Upgrade the System	$state7"
             8 "Restart System now	$state8")
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)    
    if [ "$choice" != "" ]; then
        case $choice in
            1) main_hostname_setup ;;
            2) main_dns_setup ;;
            3) main_ssh_setup ;;
            4) main_pgadmin4_setup ;;
            5) main_5 ;;
            6) main_6 ;;
            7) apt -qq update && sudo apt upgrade --yes && read -p "Press [Enter] key to continue..." && state7=!!!DONE!!! ;;
            8) shutdown -r now;;
        esac
    else
        break
    fi
done
