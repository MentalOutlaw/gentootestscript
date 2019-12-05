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
unzip rice.zip
cd apps/
chmod +x rice-gentoo.sh
sh rice-gentoo.sh
echo "Installing software listed in software.txt..."
emerge --autounmask-write $SOFTWARE
git clone https://github.com/sqlmapproject/sqlmap.git
mv sqlmap/ /root/.config/
touch sqlmap
echo "python /root/.config/sqlmap/sqlmap.py" >> sqlmap
chmod +x /root/.config/sqlmap/sqlmap
mv /root/.config/sqlmap/sqlmap /usr/bin/

echo "software installed"
cd ..
chmod + x install_wordlist.sh
sh install_wordlist.sh
echo "enumeration word list installed in /usr/share/wordlist"
