#!/bin/bash

apt install git \
  build-essential \
  libhwloc-dev \
  libssl-dev \
  libtirpc-dev \
  libmotif-dev \
  libxext-dev \
  libncurses-dev \
  libdb5.3-dev \
  libpam0g-dev \
  pkgconf \
  libsystemd-dev \
  cmake


echo ""
echo ""

sge_user=sge
sge_home=/opt/sge
sge_uid=666
sge_gid=666

echo "Will create user $sge_user with UID=${sge_uid}, GID=${sge_gid} and home at $sge_home"

cmd="groupadd -g $sge_gid $sge_user"
echo $cmd
$cmd

cmd="useradd -u ${sge_uid} -g ${sge_gid} -r -d ${sge_home} $sge_user"
echo $cmd
$cmd


