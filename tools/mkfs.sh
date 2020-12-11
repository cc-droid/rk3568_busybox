#! /bin/bash
mkdir rootfs
sudo dd if=/dev/zero of=rootfs.ext4 bs=1M count=300
sudo mkfs.ext4 -L rootfs rootfs.ext4
sudo mount ./rootfs.ext4 rootfs
sudo cp -r ./system/* ./rootfs
sudo umount rootfs
mv rootfs.ext4 rootfs.img
sudo rm -rf rootfs
