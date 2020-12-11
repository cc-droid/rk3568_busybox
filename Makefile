.PHONY: kernel

all: uboot kernel busybox createfs mkfs mkimg
	@echo "=============build busybox system done=================="

cleanall: clean_uboot clean_kernel clean_busybox clean_fs clean_img
	@echo "=============clean all system==================="

uboot:
	cd u-boot; \
	./make.sh rk3568
clean_uboot:
	cd u-boot; \
	make distclean

kernel:
	cd kernel; \
	make ARCH=arm64 rockchip_linux_defconfig; \
	make ARCH=arm64 rk3568-evb1-ddr4-v10-linux.img -j12
clean_kernel:
	cd kernel; \
	make distclean
	
busybox:
	cd busybox-1.33.1; \
	cp rk3568.config .config; \
	make; \
	make install
clean_busybox:
	cd busybox-1.33.1; \
	make distclean
	rm -rf system

createfs:
	./tools/createfs.sh
mkfs:
	./tools/mkfs.sh
clean_fs:
	rm -rf system
	rm -rf rootfs.img
mkimg:
	./tools/mkimg.sh
	rm -rf rootfs.img
clean_img:
	rm -rf images
