title: "Android 电源管理架构"
date: 2015-05-30 16:04:45
categories:
- Android Tree
- Misc
tags: [电源管理,Power,源码分析,Qualcomm]
---
　　对于移动设备，电源管理是相当重要的一部分，因为现在在公司主要负责电源管理部分，所以借用Google对其研究了一下，再结合自己的工作经验，准备接下来写一系列相关的文章。因为现在还研究得不够，所以最初的文章会不够深入。不过我会慢慢研究，然后写一些比较详细的解读。

## 高通的引导体系结构
![boot](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/20155304921b788-8a63-472f-be7c-2220a98cf428.jpg)
**SBL- Second BootLoader**
<!--more-->
## 电源管理框图
　　这里先借用网上一张老版本的图片，后面再自己绘制一张详细的框图补上来。
![power](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/20155305061d93f-df42-46c4-ae36-bd18648583b1.jpg)

## 主要文件及路径
```bash
	kernel\kernel\power\*
    arch\arm\match-xxx\pm.c
    driver\power\*
    system\core\charger\charger.c   - 关机充电信息，显示充电log等
    上层文件太分散，待后期文件详解再一一列出
```
## Android结构
　　Android的电源管理主要通过锁和定时器来切换系统的状态(即三种低功耗状态)，使系统功耗降到最低。 电源管理架构分为四大部分： APP，Framework，Hal，Kernel。

### 应用层(APP) 
　　应用层主要指应用程序及其他使用电源管理的service。

### 架构层(Framework)
　　Framework层为APP提供API接口及协调电源的管理工作，主要包含：
```bash
PowerManager.java  // 提供给应用层调用
PowerManagerService.java  // 核心文件
com_android_server_PowerManagerService.cpp、
Power.java  // 提供底层的函数接口,与JNI交互
android_os_Power.cpp  //jni交互文件
```
　　这一层的功能相对比较复杂,比如系统状态的切换，背光的调节及开关，Wake Lock的申请和释放等等，但这一层跟硬件平台无关。

### Hal层
　　Hal层为一个Power.c文件，该文件通过sysfs的方式与kernel进行通信。主要功能有申请wake_lock，释放wake_lock，设置屏幕状态等。所有对电源管理的调用应通过Android的PowerManager API来完成。

### Kernel层
　　Kernel层的电源管理方案实现主要包含三部分：
```bash
Kernel\power\：实现了系统电源管理框架机制
Arch\arm(or mips or powerpc)\mach-XXX\pm.c:实现对特定板的处理器电源管理
drivers\power:是设备电源管理的基础框架，为驱动提供了电源管理接口. 实现了针对所有设备的sysfs操作函数.
```
　　android提供了三种低功耗状态：
```bash
earlysuspend //让某些设备选择进入某种功耗较低的状态，如LCD灭掉
suspend // 除电源模块以外的外围模块和CPU均不工作，只有内存保持自刷新的一个工作状态
hibernation// 所有内存镜像都被写入到磁盘中，然后系统关机，重启后系统将恢复到关机之前的状态
```
　
---
　
### 电源管理机制
　　Android的电源管理主要通过锁和定时器来切换系统的状态(如上述三种低功耗状态),使系统功耗降到最低.
　
#### 实现流程
![framework](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/2015530390bc951-ede6-47dd-83ce-c1a6aced6e82.png)
　

#### 状态切换流程
![state](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/201553020e46e8e-7570-483b-9ea2-375cf4ae59d2.png)
