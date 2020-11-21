title: How to develop and debug kernel?
date: 2020-11-16 21:57:31
categories: Android
tags:
---

> 此篇文章是基于高通 ODM BSP 开发做的一个简单总结，起初是用来对新人进行培训的。

我觉得学习内核驱动时，最开始只需要 ‘Know what, not know how ’。 不用去探究细节，只需要知道整体的框架，知道有哪些需要我们重视的内容即可。


# 何为 Linux 内核开发？

## 首先，初步认识下 Linux kernel

![linux_intro](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/linux/linux_intro.png)

- Linux 内核的框架如上图。
- 设备子系统负责和硬件打交道。
- 大部分工作集中在设备子系统部分。

<!--more-->

## 内核开发是什么？  

- 广义上讲，新增或修改上图中内核部分的所有子系统。
- 非 Linux 源码贡献者，一般来说只修改设备子系统部分。

接下来，简单聊聊初学者需要重点关注的三个部分：设备树，字符设备，平台设备驱动。

## 设备树（DTS）  

设备树相当于一份软件中描述硬件结构的配置框图。假设下图为硬件框图：  
![dts_hw](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/linux/dts_hw.png) 

那么其软件描述的代码片段如下：

```c
/ { // root node
    model = "Qualcomm Technologies, Inc. SDM xxx";
    compatible = "qcom,sdmxxx";
    cpus {
        ... 
        cpu@0 {
            ... 
        };
        cpu@1 {
            ... 
        };
    };
    usb@<address> {
        ... 
    };
    serial@<address> {
        ... 
    };
    gpio@<address> {
        ... 
    };
    intc: interrupt-controller@<address> {
        ... 
    };
    external-bus {
        ...
        i2c@0,0 {
            ... 
            xxx@<address> { // I2C Dev
            .... 
            };
        };
        flash@1,0 {
            ... 
        };
    };
};
```

## 字符设备驱动

- 字符设备驱动是理解设备驱动的基础。
- 大多数设备都可以归于字符设备。  

![char_dev](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/linux/char_dev.png)


## 平台设备驱动模型

- 设备（或驱动）注册时，会通过总线去匹配对应的驱动（或设备）。
- 设备和驱动通常需要挂在一种实际总线上，除带有 I2C、SPI、USB 等的设备外，内核为没有实际总线的外设实现了虚拟的平台总线 。
- 平台设备驱动是独立于字符设备、网络设备等的一种抽象概念 。

![platform_dev](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/linux/platform_dev.png)  


# kernel 开发需要什么样的知识储备？

## C 语言
良好的 C 语言能力， Linux 官方推荐了如下书籍。  

- [The C Programming Language](https://book.douban.com/subject/25735837/)
- [Practical C Programming](https://book.douban.com/subject/4743677/)
- [C: A Reference Manual](https://book.douban.com/subject/1767969/)

## GNU
内核由 GNU C 和 GNU toolchain 实现，所以如下两方面的知识是需要的。

- GNU C 的编码规则
- GNU 工具链的使用

## Linux 基本命令  

- [鸟哥的 Linux 私房菜](https://book.douban.com/subject/4889838/)

## 设备驱动相关知识

- [Linux 设备驱动程序](https://book.douban.com/subject/1723151/)


## 内核原理

- [Linux 内核完全注释](https://book.douban.com/subject/3229243/)
- [深入理解 Linux 内核](https://book.douban.com/subject/1767120/)

# 在我们的工作中，kernel 开发一般怎么做？

## Android 设备通常的开发周期

在我们的工作中，kernel 开发主要集中在 Bringup、Integrate、Verify 三个阶段 。  

![product_phase](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/linux/product_phase.png)


## 源码获取
- 高通的代码分两部分：一部分是开源的，可以从 codeaurora.org 下载，还有一部分是高通产权的，需要从高通的网站上下载。
- 高通产权的代码存放路径：vendor/qcom/proprietary 。
- 实际工作中，SCM 一般会帮忙准备好 Base 代码。
> 可以通过 `repo init -u https://android.googlesource.com/platform/manifest -b android-4.0.1_r1` 在 [Source.android](https://source.android.com/setup/build/downloading) 下载 Google 官方源码。


## Bringup
- 根据需求实现各种外设模块的基本功能。
- LCD、TP 、Sensor 、Charger 等功能正常，手机能进入 Launcher 界面，能正常使用，USB 连接正常。
这样 Bringup 工作就基本完成了。

## Porting 和编写各种外设的驱动（需求的具体实现）
- Porting 硬件相关配置，即实现 DTS 。
- Porting 相关驱动 。
- Sensor 和其他外设有一点差异 。
- 其分为 AP 侧驱动（厂商提供）和 ADSP 侧驱动（高通和厂商协同）两种方式 。
- 主要配置总线、 GPIO 及 Sensor 的属性 。


## 系统维护（解 BUG）
- 对比机
- 阅读源码
- 善用调试工具
- [Createpoint](https://createpoint.qti.qualcomm.com/) + [QCOM Case](https://qualcomm-cdmatech-support.my.salesforce.com/) （*高通文档工具下载，及向高通在线寻求帮助。*）
- 搜索引擎
- GTD （主动性）
- 文档（Read + Write）

# kernel 调试的常用方式有哪些？

## 硬件调试
- 示波器
- 程控电源
- 万用表
- Power monitor 

## Logs
- 串口日志
- Logging System
- logcat/kmsg... 
- Enhanced log
- pstore
- ramdump

## Tools
- adb dumpsys
- gdb
- QPST
- Get ramdump/adsp log/... - systrace
- trace CPU/GPU/Function/Activity/... - powerTop
- power consumption
- kmemleak
- vmstat + top/ps + pmap in android
- out/soong/host/linux-x86/bin/ - simg2img/lpdump... 
- objdump

## 文件系统或节点
- sys
- power/irq/gpio ... 
- proc
- 内核信息
- 打印级别
- dynamic debug
- echo “file xxx.c +p” > /sys/kernel/dynamic_debug/control

