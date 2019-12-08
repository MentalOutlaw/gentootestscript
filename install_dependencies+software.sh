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
#mkdir -p /usr/local/portage/cross-x86_64-w64-mingw32
mkdir -p /usr/local/portage/dev-db/sqlmap
mkdir -p /usr/local/portage/dev-python/impacket
mkdir -p /usr/local/portage/dev-python/ldapdomaindump
mkdir -p /usr/local/portage/dev-python/pycryptodomex
mv ebuilds/responder-2.3.4.0-r1.ebuild /usr/local/portage/net-analyzer/responder/
mv ebuilds/ldapdomaindump-0.9.1.ebuild /usr/local/portage/dev-python/ldapdomaindump
mv ebuilds/impacket-0.9.20.ebuild /usr/local/portage/dev-python/impacket
mv ebuilds/pycryptodomex-3.9.4.ebuild /usr/local/portage/dev-python/pycryptodomex
mv ebuilds/
cd /usr/local/portage/net-analyzer/responder
ebuild responder-2.3.4.0-r1.ebuild manifest
emerge --autounmask-write net-analyzer/responder
cd /usr/local/portage/dev-python/ldapdomaindump
ebuild ldapdomaindump-0.9.1.ebuild manifest
emerge --autounmask-write dev-python/ldapdomaindump
cd /usr/local/portage/dev-python/pycryptodomex
ebuild pycryptodomex-3.9.4.ebuild manifest
emerge --autounmask-write dev-python/pycryptodomex
cd /usr/local/portage/dev-python/impacket
ebuild impacket-0.9.20.ebuild manifest
emerge --autounmask-write dev-python/impacket
cd $script_home
cd ..
mkdir Tools
cd Tools
git clone https://github.com/magnumripper/JohnTheRipper.git
cd src
./configure && make -s clean && make -sj3
cd ..
mv run/ ../john
cd ..
rm -rf JohnTheRipper
git clone https://github.com/sqlmapproject/sqlmap.git
emerge sys-devel/crossdev
crossdev --target x86_64-w64-mingw32

echo "software installed"
chmod + x install_wordlist.sh
sh install_wordlist.sh
echo "enumeration word list installed in /usr/share/wordlist"
