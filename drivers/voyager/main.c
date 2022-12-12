// SPDX-License-Identifier: GPL-2.0

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <misc/voyager.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("The Voyager");
MODULE_DESCRIPTION("kernel addon");
MODULE_VERSION("0.0.1");

bool skip_charge_therm;
bool mi_thermal_switch;

module_param(skip_charge_therm, bool, 0644);
module_param(mi_thermal_switch, bool, 0644);

static int __init kernel_addon_init(void) {
        printk(KERN_INFO "voyager kernel addon initialized");
        mi_thermal_switch = false;
        skip_charge_therm = false;

        return 0;
}

static void __exit kernel_addon_exit(void) {
        printk(KERN_INFO "kernel addon exit");
}

module_init(kernel_addon_init);
module_exit(kernel_addon_exit);
