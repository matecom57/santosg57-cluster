#!/bin/bash

nuevaIP=${1}

nl=${#nuevaIP}

if [ $nl -gt "0" ]; then

sed "s|MODIFICA|$nuevaIP|g" /home/inb/soporte/configs/Cambiar_IPs/01-network-manager-all.yaml > ./dd/01-network-manager-all.yaml.${nuevaIP}

else
  echo "falta un argumento al scrip"
fi
