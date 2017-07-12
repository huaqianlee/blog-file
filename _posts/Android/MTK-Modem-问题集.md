title: "MTK Modem 问题集"
date: 2017-07-12 23:01:42
categories: Android
tags: MTK
---
最近开始做MTK相关的工作，在第一步编译Modem时就遇到了挺多问题。特在此文整理和Modem相关的问题。

# 编译相关问题

<!--more-->
## 编译权限问题
编译时提示如下权限问题：
```bash
*******************************************
* [OS]                : Linux
* [PERL]              : v5.10.1 or v5.14.2
* [MAKE]              : GNU Make v3.81
* [SHELL]             : GNU bash v4.1.5
* [GCC-ARM-NONE-EABI] : v4.6.2 or above
* [NATIVE GCC(UBUNTU)]: v4.5 or above

*******************************************
 Start checking current Build Environment  
*******************************************
* [PERL]              : v5.14.2            [OK] !!!
* [MAKE]              : GNU Make v3.81     [OK] !!!
* [SHELL]             : GNU bash v4.2.25    [HIGHER THAN RECOMMENDED] !!!
sh: 1: tools/GCC/4.6.2/linux/bin/arm-none-eabi-gcc: Permission denied
* [GCC-ARM-NONE-EABI] : [UNKNOWN VERSION] !!!
* [NATIVE GCC(UBUNTU)]: gcc (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3  [OK] !!!

current Build Env. is not recommendation 
To avoid unexpected errors , please install the recommended Tool Chain.
*******************************************
  Build Environment is NOT RECOMMENDED!
*******************************************

makefile check is done
/bin/bash: tools/init/strcmpex_linux.exe: Permission denied
make: *** [getoptions] Error 126
```
这种问题很好解决， 通过chmod对其提供执行权限即可。

## 不能定位数据库问题
提示不能定位原始codegen 数据库，错误log如下：
```bash
[ERROR] Cannot determine the original codegen database: BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P1 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P10 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P11 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P12 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P13 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P14 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P15 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P16 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P17 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P18 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P19 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P2 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P20 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P21 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P3 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P4 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P5 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P6 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P7 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P8 BPLGUInfoCustomApp_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_MP_V94_P9
make[1]: *** [build/ZECHIN6737T_65_M0/LWG_DSDS_COTSX/bin/dep/codegen_dep/cgen_cfg_Modem.det] Error 2
make: *** [cgen] Error 2
```
此问题是因为[mt6735m_all_modem\mtk_rel\ZECHIN6737T_65_M0\LTG_DSDS\dhl\database]路径下面太多的数据库文件，只需要将多余的删除掉即可。

## 编译工具链问题
提示某些工具不能找到，log如下：
```bash
tools/GCC/4.6.2/linux/bin/arm-none-eabi-ld: cannot find -lnosys
tools/GCC/4.6.2/linux/bin/arm-none-eabi-ld: cannot find -lm
tools/GCC/4.6.2/linux/bin/arm-none-eabi-ld: cannot find -lc
tools/GCC/4.6.2/linux/bin/arm-none-eabi-ld: cannot find -lgcc
```
此问题是因为代码里面的gcc工具链有问题，需要重新安装正确的工具链，由于十分不好找，所以我上传了百度云：[GCC地址](http://pan.baidu.com/s/1pLblCkN)。





