#backs up the default make.conf
#this puts some things in place like your make.conf, aswell as package.use

LIGHTGREEN='\033[1;32m'

cd /mnt/gentoo/
stage3=$(ls stage3*)
echo "found $stage3"
tar xpvf $stage3 --xattrs-include='*.*' --numeric-owner

mkdir /mnt/gentoo/etc/portage/backup
unzip /mnt/gentoo/gentootestscript-master/gentoo/portage.zip
mv /mnt/gentoo/etc/portage/make.conf /mnt/gentoo/etc/portage/backup/
echo "moved old make.conf to /backup/"
#copies our pre-made make.conf over
cp /mnt/gentoo/gentootestscript-master/gentoo/portage/make.conf /mnt/gentoo/etc/portage/
echo "copied new make.conf to /etc/portage/"

#copies specific package.use stuff over
cp -a /mnt/gentoo/gentootestscript-master/gentoo/portage/package.use/. /mnt/gentoo/etc/portage/package.use/
echo "copied over package.use files to /etc/portage/package.use/"

#copies specific package stuff over (this might not be necessary)
cp -a /mnt/gentoo/gentootestscript-master/gentoo/portage/linux_drivers /mnt/gentoo/etc/portage/
cp -a /mnt/gentoo/gentootestscript-master/gentoo/portage/nvidia_package.license /mnt/gentoo/etc/portage/
cp -a /mnt/gentoo/gentootestscript-master/gentoo/portage/package.license /mnt/gentoo/etc/portage
cp -a /mnt/gentoo/gentootestscript-master/gentoo/portage/package.accept_keywords /mnt/gentoo/etc/portage/
echo "copied over specific package stuff"

#gentoo ebuild repository
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

echo "copied gentoo repository to repos.conf"

#copy DNS info
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
echo "copied over DNS info"

cp /mnt/gentoo/gentootestscript-master/post_chroot.sh /mnt/gentoo/
echo "copied post_chroot.sh to /mnt/gentoo"
chmod +x /mnt/gentoo/post_chroot.sh

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev


echo "mounted all the things"
echo "you should now chroot into the new environment"
echo -e ${LIGHTGREEN}"chroot /mnt/gentoo /bin/bash"
echo -e ${LIGHTGREEN}"source /etc/profile"
echo -e ${LIGHTGREEN}"export PS1=\"(chroot) \${PS1}\""

#below this point we have to create a seperate script to run in the chroot portion
#chroot /mnt/gentoo /bin/bash << "EOT"
#source /etc/profile
#export PS1="(chroot) ${PS1}"

