title: "高通平台Android源码bootloader分析之sbl1(三)"
date: 2015-08-18 00:48:26
categories:
- Android Tree
- Misc
tags: [源码分析,Qualcomm]
---
[高通平台Android源码bootloader分析之sbl1(一)](http://huaqianlee.github.io/2015/08/15/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%B8%80/)
[高通平台Android源码bootloader分析之sbl1(二)](http://huaqianlee.github.io/2015/08/15/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%BA%8C/)
[高通平台Android源码bootloader分析之sbl1(三)](http://huaqianlee.github.io/2015/08/18/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%B8%89/)


前两篇博文分析了启动流程、代码流程、cdt，接下来就分析另外几个需要格外关注的部分。

## log系统
sbl1中的log系统也是sbl1部分调试会经常接触得部分高通平台在sbl中做的log系统并不是很强大， 但是对于我们调试已经远远足够了。
###sbl1_boot_logger_init
sbl1_boot_logger_init是log系统的初始化函数，被sbl1_main_ctl函数调用（详细参考：高通平台Android源码bootloader分析之sbl1(一)），其源码如下：
<!--more-->
```c
# boot_images\core\boot\secboot3\hw\msm8916\sbl1\sbl1_mc.c
static void sbl1_boot_logger_init(  boot_log_init_data *boot_log_data,  boot_pbl_shared_data_type *pbl_shared)
{
  /*initialize boot logger*/
  boot_log_init(boot_log_data); 

  /* Write PBL timestamp milestones into beginning of log */
  boot_pbl_log_milestones(pbl_shared);

  /* Set the reference time to 0 as the start of boot*/
  boot_log_set_ref_time(0);

  /* Add SBL start entry using stored time from beginning of sbl1_main_ctl */
  boot_log_message_raw("SBL1, Start",
                       sbl_start_time,
                       LOG_MSG_TYPE_BOOT,
                       NULL);

}/* sbl1_boot_logger_init */
```

### boot_log_init
boot_log_init被上面函数调用，位于boot_logger.c中，log的打印函数也全在此文件，其源码如下：
```c
#boot_images\core\boot\secboot3\src\boot_logger.c
另几个log相关的文件，与boot_logger.c同一路径：
 boot_logger_uart.c
 boot_logger_ram.c
 boot_logger_timer.c

void boot_log_init(boot_log_init_data *init_data)
{
  /*we must first set meta info becasue boot_log_init_ram and
   * boot_log_init_timer will use the meta info structure*/
  boot_log_set_meta_info(init_data->meta_info_start);
  boot_log_init_ram(init_data); // 初始化ram log
  boot_init_timer(init_data); // 初始化时钟
  boot_log_init_uart();// 初始化串口

  /* Write image version values out to the log. */
  boot_log_image_version();

  /* Write the Boot Config register out to the log. */
  boot_log_boot_config_register();

  /* Write the Core 0 Apps frequency out to the log. */
  boot_log_apps_frequency(0);
}/* boot_log_init */

#常用的两个打印函数
void boot_log_message(char * message)
void boot_log_message_optional_data(char * message,char * optional_data)
```

### log用法
打印log时可以打印到串口和ram，如下：
```bash
# 直接使用如下两个函数即可
void boot_log_message(char * message)
void boot_log_message_optional_data(char * message,char * optional_data)

# 打印变量小技巧
static char error_message[BOOT_ERROR_MSG_LEN];

snprintf(error_message, BOOT_ERROR_MSG_LEN, "Error code %lx at %s Line %lu var = %d", err_code, filename_ptr, line，var);   
boot_log_message(error_message);
```
## 下载模式
高通目前主要支持两种下载模式：紧急下载模式和普通下载模式。

其代码我就不去详细分析了，只来看一下几个关键函数，主要源码路径：
```c
boot_images\core\boot\secboot3\src\boot_dload.c
boot_images\core\boot\secboot3\hw\msm8916\sbl1\sbl1_target.c
boot_images\core\boot\secboot3\hw\msm8916\sbl1\sbl1_mc.c
```

### boot_dload_check
boot_dload_check函数检测是否需要进入QPST下载，然后进入下载模式。
```c
# boot_images\core\boot\secboot3\src\boot_dload.c
void boot_dload_check(   bl_shared_data_type *bl_shared_data )
{

  boolean status = FALSE;
  /* Check whether USB D+ line is grounded. If it is, then enter
     PBL Download mode */
  if(boot_usb_al_check_for_pbl_dload(0))
  {
    boot_dload_transition_pbl_forced_dload(); //进入PBL下载模式
  }

  /* Determine if the downloader should be entered at this time,
     instead of continuing with the normal boot process. */
  if ( boot_dload_entry( ) == TRUE )
  {
    /* Check the UEFI ram dump cookie, we enter download mode
       only if UEFI ram dump cookie is NOT set*/
    if ( !( boot_shared_imem_cookie_ptr != NULL &&
            boot_shared_imem_cookie_ptr->uefi_ram_dump_magic == 
            UEFI_CRASH_DUMP_MAGIC_NUM ) )
    {
      /* Enter downloader for QPST */  
      sbl_dload_entry();  // 进入QPST下载模式，即普通下载模式
    }
  }
  /* Check if PMIC warm reset occured */
  BL_VERIFY((boot_pm_pon_warm_reset_status(0, &status) == PM_ERR_FLAG__SUCCESS), BL_ERR_SBL);

  /* If status is true, set abonormal reset cookie and 
     clear the warm reset status in PMIC */
  if(status)
  { 
    if ( boot_shared_imem_cookie_ptr != NULL )
       boot_shared_imem_cookie_ptr->abnormal_reset_occurred = ABNORMAL_RESET_ENABLED;

    BL_VERIFY((boot_pm_pon_warm_reset_status_clear(0) == PM_ERR_FLAG__SUCCESS), BL_ERR_SBL);
  }
} /* boot_dload_check() */

```

### 紧急下载模式
紧急下载模式进入又分为两种情况：
+ 自动进入：裸片或者sbl1异常，系统自动进入紧急下载模式；
+ 手动进入：
   * 硬件下拉某一GPIO，PBL阶段检测到此GPIO则进入紧急下载模式。
   * 软件设置magic numbers，热重启，PBL检测到magic numbers后进入紧急下载模式。


#### boot_dload_transition_pbl_forced_dload
boot_dload_transition_pbl_forced_dload函数由上boot_dload_check函数调用，其设置magic numbers，然后重启，当PBL检测到设置的magic numbers则会强制进入下载模式。源码如下：
```c
# boot_images\core\boot\secboot3\src\boot_dload.c
void boot_dload_transition_pbl_forced_dload( void )
{
  /* PBL uses the last four bits of BOOT_MISC_DETECT to trigger forced download.
     Preserve the other bits of the register. */

  uint32 register_value = 
    HWIO_TCSR_BOOT_MISC_DETECT_INM(HWIO_TCSR_BOOT_MISC_DETECT_RMSK);

  /* Clear the PBL masked area and then apply HS_USB value */
  register_value &= ~(FORCE_DLOAD_MASK);
  register_value |= FORCE_DLOAD_HS_USB_MAGIC_NUM;

  /* Write the new value back out to the register */
  HWIO_TCSR_BOOT_MISC_DETECT_OUTM(FORCE_DLOAD_MASK,
                                  register_value);

  boot_hw_reset(BOOT_WARM_RESET_TYPE);
} /* boot_dload_transition_pbl_forced_dload() */
```

### 普通下载模式
一般情况下，在通过PBL下载了软件后 ，除非device挂掉，不会再通过PBL进入紧急下载，这时会通过sbl对软件更新。在上boot_dload_check函数中会检查USB D+是否接地，是否了设置下载模式cookie（通过boot_dload_set_cookie()设置），如果皆为否，则进入普通下载模式。

#### boot_dload_set_cookie
当sbl1发生异常时，sbl_error_handler函数（位于sbl1_mc.c）会调用此函数设置cookie，此函数比较简单，源码如下：
```c
# boot_images\core\boot\secboot3\src\boot_dload.c
void boot_dload_set_cookie()
{
  HWIO_TCSR_BOOT_MISC_DETECT_OUTM(SBL_DLOAD_MODE_BIT_MASK,
                                  SBL_DLOAD_MODE_BIT_MASK);
}
```
#### sbl_dload_entry
sbl_dload_entry函数指针默认指向紧急下载入口boot_dload_transition_pbl_forced_dload函数，由PBL通过firehose协议实现下载。如下：
```c
# boot_images\core\boot\secboot3\hw\msm8916\sbl1\sbl1_target.c
void (*sbl_dload_entry)(void) = boot_dload_transition_pbl_forced_dload; 
```
#### sbl1_dload_entry 
不过如果没有定义sbl错误时进入PBL错误处理的宏，sbl_dload_entry函数指针将被重定向到sbl1_dload_entry函数，其在sbl1中直接通过sahara协议下载。如下：
```c
# boot_images\core\boot\secboot3\hw\msm8916\sbl1\sbl1_mc.c
/*DLOAD flag for SBL1 to enter PBL error handler*/
#ifdef BOOT_ENTER_PBL_DLOAD_ON_SBL_ERROR
  static boot_boolean edload_flag = TRUE;
#else
  static boot_boolean edload_flag = FALSE;
#endif

void sbl1_post_ddr_init(bl_shared_data_type *bl_shared_data)
{
...  
  if (edload_flag != TRUE)
  {
    /* Update the dload entry to sbl1 sahara dload entry function */
    sbl_dload_entry = sbl1_dload_entry;
  } 
...
}

# boot_images\core\boot\secboot3\hw\msm8916\sbl1\sbl1_target.c
void sbl1_dload_entry ()
{
  static uint32 dload_entry_count = 0;

  dload_entry_count++; 

  /* Only execute the pre-dload procedures the first time we try to enter
   * dload in case there is an error within these procedures. */
  if( dload_entry_count == 1 && &bl_shared_data != NULL )
  {
    /* Entering dload routine for the first time */
    boot_do_procedures( &bl_shared_data, sbl1_pre_dload_procs );
  }
  
  /* Enter boot Sahara */
  boot_dload_transition_enter_sahara();
  
}/* sbl_dload_entry() */
```

## 升级模式
上面的下载模式对于开发来说不是很方便，接下来分析一下更适合开发、生产的下载模式，也分为两种，如下：
1. 通过组合按键进入：比如power键+音量下键进入PBL紧急下载。
2. 通过命令进入：开机后连接USB， 通过adb reboot edl/dload 进入PBL紧急下载或sbl普通下载。

