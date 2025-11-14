#!/bin/bash

apt install rpcbind nfs-common cachefilesd

# mkdir /home/inb

cp /etc/fstab /etc/fstab.original

sed -i '/home/d' /etc/fstab

echo "" >> /etc/fstab
echo "# fmrilab homes (auto-generado por script `basename $0`" >> /etc/fstab

# para NFSv3
#echo "tesla:/home/inb /home/inb nfs timeo=14,fsc,intr,bg,resvport,soft,nfsvers=3 0 0" >> /etc/fstab

# para NFSv4
echo "hahn:/inb	/home/inb	nfs4	_netdev,auto,fsc	0	0" >> /etc/fstab

mount -av

# a partir de 28 sep 2020 regresamos /home/inb a /etc/fstab para implementarlo con NFSv4
#echo "  No se modifica fstab, porque pondremos los homes a traves de autofs en /etc/auto.home"
