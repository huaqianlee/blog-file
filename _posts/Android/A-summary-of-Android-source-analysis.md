title: "【置顶】Android 系统源码分析综述：整理总结源码分析的所有博客"
date: 2100-11-21 21:55:43
categories: Android
tags: [源码分析,Qualcomm,MTK]
---
> 一直都想对整个Android系统的源码做一个完整的分析，并形成一些有质量的文章。之前做高通平台时，也零零碎碎的分析过一些Android系统的源码，但是当时基本都是用笔记软件随意做了一些记录，没有系统性的总结，导致很多东西又忘记了。最近开始做MTK平台，就准备开始抽空好好跟读一下源码，边分析边写博客。

# 前言
之前的几篇高通的博客是基于Android 4.4 分析，现在准备通过工作时 MTK 平台 Android 7.0 的源码来进行分析，不过也会将以前基于高通的博客归类于此文。

以前看代码，喜欢按照调用流程一步步的完整跟下来，这样比较费时间，尤其觉得对于驱动部分不是很必要，所以这次就准备主要专注于关键文件和关键函数，以及软件框架。
<!--more-->
# Android架构

# 源码分析
准备从三个方向来分析源码，一是从工作相关的方向，将所有外设，从最底层到最上层；二是针对某些模块的代码进行分析；三是根据系统源码架构和结构一层一层分析原理。

## 外设方向

文章名 | 概述
---|---
[Android传感器（Sensor）架构简析 (╯_╰)](http://huaqianlee.github.io/2017/12/17/Android/android-sensor-arch-analysis/)|MTK 传感器架构简析 (╯_╰)
[Android(Linux) 输入子系统解析](http://huaqianlee.github.io/2017/11/23/Android/Android-Linux-input-system-analysis/)|从 HW 到 Framework 分析输入子系统
[Android/Linux  I2C 驱动架构分析](http://huaqianlee.github.io/2017/12/03/Android/Android-Linux-i2c-driver-arch/)|I2C驱动架构分析
[Android 电源管理之电池管理系统(BMS)](http://huaqianlee.github.io/2017/11/21/Android/BMS-of-Android-Power-Management/)|从 HW 到 APP 分析 BMS 系统  
[Android不带电量计的电量计算](http://huaqianlee.github.io/2015/01/21/Android/%E9%AB%98%E9%80%9AAndroid%E4%B8%8D%E5%B8%A6%E7%94%B5%E9%87%8F%E8%AE%A1%E7%9A%84%E7%94%B5%E9%87%8F%E8%AE%A1%E7%AE%97%E6%96%B9%E5%BC%8F/) | 高通不带库仑计电池电量算法
[Android 电源管理架构](http://huaqianlee.github.io/2015/05/30/Android/Android%E7%94%B5%E6%BA%90%E7%AE%A1%E7%90%86%E6%9E%B6%E6%9E%84/) | 高通PMU架构与电源管理机制简析
[Android电池监控系统-BMS (有坑未填)](http://huaqianlee.github.io/2015/06/06/Android/Android%E7%94%B5%E6%B1%A0%E7%9B%91%E6%8E%A7%E7%B3%BB%E7%BB%9F-BMS-%E4%B9%8B%E7%94%B5%E6%B1%A0%E7%B3%BB%E7%BB%9F%E6%9E%B6%E6%9E%84/) |高通BMS系统源码简析
[高通电池管理系统（BMS）驱动分析](http://huaqianlee.github.io/2015/06/24/Android/qaulcomm-bms-driver-analysis/)|高通 BMS 系统与驱动分析
[高通 smb135x charger 驱动分析](http://huaqianlee.github.io/2015/06/24/Android/smb135x-charger-driver/)|高通 smb135x 驱动简析
[高通 PMIC 架构简析](http://huaqianlee.github.io/2015/06/24/Android/qcom-pmic-driver/)| 高通 PMIC 架构
[高通 linear charger 驱动分析](http://huaqianlee.github.io/2015/06/24/Android/linear-charger-driver/)| 高通 linear charger 驱动简析

## 代码模块方向

### 系统方向
文章名 | 概述
---|---
[高通Android设备启动流程分析](http://huaqianlee.github.io/2015/08/23/Android/%E9%AB%98%E9%80%9AAndroid%E8%AE%BE%E5%A4%87%E5%90%AF%E5%8A%A8%E6%B5%81%E7%A8%8B%E5%88%86%E6%9E%90-%E4%BB%8Epower-on%E4%B8%8A%E7%94%B5%E5%88%B0Home-Lanucher%E5%90%AF%E5%8A%A8/)|从power-on上电到Home Lanucher启动
[怎么用Android日志系统更好地去调试](http://huaqianlee.github.io/2015/07/18/Android/%E6%80%8E%E4%B9%88%E7%94%A8Android%E6%97%A5%E5%BF%97%E7%B3%BB%E7%BB%9F%E6%9B%B4%E5%A5%BD%E5%9C%B0%E5%8E%BB%E8%B0%83%E8%AF%95-How-to-debug-with-Android-logging/)|解析 log 实现代码及实战 demo
[怎么抓取Android测试日志文件](http://huaqianlee.github.io/2015/07/19/Android/%E6%80%8E%E4%B9%88%E6%8A%93%E5%8F%96Android%E6%B5%8B%E8%AF%95%E6%97%A5%E5%BF%97%E6%96%87%E4%BB%B6-How-to-get-android-log-file/)|解析 logcat 命令 和 log的抓取

### BootLoader部分
文章名 | 概述
---|---
[高通平台Android源码bootloader分析之sbl1(一)](http://huaqianlee.github.io/2015/08/15/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%B8%80/)|高通boot架构和sbl源码执行流程
[高通平台Android源码bootloader分析之sbl1(二)](http://huaqianlee.github.io/2015/08/15/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%BA%8C/)|CDT解析
[高通平台Android源码bootloader分析之sbl1(三)](http://huaqianlee.github.io/2015/08/18/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%B8%89/)|log系统和下载升级
[Android源码bootable解析之bootloader LK(little kernel)](http://huaqianlee.github.io/2015/07/25/Android/Android%E6%BA%90%E7%A0%81bootable%E8%A7%A3%E6%9E%90%E4%B9%8BLK-bootloader-little-kernel/)|LK目录和LK源码流程

### Kernel部分
文章名 | 概述
---|---
[Android(Linux) 输入子系统解析](http://huaqianlee.github.io/2017/11/23/Android/Android-Linux-input-system-analysis/)|从 HW 到 Framework 分析输入子系统
[Linux内核设备树(DT - Device Tree)](http://huaqianlee.github.io/2015/08/19/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81%E5%88%86%E6%9E%90%E4%B9%8BLinux%E5%86%85%E6%A0%B8%E8%AE%BE%E5%A4%87%E6%A0%91-DT-Device-Tree-dts%E6%96%87%E4%BB%B6/)|基于高通平台分析设备树
[Android Selinux 权限及问题](http://huaqianlee.github.io/2017/11/14/Android/Android-SELinux-Permison-and-Question/)|SELinux权限介绍及问题解决


### 日志系统
文章名 | 概述
---|---
[Android日志系统详解](http://huaqianlee.github.io/2015/07/18/Android/Android-Logging-system-Android%E6%97%A5%E5%BF%97%E7%B3%BB%E7%BB%9F%E8%AF%A6%E8%A7%A3/)|logging system
[怎么用Android日志系统更好地去调试](http://huaqianlee.github.io/2015/07/18/Android/%E6%80%8E%E4%B9%88%E7%94%A8Android%E6%97%A5%E5%BF%97%E7%B3%BB%E7%BB%9F%E6%9B%B4%E5%A5%BD%E5%9C%B0%E5%8E%BB%E8%B0%83%E8%AF%95-How-to-debug-with-Android-logging/)|代码中的 log
[怎么抓取Android测试日志文件](http://huaqianlee.github.io/2015/07/19/Android/%E6%80%8E%E4%B9%88%E6%8A%93%E5%8F%96Android%E6%B5%8B%E8%AF%95%E6%97%A5%E5%BF%97%E6%96%87%E4%BB%B6-How-to-get-android-log-file/)|logcat 简析



### 编译系统
文章名 | 概述
---|---
[Android编译过程详解之一](http://huaqianlee.github.io/2015/07/11/Android/Android%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%B8%80/)|高通自定义脚本与lunch
[Android编译过程详解之二](http://huaqianlee.github.io/2015/07/12/Android/Android%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%BA%8C/)|Build系统及.mk文件解析
[Android编译过程详解之三](http://huaqianlee.github.io/2015/07/12/Android/Android%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%B8%89/)|客制化解析
[Android.mk解析](http://huaqianlee.github.io/2015/07/12/Android/About-ActivityNotFoundException-Unable-to-find-explicit-activity-class-Android-mk%E8%A7%A3%E6%9E%90/)|一个bug及Android.mk文件详解



## 架构原理方向








