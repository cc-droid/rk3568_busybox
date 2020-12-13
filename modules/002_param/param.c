#include <linux/module.h>
#include <linux/init.h>
#include <linux/moduleparam.h>

static int num = 0;
module_param(num, int, S_IRUGO);

static int array[10] = {0};
static int array_size;
module_param_array(array, int, &array_size, S_IRUGO);

static char kstr[10];
module_param_string(str, kstr, sizeof(kstr), S_IRUGO);

static int __init param_init(void){
    int n;
    printk(KERN_ALERT"param init\n");
    
    printk(KERN_ALERT"num=%d\n",num);

    for(n=0;n<array_size;n++){
        printk(KERN_ALERT"array[%d]=%d\n",n,array[n]);
    }
    printk(KERN_ALERT"array_size=%d\n",array_size);

    printk(KERN_ALERT"str=%s\n",kstr);

    return 0;
}
static void __exit param_exit(void){
    printk(KERN_ALERT"param exit\n");
}

module_init(param_init);
module_exit(param_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("ccdroid");
