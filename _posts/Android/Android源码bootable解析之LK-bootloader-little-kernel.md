title: "Android源码bootable解析之bootloader LK(little kernel)"
date: 2015-07-25 15:56:13
categories: Android
tags: [源码分析,Qualcomm]
---
记得当初学Linux时候，bootloader 代码相对来说还比较简单，主要几个汇编文件加上几个C文件，编译一个uboot就ok了。做Android驱动后，发现Android专门做了一个目录bootable来实现boot等相关功能。功能也比较多，所以就准备来研究一下这一部分。今天就先研究一下LK，LK全称为Little Kernel，是AP模块bootloader中实现的一个微型系统。

##boot架构
<!--more-->
首先来了解一下bootable代码的目录结构，其下主要有三个子目录，如下：     
```bash
#bootable
-bootloader/LK
   -app            #功能实现，如 adb 命令
   -arch           #CPU架构
   -dev            #设备驱动
   -include      #头文件
   -kernel        #主文件，main.c
   -lib             #库文件
   -platform    #平台文件，如：msm8916
   -projiect     #mk文件
   -make       #mk文件
   -scripts      #脚本文件
   -target        #目标设备文件
   AndroidBoot.mk
   makefie
-recovery #由lk启动，主要用来更新主系统（即我们平时使用的Android系统）
-diskinstaller #打包镜像
```

##LK流程分析
在LK的链接文件ssystem-onesegment.ld 或  system-twosegment.ld （位于bootable/bootloadler/lk/arch/arm/，此文件用来指定代码的内存分布等）中，LK指定lk/arch/crt0.s中的_start函数为入口函数，crt.s主要初始化CPU，然后长跳转（bl）到lk/kernel/main.c中kmain函数，初始化lk系统，接着初始化boot，跳转到kernel。接下来按照此流程来分析一下。

###kmain()
与 boot 启动初始化相关函数为 arch_early_init、  platform_early_init 、bootstrap2/bootstrap_nandwrite，这些函数比较重要,待会儿再详解,如下:
```bash
void kmain(void)
{
	thread_init_early(); // 初始化化lk线程上下文
	arch_early_init(); // 架构初始化，如关闭cache，使能mmu
	platform_early_init(); // 平台早期初始化
	target_early_init(); //目标设备早期初始化
	bs_set_timestamp(BS_BL_START);
	call_constructors(); //静态构造函数初始化
	heap_init(); // 堆初始化
	thread_init(); // 初始化线程
	dpc_init();  //lk系统控制器初始化
	timer_init(); //kernel时钟初始化

#if (!ENABLE_NANDWRITE)
	thread_resume(thread_create("bootstrap2", &bootstrap2, NULL, DEFAULT_PRIORITY, DEFAULT_STACK_SIZE)); // 创建一个线程初始化系统
	exit_critical_section(); //使能中断
	thread_become_idle(); //本线程切换为idle线程
#else
        bootstrap_nandwrite(); 
#endif
}
```
###arch_early_init()
因为高通平台用的arm架构,所以文件路径为:\bootable\bootloader\lk\arch\arm\arch.c.
```bash
void arch_early_init(void)
{
	arch_disable_cache(UCACHE); //关闭cache
	set_vector_base(MEMBASE); // 设置异常向量基地址
	arm_mmu_init(); //初始化mmu
	arch_enable_cache(UCACHE); //打开cache

	/* enable cp10 and cp11 */
	__asm__ volatile("mrc	p15, 0, %0, c1, c0, 2" : "=r" (val));
	val |= (3<<22)|(3<<20);
	__asm__ volatile("mcr	p15, 0, %0, c1, c0, 2" :: "r" (val));
	/* set enable bit in fpexc(中断相关寄存器) */
	__asm__ volatile("mrc  p10, 7, %0, c8, c0, 0" : "=r" (val));
	val |= (1<<30);
	__asm__ volatile("mcr  p10, 7, %0, c8, c0, 0" :: "r" (val));
	/* enable the cycle count register */
	__asm__ volatile("mrc	p15, 0, %0, c9, c12, 0" : "=r" (en));
	en &= ~(1<<3); /* cycle count every cycle */
	en |= 1; /* enable all performance counters */
	__asm__ volatile("mcr	p15, 0, %0, c9, c12, 0" :: "r" (en));

	/* enable cycle counter */
	en = (1<<31);
	__asm__ volatile("mcr	p15, 0, %0, c9, c12, 1" :: "r" (en));
}
```

###platform_early_init
每个平台的初始化不一样,我使用的msm8916,路径为:\bootable\bootloader\lk\platform\msm8916\platform.c,如下:
```bash
void platform_early_init(void)
{
	board_init(); //主板初始化
	platform_clock_init(); //时钟初始化
	qgic_init();
	qtimer_init(); 
}
```
###bootstrap2 
此函数由kmain中创建的线程调用，路径为:bootable\bootloader\lk\kernel\main.c。
```bash
static int bootstrap2(void *arg)
{
	arch_init(); //架构初始化
	bio_init();
	fs_init();
	platform_init(); //平台初始化, 主要初始化系统时钟,超频等
	target_init(); //目标设备初始化,主要初始化Flash,整合分区表等
	apps_init(); // 应用功能初始化,调用aboot_init,加载kernel等
}
```

###aboot_init
此函数由上apps_init函数调用，路径: bootable\bootloader\lk\app\aboot\aboot.c.
```bash
/* Setup page size information for nv storage */
	if (target_is_emmc_boot())
	{
		page_size = mmc_page_size();
		page_mask = page_size - 1;
	}
	else
	{
		page_size = flash_page_size();
		page_mask = page_size - 1;
	}
	read_device_info(&device); //读取设备信息
	target_display_init(device.display_panel); // splash屏初始化
    target_serialno((unsigned char *) sn_buf); //设置串口号
	memset(display_panel_buf, '\0', MAX_PANEL_BUF_SIZE); //初始化显存

	if (is_user_force_reset()) // 检查关机原因,如果强制重启则正常启动
		goto normal_boot;

	if (keys_get_state(KEY_VOLUMEUP) && keys_get_state(KEY_VOLUMEDOWN)) // 如果按下音量上下键
	{
		reboot_device(DLOAD); //重启进入紧急下载	
		if (!pm8x41_ponpon_pwrkey()) {//如果按下power键和音量键,进入fastboot模式,这很可能为自定义,Android源码没有
		boot_into_fastboot = true;
		}
    /*检查重启模式,并进入相应模式*/
	reboot_mode = check_reboot_mode();
	hard_reboot_mode = check_hard_reboot_mode();
	if (reboot_mode == RECOVERY_MODE ||
		hard_reboot_mode == RECOVERY_HARD_RESET_MODE) {
		boot_into_recovery = 1;
	} else if(reboot_mode == FASTBOOT_MODE ||
		hard_reboot_mode == FASTBOOT_HARD_RESET_MODE) {
		boot_into_fastboot = true;
	} else if(reboot_mode == ALARM_BOOT ||
		hard_reboot_mode == RTC_HARD_RESET_MODE) {
		boot_reason_alarm = true;
	}
	}

normal_boot:
	if (!boot_into_fastboot)
	{
		if (target_is_emmc_boot())
		{
			if(emmc_recovery_init()) //emmc_recovery初始化
			set_tamper_fuse_cmd();
			set_tamper_flag(device.is_tampered);
			boot_linux_from_mmc();
		}
		else 
		{
			recovery_init();  // recovery模式初始化
			set_tamper_flag(device.is_tampered);
       }
		boot_linux_from_flash(); //从Flash中加载启动内核
	}
	/*不应该执行到这儿,只有没能正常启动时才会执行到这*/
	aboot_fastboot_register_commands(); // 注册fastboot命令,
	partition_dump(); //dump(即保存)分区表调试信息
	fastboot_init(target_get_scratch_address(), target_get_max_flash_size()); //初始化并进入fastboot
}
```

###boot_linux_from_flash

路径: bootable\bootloader\lk\app\aboot\aboot.c。此函数实现内核的加载，boot镜像boot.img由如下几部分构成：kernel头、kernel、ramdisk(虚拟磁盘)、second stage（可以没有）。
```bash
if (target_is_emmc_boot()) {  // 如果目标设备是emmc boot(内嵌boot)
		hdr = (struct boot_img_hdr *)EMMC_BOOT_IMG_HEADER_ADDR; // 获取emmc boot镜像首地址
		goto continue_boot; // 继续启动
	}

	ptable = flash_get_ptable(); // 获取分区表
	if(!boot_into_recovery) //非recovery模式
	{
	    ptn = ptable_find(ptable, "boot"); //获取boot分区
	}
	else
	{
	    ptn = ptable_find(ptable, "recovery"); // 获取recovery分区
	}

	if (flash_read(ptn, offset, buf, page_size)) //获取boot镜像
	if (memcmp(hdr->magic, BOOT_MAGIC, BOOT_MAGIC_SIZE)) //校验boot头
	if (hdr->page_size != page_size) //校验boot页大小

	/*
	 * Update the kernel/ramdisk/tags address if the boot image header
	 * has default values, these default values come from mkbootimg when
	 * the boot image is flashed using fastboot flash:raw
	 */
	update_ker_tags_rdisk_addr(hdr); //读取boot image头，如有默认值则更新kernel、ramdisk、tag地址

	/* Get virtual addresses since the hdr saves physical addresses. */
	/* 根据物理地址获取虚拟地址 */
	hdr->kernel_addr = VA((addr_t)(hdr->kernel_addr));
	hdr->ramdisk_addr = VA((addr_t)(hdr->ramdisk_addr));
	hdr->tags_addr = VA((addr_t)(hdr->tags_addr));

	kernel_actual  = ROUND_TO_PAGE(hdr->kernel_size,  page_mask); //获取kernel实际地址
	ramdisk_actual = ROUND_TO_PAGE(hdr->ramdisk_size, page_mask); // 获取ramdisk实际地址

	/* Check if the addresses in the header are valid. */
	/* 检查镜像头中的地址有效性*/
	if (check_aboot_addr_range_overlap(hdr->kernel_addr, kernel_actual) ||
		check_aboot_addr_range_overlap(hdr->ramdisk_addr, ramdisk_actual))
#ifndef DEVICE_TREE // 设备树,即dts\dtsi文件
		if (check_aboot_addr_range_overlap(hdr->tags_addr, MAX_TAGS_SIZE)) //检查设备树地址是否与aboot地址重合
#endif

	/* Authenticate Kernel */
	/* 鉴定内核 */
	if(target_use_signed_kernel() && (!device.is_unlocked)) //如果用签名kernel并且设备未被锁
	{
		image_addr = (unsigned char *)target_get_scratch_address();
		offset = 0;

#if DEVICE_TREE
		dt_actual = ROUND_TO_PAGE(hdr->dt_size, page_mask);
		imagesize_actual = (page_size + kernel_actual + ramdisk_actual + dt_actual);//获取镜像实际地址
		if (check_aboot_addr_range_overlap(hdr->tags_addr, hdr->dt_size)) //检查设备树地址是否与aboot地址重合
#else
		imagesize_actual = (page_size + kernel_actual + ramdisk_actual);
#endif
		bs_set_timestamp(BS_KERNEL_LOAD_START); // 开始加载boot镜像

		/* Read image without signature */
		/* 读取没有签名的镜像*/
		if (flash_read(ptn, offset, (void *)image_addr, imagesize_actual))
		bs_set_timestamp(BS_KERNEL_LOAD_DONE); //boot镜像加载完成

		offset = imagesize_actual;
		/* Read signature */
		/* 获取boot镜像签名 */
		if (flash_read(ptn, offset, (void *)(image_addr + offset), page_size))
		verify_signed_bootimg(image_addr, imagesize_actual);

		/* Move kernel and ramdisk to correct address */
		/* 移动kernel和ramdisk到正确地址*/
		memmove((void*) hdr->kernel_addr, (char *)(image_addr + page_size), hdr->kernel_size);
		memmove((void*) hdr->ramdisk_addr, (char *)(image_addr + page_size + kernel_actual), hdr->ramdisk_size);
#if DEVICE_TREE
		/* Validate and Read device device tree in the "tags_add */
		/* 校验并获取设备树*/
		if (check_aboot_addr_range_overlap(hdr->tags_addr, dt_entry.size))
		memmove((void*) hdr->tags_addr, (char *)(image_addr + page_size + kernel_actual + ramdisk_actual), hdr->dt_size);
#endif

		/* Make sure everything from scratch address is read before next step!*/
		if(device.is_tampered)
		{
			write_device_info_flash(&device);
		}
#if USE_PCOM_SECBOOT
		set_tamper_flag(device.is_tampered);
#endif
	}
	else
	{
		offset = page_size;

		kernel_actual = ROUND_TO_PAGE(hdr->kernel_size, page_mask);
		ramdisk_actual = ROUND_TO_PAGE(hdr->ramdisk_size, page_mask);
		second_actual = ROUND_TO_PAGE(hdr->second_size, page_mask);

		bs_set_timestamp(BS_KERNEL_LOAD_START); // 开始加载boot镜像

		if (flash_read(ptn, offset, (void *)hdr->kernel_addr, kernel_actual)) // 获取boot镜像
		offset += kernel_actual;
		if (flash_read(ptn, offset, (void *)hdr->ramdisk_addr, ramdisk_actual)) //获取ramdisk镜像
		offset += ramdisk_actual;
		bs_set_timestamp(BS_KERNEL_LOAD_DONE); // 结束加载

		if(hdr->second_size != 0) {
			offset += second_actual;
			/* Second image loading not implemented. */
			ASSERT(0); //跳过第二镜像
		}

#if DEVICE_TREE
		if(hdr->dt_size != 0) { // 如果设备文件存在

			/* Read the device tree table into buffer */			
			if(flash_read(ptn, offset, (void *) dt_buf, page_size))  // 读取设备树分区
			table = (struct dt_table*) dt_buf;

			if (dev_tree_validate(table, hdr->page_size, &dt_hdr_size) != 0) //校验设备树分区

			table = (struct dt_table*) memalign(CACHE_LINE, dt_hdr_size); // 获取内存地址

			/* Read the entire device tree table into buffer */
			if(flash_read(ptn, offset, (void *)table, dt_hdr_size)) // 读取设备树分区

			/* Find index of device tree within device tree table */
			if(dev_tree_get_entry_info(table, &dt_entry) != 0) //获取设备树地址

			/* Validate and Read device device tree in the "tags_add */
			if (check_aboot_addr_range_overlap(hdr->tags_addr, dt_entry.size)) // 校验设备树地址是否与aboot地址重合

			/* Read device device tree in the "tags_add */
			if(flash_read(ptn, offset + dt_entry.offset, (void *)hdr->tags_addr, dt_entry.size)) // 获取设备树
		}
#endif

	}
continue_boot:

	/* TODO: create/pass atags to kernel */

	boot_linux((void *)hdr->kernel_addr, (void *)hdr->tags_addr,
		   (const char *)hdr->cmdline, board_machtype(),
		   (void *)hdr->ramdisk_addr, hdr->ramdisk_size); //启动内核
	return 0;
}
```
>因为时间有限,并没有详细去跟代码。很多细节都是大概扫了一下函数内容或者根据注释得出结果，如有错误,欢迎指出,共同学习,共同进步。

#附
boot.img的头格式定义在：bootable\bootloader\lk\app\nandwrite\bootimg.h。如下：
```c
struct boot_img_hdr
{
    unsigned char magic[BOOT_MAGIC_SIZE];
    unsigned kernel_size;  /* size in bytes */
    unsigned kernel_addr;  /* physical load addr */
    unsigned ramdisk_size; /* size in bytes */
    unsigned ramdisk_addr; /* physical load addr */
    unsigned second_size;  /* size in bytes */
    unsigned second_addr;  /* physical load addr */
    unsigned tags_addr;    /* physical addr for kernel tags */
    unsigned page_size;    /* flash page size we assume */
    unsigned unused[2];    /* future expansion: should be 0 */
    unsigned char name[BOOT_NAME_SIZE]; /* asciiz product name */
    unsigned char cmdline[BOOT_ARGS_SIZE];
    unsigned id[8]; /* timestamp / checksum / sha1 / etc */
};
```
当我们将编译生成的boot.img用文本编辑软件打开后，能看到boot_im_hdr格式定义的头，如下：
　　![boot.img](http://7xjdax.com1.z0.glb.clouddn.com/blogboot_img.png)