#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "The script has to be run as root."
  exit
fi

echo "This script is designed for gentoo linux and it will not work in any other OS"
echo "Installing dependencies listed in dependencies.txt..."

DEPLIST="`sed -e 's/#.*$//' -e '/^$/d' dependencies.txt | tr '\n' ' '`"
SOFTWARE="`sed -e 's/#.*$//' -e '/^$/d' software.txt | tr '\n' ' '`"

emerge --autounmask-write $DEPLIST
USE="X" emerge app-editors/vim
USE="perl xft" emerge x11-terms/rxvt-unicode
USE="cli libmpv" emerge media-video/mpv
echo "installed dependencies"
sleep 5
#defines the directory this script runs in so we can easily return to it
script_home=$(pwd)
unzip rice.zip
cd apps/
chmod +x rice-gentoo.sh
sh rice-gentoo.sh
echo "Installing software listed in software.txt..."
emerge --autounmask-write $SOFTWARE

#installs software from pentoo overlay
cd $script_home
mkdir -p /usr/local/portage/net-analyzer/responder
mv ebuilds/responder-2.3.4.0-r1.ebuild /usr/local/portage/net-analyzer/responder/
cd /usr/local/portage/net-analyzer/responder
ebuild responder-2.3.4.0-r1.ebuild manifest
emerge --autounmask-write net-analyzer/responder
cd $script_home

echo "software installed"
chmod + x install_wordlist.sh
sh install_wordlist.sh
echo "enumeration word list installed in /usr/share/wordlist"
