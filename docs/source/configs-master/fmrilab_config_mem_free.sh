#!/bin/bash

leave_these_gb_free=6



host_group="@allhosts"
hosts=`qstat -f | grep all.q | sort | awk -F@ '{print $2}' | awk '{print $1}'`

for h in $hosts
do
  echo "[INFO] Working on $h"
  oMEMFREE=`qhost -F mem_total -h $h|tail -n 1|cut -d: -f3|sed -e s/total/free/`
  MEMFREE=`qhost -F mem_total -h $h|tail -n 1|cut -d: -f3 | cut -d= -f2 | cut -d. -f1`
  if [ $MEMFREE -lt $leave_these_gb_free ]
  then
    echo "[ERROR] Cannot subtract $leave_these_gb_free GB from $MEMFREE GB in host $h"
    continue
  fi
  gb_free=$(( $MEMFREE - $leave_these_gb_free ))
  #my_MEMFREE=mem_free=${gb_free}G
  echo "[INFO] host $h has $oMEMFREE . Reducing by $leave_these_gb_free GB. Will now be $gb_free"
  cmd="qconf -mattr exechost complex_values mem_free=${gb_free}G $h"
  echo "[INFO] command is: $cmd"
  $cmd

#  cmd="qconf -mattr exechost complex_values h_vmem=${gb_free}G $h"
#  echo "[INFO] command is: $cmd"
#  $cmd

  cmd="qconf -dattr exechost complex_values h_vmem $h"
  echo "[INFO] command is: $cmd"
  $cmd


  echo ""
done


echo "Make sure you have made mem_free and h_vmem consumable using qconf -mc"
