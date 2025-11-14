#!/bin/bash
#===============================================================================
#          FILE:  fmrilab_backups_distribuido.sh
#         USAGE:  ./fmrilab_backups_distribuido.sh 
#   DESCRIPTION:  Script de respaldo distribuido
#         NOTES:  This new script is going to be executed in drobo and will mount each computer 
#        AUTHOR:  Edgar Morales, nekrum@gmail.com
#         NOTES:  This new script is going to be executed in synilogy
#       VERSION:  1.0
#       CREATED:  27/12/13 16:12:55 CST
#===============================================================================

# Send email of log to:
to_email="nekrum@gmail.com"

# List of files and directories that the backup is going to exclude
EXCLUDES=/volume1/fmrilab/backup/fmrilab_backup_exclude.txt
logdir=/volume1/fmrilab/backup/logs/
# Directory where the kups are going to be save By the moment it is changed
# to another location for test
DESTINATION=/volume1/fmrilab/backup/datos
# Machine file list
MACHINELIST=$(echo -e "$(awk '/share/ && /resp/ {print $1}' /volume1/fmrilab/backup/hosts) \nfourier2")
### PRUEBAS REMOVER
echo "$EXCLUDES $logdir $DESTINATION $MACHINELIST"

### Function for backup

respaldo (){
	BSERVER=$1
	#Check if the exclude file exist
	if ["$BSERVER" != "fourier2"];then
		if ! ping $BSERVER -c 3 2&>1 > /dev/null 
       		then 
			echo "FATAL ERROR: Can't PING $BSERVER" | tee -a $logfile
			echo "0" > $doBackupCheckFile
		fi
	fi
	if [ ! -f $EXCLUDES ]
	then
	      	echo "FATAL ERROR: File does not exist: $EXCLUDES" | tee -a $logfile
	  	echo "0" > $doBackupCheckFile
	fi
	#In synology, rsync is in /usr/syno/bin/rsync and is execute automatically
	OPTS="--stats -h --force --ignore-errors --delete-excluded --exclude-from=$EXCLUDES --delete -av "
	# Check if the doBackup exist to proceed
	doBackup=$(cat $doBackupCheckFile)
	echo "doBackup is $doBackup"
	if [ $doBackup -eq 1 ]
	then
	    echo "  Working on $BSERVER" | tee -a $logfile
	    date | tee -a $logfile
	    if ["$BSERVER" != "fourier2"];then
			time rsync  $OPTS -e 'ssh -p 22' --link-dest=../backup.1 soporte@$BSERVER:/datos/$BSERVER $DESTINATION/backup.0/ | tee -a $logfile
		else	
			time rsync  $OPTS -e 'ssh -p 22' --link-dest=../backup.1 soporte@fourier:/datos/$BSERVER $DESTINATION/backup.0/ | tee -a $logfile
		fi
		if [[ $? != 0 ]]
		then 
			echo "0" > $doBackupCheckFile
			echo " FATAL ERROR IN RSYNC of $BSERVER   " | tee -a $logfile

		fi
	else
		echo "----------------------------------------------------------" | tee -a $logfile
        	echo "     NOT DOING THE BACKUPS BECAUSE OF PREVIOUS ERRORS     " | tee -a $logfile
		echo "----------------------------------------------------------" | tee -a $logfile
	fi
}

### Function to rotate
rotar (){
# How many backups would you like to keep, each time you run
# the backup script, a new one will be created, so if you want:
# Daily for a week, script goes cron daily and enter 7.
# Hourly for 3 days, script goes cron hourly and enter 72 (24 hours x 3 days)
NUMOFBACKUPS=7

# Where are we backing up to?

BACKUPLOC=$1                 
                             
# Delete the oldest backup   
NUMOFBACKUPS=$(expr $NUMOFBACKUPS - 1)
if [ -d $BACKUPLOC/backup.$NUMOFBACKUPS ]
then
        echo "delete backup.$NUMOFBACKUPS"     
        rm -Rf $BACKUPLOC/backup.$NUMOFBACKUPS 
fi                                             
echo "Hello, I will move some snapshots around for you in $BACKUPLOC"
# Move each snapshot                                                 
while [ $NUMOFBACKUPS -gt 0 ]                                        
do
	NUMOFBACKUPS=$(expr $NUMOFBACKUPS - 1)
        if [ -d $BACKUPLOC/backup.$NUMOFBACKUPS ]
       	then
		NEW=$(expr $NUMOFBACKUPS + 1)
	        mv $BACKUPLOC/backup.$NUMOFBACKUPS $BACKUPLOC/backup.$NEW
		echo "Move backup.$NUMOFBACKUPS to backup.$NEW"          
	else                                                             
	echo "  Directory does not exist: $BACKUPLOC/backup.$NUMOFBACKUPS"
	fi  
done
}




# Check if sudo
if [ ! $(id -u) -eq 0 ]
then
	echo "Only sudo can do this"
	exit 2
fi

# This create the maquinas directory to list the machines that are in the process
mkdir -p ${logdir}maquinas


# This file gets a zero value if anything is wrong and skips the backup part.
doBackupCheckFile=${logdir}/backups_$$.doBackup
echo "1" > $doBackupCheckFile

# Delete old log files, if any (7 days or older).
find $logdir -mtime +7 -exec rm {} \;

# start a log file
logfile=${logdir}/`date '+%F_at_%Hh_%Mmin'`.txt
date > $logfile

############# Crear un script que revise si hay una instancia
# check if already running a backup session
this_pid=$$
saved_pid=${logdir}/running_pid.txt
if [ -f $saved_pid ]
then
  old_pid=`cat $saved_pid`
  echo "OLD PID is $old_pid .   Current PID is $this_pid"
  if [ $old_pid -eq $this_pid ]
  then
    echo "FATAL ERROR: Another backup session is already runnning ($old_pid)." | tee -a $logfile
    echo "0" > $doBackupCheckFile
  fi
fi
echo $this_pid > $saved_pid

# Execute finaliza function to get te value of $falta

################################################################3
#### Function finaliza
finaliza () {
if [ "$(ls -A ${logdir}/maquinas/)" ]
then
	echo "Si hay archivos"
	return 0
else
	echo "No hay Archivos"
	return 1
fi
}

if  finaliza 
then 
	echo "0" > $doBackupCheckFile
	echo "SERVER BACKUP WITH PROBLEMS: " | tee -a $logfile
	echo "$(ls -A ${logdir}/maquinas/)" | tee -a $logfile
	echo "---------------------------------" | tee -a $logfile
else
#	if [ $doBackup -eq 1 ]
#      	then 
		rotar $DESTINATION
#	fi
	for i in $MACHINELIST
	do
		touch ${logdir}/maquinas/${i}
		respaldo $i
		if [ $doBackup -eq 1 ]
		then 
			rm ${logdir}/maquinas/${i}
		fi
	done
fi

echo "Sending email to $to_email"
started=`head -n 1 $logfile`
finished=`tail -n 1 $logfile`
FatalErrors=`grep -i ^Fatal $logfile`

if [ -z "$FatalErrors" ]
then
  tmpLog=${logdir}/rsync_backup_tmplog_$$.txt
  head $logfile >> $tmpLog
  echo "..." >> $tmpLog
  tail $logfile >> $tmpLog
  echo "-------" >> $tmpLog
  grep bytes $logfile >> $tmpLog
  grep speedup $logfile >> $tmpLog
  message=$(cat $tmpLog)
  subject="[fmrilab backup] OK `date`"
  rm $tmpLog
else
  tmpLog=/tmp/rsync_backup_tmplog_$$.txt
  head $logfile >> $tmpLog
  echo $FatalErrors >> $tmpLog
  tail $logfile >> $tmpLog
  message=$(cat $tmpLog)
  subject="[fmrilab backup] ERROR `date`"
fi


todomensaje="Started at  : $started
Finished at : $finished                                    
...
$message"

echo "$subject" > archivomensaje.txt
echo "$todomensaje" >> archivomensaje.txt

scp archivomensaje.txt soporte@talairach:~/archivomensaje.txt
ssh soporte@talairach  'chmod u+wr ~/archivomensaje.txt ; /home/inb/soporte/fmrilab-scripts/mantenimiento/./fmrilab_aviso_correo.sh -c lconcha@gmail.com -e "$(head -1 ~/archivomensaje.txt)" -a ~/archivomensaje.txt'
ssh soporte@talairach  '/home/inb/soporte/fmrilab-scripts/mantenimiento/./fmrilab_aviso_correo.sh -c nekrum@gmail.com -e "$(head -1 ~/archivomensaje.txt)" -a ~/archivomensaje.txt ; rm -f ~/archivomensaje.txt'

# remove pid check file to avoid running to backup sessions
rm $saved_pid $doBackupCheckFile
