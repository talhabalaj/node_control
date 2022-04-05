#!/bin/bash
#
# Name:		install-VezGate-Proxy.sh
# Version:	2
# Author:	umar
# Purpose:	(For Cloud Servers) Sets up proxy server for Apps
# Usage:	bash install-vpn-server.sh
#################################################################################################

if [ -z $domain ]; then
  echo 'No Domain Given, Exiting' >&2
  exit 1
fi

if ! [ -f "/etc/debian_version" ]; then
  logger -s "[error] Debian is required"
  exit -1
fi

export DEBIAN_FRONTEND=noninteractive

myip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
echo "Host IP is $myip"

timedatectl set-timezone UTC
apt-get -y update
apt-get -y install ufw certbot nginx python3-certbot-nginx curl net-tools mtr iptraf-ng wget nload dnsutils

domain_ip=$(dig +short $domain)

if [ -z $domain_ip ]; then
  echo 'No IP Found, Exiting' >&2
  exit 1
fi

echo "Domain IP is $domain_ip"

if [ $domain_ip != $myip ]; then
  echo 'IP Mismatch, Exiting' >&2
  exit 1
fi

ufw allow from 124.29.223.2
ufw allow from 43.251.253.46
ufw allow from 92.204.163.160/29
ufw allow from 92.204.174.192/26
ufw allow from 92.42.105.64/28
ufw allow from 92.42.110.56/29
ufw allow from 134.119.185.88/29
ufw allow from 92.204.172.192/29
ufw allow from 151.106.6.0/28
ufw allow http
ufw allow https
ufw --force enable
ufw status

cat <<END >/etc/nginx/sites-available/$domain
server {
        listen 80;
        server_name     $domain;
        proxy_set_header  proxy-domain-name \$host;
        proxy_set_header  client-real-ip \$remote_addr;
        proxy_set_header  proxy-request-key sOmeSecReTk3Ywh1Ch15uNBr34k4bLe;
        proxy_set_header  its-nginx-proxied 1;


        location / {
                proxy_pass http://vezcoremainapis1.rateela.com:33721;
        }

}
END


ln -s /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/$domain
rm -f /etc/nginx/sites-enabled/default
certbot --nginx --redirect --agree-tos --no-eff-email --email chotasharla@gmail.com -d $domain

systemctl restart nginx
systemctl status nginx