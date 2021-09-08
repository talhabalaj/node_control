if ! [ -f "/etc/debian_version" ]; then
  logger -s "[error] Debian is required"
  exit -1;
fi

apt update -y
apt upgrade -y
apt install -y python3-pip nload htop mtr iptraf-ng git ufw

pip3 install git+https://github.com/shadowsocks/shadowsocks.git@master

echo y | ufw reset
ufw allow from 124.29.223.2
ufw allow from 43.251.253.46
ufw allow from 92.204.163.160/29
ufw allow from 92.204.174.192/26
ufw allow from 92.42.105.64/28
ufw allow from 92.42.110.56/29
ufw allow from 134.119.185.88/29
ufw allow $PORT
ufw allow ssh
echo y | ufw enable


mkdir -p /etc/mycode/
cd /etc/mycode
cat > ss.json <<EOF
{
  "server": "0.0.0.0",
  "mode":"tcp_and_udp",
  "server_port": $PORT,
  "password": "$PASSWORD",
  "timeout":300,
  "method":"aes-256-cfb",
  "nameserver":"8.8.8.8"
}
EOF

SS_SERVER=$(which ssserver)
cat > /etc/systemd/system/ssserver.service <<EOF
[Unit]
Description=Shadow socks server

[Service]
User=root
WorkingDirectory=/etc/mycode/
ExecStart=$SS_SERVER -c ss.json
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ssserver.service
systemctl restart ssserver.service