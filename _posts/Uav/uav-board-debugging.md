title: "无人机开发主板调试"
date: 2016-04-02 21:01:57
categories:
- Discovery
- Uav
tags: 调试
---


## 问题一 ： 新板子不能开机，关键点：板子2+32（ddr+emmc）换为了2+16 .

自己的uav主板回来后将软件刷入板子(高通msm8074), 板子不能正常启动.

通过分析log， 发现死在boot_images\core\boot\secboot3\hw\msm8974\sbl1\sbl1_mc.c 中 sbl1_tlmm_init() ---> boot_gpio_init()， 当我屏蔽此函数后， log如下：  
```bash 
Format: Log Type - Time(microsec) - Message 
Log type: B - since boot(excluding boot rom). D - delta 
B - 41663 - SBL1, Start 
B - 46909 - scatterload_region && ram_init, Start 
D - 30 - scatterload_region && ram_init, Delta 
B - 63897 - pm_device_init, Start 
D - 27297 - pm_device_init, Delta 
B - 91317 - boot_flash_init, Start 
D - 10919 - boot_flash_init, Delta 
B - 102632 - boot_config_data_table_init, Start 
D - 134932 - boot_config_data_table_init, Delta 
B - 239150 - sbl1_ddr_set_params, Start 
B - 241773 - Pre_DDR_clock_init, Start 
D - 274 - Pre_DDR_clock_init, Delta 
D - 0 - sbl1_ddr_set_params, Delta 
B - 255773 - pm_driver_init, Start 
D - 16134 - pm_driver_init, Delta 
B - 271907 - clock_init, Start 
D - 152 - clock_init, Delta 
B - 274988 - Image Load, Start 
B - 295209 - Tz Execution, Start 
D - 193065 - Tz Execution, Delta 
B - 496387 - Image Load, Start 
B - 506361 - Signal PBL to Jump to RPM FW 
B - 506605 - sbl1_wait_for_ddr_training, Start   
B - 540399 - 1######################################################### 
D - 45323 - sbl1_wait_for_ddr_training, Delta 
#不屏蔽boot_gpio_init()函数,则停在此处， boot_gpio_init()中
B - 558302 - 11#########################################################   
B - 685884 - Image Load, Start 
B - 689391 - WDT Execution, Start 
D - 213 - WDT Execution, Delta 
B - 694790 - Image Load, Start 
B - 707905 - sbl1_efs_handle_cookies, Start 
```
　
<!--more-->
继续跟代码一无所获。怀疑ddr配置，但仔细一想，用的相同的ddr，应该没问题，就没深究， 如若要修改对比ddr配置，参考如下方式：
```bash
ddr参数：
boot_images\core\boot\secboot3\scripts\8974_cdp_jedec_ddr_4_die_interleave_dal.xml   ---> DDR 参数配置文件（对比ddr数据手册），
编译：
python cdt_generator.py 8974_cdp_jedec_ddr_4_die_interleave_dal.xml binfile.bin
将生成boot_cdt_array.c和ddr.bin，boot_cdt_array.c替换boot_images\core\boot\secboot3\hw\msm8974\boot_cdt_array.c,然后重新make boot
```

后怀疑应该是更换emmc后分区导致，给userdata分太多空间，而emmc空间不够。
修改相关文件：
```bash
W:\uav\apq8074-le-1-0_ap_standard_oem\boot_images\core\storage\tools\ptool\ptool.py #  python script to create GPT partition table 
W:\uav\apq8074-le-1-0_ap_standard_oem\common\build\partition.xml  # partition table information 
W:\uav\apq8074-le-1-0_ap_standard_oem\apps_proc\device\qcom\msm8974\BoardConfig.mk #  file system image size for android 

解析partition.xml，生成相关文件：
ptool.py -x partition.xml   # 解析partition.xml， 生成partition.bin, rawprogram.xml等文件


apps_proc/oe-core下执行命令生成相应文件：
./meta-qti/scripts/mkuserimage.sh 

common/build下执行如下打包命令 :
python update_common_info.py 
```
> 如能正常启动：fastboot flash partition gpt_backup0.bin --> You MUST flash the new partition table first so others should be flashed on new layout. 　　



　

于是，将userdata分区空间改小一半，终于看到了一丝胜利的曙光，不过虽然能进入linaro系统，但是仍然有问题，空间不够，串口log如下：
![uav_boot_log_1](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/uav_boot_small.png)

　　



最后，将userdata相应加大，板子成功启动。串口log如下： 
![uav_boot_log_2](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/uav_boot_ok.png)


　
## 附 USB调试信息打开
1. Dynamic UDC debug 
```bash
Echo ‘file dwc3-msm.c +p’ > /d/dynamic_debug/control 
Echo ‘file dwc3_otg.c +p’ > /d/dynamic_debug/control 
Echo ‘file phy-msm-qusb.c +p’ > /d/dynamic_debug/control 
Echo ‘file phy-msm-qmp.c +p’ > /d/dynamic_debug/control 
```

2. Kernel UDC debug configurations 

```bash 
# W:\uav\apq8074-le-1-0_ap_standard_oem\apps_proc\linux\drivers\usb\dwc3\Makefile
CONFIG_USB_DWC3_DEBUG 
CONFIG_USB_DWC3_VERBOSE

# linux/drivers/usb/dwc3/dwc3_otg.c
添加如下：
 #undef dev_dbg 
 #define dev_dbg dev_info  
```
