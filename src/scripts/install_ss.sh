if ! [ -f "/etc/debian_version" ]; then
  logger -s "[error] Debian is required"
  exit -1;
fi


cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian/ buster main
deb-src http://deb.debian.org/debian/ buster main
deb http://deb.debian.org/debian/ buster-updates main
deb-src http://deb.debian.org/debian/ buster-updates main
deb http://security.debian.org/debian-security buster/updates main
deb-src http://security.debian.org/debian-security buster/updates main
EOF

export DEBIAN_FRONTEND=noninteractive 

apt update -y -q
apt install -y -q nload htop mtr iptraf-ng git ufw wget xz-utils tar

mkdir -p /etc/mycode/
cd /etc/mycode

wget https://github.com/aahhoo/server2021/raw/master/server2021.tar.xz
tar -xf server2021.tar.xz

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


cat >> /etc/security/limits.conf <<EOF
root soft nofile 51200
root hard nofile 51200
EOF

cat >> /etc/sysctl.conf <<EOF
fs.file-max = 51200
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = hybla
## net.core.default_qdisc=fq
## net.ipv4.tcp_congestion_control=bbr
EOF

sysctl -p
ulimit -n 51200

cat > ss.json <<EOF
{
  "server": "0.0.0.0",
  "mode":"tcp_and_udp",
  "server_port": $PORT,
  "password": "$PASSWORD",
  "timeout":300,
  "method":"aes-256-gcm",
  "nameserver":"8.8.8.8"
}
EOF

SS_SERVER="$(pwd)/ssserver"

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