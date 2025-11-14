#!/bin/bash

# UBUNTU REPOSITORIES

## CLI apps
apt -y install ssh sshfs \
  git git-lfs git-annex \
  wget \
  htop \
  byobu \
  tree \
  xvfb \
  parallel \
  build-essential \
  cmake \
  curl \
  gdebi-core\
  apcupsd \
  environment-modules \
  neofetch \
  borgbackup \
  python-is-python3 python3-matplotlib python3-numpy \
  xfonts-base xfonts-100dpi \
  ncdu \
  pigz \
  detox \
  jq \
  zsh \
  libreoffice-java-common \
  datamash gnuplot \
  dcmtk \
  libc6:i386
  
## Apps
apt -y install gnome-tweaks gnome-shell-extensions \
  xterm tcsh tilix \
  shutter flameshot \
  inkscape \
  x2goclient x2goserver lxde \
  vlc \
  vim
  
	# terminator \ terminal padre pero se instala por encima del default

apt -y autoremove

### añadidos para mrtrix y afni: python-is-python3 python3-matplotlib python3-numpy 
### añadidos para afni: tcsh, xfonts-base, xfonts-100dpi


# PPA SOFTWARE

## Installing R base
	# update indices
	#apt update -qq
	# install two helper packages we need
	#apt -y install --no-install-recommends software-properties-common dirmngr
	# add the signing key (by Michael Rutter) for these repos
	# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc 
	# Fingerprint: E298A3A825C0D65DFD57CBB651716619E084DAB9
	#wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
	# add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
	#add-apt-repository -y "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

	#apt -y install --no-install-recommends r-base r-base-dev





## DEB-GET SOFTWARE
export DEBGET_TOKEN=$(cat lconcha_debget_token.txt)

#Install deb-get
curl -sL https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | sudo -E bash -s install deb-get

# install office fonts for onlyoffice
apt install ttf-mscorefonts-installer -y

# install deb-get software
deb-get install code \
	rclone \
	github-desktop \
	zotero \
	pandoc \
	zoom \
	google-chrome-stable \
	brave-browser \
	bitwarden keepassxc \
	sejda-desktop \
	rocketchat \
	bat lsd duf fd du-dust \
	onlyoffice-desktopeditors \
        micro

# NEUROSTUFF SOFTWARE

## MRtrix3 (git g++ python-is-python3 instalados arriba)
apt -y  install zlib1g libqt5opengl5 libqt5svg5 libtiff5 libeigen3-dev libgl1-mesa-dev libfftw3-dev libpng-dev
	# en las instrucciones de mrtrix todos eran packetes -dev  

## Afni (python stuff, tcsh, xfonts-base, xfonts-100dpi instalados arriba)
apt -y install gsl-bin libcurl4-openssl-dev libgdal-dev libglw1-mesa libjpeg62 libnode-dev libopenblas-dev libudunits2-dev libxm4 libxml2-dev libssl-dev
	# faltan para el 22.04  libgfortran4 libgfortran-8-dev
#### link simbolico que afni requiere
#ln -s /usr/lib/x86_64-linux-gnu/libgsl.so.23 /usr/lib/x86_64-linux-gnu/libgsl.so.19 # Ubunu 20.04
ln -sf /usr/lib/x86_64-linux-gnu/libgsl.so.27 /usr/lib/x86_64-linux-gnu/libgsl.so.19

## para dsi-studio
apt -y install qt6-base-dev libqt6charts6-dev

# Para singularity
apt -y install fuse2fs squashfuse gocryptfs


# Terminando la instalacion

## removing .deb in /tmp
rm -f -v /tmp/*.deb




