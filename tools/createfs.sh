#! /bin/bash
cd system
mkdir dev etc lib mnt proc sys tmp var etc/init.d
cp -r ../toolchain/gcc/linux-x86/aarch64/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu/aarch64-linux-gnu/libc/lib/* ./lib/
#创建 rcS 文件
cat <<EOF >etc/init.d/rcS
#! /bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:\$PATH
runlevel=S
prevlevel=N
umask 022
export PATH runlevel prevlevel
/bin/hostname iTOP-RK3568
mount -a
mkdir /dev/pts
mount -t devpts devpts /dev/pts
echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s
mkdir -p /var/empty
mkdir -p /var/log
mkdir -p /var/log/boa
mkdir -p /var/lock
mkdir -p /var/run
mkdir -p /var/tmp
syslogd
/etc/rc.d/init.d/netd start
mkdir /mnt/disk
/sbin/ifconfig lo 127.0.0.1
#/etc/init.d/ifconfig-eth0
/etc/init.d/ifconfig-eth1
sleep 1
echo "*************************************" >/dev/ttyFIQ0
echo "http://topeetboard.com" > /dev/ttyFIQ0
echo "*************************************" > /dev/ttyFIQ0
route add default gw 192.168.6.1
tcpsvd 0 21 ftpd -w / &
EOF
 chmod 777 etc/init.d/rcS
#创建 fstab 文件
cat <<EOF >etc/fstab
#<file system> <dir> <type> <options> <dump> <pass>
proc /proc proc defaults 0 0
tmpfs /tmp tmpfs defaults 0 0
sysfs /sys sysfs defaults 0 0
EOF
 chmod 777 etc/fstab
#创建inittab
cat <<EOF >etc/inittab
::sysinit:/etc/init.d/rcS
console::askfirst:-/bin/sh
::restart:/sbin/init
::shutdown:/bin/umount -a -r
::shutdown:/sbin/swapoff -a
EOF
 chmod 777 etc/inittab
#创建 passwd 文件
cat <<EOF >etc/passwd
root:J7ViBgrXF1SyI:0:0:root:/:/bin/sh
bin:*:1:1:bin:/bin:
daemon:*:2:2:daemon:/sbin:
nobody:*:99:99:Nobody:/:
EOF
 chmod 777 etc/passwd
#创建 profile 文件
cat <<EOF >etc/profile
USER="`id -un`"
LOGNAME=\$USER
PS1='[\$USER@\$HOSTNAME]:\$PWD# '
PATH=\$PATH
HOSTNAME=`/bin/hostname`
export USER LOGNAME PS1 PATH
EOF
 chmod 777 etc/profile
#创建 eth0-setting 和 eth1-setting 文件
cat <<EOF >etc/eth0-setting
IP=192.168.6.230
Mask=255.255.255.0
Gateway=192.168.6.1
DNS=192.168.6.1
MAC=08:90:90:90:90:90
EOF
cat <<EOF >etc/eth1-setting
IP=192.168.6.231
Mask=255.255.255.0
Gateway=192.168.6.1
DNS=192.168.6.1
MAC=BE:C8:1D:14:82:1D
EOF
 chmod 777 etc/eth0-setting
 chmod 777 etc/eth1-setting
#创建 ifconfig-eth0 和 ifconfig-eth1
cat <<EOF >etc/init.d/ifconfig-eth0
#!/bin/sh
echo -n Try to bring eth0 interface up......>/dev/ttyFIQ0
if [ -f /etc/eth0-setting ] ; then
source /etc/eth0-setting
if grep -q "^/dev/root / nfs " /etc/mtab ; then
echo -n NFS root ... > /dev/ttyFIQ0
else
ifconfig eth0 down
ifconfig eth0 hw ether \$MAC
ifconfig eth0 \$IP netmask \$Mask up
route add default gw \$Gateway
fi
echo nameserver \$DNS > /etc/resolv.conf
else
if grep -q "^/dev/root / nfs " /etc/mtab ; then
echo -n NFS root ... > /dev/ttyFIQ0
else
/sbin/ifconfig eth0 192.168.253.12 netmask 255.255.255.0 up
fi
fi 
echo Done >/dev/ttyFIQ0
EOF
cat <<EOF >etc/init.d/ifconfig-eth1
#!/bin/sh
echo -n Try to bring eth0 interface up......>/dev/ttyFIQ0
if [ -f /etc/eth1-setting ] ; then
source /etc/eth1-setting
if grep -q "^/dev/root / nfs " /etc/mtab ; then
echo -n NFS root ... > /dev/ttyFIQ0
else
ifconfig eth1 down
ifconfig eth1 hw ether \$MAC
ifconfig eth1 \$IP netmask \$Mask up
route add default gw \$Gateway
fi
echo nameserver \$DNS > /etc/resolv.conf
else
if grep -q "^/dev/root / nfs " /etc/mtab ; then
echo -n NFS root ... > /dev/ttyFIQ0
else
/sbin/ifconfig eth0 192.168.253.12 netmask 255.255.255.0 up
fi
fi 
echo Done >/dev/ttyFIQ0
EOF
 chmod 777 etc/init.d/ifconfig-eth0
 chmod 777 etc/init.d/ifconfig-eth1
#创建 medv.conf
cat <<EOF >etc/mdev.conf
sd[a-z][0-9] 0:0 666 @ /etc/hotplug/udisk_inserting
sd[a-z] 0:0 666 $ /etc/hotplug/udisk_removing
EOF
#创建 hotplug 文件夹
cd etc
mkdir hotplug
cd hotplug
cat <<EOF >udisk_inserting
#!/bin/sh
echo "usbdisk insert!" > /dev/console
if [ -e "/dev/\$MDEV" ] ; then
mkdir -p /mnt/usbdisk/\$MDEV
mount /dev/\$MDEV /mnt/usbdisk/\$MDEV
echo "/dev/\$MDEV mounted in /mnt/usbdisk/\$MDEV">/dev/console
fi
EOF
cat <<EOF >udisk_removing
#!/bin/sh
echo "usbdisk remove!" > /dev/console
umount -l /mnt/usbdisk/sd*
rm -rf /mnt/usbdisk/sd*
EOF
chmod 777 *
#回到顶层目录
cd ../../
#创建 mtab 文件
#进入etc目录
cd etc
ln -s /proc/mounts mtab
#创建 netd 文件
mkdir rc.d
cd rc.d
mkdir init.d
cd init.d
cat <<EOF >netd
#!/bin/sh
base=inetd
# See how we were called.
case "\$1" in
start)
/usr/sbin/\$base
;;
stop)
pid=`/bin/pidof \$base`
if [ -n "\$pid" ]; then
kill -9 \$pid
fi
;;
esac
exit 0
EOF
chmod 777 netd
#回到顶层目录
cd ../../../
