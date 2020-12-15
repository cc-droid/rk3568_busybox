obj-m=param.o

KDIR=$$TOP_DIR/kernel

all:
	make -C $(KDIR) M=`pwd` modules
clean:
	rm -rf *.ko *.mod.c *.mod.o *.o modules.order Module.symvers .*.*.cmd .tmp_versions
