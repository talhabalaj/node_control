#!/bin/bash

IS_DEBIAN=1

if ! [ -f "/etc/debian_version" ]
  then IS_DEBIAN=0
fi


if [ -z "$NODE_TYPE" ]
  then 
    echo "NODE_TYPE is required as a env"
    exit 1
fi

if [ -z "$NODE_PORT" ] && [ "$NODE_TYPE" == "shadowsocks" ]  
  then 
    echo "NODE_PORT is required as a env for shadowsocks"
fi

mem=$(cat /proc/meminfo | grep Mem | awk  'FNR==1 {total = $2} FNR==2 {free = $2} END {print ((total-free)/total)*100}')
cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

if [ "$IS_DEBIAN" -ne 0 ]
  then
  interface=$(route -n | grep UG | tail -1 | awk '{print $NF}')

  if [ -z "$interface" ] 
    then 
      interface=$(route -n | grep U | tail -1 | awk '{print $NF}')
  fi
else
  interface=$(ip r | grep default | awk '{print $5}')
fi

rx=$(S=1; F=/sys/class/net/$interface/statistics/rx_bytes; X=`cat $F`; sleep $S; Y=`cat $F`; BPS="$(((Y-X)/S))"; echo $BPS)
tx=$(S=1; F=/sys/class/net/$interface/statistics/tx_bytes; X=`cat $F`; sleep $S; Y=`cat $F`; BPS="$(((Y-X)/S))"; echo $BPS)

if [ "$NODE_TYPE" != "shadowsocks" ]
  then 
    connected_users=$(occtl show users | wc -l)
    connected_users=$((($connected_users-1)))
  else 
    service_status=$(systemctl status ssserver | grep Active: | awk '{print $2}')
    connected_users=$(netstat -anp | grep :$NODE_PORT | grep ESTABLISHED | wc -l)
fi


echo "{ \"mem\": $mem, \"cpu\": $cpu, \"rx\": $rx, \"tx\": $tx, \"connected_users\": $connected_users, \"interface\": \"$interface\", \"service_status\": \"$service_status\"  }"
