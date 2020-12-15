#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int main(int argc, char* argv[]){
    char read_buf[64] = {0};
    char write_buf[64] = "write to kernel.";

    int fd;

    fd = open("/dev/chardev", O_RDWR);
    if(fd<0){
        printf("open chardev failed.\n");
        return -1;
    }

    read(fd, read_buf, sizeof(read_buf));
    printf("read_buf=%s\n", read_buf);

    write(fd, write_buf, sizeof(write_buf));

    close(fd);

    return 0;
}
