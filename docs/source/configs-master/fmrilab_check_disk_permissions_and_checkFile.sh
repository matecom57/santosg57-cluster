#!/bin/bash

# Checar si soy sudo
if [ ! $(id -u) -eq 0 ]; then
	echo "Only sudo can do this"
	exit 2
fi



ls -d /datos/`hostname`* | while read d
do
  chgrp fmriuser $d
  chmod g=rwx $d
  if [ ! -d ${d}/.testDir ]
  then
    mkdir -v ${d}/.testDir
  fi
  if [ ! -f ${d}/.testDir/.testFile ]
  then
    echo "Writing testfile in $d"
    echo OK > ${d}/.testDir/.testFile 
  else
    echo "testfile exists: ${d}/.testDir/.testFile"
    cat ${d}/.testDir/.testFile
  fi
done



ls -ld /datos/`hostname`*
