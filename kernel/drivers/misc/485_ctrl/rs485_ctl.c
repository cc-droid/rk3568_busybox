
#include <linux/module.h>
#include <linux/miscdevice.h>
#include <linux/err.h>
#include <linux/gpio.h>
#include <linux/gpio/consumer.h>
#include <linux/kernel.h>
#include <linux/leds.h>
#include <linux/module.h>
#include <linux/of.h>
#include <linux/platform_device.h>
#include <linux/property.h>
#include <linux/slab.h>
#include <linux/init.h>
#include <asm/types.h>
#include <linux/uaccess.h>
#include <linux/of_gpio.h>
#include <linux/miscdevice.h>

#define CMD_SWITCH_STATE 0
#define CMD_GET_STATE 1
#define RSR485_RECEIVER_STATE 0
#define RSR485_SENDER_STATE 1

static DEFINE_MUTEX(rs485_mutex_lock);

static int ctrl_gpio;
static int rs485_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
	int ret = 0;
	switch (cmd) {
	case CMD_SWITCH_STATE:
		gpio_set_value(ctrl_gpio, arg);
		if (gpio_get_value(ctrl_gpio) != arg) {
			printk("[debug] gpio set value failed:%d\n", ret);
			return -1;
		}
		printk("[debug] gpio set value %ld success\n", arg);
		break;
	case CMD_GET_STATE:
		ret = gpio_get_value(ctrl_gpio);
		if (ret < 0) {
			printk("[debug] gpio get value failed:%d\n", ret);
			return -1;
		}
		if (copy_to_user((int *)arg, &ret, sizeof(int))) {
			printk("copy data to user space failed!\n");
			return -1;
		}
		break;
	}
	return 0;
}

static int rs485_open(struct inode *inode, struct file *file)
{
	return nonseekable_open(inode, file);
}

static long rs485_unlocked_ioctl(struct file *file, unsigned int cmd,
				 unsigned long arg)
{
	int ret;
	mutex_lock(&rs485_mutex_lock);
	ret = rs485_ioctl(file, cmd, arg);
	mutex_unlock(&rs485_mutex_lock);
	return ret;
}

static const struct file_operations rs485_fops = {
	.owner = THIS_MODULE,
	.open = rs485_open,
	.unlocked_ioctl = rs485_unlocked_ioctl,
};

static struct miscdevice rs485_miscdev = { MISC_DYNAMIC_MINOR, "rs485_ctl",
					   &rs485_fops };

static const struct of_device_id of_rs485_ctl_match[] = {
	{
		.compatible = "topeet,rs485_ctl",
	},
	{},
};

MODULE_DEVICE_TABLE(of, of_rs485_ctl_match);

static int rs485_ctl_probe(struct platform_device *pdev)
{
	int ret;
	struct device *dev;
	printk("[debug] rs485_ctl_probe");

	dev = &pdev->dev;
	
	ctrl_gpio = of_get_named_gpio(dev->of_node, "gpios", 0);
	if (!gpio_is_valid(ctrl_gpio)) {
		printk("of_get_named_gpio is error \n");
		return -1;
	}
	ret = devm_gpio_request(dev, ctrl_gpio, "rs485_ctl");
	if (ret < 0) {
		dev_err(&pdev->dev, "failed to request GPIO#%d: %d\n",
			ctrl_gpio, ret);
		return -1;
	}
	gpio_direction_output(ctrl_gpio, 1);
	ret = misc_register(&rs485_miscdev);
	if (ret < 0)
		return ret;

	return 0;
}

static int rs485_ctl_remove(struct platform_device *pdev)
{
	printk("[debug] rs485_ctl_shutdown");
	misc_deregister(&rs485_miscdev);
	return 0;
}

static struct platform_driver rs485_ctl_driver = {
	.probe		= rs485_ctl_probe,
	.remove		= rs485_ctl_remove,
	.driver		= {
		.name	= "rs485-ctl-gpio",
		.of_match_table = of_rs485_ctl_match,
	},
};

module_platform_driver(rs485_ctl_driver);

MODULE_AUTHOR("topeet apple");
MODULE_DESCRIPTION("GPIO rs485 ctl driver");
MODULE_LICENSE("GPL");
MODULE_ALIAS("platform:rs485_ctl");
