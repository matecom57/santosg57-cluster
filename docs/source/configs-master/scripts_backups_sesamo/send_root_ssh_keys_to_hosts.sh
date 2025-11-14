#!/bin/ash

echo "This script must be run by root"
echo "Do not run this on hosts onto which you have already sent your rsa.pub key"
echo "Just do not run this script, get ideas from it"
echo "It is meant to send sesamo's rsa.pub key to the host and set up password-less auth"
echo "  particularly for the automated rsync backups that run through backup_datos_lconcha.sh"


if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi


listOfDestinations=/volume1/fmrilab/backup/datos_backup_locations.txt

echo $listOfDestinations



awk '{print $1}' $listOfDestinations | sort | uniq | while read h
do
  echo "Working on host $h"
  cat ~/.ssh/id_rsa.pub | ssh soporte@$h 'tee -a .ssh/authorized_keys'
done

