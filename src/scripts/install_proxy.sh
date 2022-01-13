#!/bin/bash
#
# Name:		install-VezGate-Proxy.sh
# Version:	1
# Author:	umar
# Purpose:	(For Cloud Servers) Sets up proxy server for Apps
# Usage:	bash install-vpn-server.sh
#################################################################################################

# read -p "Enter Domain For This Proxy: " domain
if [ -z $domain ] ; then
    echo 'No Domain Given, Exiting' >&2
    exit 1
fi
# read -p "Enter Git Username: " VGPMYGITUSERNAME
# if [ -z $VGPMYGITUSERNAME ] ; then
#     echo 'NO GIT username given, exiting....'
#     exit 1
# fi
# echo '-'
# read -p "Enter Git Password: " VGPMYGITPASSWORD
# if [ -z $VGPMYGITPASSWORD ] ; then
#     echo 'NO GIT Password given, exiting....'
#     exit 1
# fi

myip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
echo "Host IP is $myip"

timedatectl set-timezone UTC
apt-get -y update
apt-get -y install build-essential git curl net-tools mtr iptraf-ng wget nload ufw certbot dnsutils

domain_ip=$(dig likova.club | grep "IN" | grep "^[^;]" | awk '{ print $5 }')

if [ -z $domain_ip ] ; then
  echo 'No IP Found, Exiting' >&2
  exit 1
fi

echo "Domain IP is $domain_ip"

if [ $domain_ip != $myip ] ; then
  echo 'IP Mismatch, Exiting' >&2
  exit 1
fi


curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt-get install -y nodejs

ufw allow from 124.29.223.2
ufw allow from 43.251.253.46
ufw allow from 92.204.163.160/29
ufw allow from 92.204.174.192/26
ufw allow from 92.42.105.64/28
ufw allow from 92.42.110.56/29
ufw allow from 134.119.185.88/29
ufw allow http
ufw allow https
ufw enable

npm install pm2@latest -g
pm2 update
pm2 startup

mkdir /etc/mycode
cd /etc/mycode

git clone "https://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@github.com/aahhoo/VezGate-PROXY.git"

sed -i "s/REPLACE_CERT_DOMAIN_HERE/$domain/g" /etc/mycode/VezGate-PROXY/sslCertObj.js

cd VezGate-PROXY

npm i
pm2 start ecosystem.config.js
pm2 save
pm2 stop all
certbot certonly --standalone --preferred-challenges http --agree-tos --email mypublicemailidforemail123@gmail.com -d $domain
pm2 start all

cat > "cronfile.sh" <<EOF
0 0 */30 * * /usr/bin/certbot renew --quiet
EOF

crontab cronfile.sh