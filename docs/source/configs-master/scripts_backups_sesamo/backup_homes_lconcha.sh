#!/bin/ash

origin="soporte@tesla:/home/inb"
destination=/volume1/fmrilab/backup 
logfile=/volume1/fmrilab/backup/logs/backup_homes_`date '+%F_at_%Hh_%Mmin'`.txt
excludeFile=/volume1/fmrilab/backup/scripts/fmrilab_backup_exclude.txt



time rsync --stats -h --force --ignore-errors --delete-excluded \
 --exclude-from=$excludeFile \
 --delete -aHXx --numeric-ids \
 $origin \
 ${destination}/ &> $logfile  


