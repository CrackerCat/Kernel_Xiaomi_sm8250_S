// SPDX-License-Identifier: GPL-2.0

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/sched.h>
#include <linux/pid.h>
#include <linux/signal.h>
#include <misc/voyager.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("The Voyager");
MODULE_DESCRIPTION("kernel addon");
MODULE_VERSION("0.0.1");

bool skip_charge_therm;
bool mi_thermal_switch;
bool inited = false;
bool enhance_background = true;

module_param(skip_charge_therm, bool, 0644);
module_param(mi_thermal_switch, bool, 0644);
module_param(enhance_background, bool, 0644);

#define vk_err(fmt, ...) \
	pr_err("kernel addon: %s: " fmt, __func__, ##__VA_ARGS__)

static const char *target[] = {
        "MiuiMemoryServic",
        "lmkd",
};

inline void sigkill_filter(struct siginfo *info, bool *ignored)
{
        struct task_struct *tsk;
        int sig = info->si_signo;
        int *pid = &info->si_pid;
	int i;

	if (sig != SIGKILL && sig != SIGTERM)
	        return;
        
        tsk = pid_task((void *)pid, PIDTYPE_PID);
        if (tsk == NULL)
                return;

        for (i = 0; i < ARRAY_SIZE(target); i++) {
	        if (!strcmp(tsk->comm, target[i]))
                        vk_err("Blocking \"%s\"(%d) send signal %d to "
				"\"%s\"(%d)\n", NULL);
	        	*ignored = true;
        }
}

static int __init kernel_addon_init(void) {
        printk(KERN_INFO "voyager kernel addon initialized");
        mi_thermal_switch = false;
        skip_charge_therm = false;
      
        inited = true;
        return 0;
}

static void __exit kernel_addon_exit(void) {
        printk(KERN_INFO "kernel addon exit");
}

module_init(kernel_addon_init);
module_exit(kernel_addon_exit);
