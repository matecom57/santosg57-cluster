#!/bin/bash

echo "Istalling ganglia-monitor"
sudo apt install ganglia-monitor -y

echo "Editing /etc/ganglia/gmond.conf"
cp -v /etc/ganglia/gmond.conf /etc/ganglia/gmond.conf.bak
cp -v fmrilab_gmond.conf /etc/ganglia/gmond.conf

echo "Starting ganglia monitor"
systemctl start ganglia-monitor
#systemctl status ganglia-monitor

