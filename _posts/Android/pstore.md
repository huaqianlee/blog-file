title: Pstore 的一些记录
date: 2020-11-13 00:00:51
categories:
- Android Tree
- Kernel
tags:
---

# What is pstore？

`pstore, persistent storage`, 是一个存储内核日志或者内核 panic 的文件系统，内核会把相关信息存储在一个不能被其他用户重写的指定 RAM 区域，下一次启动时，这个区域会被挂载到 `/pstore`，一般在 `/sys/fs/pstore`, 这样我们就可以访问这些数据了。

pstore 在内核中的开关是 CONFIG_PSTORE，pstore 提供的是一套可扩展的机制，提供如下类型：
- PSTORE_TYPE_DMESG, 表示内核日志
- PSTORE_TYPE_MCE, 表示硬件错误
- PSTORE_TYPE_CONSOLE, 表示控制台输出,所有内核信息。
- PSTORE_TYPE_FTRACE, 表示函数调用序列, ftrace 信息。

ramoops 指的是采用 ram 保存 oops 信息的一个功能，这个功能从 3.10.40 开始采用 pstore 机制来实现，内核中的开关控制：
- PSTORE_PMSG，用户空间信息，/dev/pmsg0，pmsg-ramoops-<ID>
- PSTORE_CONSOLE，控制台输出，所有内核信息，console-ramoops-<ID>
- PSTORE_FTRACE，函数调用序列, ftrace 信息。
- PSTORE_RAM， panic/oops 信息


# How to config?

<!--more-->
用我本地的 SDM660 和 MSM8909 平台源码配置 pstore 时，按照如下方式可以实现：  
```c
// kernel/msm-4.14/arch/arm64/configs/vendor/sdm660_defconfig
CONFIG_PSTORE=y
CONFIG_PSTORE_CONSOLE=y
CONFIG_PSTORE_RAM=y
CONFIG_PSTORE_FTRACE=y

CONFIG_DEBUG_FS=y
CONFIG_FUNCTION_TRACER=y

and disable below config:
# CONFIG_STRICT_MEMORY_RWX

# kernel/msm-4.14/fs/pstore/ram.c
-static ulong ramoops_console_size = MIN_MEM_SIZE;
+static ulong ramoops_console_size = 256*1024UL;

- static ulong mem_address;
+ static ulong mem_address=0x9ff00000;
 module_param(mem_address, ulong, 0400);
 MODULE_PARM_DESC(mem_address,
         "start of reserved RAM used to store oops/panic logs");
 
- static ulong mem_size;
+ static ulong mem_size=0x100000;


// kernel/msm-4.14/arch/arm64/boot/dts/qcom/sdm660.dtsi
// 在 RAM 中保留空间：       
	reserved-memory {
		#address-cells = <2>;
		#size-cells = <2>;
		ranges;
        ...
+        pstore_reserve_mem: pstore_reserve_mem_region@0 {
+            linux,reserve-contiguous-region;
+            linux,reserve-region;
+            linux,remove-completely;
+            reg = <0x0 0x9ff00000 0x0 0x00100000>;
+            label = "pstore_reserve_mem";
+        };
...
}
```

基于我的实验，在 SM6125 平台按照如下方式修改可以使 ramoops 正常工作。
```c
// arch/arm64/boot/dts/qcom/trinket.dtsi
@@ -594,6 +594,18 @@
size = <0 0x2000000>;
linux,cma-default;
};
+
+ /* enabled pstore */
+ ramoops: ramoops@ffc00000 {
+ compatible = "removed-dma-pool", "ramoops";
+ no-map;
+ reg = <0 0xffc00000 0 0x00100000>;
+ record-size = <0x1000>;
+ console-size = <0x40000>;
+ ftrace-size = <0x0>;
+ msg-size = <0x20000 0x20000>;
+ cc-size = <0x0>;
+ };
};
};

// arch/arm64/configs/vendor/trinket-perf_defconfig
CONFIG_SND_SOC_DBMDX_VA_I2S_MASTER=y
CONFIG_SND_SOC_DBMDX_AEC_REF_32_TO_16_BIT=y
CONFIG_ANT_CHECK=y
+
+# enable pstore
+CONFIG_PSTORE=y
+CONFIG_PSTORE_FTRACE=y
+CONFIG_PSTORE_PMSG=y
+CONFIG_PSTORE_RAM=y
+CONFIG_PSTORE_CONSOLE=y
-CONFIG_FREE_PAGES_RDONLY=y

//为了保持在 DDR 中保存 `pstore` 的内容，需要设备 WARM-RESET。
# drivers/power/reset/msm-poweroff.c,
static void msm_restart_prepare(const char *cmd)
{
bool need_warm_reset = false;
...
+ /* WARM-RESET is needed for keeping PSTORE content in DDR */
+ need_warm_reset = true;

/* Hard reset the PMIC unless memory contents must be maintained. */
if (need_warm_reset) {
    qpnp_pon_system_pwr_off(PON_POWER_OFF_WARM_RESET);
} else {
    qpnp_pon_system_pwr_off(PON_POWER_OFF_HARD_RESET);
}
```

# Where does sysfs create?

我们可以在 `/sys/fs/pstore/*` 看到加载的 `pstore` 数据，如下：
```bash
ls /sys/fs/pstore/                                                                                                                                                                               
console-ramoops-0 pmsg-ramoops-0  ...
```

其来自于如下源码：
```c
// /kernel/msm-4.4/fs/pstore/inode.c#300
int pstore_mkfile(enum pstore_type_id type, char *psname, u64 id, int count,
		  char *data, bool compressed, size_t size,
		  struct timespec time, struct pstore_info *psi)
{
...
	switch (type) {
	case PSTORE_TYPE_DMESG:
		scnprintf(name, sizeof(name), "dmesg-%s-%lld%s",
			  psname, id, compressed ? ".enc.z" : "");
		break;
	case PSTORE_TYPE_CONSOLE:
		scnprintf(name, sizeof(name), "console-%s-%lld", psname, id);
		break;
	case PSTORE_TYPE_FTRACE:
		scnprintf(name, sizeof(name), "ftrace-%s-%lld", psname, id);
		break;
	case PSTORE_TYPE_MCE:
		scnprintf(name, sizeof(name), "mce-%s-%lld", psname, id);
		break;
	case PSTORE_TYPE_PPC_RTAS:
		scnprintf(name, sizeof(name), "rtas-%s-%lld", psname, id);
		break;
	case PSTORE_TYPE_PPC_OF:
		scnprintf(name, sizeof(name), "powerpc-ofw-%s-%lld",
			  psname, id);
		break;
	case PSTORE_TYPE_PPC_COMMON:
		scnprintf(name, sizeof(name), "powerpc-common-%s-%lld",
			  psname, id);
		break;
	case PSTORE_TYPE_PMSG:
		scnprintf(name, sizeof(name), "pmsg-%s-%lld", psname, id);
		break;
	case PSTORE_TYPE_PPC_OPAL:
		sprintf(name, "powerpc-opal-%s-%lld", psname, id);
		break;
	case PSTORE_TYPE_UNKNOWN:
		scnprintf(name, sizeof(name), "unknown-%s-%lld", psname, id);
		break;
	default:
		scnprintf(name, sizeof(name), "type%d-%s-%lld",
			  type, psname, id);
		break;
	}
...
```

# How to test?

```bash
# 检查 pstore 配置成功与否。
cat /sys/module/pstore/parameters/*  
ramoops # backend
-1      # update_ms

# 检查相关预留 size 是否配置成功
ls /sys/module/ramoops/parameters
console_size ftrace_size mem_type         pmsg_pmc_size    record_size 
dump_oops    mem_address pmsg_events_size pmsg_radio_size  
ecc          mem_size    pmsg_main_size   pmsg_system_size 
cat /sys/module/ramoops/parameters/*
131072
1
1
0
2499805184
1441792
0
262144
262144
262144
262144
262144
0

# enable record ftrace
mount -t debugfs debugfs /sys/kernel/debug/
echo 1 > /sys/kernel/debug/pstore/record_ftrace

# `pstore` 配置成功后，不能自动重启并加载 pstore 数据的话，一般是由于配置了 panic 时进入 download mode。即 download_mode 为 1，定义于 `kernel/msm-4.14/drivers/power/reset/msm-poweroff.c`。
# disable download mode:
echo 0 > /sys/module/msm_poweroff/parameters/download_mode
echo c > /proc/sysrq-trigger

ls /sys/fs/pstore/
  console-ramoops
  dmesg-ramoops-0
  dmesg-ramoops-1
  ftrace-ramoops

cat /sys/fs/pstore/ftrace-ramoops
0 c08bf830  c08bfbf0  do_page_fault.part.8 <- do_page_fault+0x3c/0xa8
0 c001b770  c08bfb48  fixup_exception <- do_page_fault.part.8+0x32c/0x398
0 c0045bb0  c001b780  search_exception_tables <- fixup_exception+0x20/0x38
0 c008914c  c0045bd8  search_module_extables <- search_exception_tables+0x38/0x44
0 c08bff5c  c008915c  add_preempt_count <- search_module_extables+0x24/0xc0
0 c08bfe78  c00891cc  sub_preempt_count <- search_module_extables+0x94/0xc0
0 c08b2e28  c08bfb64  __do_kernel_fault.part.7 <- do_page_fault.part.8+0x348/0x398
```



# How to debug?

1. 在 `msm_restart_probe` 中加日志确认 PMIC 是被配置为 warm reset mode。
2. 如果需要为未知重启保存 `pstore` 日志，需要确认 `XBL` 中正确设置了 PSHOLD trigger 为 PMIC warm reset mode。
3. 查看 `pstore` setup 流程：
```c
ramoops_init
ramoops_register_dummy
ramoops_probe
ramoops_register
```

4. 查看 `pstore` 数据保存流程：
```c
register a pstore_dumper
// when panic happens, kmsg_dump is called
call dumper->dump
pstore_dump
```

5. 查看 `pstore` 数据读取流程：
```c
ramoops_probe
persistent_ram_post_init
pstore_register
pstore_get_records
ramoops_pstore_read
pstore_decompress (only for dmesg)
pstore_mkfile (save to files)
```


