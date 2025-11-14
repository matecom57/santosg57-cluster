#!/bin/bash

#Only root can run this script
u=$(whoami)
if [[ ! "${u}" == "root" ]]
then
  echo "ERROR. Only root can run this script."
  exit 0
fi

this_directory=$(dirname `readlink -f $0`)

cp ${this_directory}/fmrilab_sudoers.txt /etc/sudoers.d/fmrilab