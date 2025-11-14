#!/bin/bash

# Checar si soy sudo
if [ ! $(id -u) -eq 0 ]; then
	echo "Only sudo can do this"
	exit 2
fi

echo "Will fix apparmor allowed homes so that we can use snaps"
# https://bugs.launchpad.net/snappy/+bug/1620771




apparmorfile=/etc/apparmor.d/tunables/home.d/fmrilab
echo @{HOMEDIRS}+=/home/inb/ > $apparmorfile
rm -f /etc/apparmor.d/cache/* /var/cache/apparmor/snap.*

echo "YOU NEED TO REBOOT FOR CHANGES TO TAKE EFFECT!"
