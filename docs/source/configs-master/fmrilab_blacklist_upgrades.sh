#!/bin/bash


strmatched=$(lspci | grep VGA | grep NVIDIA)
if [ ! -z "$strmatched" ]
then
    hasNVIDIA=1
else
    hasNVIDIA=0
fi

if [ $hasNVIDIA -eq 1 ]
then
    echo "[INFO] NVIDIA card found"
    echo "       $strmatched"
    # Avoid automatic upgrade of nvidia drivers and CUDA
    fupgrades=/etc/apt/apt.conf.d/50unattended-upgrades
    strmatched=$(grep libnvidia- $fupgrades) 
    if [ -z $strmatched ]
    then
    echo "[INFO] Disabling automatic upgrades of nvidia drivers and CUDA"
    echo "       Editing $fupgrades"
    sed -i \
        's/Unattended-Upgrade::Package-Blacklist {/Unattended-Upgrade::Package-Blacklist {\n    "nvidia-";\n    "libnvidia-";\n/' \
        $fupgrades
    else
    echo "[INFO] Nvidia upgrades already disabled in $fupgrades"
    fi
fi

