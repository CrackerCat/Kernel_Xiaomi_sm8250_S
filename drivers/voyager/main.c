// SPDX-License-Identifier: GPL-2.0

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/sched.h>
#include <linux/pid.h>
#include <linux/signal.h>
#include <misc/voyager.h>

#include <trace/hooks/misc.h>

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

static const char *target = "ActivityManager";

inline void sigkill_filter(struct task_struct *t, struct siginfo *info, pid_t pid, bool ignored)
{
	struct task_struct *pid_task;
	struct pid *pid_struct;
	int sig;

	if (!inited)
	        return;

	sig = info->si_signo;
	if (pid < 0)
		pid = -pid;

	if (sig != SIGKILL && sig != SIGTERM)
	        return;

	pid_struct = find_get_pid(pid);
	if (!pid_struct)
		return;

	pid_task = get_pid_task(pid_struct, PIDTYPE_PID);
	if (!pid_task)
		return;

	if (!strcmp(target, t->comm))
		ignored = true;
        else
	        return;
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
