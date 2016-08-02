title: "高通平台Android源码bootloader分析之sbl1(二)"
date: 2015-08-15 20:44:46
categories: Android
tags: [源码分析,Qualcomm]
---
[高通平台Android源码bootloader分析之sbl1(一)](http://huaqianlee.github.io/2015/08/15/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%B8%80/)
[高通平台Android源码bootloader分析之sbl1(二)](http://huaqianlee.github.io/2015/08/15/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%BA%8C/)
[高通平台Android源码bootloader分析之sbl1(三)](http://huaqianlee.github.io/2015/08/18/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%B8%89/)


在上一篇博文中主要描述了启动流程，及代码执行流程，并重点介绍了一下我重点关注的部分。这个sbl部分也算有点庞大，我们没有精力也没有必要去分析全部，所以接下来就来分析一下sbl1中另外几个需要格外关注的部分：
* CDT ：主要提供平台设备数据
* log system：log日志系统，当然没有kernel里面那么强大了
* download：代码下载烧写实现
* ramdump：异常信息dump
　
本篇博文就先来分析一下CDT， 其他部分后面再分析。
<!--more-->
##CDT
CDT主要提供Platform ID、ddr硬件配置等平台设备数据。很多module利用这些信息去减少依赖及执行动态初始化。CDT通常被厂家写入EEPROM中，如没有eeprom则会在编译bootloader时链入。
　
sbl中主要涉及到如下关键文件：
```bash
boot_images\core\boot\secboot3\hw\msm8916\boot_cdt_array.c // config_data_table配置表定义
boot_images\core\systemdrivers\platforminfo\src\PlatformInfo.c
boot_images\core\boot\secboot3\scripts\cdt_generator.py
boot_images\core\boot\secboot3\scripts\jedec_lpddr3_single_channel.xml
```
###boot程序加载CDT
对于CDT，boot程序主要有如下动作：
1. sbl1校验eMMC的boot分区中的CDT分区，如果ok，则加载CDT镜像，如果不ok，则执行第2步；
2. sbl1从sbl1.mbn中加载默认cdt分区表（config_data_table[]）；
3. sbl1通过SMEM将平台信息传递到lk；sbl1 - SMEM_HW_SW_BUILD_ID，lk - SMEM_BOARD_INFO_LOCATION.
4. lk获取平台信息，加载dt头，然后搜寻相应的dt入口；
5. lk通过正确的dt入口地址跳转到kernel。

####关键函数：
```bash
#sbl1
boot_updat_config_data_table（boot_images\core\boot\secboot3\src\boot_config_emmc.c）
#lk
dev_tree_get_entry_info(bootable\bootloader\lk\platform\msm_shared\dev_tree.c)
```
####关键枚举：
```bash
#boot_images\core\api\systemdrivers\DDIChipInfo.h
DALCHIPINFO_ID_APQ8026     = 199,
DALCHIPINFO_ID_MSM8926     = 200,
DALCHIPINFO_ID_MSM8326     = 205,
DALCHIPINFO_ID_MSM8916     = 206,
DALCHIPINFO_ID_MSM8994     = 207,
#boot_images\core\api\systemdrivers\PlatformInfoDefs.h
DALPLATFORMINFO_TYPE_SURF         = 0x01,  /**< Target is a SURF device. */
DALPLATFORMINFO_TYPE_CDP          = DALPLATFORMINFO_TYPE_SURF,  /**< Target is a CDP (aka SURF) device. */
DALPLATFORMINFO_TYPE_MTP_MSM      = 0x08,  /**< Target is a MSM MTP device. */
DALPLATFORMINFO_TYPE_QRD          = 0x0B,  /**< Target is a QRD device. */
```
####DT头
```dts
#kernel\arch\arm\boot\dts\qcom\msm8916-cdp.dts
/ {
  model = "Qualcomm Technologies, Inc. MSM 8916 CDP";
  compatible = "qcom,msm8916-cdp", "qcom,msm8916", "qcom,cdp";
  qcom,board-id = <1 0>;// id为0x01则为cdp设备，与下cdt描述xml中对应
};
#kernel\arch\arm\boot\dts\qcom\msm8916-mtp.dts
/ {
  model = "Qualcomm Technologies, Inc. MSM 8916 MTP";
  compatible = "qcom,msm8916-mtp", "qcom,msm8916", "qcom, mtp";
  qcom,board-id = <8 0>; // id为0x08则为mtp设备
};
#kernel\arch\arm\boot\dts\qcom\msm8916-qrd.dts
/ {
  model = "Qualcomm Technologies, Inc. MSM 8916 QRD";
  compatible = "qcom,msm8916-qrd", "qcom,msm8916", "qcom, qrd";
  qcom,board-id = <11 0>; // id为0x0b则为qrd设备
};
```
>dt.img的格式，参考dtbtool.txt和bootable\bootloader\lk\platform\msm_shared\smem.h

####CDT描述的xml文件
```xml
#boot_images\core\boot\secboot3\scripts\jedec_lpddr3_single_channel.xml
      <device id="cdb0">
        <props name="platform_id" type="DALPROP_ATTR_TYPE_BYTE_SEQ">
 
          /*byte0 - platform id版本
             byte1 - platform id，因此此为mtp设备
             byte2 - platform id硬件版本*/         
          0x03, 0x08, 0x01, 0x00, 0x00, 0x00, end 
        
        </props>
      </device>
...
```
上述xml中设备对应的结构体包如下：
```c
typedef PACKED struct
{
  uint8                 nVersion;
  uint8                 nPlatform;　　　　　 //平台id，用于高通不同平台，不能修改。
  uint8                 nHWVersionMajor;     //硬件版本号
  uint8                 nHWVersionMinor;
  uint8                 nSubtype;　　　　//　默认为０，可以用来区分项目
  uint8                 nNumKVPS;
  PlatformInfoKVPSCDTType  aKVPS[];
} PlatformInfoCDTType;
```
###platform info
在上一篇博文分析的sbl执行流程中，有两个和platform info有关的两个关键函数，如下：

####boot_config_data_table_init
此函数主要初始化配置数据表，如果eeprom/emmc中存在cdt，则更新编译时链入的cdt表。
```c
#boot_images\core\boot\secboot3\src\boot_config_data.c
void boot_config_data_table_init(bl_shared_data_type* bl_shared_data)
{
  char bootlog_buffer[BOOT_LOG_TEMP_BUFFER_SIZE];
  uint32 bytes_read = 0;


  /* Reset the flash byte counter so the number of bytes read from flash
     can be retreived later. */
  boot_statistics_reset_flash_byte_counter();

  boot_log_message("boot_config_data_table_init, Start");
  boot_log_start_timer();
  
  /*populate configuration data table's info*/
  config_data_table_info.size = config_data_table_size;
  config_data_table_info.cdt_ptr = config_data_table; // 定义在boot_cdt_array.c 

  boot_update_config_data_table(&config_data_table_info);
  
  /*put a pointer to the table info into sbl shared data so next sbl can access it*/
  bl_shared_data->sbl_shared_data->config_data_table_info = &config_data_table_info;

  
  /* Retreive the number of bytes read from flash via boot statistics. */
  bytes_read = boot_statistics_get_flash_byte_counter();
  

  /* Convert CDT size to string for boot logger. */
  snprintf(bootlog_buffer,
           BOOT_LOG_TEMP_BUFFER_SIZE,
           "(%d Bytes)",
           bytes_read);


  boot_log_stop_timer_optional_data("boot_config_data_table_init, Delta",
                                    bootlog_buffer);
}
```
####config_data_table
config_data_table定义了与上xml文件对应的配置表，存储在memory，用于初始化cdt，如此表存在则此表数据为最终数据。源码如下：
```c
# boot_images\core\boot\secboot3\hw\msm8916\boot_cdt_array.c
uint8 config_data_table[CONFIG_DATA_TABLE_MAX_SIZE] = 
{
  /* Header */

  0x43, 0x44, 0x54, 0x00, 
  0x01, 0x00, 0x00, 0x00, 
  0x00, 0x00, 0x00, 0x00, 
  0x00, 0x00, 

  /* Meta data */

  0x16, 0x00, 0x06, 0x00, 
  0x1C, 0x00, 0x88, 0x01, 

  /* Block data */
#ifdef BOOT_PRE_SILICON
  #ifdef FEATURE_RUMI_BOOT
  0x03, 0x0F, 0x01, 0x00, 0x00, 0x00,
  #else
  0x03, 0x10, 0x01, 0x00, 0x00, 0x00,
  #endif
#else
  0x03, 0x0B, 0x01, 0x00, 0x00, 0x00,// platform id 等信息
#endif
....

uint32 config_data_table_size = 420; // cdt表size
```

####sbl1_hw_platform_smem
此函数主要解析cdt表获得sw-platform id，调用platform id api并传送指针到获得的id，然后调用hw_init_smem存储platform id到SMEM。
```c
#boot_images\core\boot\secboot3\hw\msm8909\sbl1\sbl1_mc.c
void sbl1_hw_platform_smem(bl_shared_data_type* bl_shared_data)
{
    ....... 
  struct cdt_info *cdt_info_ptr = (struct cdt_info *)
                          bl_shared_data->sbl_shared_data->config_data_table_info;
  /*get a pointer to platform id data from configuration data table*/
  platform_id_cdb_ptr = 
              boot_get_config_data_block(cdt_info_ptr->cdt_ptr,
                                         CONFIG_DATA_BLOCK_INDEX_V1_PLATFORM_ID,
                                         &platform_id_len);  
  if(platform_id_cdb_ptr != NULL)
  {
    eResult = boot_DAL_DeviceAttachEx(NULL,
                                      DALDEVICEID_PLATFORMINFO,
                                      DALPLATFORMINFO_INTERFACE_VERSION,
                                      &phPlatform);
    if (eResult == DAL_SUCCESS) 
    {
      /*call the following API to store the platform id to DAL and SMEM*/
      boot_DalPlatformInfo_CDTConfigPostDDR(phPlatform, platform_id_cdb_ptr);      
      boot_DAL_DeviceDetach(phPlatform);
    }
  }  
}
```
###platform info匹配
platform info中的platform id十分重要，lk、kernel中dts都是根据platform id及subtype id等platform info来匹配的。lk和kernel中涉及到的主要函数和代码路径如下：
```bash
#lk
/*ootable\bootloader\lk\platform\msm_shared\smem.h */
enum platform_subtype 

/*bootable\bootloader\lk\platform\msm_shared\board.c */
static void platform_detect()
uint32_t board_hardware_subtype(void)
uint32_t board_hardware_id()

/*bootable\bootloader\lk\platform\msm_shared\dev_tree.c*/
int dev_tree_get_entry_info(struct dt_table *table, struct dt_entry *dt_entry_info)

#kernel
kernel\arch\arm\kernel\setup.c
kernel\arch\arm\boot\dts\qcom
```
当我们在项目开发时就可以同cdt这些信息来配置不同项目，如下：
```bash
-------------------------------------------------------------
  sbl1        platform subtype_id           boot_cdt_array.c
-------------------------------------------------------------
  lk              匹配dts                    dev_tree.c
-------------------------------------------------------------
  kernel     通过传入dts地址创建设备          setup.c
-------------------------------------------------------------
```
###DDR配置
ddr相关的东西我很少动， 也就不深入分析了，列出几个关键函数，如果需要深入了解的话再分析。ddr初始化主要涉及3个函数，见如下load_qsee_pre_procs函数指针数组：
```c
 boot_procedure_func_type load_qsee_pre_procs[] = 
{
  /* Save reset register logs */
  boot_save_reset_register_log,
  
  /* Initialize the flash device */
  boot_flash_init,
  
  /* Copy the configure data table from eeprom */
  boot_config_data_table_init, // 函数一 ： 加载配置表
  
  /* Store platform id */
  sbl1_hw_platform_pre_ddr,
  
  /* Configure ddr parameters based on eeprom CDT table data. */
  sbl1_ddr_set_params, // 函数二：配置ddr
  
  /* Initialize DDR */
  (boot_procedure_func_type)sbl1_ddr_init, // 函数三：初始化ddr

  /*----------------------------------------------------------------------
   Run deviceprogrammer if compiling the deviceprogrammer_ddr image.
  ----------------------------------------------------------------------*/
  boot_deviceprogrammer_ddr_main,
  
  /* Initialize SBL1 DDR ZI region, relocate boot log to DDR */   
  sbl1_post_ddr_init,
  
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
};
```
