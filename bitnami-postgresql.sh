#!/bin/bash
#enable ssh
sudo rm -f /etc/ssh/sshd_not_to_be_run
sudo vim /etc/ssh/sshd_config &&
sudo systemctl enable ssh
sudo systemctl start ssh
#always up to date
sudo apt update && sudo apt upgrade --yes


#install pgadmin4
read -p "Please choose your PGAdmin email adress: "  pg_admin_email
read -p "Please choose your PGAdmin password: "  pg_admin_pwd

if [[ ! -d "$PGADMIN_SETUP_EMAIL" ]]; then 
    export PGADMIN_SETUP_EMAIL="${pg_admin_email}"
    export PGADMIN_SETUP_PASSWORD="${pg_admin_pwd}"
    echo 'export PGADMIN_SETUP_EMAIL="${pg_admin_email}"' >> ~/.bashrc
    echo 'export PGADMIN_SETUP_PASSWORD="${pg_admin_pwd}"' >> ~/.bashrc
fi

sudo apt-get install gnupg --yes
curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add
sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
sudo apt install pgadmin4-web --yes
sudo vim /usr/pgadmin4/bin/setup-web.sh &&
# silently install the below --yes indicate auto install
sudo /usr/pgadmin4/bin/setup-web.sh --yes
sudo ufw allow http


#local DNS resolver
sudo apt install avahi-daemon libnss-mdns avahi-utils --yes
#dbus is missing
sudo apt install dbus --yes
read -p "Please choose your new Hostname: "  newhostname
sudo hostnamectl set-hostname $newhostname
sudo shutdown -r now
