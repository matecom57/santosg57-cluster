#!/bin/bash

apt install rpcbind nfs-common autofs


masterFilesDir=.

fmrilab_misc=${masterFilesDir}/fmrilab_auto.misc
fmrilab_home=${masterFilesDir}/fmrilab_auto.home
fmrilab_master=${masterFilesDir}/auto.master

isOK=1
for f in $fmrilab_misc $fmrilab_home $fmrilab_master
do
  if [ ! -f $f ]
  then
   isOK=0
   echo "ERROR   Cannot find $f"
  fi
done

if [ $isOK -eq 0 ]
then
  echo "ERRORS were found. Quitting."
  exit 2
fi

tmpMisc=/tmp/tmpMisc_$$


cp -v /etc/auto.misc /etc/auto.misc.bak
cp -v $fmrilab_misc /etc/auto.misc
cp -v $fmrilab_master /etc/auto.master
#cp -v $fmrilab_home /etc/auto.home



if [ ! -f /etc/default/cachefilesd ]
then
  echo "Habilitando cache para NFS y teoricamente para autofs"
  apt install cachefilesd
fi

sed -i 's/#RUN=yes/RUN=yes/' /etc/default/cachefilesd
echo "Reiniciando servicios"
echo "-- cachefilesd"
service cachefilesd restart
echo "-- autofs"
service autofs reload
service autofs restart
