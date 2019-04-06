title: "Android电池监控系统(BMS)之一电池系统架构"
date: 2015-06-06 22:17:36
categories: Android
tags: [电源管理,源码分析]
---
*Platform Information :
　System:    Ａndroid4.4.4 
　Platform:  Qualcomm msm8916
　Author:     Andy Lee
　Email:        huaqianlee@gmail.com*

**如有错误欢迎指出，共同学习，共同进步**
　
　　电池对移动设备的重要性不言而喻，所以电池监控系统也是Android的重中之重。今天就结合工作中的内容来分析一下电池监控系统。
##电池系统架构
　　Android中的电池使用方式包括AC（即电源适配器）、Wireless（无线充电）、USB、Battery 等不同的模式。在APP层，通常包括电池状态显示等功能。在framework层 ，主要包括从底层获取电池信息、电池管理、LED控制、绘制更新充电图标等功能。因此，bms主要负责电池状态信息读取和更新相应状态。其架构如下：　
　
　　![电池系统架构](image/201566Android-bms-arch.png)

自上而下，Android电池监控系统分为如下几个部分：

###电池信息查看APP
　　此部分主要是指查看电池信息的APP，比如电池医生、手机内置的电池信息查看APP等。这里就用工作的为例，在拨号状态下输入\*#360\*#，则会打开电池信息查看APP。如下所示：
<!--more-->　
　　　![电池信息](image/201566battery-info.png)

　　代码主要路径：
- packages\apps\Settings\src\com\android\settings\BatteryOemInfo.java  //APP
- packages\apps\Dialer\src\com\android\dialer\SpecialCharSequenceMgr.java   // 命令 配置

　　在手机 /sys/class/power_supply/bms/、/sys/class/power_supply/battery/文件夹中保存了电池的所有相关信息节点，这些节点是由Linux内核创建，待会儿驱动部分将讲到此内容。此APP比较简单，主要就是读取这些文件节点、接收电池信息广播（后面将讲到此广播由BatteryService.java中发出Intent.ACTION_BATTERY_CHANGED），电池信息包括充电设备等信息，然后将这些内容更新到UI界面加以显示，SpecialCharSequenceMgr.Java中主要实现通过判断拨号命令掉用此APP。

###Java框架及本地框架
　　此部分的核心文件是BatteryService.java，作为电池、充电相关的服务，其监听Uevent、读取sysfs 中的状态 、广播Intent.ACTION_BATTERY_CHANGED。此部分代码路径如下：

**frameworks\base\services\java\com\android\server**
- frameworks\base\services\java\com\android\server\BatteryService.java   // 电池管理，开机充电led控制
- frameworks\base\services\java\com\android\server\am\BatteryStatsService.java // 影响电池的所有信息及操作，如：关机，屏幕亮度、wakelock、GPS等。

**frameworks\base\core\java\android\os**
- frameworks\base\core\java\android\os\BatteryManager.java // 电池信息广播Intent（ACTION_BATTERY_CHANGED）用到的字符串和常量
- frameworks\base\core\java\android\os\BatteryStats.java  // 存取电池使用情况统计，包括wakelocks, processes, packages, and services等
- frameworks\base\core\java\android\os\BatteryProperties.java  // 打包电池信息读写代码，与下BatteryProperties.cpp同步
 
- frameworks\base\core\java\com\android\internal\os\BatteryStatsImpl.java // 影响电池的所有信息及操作，时间以ms为单位
- frameworks\base\core\java\com\android\internal\app\IBatteryStats.aidl    // .aidl为接口定义文件， 定义电池状态信息及相关操作方法。

**frameworks\base\packages\SystemUI\src\com\android\systemui**
- frameworks\base\packages\SystemUI\src\com\android\systemui\BatteryMeterView.java // 创建系统广播接收器，接收电池信息广播，绘制电池状态图标
- frameworks\base\packages\SystemUI\src\com\android\systemui\statusbar\policy\BatteryController.java // 定义一个广播接收器并在构造器里注册接收电池信息广播，收到自己广播后回调修改pluged、level
- frameworks\base\packages\SystemUI\src\com\android\systemui\statusbar\policy\BatteryLevel.java // 定义电量百分比显示TextView类
- frameworks\base\packages\SystemUI\src\com\android\systemui\power\PowerUI.java // 创建系统广播接收器，接收电池信息广播，弹出低电警告等

**frameworks\native\services**
- frameworks\native\services\sensorservice\BatteryService.cpp // 定义BatteryService.h中创建的BatteryService类的成员函数
- frameworks\native\services\batteryservice\BatteryProperties.cpp // 打包电池信息读写代码,与上BatteryProperties.java同步
- frameworks\native\services\batteryservice\IBatteryPropertiesListener.cpp // 监听电池信息  ，和下文件一起为BatteryService.java中的update(BatteryProperties)服务
- frameworks\native\services\batteryservice\IBatteryPropertiesRegistrar.cpp  // 注册电池监听

**system\core\healthd**
- system\core\healthd\BatteryMonitor.cpp // 从/sys/class/power_supply中获取电池信息，并update BatteryProperties
- system\core\healthd\BatteryPropertiesRegistrar.cpp // 好像系统没有用到，暂时还不知道此文件的用处
- system\core\healthd\healthd.cpp // 监听底层上报事件，调用BatteryMonitor.cpp中的update

// BatteryService.java
processValuesLocked   connect /dis/ led   广播
sendIntentLocked() 电池状态改变，广播

mBatteryPropertiesRegistrar = IBatteryPropertiesRegistrar.Stub.asInterface(b); 注册
    BatteryService.this.update(props)
      update()
        processValuesLocked(); 

 mBatteryPropertiesRegistrar.registerListener(mBatteryPropertiesListener);
frameworks\native\services\batteryservice\IBatteryPropertiesRegistrar.cpp
frameworks\native\services\batteryservice\IBatteryPropertiesListener.cpp

　
未完待续....

