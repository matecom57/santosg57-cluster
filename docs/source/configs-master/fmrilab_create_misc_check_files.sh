#!/bin/bash


grep $HOSTNAME /etc/fstab | awk '{print $2}' | while read d
do
  testfile=${d}/.testDir/.testFile
  echo "Looking for $testfile"
  if [ -f $testfile ]
  then
    echo "Found it"
    cat $testfile
    continue
  fi
  if [ ! -d ${d}/.testDir ]
  then
     echo "Creating ${d}/.testDir"
     mkdir -v ${d}/.testDir
  fi
  echo "Creating  $testfile"
   echo OK > $testfile
  cat $testfile
done

#cat $testfile
