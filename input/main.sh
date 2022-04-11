#!/bin/bash

echo "127.0.0.1 localhost" > /etc/hosts
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

echo "#!/bin/sh" > /etc/profile.d/userland.sh
echo "unset LD_PRELOAD" >> /etc/profile.d/userland.sh
echo "unset LD_LIBRARY_PATH" >> /etc/profile.d/userland.sh
echo "export LIBGL_ALWAYS_SOFTWARE=1" >> /etc/profile.d/userland.sh
chmod +x /etc/profile.d/userland.sh

#update our repos so we can install some packages
echo "deb http://deb.debian.org/debian/ buster main contrib non-free" > /etc/apt/sources.list
echo "#deb-src http://deb.debian.org/debian/ buster main contrib non-free" >> /etc/apt/sources.list
echo "deb http://deb.debian.org/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list
echo "#deb-src http://deb.debian.org/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list
apt-get update

#install some packages with need for UserLAnd
apt-get install -y --no-install-recommends sudo dropbear libgl1-mesa-glx tightvncserver xterm xfonts-base twm openbox expect
apt-get install -y inkscape 

#clean up after ourselves
apt-get clean

#fix a couple of things

update-mime-database /usr/share/mime
find /usr/lib -name gdk-pixbuf-query-loaders -exec {} --update-cache \;

sed -i 's/<\/applications>/<application class="*"> <position force="yes"> <x>0<\/x> <y>0<\/y> <\/position> <size> <width>100%<\/width> <height>100%<\/height> <\/size> <\/application> <\/applications>/g' /etc/xdg/openbox/rc.xml
openbox --reconfigure

#tar up what we have before we grow it
tar -czvf /output/rootfs.tar.gz --exclude sys --exclude dev --exclude proc --exclude mnt --exclude etc/mtab --exclude output --exclude input --exclude .dockerenv /

#build disableselinux to go with this release
apt-get update
apt-get -y install build-essential
gcc -shared -fpic /input/disableselinux.c -o /output/libdisableselinux.so

#grab a static version of busybox that we can use to set things up later
apt-get -y install busybox-static
cp /bin/busybox output/busybox
