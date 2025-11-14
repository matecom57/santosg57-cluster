#!/bin/bash



echo "Primero modificamos detalles de UID del primer usuario que es sudo"
firstuser=`getent group sudo | cut -d: -f4`
newUID=5000
echo "  Cambiando de lugar el home del primer usuario ($firstuser) a /localhome/${firstuser}"
mkdir -p /localhome/$firstuser
usermod -d /localhome/$firstuser -m $firstuser
newUID=5000
echo "  Cambiando UID del usuario $firstuser a $newUID"
usermod -u $newUID $firstuser

