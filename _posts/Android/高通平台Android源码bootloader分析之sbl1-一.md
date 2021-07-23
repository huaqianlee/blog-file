title: "高通平台Android源码bootloader分析之sbl1(一)"
date: 2015-08-15 20:44:33
categories:
- Android Tree
- Misc
tags: [源码分析,Qualcomm]
---
[高通平台Android源码bootloader分析之sbl1(一)](http://huaqianlee.github.io/2015/08/15/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%B8%80/)
[高通平台Android源码bootloader分析之sbl1(二)](http://huaqianlee.github.io/2015/08/15/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%BA%8C/)
[高通平台Android源码bootloader分析之sbl1(三)](http://huaqianlee.github.io/2015/08/18/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%B8%89/)




高通8k平台的boot过程搞得比较复杂， 我也是前段时间遇到一些问题深入研究了一下才搞明白。不过虽然弄得很复杂，我们需要动的东西其实很少，modem侧基本就sbl1（全称：Secondary boot loader）的代码需要动一下，ap侧就APPSBL代码需要动（对此部分不了解，可参照：[bootable 源码解析](http://huaqianlee.github.io/2015/07/25/Android/Android%E6%BA%90%E7%A0%81bootable%E8%A7%A3%E6%9E%90%E4%B9%8BLK-bootloader-little-kernel/)），其他的都是高通搞好了的，甚至有些我们看不到代码。今天就要分析一下开机前几秒钟起着关键作用的sbl1， 这套代码在modem侧的boot_images\中。

## 启动流程
首先来看一下高通的bootloader流程框图，主要由ap、RPM及modem三部分构成，由于我工作主要涉及到ap侧，所以对RPM和modem侧代码不了解，以后有空时间的话到可以研究一下，框图如下：
<!--more-->
![boot arch](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/20155304921b788-8a63-472f-be7c-2220a98cf428.jpg)
由上图可知，系统启动流程主要由以下几步组成：
1. 系统上电或重启。

2. 在Cortex-a53芯片中，ap侧的PBL执行，从boot device中加载sbl1镜像到TCM，并对镜像进行校验，然后跳转到sbl1中继续执行.

3. sbl1初始化ddr，从boot device中加载QSEE镜像和QHEE镜像到DDR，并对镜像进行校验，QSEE执行并设置一个安全的环境，QHEE为VMM设置、SMMU配置及xPU访问控制服务。

4. sbl1从boot device加载RPM固件镜像到code-RAM，并对镜像进行校验。

5. sbl1从启动设备加载HLOS APPSBL镜像到ddr，并对镜像进行校验。

6. sbl1跳转到QSEE->QHEE。

7. QHEE通知RPM侧跳转到RPM固件中并自己跳转到HLOS APPSBL中执行。RPM侧开始执行RPM固件。

8. QHEE跳转到HLOS APPSBL中初始化系统。

9. HLOS APPSBL加载和校验HLOS内核。

10. 由内核来加载文件系统等完成整个Android系统的启动。

>HLOS APPSBL即为ap侧的bootloader，见：[bootable源码解析](http://huaqianlee.github.io/2015/07/25/Android/Android%E6%BA%90%E7%A0%81bootable%E8%A7%A3%E6%9E%90%E4%B9%8BLK-bootloader-little-kernel/)

　　
modem侧主要是射频网络相关的代码，我没有研究过也不了解，RPM侧的代码也没怎么研究，高通文档对其介绍如下：
![RPM](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/blogRPM.png)

## sbl1流程分析
接下来我就来跟一下sbl1的代码，总结出关键流程，此部分代码皆在modem侧。我平时主要会涉及的几个重要文件：
```bash
boot_images\core\boot\secboot3\hw\msm8916\sbl1\sbl1_hw.c
boot_images\core\systemdrivers\pmic\framework\src\pm_init.c
boot_images\core\boot\secboot3\hw\msm8909\sbl1\sbl1_config.c
boot_images\core\systemdrivers\pmic\app\chg\src\pm_app_chg_alg.c
boot_images\core\systemdrivers\pmic\drivers\smb\src\pm_smb.c // 如果带smb135x芯片
```

首先从其入口文件sbl1.s开始，如下：
### sbl1入口： sbl1.s
此部分代码路径在：boot_images/core/boot/secboot3/hw/msm8916/sbl1/sbl1.s，此文件引导处理器，主要有实现如下操作：
* 设置硬件，继续boot进程。
* 初始化ddr。
* 加载Trust_Zone操作系统。
* 加载RPM固件。
* 加载APPSBL然后继续boot进程。

关键源码如下：
```asm
/*引入c函数，主要为异常实现函数，及一个关键函数sbl1_main_ctl*/
; Import the external symbols that are referenced in this module.
IMPORT |Image$$SBL1_SVC_STACK$$ZI$$Limit|
IMPORT |Image$$SBL1_UND_STACK$$ZI$$Limit|
IMPORT |Image$$SBL1_ABT_STACK$$ZI$$Limit|
IMPORT boot_undefined_instruction_c_handler
IMPORT boot_swi_c_handler
IMPORT boot_prefetch_abort_c_handler
IMPORT boot_data_abort_c_handler
IMPORT boot_reserved_c_handler
IMPORT boot_irq_c_handler
IMPORT boot_fiq_c_handler
IMPORT boot_nested_exception_c_handler
IMPORT sbl1_main_ctl #主要关注此函数
IMPORT boot_crash_dump_regs_ptr
...
# 关于中断向量配置等汇编语句，就没有去详细看了，我们一般也不会涉及到这么底层的东西
```
### sbl1_main_ctl
此函数位于boot_images\core\boot\secboot3\hw\mdm9x45\sbl1\sbl1_mc.c，主要完成初始化RAM等工作， 注此函数决不return。部分关键源码如下，我加汉字解释的是我认为我们应该关注的部分：
```c
/* Calculate the SBL start time for use during boot logger initialization. */
sbl_start_time = CALCULATE_TIMESTAMP(HWIO_IN(TIMETICK_CLK));
boot_clock_debug_init();
/* Enter debug mode if debug cookie is set */
sbl1_debug_mode_enter();  
/* Initialize the stack protection canary */
boot_init_stack_chk_canary();

/* Initialize boot shared imem */
boot_shared_imem_init(&bl_shared_data);
/*初始化RAM*/
boot_ram_init(&sbl1_ram_init_data);
/*初始化log系统，即串口驱动*/
sbl1_boot_logger_init(&boot_log_data, pbl_shared);
/*检索PBL传递过来的数据*/ 
sbl1_retrieve_shared_info_from_pbl(pbl_shared); 
/* Initialize the QSEE interface */
sbl1_init_sbl_qsee_interface(&bl_shared_data,&sbl_verified_info);
/* Initialize SBL memory map. Initializing early because drivers could be located in RPM Code RAM. */
sbl1_populate_initial_mem_map(&bl_shared_data);
/*初始化DAL*/
boot_DALSYS_InitMod(NULL); 
/*配置PMIC芯片，以便我们能通过PS_HOLD复位*/
sbl1_hw_init();
/*执行sbl1的目标依赖进程*/
boot_config_process_bl(&bl_shared_data, SBL1_IMG, sbl1_config_table);
```
### sbl1_config_table
sbl1_config_table为一个结构体数组，里面存储了加载QSEE、RPM、APPSBL等镜像所需要的配置参数及执行函数，位于boot_images\core\boot\secboot3\hw\msm8909\sbl1\sbl1_config.c。其关键代码如下：
```c
boot_configuration_table_entry sbl1_config_table[] = 
{

 /* SBL1 -> QSEE */
  {
    SBL1_IMG,                   /* host_img_id */
    CONFIG_IMG_QC,              /* host_img_type */
    GEN_IMG,                    /* target_img_id */
    CONFIG_IMG_ELF,             /* target_img_type */
    ...
    load_qsee_pre_procs,        /* pre_procs */ 
    load_qsee_post_procs,       /* post_procs */
}
/* SBL1 -> QHEE */
...
/* SBL1 -> RPM */
...
/* SBL1 -> APPSBL （即lk部分） */
...
```
### load_qsee_pre_procs
load_qsee_pre_procs为一个函数结构体数组，在QSEE加载之前执行。源码注释写得很清楚并且容易理解，我就不多此一举去翻译了，关键源码如下：
```c
  /* Save reset register logs */
  boot_save_reset_register_log,
  
  /* Initialize the flash device */
  boot_flash_init,
  
  /* Copy the configure data table from eeprom */
  boot_config_data_table_init,
  
  /* Store platform id */
  sbl1_hw_platform_pre_ddr,
  
  /* Configure ddr parameters based on eeprom CDT table data. */
  sbl1_ddr_set_params,
  
  /* Initialize DDR */
  (boot_procedure_func_type)sbl1_ddr_init,

  /*----------------------------------------------------------------------
   Run deviceprogrammer if compiling the deviceprogrammer_ddr image.
  ----------------------------------------------------------------------*/
  boot_deviceprogrammer_ddr_main,
  
  /* Initialize SBL1 DDR ZI region, relocate boot log to DDR */   
  sbl1_post_ddr_init,
  
  /* 此函数挺重要，我能改到的东西基本上都基于它，所有的PMIC API都是在此函数调用boot_pm_dirver_init()之后再被调用*/
  sbl1_hw_init_secondary, 
 
  /* DDR training */
  (boot_procedure_func_type)sbl1_wait_for_ddr_training,
  
  /* Initialize SBL1 DDR ZI region, relocate page table to DDR */
  sbl1_post_ddr_training_init, 
  
  /* Zero out QSEE and QHEE region if needed.  This MUST be done before
     boot_dload_dump_security_regions executes for security reasons. */
  sbl1_cleanse_security_regions,

  /* Backup QSEE and QHEE region for ramdumps taken after SBL has executed */
  boot_dload_dump_security_regions,

  /* Check to see if DLOAD mode needs to be entered */
  boot_dload_check,

  /* Last entry in the table. */
  NULL 
```
### load_qsee_post_procs
load_qsee_post_procs同样也为一个函数结构体数组，其在加载QSEE之后执行。关键源码如下：
```c
 /* Enable the secure watchdog
     This is done after boot_dload_check that way if we are in the final stage
     of an abnormal reset boot_dload_check will finalize the stage. */
  boot_secure_watchdog_init,
  
  /* Load SEC partition if it exists.  This must be done after QSEE is
     loaded as the partition is loaded into a QSEE buffer. */
  sbl1_load_sec_partition,  

  /* Set the memory barrier pointer to shared memory */
  boot_cache_set_memory_barrier,

  /*----------------------------------------------------------------------
   Put SMEM in debug state such that smem_alloc() calls will return NULL. 
   The state is changed back to normal once smem_boot_init() is called.
   This call has to be made after setting the memory barrier.
  ----------------------------------------------------------------------*/
  boot_smem_debug_init,  
    
  /* Initialize shared memory after dload to preserve logs */
  boot_smem_init,

#if !defined(FEATURE_RUMI_BOOT)
  /* Stub out for rumi build. pmic api  pm_get_power_on_status gets 
     called from below api to get power on reason */ 
  /*----------------------------------------------------------------------
   Store Power on Status in SMEM. 
   Needs to be done after PMIC and SMEM initialization
  ----------------------------------------------------------------------*/
  boot_smem_store_pon_status,
#endif  

  /*----------------------------------------------------------------------
   Store the platform id to smem
  ----------------------------------------------------------------------*/
  sbl1_hw_platform_smem,
   
  /*----------------------------------------------------------------------
   Get shared data out of the flash device module
  ----------------------------------------------------------------------*/
  boot_share_flash_data,
  
  /*----------------------------------------------------------------------
   populate the ram partition table
  ----------------------------------------------------------------------*/
  boot_populate_ram_partition_table,

  /*----------------------------------------------------------------------
   Initialize GPIO for low power configuration
  ----------------------------------------------------------------------*/
  sbl1_tlmm_init,
  
  /*-----------------------------------------------------------------------
   Calls efs cookie handling api to perform efs backup/restore
  -----------------------------------------------------------------------*/  
  sbl1_efs_handle_cookies,
    
  /*-----------------------------------------------------------------------
   APT Security Test
   ----------------------------------------------------------------------*/
  (boot_procedure_func_type)boot_apt_test,

  /* Last entry in the table. */
  NULL 
```
### pm_chg_charger_detect_state
pm_chg_charger_detect_state函数是启动工程中非常重要的一个函数，它将监测电池的状态，然后决定启动过程，调用关系和解析如下：
```bash
sbl1_hw_init_secondary
 ->boot_pm_dirver_init 
  ->pm_driver_init #初始化PMIC驱动
   ->pm_driver_post_init
    ->pm_chg_sbl_charging_state_entry
     ->pm_chg_battery_and_debug_board_detect_state
      ->pm_chg_charger_detect_state #监测电池状态，电池正常则启动，weak则死循环，充电知道电池正常
       ->pm_chg_enable_usb_charging
```

### pm_chg_sbl_charging_state_entry
pm_chg_sbl_charging_state_entry是充电状态机的入口函数， 如果充电状态不正确的话会造成死机，代码如下：
```c
pm_err_flag_type  pm_chg_sbl_charging_state_entry(void)   //called at the end of pm_driver_init
{
    pm_err_flag_type err_flag = PM_ERR_FLAG__SUCCESS;

    pm_chg_status.previous_state = PM_CHG_ENTRY_STATE;
    pm_chg_status.current_state  = PM_CHG_ENTRY_STATE;
    pm_chg_status.batt_level  = 0;

    //Get handle for charger algorithm specific data (from Dal config)
    sbl_chg_app_ds = (uint16*)pm_target_information_get_specific_info(PM_PROP_CHG_APP_LUT);

    //Check Battery/Debug board presence
    next_state_ptr = &pm_chg_state__battery_and_debug_board_detect;

    err_flag |= pm_chg_sbl_charging_initialize();
    
    err_flag |= pm_chg_process_sbl_charger_states();  //Process next sbl charging state
    
    if( err_flag != PM_ERR_FLAG__SUCCESS)  
    {//Handle All SBL charger algorithm errors
       PM_ERR_FATAL();      // sbl充电状态异常的话，调用此函数，此函数其实就是一个空的while(1)，如果执行到此步，机器则死机，必须断电才能继续工作
    }
   
    return err_flag;
}
```

### pm_chg_process_sbl_charger_states
pm_chg_process_sbl_charger_states函数也是启动过程中非常重要的一个函数，此函数里面有一个死循环，用来更新充电状态或者关机，其被pm_chg_sbl_charging_state_entry函数调用（见上调用关系）。插上充电器开机前几秒就出现的重启问题， 多半是此部分出了状况。代码如下：
```c
static pm_err_flag_type  pm_chg_process_sbl_charger_states(void)
{
    pm_err_flag_type err_flag = PM_ERR_FLAG__SUCCESS;
    pm_chg_state_alg_ptr_type next_state = NULL;

    //Process SBL charging states transitions
    while( (next_state_ptr != NULL)  )
    {
        pm_chg_status.previous_state = pm_chg_status.current_state;
        pm_chg_status.current_state  = next_state_ptr->current_chg_state;

        next_state = next_state_ptr->next_chg_state_alg;
        if (next_state)
        {
           err_flag = next_state();  //transition to next state
        }
                
        if ( ( err_flag                     != PM_ERR_FLAG__SUCCESS  )  ||
             ( pm_chg_status.current_state == PM_CHG_BOOTUP_STATE   )  ||
             ( pm_chg_status.current_state == PM_CHG_SHUTDOWN_STATE )      //Shutdown state condition will never happen but we have it for sake of being complete
           )
        {
            break;  
        }
    }
    return err_flag;
}

```

