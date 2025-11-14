#!/bin/bash


# Checar si soy sudo
if [ ! $(id -u) -eq 0 ]; then
        echo "Only sudo can do this"
        exit 2
fi


# try to find the  configuration directory
if [ -d /opt/netdata/etc/netdata ]; then
  netdataetcdir=/opt/netdata/etc/netdata
  updater=/opt/netdata/usr/libexec/netdata/netdata-updater.sh
  ndcli=/opt/netdata/bin/netdatacli
fi
if [ -d /etc/netdata ]; then
  netdataetcdir=/etc/netdata
  updater=/usr/libexec/netdata/netdata-updater.sh
  ndcli=/usr/sbin/netdatacli
fi



if [ -d $netdataetcdir ]
then
   echo "This node has netdata enabled, with the etc dir at $netdataetcdir"
else
   echo "[ERROR] To add this node to netdata, go to app.netdata.cloud , connect nodes, and copy-paste the command that starts with wget"
   exit 2
fi

#echo "script is unfinished, not running the rest."
#exit 0

cp -v /home/inb/soporte/configs/netdata_configfiles/disks.conf ${netdataetcdir}/health.d/

echo "Restarting netdata health monitor"
$ndcli reload-health
echo "Done"


echo "Configuring automatic updates"
$updater --enable-auto-updates
