#!/bin/bash

BASEDIR=$(dirname "$0") 
dnsconf="$BASEDIR/dns.conf"

files=""
while read line || [ -n "$line" ]; do 
DNS=$line; 
cat "$BASEDIR/record-template.txt" | sed "s/<DNS>/$DNS/" > "$BASEDIR/etc/db.$DNS"
files="  $files\nfile \/coredns-config\/db.$DNS $DNS"
done < $dnsconf

cat "$BASEDIR/corefile-template.txt" | sed "s/<FILES>/$files/" > "$BASEDIR/Corefile"