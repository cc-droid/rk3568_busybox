#include <linux/init.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/fs.h>
#include <linux/kdev_t.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/uaccess.h>

static int major;
static int minor;
module_param(major,int,S_IRUGO);
module_param(minor,int,S_IRUGO);

static dev_t dev_num;
struct cdev chrdev;
struct class* class;
struct device* chardev;

static int chardev_open (struct inode *inode, struct file *file){
    printk(KERN_ALERT"open chardev...\n");

    return 0;
}

static ssize_t chardev_read (struct file *file, char __user *buf, size_t size, loff_t *off){
    char kbuf[64] = "test chardev_write.";

    printk(KERN_ALERT"read chardev...\n");

   
    if(copy_to_user(buf, kbuf, strlen(kbuf))!=0){
        printk(KERN_ALERT"copy to user failed.\n");
        return -1;
    }

    return 0;
}

static ssize_t chardev_write (struct file *file, const char __user *buf, size_t size, loff_t *off){
    char kbuf[64] ={0};

    printk(KERN_ALERT"write chardev...\n");

    if(copy_from_user(kbuf, buf, size)!=0){
        printk(KERN_ALERT"copy from user failed.\n");
        return -1;
    }
    
    printk(KERN_ALERT"kbuf=%s\n", kbuf);

    return 0;
}

static int chardev_release (struct inode *inode, struct file *file){
    printk(KERN_ALERT"release chardev...\n");
    
    return 0;
}

struct file_operations chardev_ops = {
    .owner = THIS_MODULE,
    .open = chardev_open,
    .read = chardev_read,
    .write = chardev_write,
    .release = chardev_release
};

static int __init char_init(void){
    int ret;

    printk(KERN_ALERT"char init...\n");

    if(major){
        dev_num = MKDEV(major,minor);
        ret = register_chrdev_region(dev_num, 1, "chrdev_reg" );
        if(ret<0){
            printk(KERN_ALERT"register char devnum failed.\n");
            return ret;
        }
        printk(KERN_ALERT"major=%d minor=%d \n", major, minor);

    }else{
        ret = alloc_chrdev_region(&dev_num, 0, 1, "chrdev_alloc");
        if(ret<0){
            printk(KERN_ALERT"alloc char devnum failed.\n");
            return ret;
        }
        major = MAJOR(dev_num);
        minor = MINOR(dev_num);
        printk(KERN_ALERT"major=%d minor=%d \n", major, minor);
        
    }
    
    chrdev.owner = THIS_MODULE;
    cdev_init(&chrdev, &chardev_ops);
    cdev_add(&chrdev, dev_num, 1);

    class = class_create(THIS_MODULE, "chardev");
    chardev = device_create(class, NULL, dev_num,NULL, "chardev");

    return ret;
}

static void __exit char_exit(void){
    printk(KERN_ALERT"char exit...\n");
    
    device_destroy(class, dev_num);
    class_destroy(class);
    cdev_del(&chrdev);
    unregister_chrdev_region(dev_num, 1);
}

module_init(char_init);
module_exit(char_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("ccdroid");
