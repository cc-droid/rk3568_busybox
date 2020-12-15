CC=$${CROSS_COMPILE}gcc

SRCS = $(wildcard *.c)				#获取当前目录下的.c文件
OBJS = $(SRCS:.c=.o)				#把SRCS的所有.c文件改为.o文件存入OBJS
DEPS = $(SRCS:.c=.d)				#把SRCS的所有.c文件改为.d文件存入OBJS
BIN  = test

.PHONY:all clean					#解析阶段执行（此行下边部分）

all: $(BIN) $(DEPS)					#DEPS把.d的依赖关系也关联进总依赖树来，不然.h的内容更新了，下次编译不起作用
ifneq ("$(wildcard $(DEPS))","")	#第一次解析时，DEPS还没有生成，不用包含
include $(DEPS)						#把用-MM产生的（usb.o: usb.c usb.h）所有加入规则中，如果两条规则目标一样，依赖会合并
endif
$(BIN):$(OBJS)						#运行阶段执行（此行下边部分）
	$(CC) -o $@ $^
%.o:%.c                             #-c命令是必须依赖与目标一一对应，同时由于.h文件在预编译之后就不需要了
	$(CC) -o $@ -c $(filter %.c,$^)	
%.d:%.c								#-MM会自动根据.c文件所包含的.h文件查找生成依赖关系
	$(CC) -MM $^ > $@					
clean:
	rm -f  $(BIN) $(OBJS) $(DEPS)
