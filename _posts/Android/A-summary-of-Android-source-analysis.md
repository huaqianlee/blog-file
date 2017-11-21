title: "Android 系统源码分析综述"
date: 2017-11-21 21:55:43
categories: Android
tags: [源码分析,Qualcomm,MTK]
---
> 一直都想对整个Android系统的源码做一个完整的分析，并形成一些有质量的文章。之前做高通平台时，也零零碎碎的分析过一些Android系统的源码，但是当时基本都是用笔记软件随意做了一些记录，没有系统性的总结，导致很多东西又忘记了。最近开始做MTK平台，就准备开始抽空好好跟读一下源码，边分析边写博客。

# 一、 前言
之前的几篇高通的博客是基于Android 4.4 分析，现在准备通过工作时 MTK 平台 Android 7.0 的源码来进行分析，不过也会将以前基于高通的博客归类于此文。

以前看代码，喜欢按照调用流程一步步的完整跟下来，这样比较费时间，尤其觉得对于驱动部分不是很必要，所以这次就准备主要专注于关键文件和关键函数，以及软件框架。
<!--more-->
# 二、Android架构

# 三、源码分析
准备从三个方向来分析源码，一是从工作相关的方向，将所有外设，从最底层到最上层；二是针对某些模块的代码进行分析；三是根据系统源码架构和结构一层一层分析原理。

## 3.1 外设方向

文章名 | 概述
---|---
[Android不带电量计的电量计算](http://huaqianlee.github.io/2015/01/21/Android/%E9%AB%98%E9%80%9AAndroid%E4%B8%8D%E5%B8%A6%E7%94%B5%E9%87%8F%E8%AE%A1%E7%9A%84%E7%94%B5%E9%87%8F%E8%AE%A1%E7%AE%97%E6%96%B9%E5%BC%8F/) | 高通不带库仑计电池电量算法
[Android 电源管理架构](http://huaqianlee.github.io/2015/05/30/Android/Android%E7%94%B5%E6%BA%90%E7%AE%A1%E7%90%86%E6%9E%B6%E6%9E%84/) | 高通PMU架构与电源管理机制简析
[Android电池监控系统-BMS (有坑未填)](http://huaqianlee.github.io/2015/06/06/Android/Android%E7%94%B5%E6%B1%A0%E7%9B%91%E6%8E%A7%E7%B3%BB%E7%BB%9F-BMS-%E4%B9%8B%E7%94%B5%E6%B1%A0%E7%B3%BB%E7%BB%9F%E6%9E%B6%E6%9E%84/) |高通BMS系统源码简析

## 3.2 代码模块方向

### 3.2.0 系统方向
文章名 | 概述
---|---
[高通Android设备启动流程分析](http://huaqianlee.github.io/2015/08/23/Android/%E9%AB%98%E9%80%9AAndroid%E8%AE%BE%E5%A4%87%E5%90%AF%E5%8A%A8%E6%B5%81%E7%A8%8B%E5%88%86%E6%9E%90-%E4%BB%8Epower-on%E4%B8%8A%E7%94%B5%E5%88%B0Home-Lanucher%E5%90%AF%E5%8A%A8/)|从power-on上电到Home Lanucher启动


### 3.2.1 BootLoader部分
文章名 | 概述
---|---
[高通平台Android源码bootloader分析之sbl1(一)](http://huaqianlee.github.io/2015/08/15/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%B8%80/)|高通boot架构和sbl源码执行流程
[高通平台Android源码bootloader分析之sbl1(二)](http://huaqianlee.github.io/2015/08/15/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%BA%8C/)|CDT解析
[高通平台Android源码bootloader分析之sbl1(三)](http://huaqianlee.github.io/2015/08/18/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%B8%89/)|log系统和下载升级
[Android源码bootable解析之bootloader LK(little kernel)](http://huaqianlee.github.io/2015/07/25/Android/Android%E6%BA%90%E7%A0%81bootable%E8%A7%A3%E6%9E%90%E4%B9%8BLK-bootloader-little-kernel/)|LK目录和LK源码流程

### 3.2.2 Kernel部分
文章名 | 概述
---|---
[Linux内核设备树(DT - Device Tree)](http://huaqianlee.github.io/2015/08/19/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81%E5%88%86%E6%9E%90%E4%B9%8BLinux%E5%86%85%E6%A0%B8%E8%AE%BE%E5%A4%87%E6%A0%91-DT-Device-Tree-dts%E6%96%87%E4%BB%B6/)|基于高通平台分析设备树
[Android Selinux 权限及问题](http://huaqianlee.github.io/2017/11/14/Android/Android-SELinux-Permison-and-Question/)|SELinux权限介绍及问题解决


### 3.2.3 日志系统
文章名 | 概述
---|---
[Android日志系统详解](http://huaqianlee.github.io/2015/07/18/Android/Android-Logging-system-Android%E6%97%A5%E5%BF%97%E7%B3%BB%E7%BB%9F%E8%AF%A6%E8%A7%A3/)|logging system



### 编译系统
文章名 | 概述
---|---
[Android编译过程详解之一](http://huaqianlee.github.io/2015/07/11/Android/Android%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%B8%80/)|高通自定义脚本与lunch
[Android编译过程详解之二](http://huaqianlee.github.io/2015/07/12/Android/Android%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%BA%8C/)|Build系统及.mk文件解析
[Android编译过程详解之三](http://huaqianlee.github.io/2015/07/12/Android/Android%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%B8%89/)|客制化解析
[Android.mk解析](http://huaqianlee.github.io/2015/07/12/Android/About-ActivityNotFoundException-Unable-to-find-explicit-activity-class-Android-mk%E8%A7%A3%E6%9E%90/)|一个bug及Android.mk文件详解



## 3.3 架构原理方向








