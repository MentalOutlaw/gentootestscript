#TODO
#Replace all the echo with printf

LIGHTGREEN='\033[1;32m'
LIGHTBLUE='\033[1;34m'
echo -e ${LIGHTBLUE}"Enter the username for your NON ROOT user"
#There is a possibility this won't work since the handbook creates a user after rebooting and logging as root
read username
echo -e ${LIGHTBLUE}"Do you want to migrate openssl to libressl?"
read sslmigrateanswer
echo -e ${LIGHTBLUE}"Enter Yes to make a kernel from scratch, edit to edit the hardened config, or No to use the default hardened config"
read kernelanswer
echo -e ${LIGHTBLUE}"Enter the Hostname you want to use"
read hostname


mount /dev/sda1 /boot
echo "mounted boot"
emerge-webrsync
echo "webrsync complete"

if [ $sslmigrateanswer = "yes" ]; then
	echo "beginning openssl to libressl migration"
	emerge -uvNDq world
	emerge gentoolkit
	equery d openssl
	equery d libressl
	echo "openssl and libressl dependencies considered"
	echo 'USE="${USE} libressl"' >> /etc/portage/make.conf
	echo "added libressl use flag to /portage/make.conf"
	echo 'CURL_SSL="libressl"' >> /etc/portage/make.conf
	mkdir -p /etc/portage/profile
	echo "-libressl" >> /etc/portage/profile/use.stable.mask
	echo "dev-libs/openssl" >> /etc/portage/package.mask
	echo "dev-libs/libressl" >> /etc/portage/package.accept_keywords
	emerge -f libressl
	emerge -C openssl
	echo "removed openssl"
	emerge -1q libressl
	echo "installed libressl"
	emerge -1q openssh wget python:2.7 python:3.4 iputils
else
	echo "using default openssl"
fi

echo "preparing to do big emerge"

emerge --verbose --update --deep --newuse @world
echo "big emerge complete"
echo "America/NewYork" > /etc/timezone
emerge --config sys-libs/timezone-data
echo "timezone data emerged"
en_US.UTF-8 UTF-8
printf "en_US.UTF-8 UTF-8\n" >> /etc/locale.gen
locale-gen
echo "script complete"
eselect locale set 4
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

#Installs the kernel
emerge sys-kernel/gentoo-sources
cd /usr/src/linux
emerge sys-apps/pciutils
emerge lzop
emerge app-arch/lz4
echo "Do you want to configure your own kernel?"
if [ $kernelanswer = "No" ]; then
	cp /gentootestscript-master/gentoo/kernel/gentoohardenedminimal /usr/src/linux
	mv gentoohardenedminimal .config
	make oldconfig
	make && make modules_install
	make install
	echo "Kernel installed"
elif [ $kernelanswer = "edit" ]; then
	cp /gentootestscript-master/gentoo/kernel/gentoohardenedminimal /usr/src/linux
	mv gentoohardenedminimal .config
	make menuconfig
	make && make modules_install
	make install
	echo "Kernel installed"
else
	echo "time to configure your own kernel"
	make menuconfig
	make && make modules_installl
	make install
	echo "Kernel installed"
fi

#enables DHCP
sed -i -e "s/localhost/$hostname/g" /etc/conf.d/hostname
emerge --noreplace net-misc/netifrc
echo "config_enp0s3=\"dhcp\"" >> /etc/conf.d/net
echo -e "/dev/sda1\t\t/boot\t\text4\t\tdefaults,noatime\t0 2" >> /etc/fstab
echo -e "/dev/sda2\t\t/\t\text4\t\tnoatime\t0 1" >> /etc/fstab
cd /etc/init.d
ln -s net.lo net.enp0s3
rc-update add net.enp0s3 default
echo "dhcp enabled"
emerge app-admin/sysklogd
emerge app-admin/sudo
rm -rf /etc/sudoers
cp sudoers /etc/
echo "installed sudo and enabled it for wheel group"
rc-update add sysklogd default
emerge sys-apps/mlocate
emerge net-misc/dhcpcd

#installs grub
emerge --verbose sys-boot/grub:2
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
useradd -m -G users,wheel,audio -s /bin/bash $username
echo "preparing to exit the system, run the following commands and then reboot without the CD"
echo "you should now have a working Gentoo installation, dont forget to set your root and user passwords!"
echo -e ${LIGHTGREEN}"passwd"
echo -e ${LIGHTGREEN}"passwd $username"
echo -e ${LIGHTGREEN}"exit"
echo -e ${LIGHTGREEN}"cd"
echo -e ${LIGHTGREEN}"umount -l /mnt/gentoo/dev{/shm,/pts,}"
echo -e ${LIGHTGREEN}"umount -R /mnt/gentoo"
echo -e ${LIGHTGREEN}"reboot"
exit
