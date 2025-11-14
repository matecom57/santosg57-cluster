#!/bin/bash


fullHosts=./fmrilab_hosts.txt

tmphosts=/tmp/tmphosts_$$

echo "127.0.0.1	localhost" > $tmphosts
#echo "127.0.1.1	`uname -n`.inb.unam.mx	`uname -n`" >> $tmphosts
cat $fullHosts >> $tmphosts 

echo ""
cat $tmphosts

cp /etc/hosts /etc/hosts.old
mv $tmphosts /etc/hosts
