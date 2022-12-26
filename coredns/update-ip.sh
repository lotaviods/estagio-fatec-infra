#!/bin/bash

BASEDIR=$(dirname "$0") 

OS=`uname`


if ! (type ifconfig > /dev/null 2>&1);
then

    case $OS in
    Linux) MSG="use: apt-get install net-tools or sudo apt-get install net-tools to install it";;
    Darwin|FreeBSD|OpenBSD) MSG="" ;;
    *) MSG="" ;;
    esac
        
    echo "ifconfig command not found. $MSG"
    exit
fi

case $OS in
   Linux) IP=`ifconfig -a | grep inet | grep -v '127.0.0.1' | awk '{ print $2}'`;;
   Darwin|FreeBSD|OpenBSD) IP=`ifconfig  | grep -E 'inet.[0-9]' | grep -v '127.0.0.1' | awk '{ print $2}'` ;;
   SunOS) IP=`ifconfig -a | grep inet | grep -v '127.0.0.1' | awk '{ print $2}'`;;
   *) IP="";;
esac

if [[ ${#IP} -le 1 ]] ;then
    echo "Ip address not found"
    exit;
fi

title="Select the address "
prompt="Pick an option:"
options=($IP)

lenghtOptions=$((${#options[@]}))
offbound=$lenghtOptions+1

if [[ $lenghtOptions -gt 1 ]];then

    echo "$title"
    PS3="$prompt "
    select opt in "${options[@]}" "Quit"; do 

        re='^[0-9]+$'
        if ! [[ $REPLY =~ $re ]] || [[ $REPLY -lt 1 ]] || [[ $REPLY -gt $offbound ]]; then
            echo "Invalid option. Try another one.";
            continue;
        fi;

        if [[ $REPLY -eq $offbound ]]; then
            echo "Goodbye!"; 
            exit;
        fi;

        IP=$opt
        break
    done
fi;

dnsconf="$BASEDIR/dns.conf"
while read line || [ -n "$line" ]; do 
    DNS=$line; 
    FILE="$BASEDIR/etc/db.$DNS"
    case $OS in
        Linux) sed -i "s/IN A.*/IN A $IP/" "$FILE";;
        Darwin|FreeBSD|OpenBSD) sed -i '' "s/IN A.*/IN A $IP/" "$FILE" ;;
    esac
done < $dnsconf

echo "$IP have been configured"

CONTAINERID=$(docker ps -q -f name=coredns)
if [ $CONTAINERID ]; then
    docker restart $CONTAINERID
fi

case $OS in
   Linux) sudo systemd-resolve --flush-caches;;
   Darwin)sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder ;;
esac

