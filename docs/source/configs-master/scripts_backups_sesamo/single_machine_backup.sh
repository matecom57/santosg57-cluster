#!/bin/ash


print_help()
{
  echo "
  `basename $0` host folder [-options]

  Options:
   -help

  Example: 
  
  `basename $0` mansfield /datos/mansfield

  Luis Concha
  INB
  June 2018
"
}

if [ $# -lt 2 ] 
then
  echo "  ERROR: Need more arguments..."
  print_help
  exit 1
fi

thisHost=$1
thisFolder=$2


destination=/volume1/fmrilab/backup/datos
excludeFile=/volume1/fmrilab/backup/fmrilab_backup_exclude.txt

origin="soporte@${thisHost}:${thisFolder}"
  
  
time rsync --stats -h --force --ignore-errors --delete-excluded \
 --include="*.testDir" \
 --include="*.backup_check_file.txt" \
 --exclude-from=$excludeFile \
 --delete -aHXx --numeric-ids \
 $origin \
 ${destination}/ 
