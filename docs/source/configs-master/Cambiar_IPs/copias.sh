#!/bin/bash

while IFS= read -r line
do
#  echo "$line"
  nl=${#line}
  if [ $nl -gt "0" ]; then
    campos=($line)
    ca1=${campos[0]}
#    echo $ca1
    ss=$(expr substr $ca1 1 1)
    if [[ "${ss}" = "1" ]]; then
      ca2=${campos[1]}
      echo ${ca2}
      ./crea_copia.sh ${ca1}
    fi
  fi
done <  fmrilab_hosts.txt
