#!/bin/ash


destination=/volume1/fmrilab/backup/datos
excludeFile=/volume1/fmrilab/backup/scripts/fmrilab_backup_exclude.txt
listOfDestinations=/volume1/fmrilab/backup/datos_backup_locations.txt
currentRunningFile=/volume1/fmrilab/backup/logs/maquinas/backups_running.txt

echo "========================"
echo "Script starts"
whoami
hostname
date
echo "========================="


echo "" >> $currentRunningFile
echo "START" >> $currentRunningFile
date >> $currentRunningFile

cat $listOfDestinations | while read line
do
  thisHost=`echo $line | awk '{print $1}'`
  thisFolder=`echo $line | awk '{print $2}'`
  origin="soporte@${thisHost}:${thisFolder}"
  echo ""
  logfile=/volume1/fmrilab/backup/logs/backup_`basename $thisFolder`_`date '+%F_at_%Hh_%Mmin'`.txt
  
  printf "%s %s"  $thisHost $logfile | tee -a $currentRunningFile
  
  
   time rsync --stats -h --force --ignore-errors --delete-excluded \
   --include="*.testDir" \
   --include="*.backup_check_file.txt" \
   --exclude-from=$excludeFile \
   --delete -aHXx --numeric-ids \
   $origin \
   ${destination}/ 2>&1 | tee $logfile  

  printf "  %s\n" "done." >> $currentRunningFile
done


echo "FINISH" >> $currentRunningFile
date >> $currentRunningFile

