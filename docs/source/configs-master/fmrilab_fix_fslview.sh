#!/bin/bash

# Checar si soy sudo
if [ ! $(id -u) -eq 0 ]; then
	echo "Only sudo can do this"
	exit 2
fi


dirstart=`pwd`

apt install libmng2
ln -s /usr/lib/x86_64-linux-gnu/libmng.so.2 /usr/lib/x86_64-linux-gnu/libmng.so.1
apt install libjpeg62

if [ ! -f libpng_1.2.54.orig.tar.xz ]
then
  wget  http://archive.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng_1.2.54.orig.tar.xz
fi

tar xvf libpng_1.2.54.orig.tar.xz -C /tmp

cd /tmp/libpng-1.2.54
./autogen.sh
./configure

make -j8 
make install

ldconfig

cd $dirstart

rm -fR /tmp/libpng-1.2.54

