title: "Android 电源管理之电池管理系统(BMS)"
date: 2017-11-21 21:56:28
categories: Android
tags: [源码分析,MTK]
---
>Android 源码分析系列综述博文： [Android 系统源码分析综述](http://huaqianlee.github.io/2100/11/21/Android/A-summary-of-Android-source-analysis/)

*Platform information： MTK6797（X20）+ Android 7.0*

之前做高通的时候，对高通此部分做过粗略的分析，不过当时胡乱做的些笔记，只简单整理了几篇博客，感兴趣可以参考如下路径：

[高通平台Android源码bootloader分析之sbl1(一)](http://huaqianlee.github.io/2015/08/15/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%B8%80/)

[高通平台Android源码bootloader分析之sbl1(二)](http://huaqianlee.github.io/2015/08/15/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%BA%8C/)

[高通平台Android源码bootloader分析之sbl1(三)](http://huaqianlee.github.io/2015/08/18/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%B8%89/)

[Android不带电量计的电量计算](http://huaqianlee.github.io/2015/01/21/Android/%E9%AB%98%E9%80%9AAndroid%E4%B8%8D%E5%B8%A6%E7%94%B5%E9%87%8F%E8%AE%A1%E7%9A%84%E7%94%B5%E9%87%8F%E8%AE%A1%E7%AE%97%E6%96%B9%E5%BC%8F/)

[Android 电源管理架构](http://huaqianlee.github.io/2015/05/30/Android/Android%E7%94%B5%E6%BA%90%E7%AE%A1%E7%90%86%E6%9E%B6%E6%9E%84/)

[Android电池监控系统-BMS-之电池系统架构 (有坑未填)](http://huaqianlee.github.io/2015/06/06/Android/Android%E7%94%B5%E6%B1%A0%E7%9B%91%E6%8E%A7%E7%B3%BB%E7%BB%9F-BMS-%E4%B9%8B%E7%94%B5%E6%B1%A0%E7%B3%BB%E7%BB%9F%E6%9E%B6%E6%9E%84/)

[高通电池管理系统（BMS）驱动分析](http://huaqianlee.github.io/2015/06/24/Android/qaulcomm-bms-driver-analysis/)

[高通 smb135x charger 驱动分析](http://huaqianlee.github.io/2015/06/24/Android/smb135x-charger-driver/)

[高通 PMIC 架构简析](http://huaqianlee.github.io/2015/06/24/Android/qcom-pmic-driver/)

[高通 linear charger 驱动分析](http://huaqianlee.github.io/2015/06/24/Android/linear-charger-driver/)

# 充电简析
## 充电状态机
电池充电过程分为预充、恒流充电（CC模式）、恒压充电（CV模式）、涓流充电四个流程，MTK的状态机如下：

![state](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/mtk/chargind_state.jpg)
<!--more-->
## 充电简要流程框图

![flow](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/mtkGauge_arch.jpg)

# BMS 架构
MTK 的 BMS 架构如下：
![bms](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/mtk/battery%20introduction.jpg)

我准备将BMS从硬件到APP分为不同的架构层来分析。接下来分别分析下不同的架构层。

## 硬件层
硬件层主要分为三个部分：PMIC，Fuel Gauge 和 ADC。本文主要分析软件，所以硬件就不准备深入研究了。
### 1.1.1 PMIC
智能手机方案一般都会有一个PMIC芯片，有些也还会采用外接充电IC，使不使用外接IC，软件驱动会有一些区别。

### Fuel Gauge
Fuel Gauge 是 MTK 为充放电、电量算法提供服务的一个硬件电路，电路中的电阻比较重要。

### ADC
FGADC 和 AUXADC 分别采样电池的电流、电压（还会采样电池温度）。


## BootLoader层
BootLoader部分没有在上图表现出来，也可以将其归为driver部分。
### 1.2.1 Preloader层
此部分会对充电做一些初始设置，比如设置手机尽早开始充电以避免电池低电压不能进入接下来的充电状态，关键路径如下：
```c
alps\vendor\mediatek\proprietary\bootable\bootloader\preloader\platform\mt6797\src\drivers\platform.c
```

### LK层
此部分主要针对充电主要做三件事：1. 启动方式、充电状态监测；2. 初始化充电IC；3. 充电器状态监测处理。

#### 启动方式、充电状态监测
```c
# alps\vendor\mediatek\proprietary\bootable\bootloader\lk\platform\mt6797\include\platform\boot_mode.h
# alps\vendor\mediatek\proprietary\bootable\bootloader\lk\platform\mt6797\boot_mode.c
boot_mode_select() // 启动方式判断及处理

# alps\vendor\mediatek\proprietary\bootable\bootloader\lk\platform\mt6797\platform.c
platform_init() {
    upmu_is_chr_det() // 充电检测，Unplugged则关机
    if (kernel_charging_boot() == 1) { // 充电启动，显示关机充电信息
        /*判断充电设备和状态，显示充电图标和点亮充电指示灯*/
        mt_disp_power(TRUE);
		mt_disp_show_low_battery();
		mt65xx_leds_brightness_set(6, 110);
    }// 否则，闹钟启动灯其他方式启动，显示开机界面
    
}
boot_mode_select(); // 区分开机过程

# alps\vendor\mediatek\proprietary\bootable\bootloader\lk\platform\mt6797\mt_kernel_power_off_charging.c
set_off_mode_charge_status()
kernel_power_off_charging_detection(void) { // 充电状态监测
    get_off_mode_charge_status()
	if (upmu_is_chr_det() == KAL_TRUE) {
		if (off_mode_status) {
			g_boot_mode = KERNEL_POWER_OFF_CHARGING_BOOT;
		} else {
			g_boot_mode = NORMAL_BOOT;
		}
		return TRUE;
	} else {
		mt6575_power_off();
	}
}

```

#### 初始化充电IC
充电IC的初始化工作，有些可以被kernel驱动覆盖，有些不能，所以有时候一些修改记得在LK和kernel里面都得完成。
```c
# alps\vendor\mediatek\proprietary\bootable\bootloader\lk\platform\mt6797\mt_battery.c
pchr_turn_on_charging() { //打开充电
	bq25890_hw_init();
	bq25890_charging_enable(bEnable);
	bq25890_dump_register();
}

# alps\vendor\mediatek\proprietary\bootable\bootloader\lk\platform\mt6797\rules.mk
    ifeq ($(MTK_BQ25896_SUPPORT),yes)
      OBJS +=$(LOCAL_DIR)/bq25890.o
      DEFINES += MTK_BQ25896_SUPPORT
      DEFINES += SWCHR_POWER_PATH

# alps\vendor\mediatek\proprietary\bootable\bootloader\lk\platform\mt6797\include\platform\bq25890.h
# alps\vendor\mediatek\proprietary\bootable\bootloader\lk\platform\mt6797\bq25890.c
void bq25890_hw_init(void)
# 充电IC初始化及电流电压等相关设置
```
#### 1.2.2.3 充电器状态监测处理
```c
# alps\vendor\mediatek\proprietary\bootable\bootloader\lk\app\mt_boot\mt_boot.c
boot_linux_fdt() {
    if (kernel_charging_boot() == -1) 
    	mt6575_power_off(); // if Unplugged, 关机

	if (kernel_charging_boot() == 1) {
		if (pmic_detect_powerkey()) {
			mtk_arch_reset(1); // 跳转kernel前如果按键，重启
		}
	}
}
```
#### 充电图标
MTK之前很多方案是在lk里面绘制关机充电图标，然后采样IPO协议实现关机充电。不过现在已采取高通类似方案在Health部分绘制关机充电图标了。
```c
# alps\vendor\mediatek\proprietary\bootable\bootloader\lk\platform\mt6755\mt_logo.c
```
IPO方式流程图如下：
![IPO](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/mtk/power%20off%20charging.jpg)
> 由于初次接触MTK，又没有深入研究此部分，此部分如有错误，敬请谅解和指出。


## Kernel层
Kernel 部分软件流程框图，不过此图是我从MTK文档上截取没有做修改，所以图片中外部充电IC代码为Fan5405，对应于我的代码应该为bq24290（bq24296）。如下：
![arch](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/mtk/kernel_cod_arch.jpg)
### 1.3.1 ADC部分
电流电压采样部分代码没有深入查看，主要看了如下一个文件：
```c
# alps\kernel-3.18\drivers\misc\mediatek\power\mt6797\pmic_auxadc.c
pmic_auxadc_init()
PMIC_IMM_GetCurrent // 算出电流
```

### HAL部分
此 HAL 并不是真正的 HAL 层，实际是驱动部分，实现部分结构体，针对 MTK 不同充电方案提供支持，读取各项参数。我所阅读的代码使用了外接充电 IC BQ24296（switch charger），驱动不会走 linear_charging.c，走 switch_charging.c + bq25896 驱动部分。
```c
# alps\kernel-3.18\drivers\misc\mediatek\power\mt6797\charging_hw_pmic.c
charging_value_to_parameter()
charging_parameter_to_value()
charging_hw_init() // PMIC初始化
charging_get/set_current()
charging_sw_init()
chr_control_interface()

# alps\kernel-3.18\drivers\misc\mediatek\include\mt-plat\battery_meter_hal.h
BATTERY_METER_CTRL_CMD

# alps\kernel-3.18\drivers\misc\mediatek\power\mt6797\battery_meter_hal.c
get_hw_ocv
read_adc_v_bat_sense()  // 读取电池电压，根据宏判断 batsense 还是 isense

# alps\kernel-3.18\drivers\misc\mediatek\power\mt6797\bq25890.h
// 硬件定义及接口

# alps\kernel-3.18\drivers\misc\mediatek\power\mt6797\bq25890.c
bq25890_driver_probe() // 注册驱动
bq25890_get_xx() // get 接口
bq25890_set_xx() // set 接口
bq25890_hw_init() 

# alps\kernel-3.18\drivers\misc\mediatek\power\mt6797\charging_hw_bq25890.c
is_chr_det() // 充电器检测
    val = pmic_get_register_value(MT6351_PMIC_RGS_CHRDET);
charging_hw_init() // 充电IC初始化     
charging_sw_init() // 充电IC初始化
charging_get_xx() // 封装后的 get 接口
charging_get_charger_type() // 获取充电器类型
charging_set_xx() // 封装后的 set 接口
charging_set_current() // 设置充电电流
```

### Common部分
PMIC充电控制、充电控制主线程、SW FG算法等内容在此部分实现。battery_common*.c 是一个关键文件，其是充电控制的主线程，battery 设备也由此文件注册。
```c
# alps\kernel-3.18\drivers\misc\mediatek\include\mt-plat\charging.h
CHARGING_CTRL_CMD
CHARGER_TYPE
BATTERY_VOLTAGE_ENUM
CHR_CURRENT_ENUM
// 如上等电池相关宏定义

# alps\kernel-3.18\drivers\misc\mediatek\include\mt-plat\battery_common.h
// 充电等相关参数定义

# alps/kernel-3.18/drivers/power/mediatek/battery_common_fg_20.c 
// 充电控制主线程
power_supply_property xx // 定义电池相关文件节点，后面接口函数对其更新
upmu_is_chr_det() // 充电状态监测
wireless/ac/usb_get_get_property() // 更新 charger
battery_update() 
bat_routine_thread()
    hrtimer_start() // 开始定时器，定时更新数据
battery_init() //

# alps\kernel-3.18\drivers\misc\mediatek\include\mt-plat\battery_meter.h
// SW FG 算法相关定义
# alps/kernel-3.18/drivers/power/mediatek/battery_meter_fg_20.c 
// SW FG算法,也即是OAM
SW FG的原理：
a.PMIC adc来获取raw vbat电压。
b.通过ZCV表格，将vbat转换成OCV
c.ocv-vbat/r 来获取电流I
d.对电流i 进行积分，获取电量。

/*
 * MTK vendor 封装了 FG2.0 算法，计算soc，然后通过netlink发送到Kernel
 * 算法部分可以参考FG1.0的代码（battery_meter.c）
 */
BMT_status.SOC = battery_meter_get_battery_percentage()
  gFG_capacity_by_c //库仑计计算的电量值
    bmd_ctrl_cmd_from_user（）// meter  数据
      memcpy(&gFG_capacity_by_c,...)
        nl_data_handler（）->data = NLMSG_DATA(nlh)

D0值：读取电池电压，将电池电压按对应电池的ZCV表查找对应的百分比，根据一定算法运算出的初始电量。


# alps\kernel-3.18\drivers\power\mediatek\linear_charging.c
// PMIC充电控制， CC模式CV模式切换
mtk_tuning_voltage()

/*linear_charging.c 和 switch_charging.c二选一*/
# alps\kernel-3.18\drivers\power\mediatek\switch_charging.c
// SW charger充电控制， CC模式CV模式切换
set_chr_input_current_limit()
set_bat_sw_cv_charging_current_limit()
...
charging_full_check()

# alps\kernel-3.18\drivers\misc\mediatek\power\mt6797\pmic_chr_type_det.c
```
Fuel Gauge Control 和 Charging Control 框图如下：

![FG&Charging Control](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/mtk/charging_control.jpg)


### 客制化部分
不同于高通将电池曲线合入DTS，MTK是以头文件的形式合入电池曲线（好像也有DTS方式）。
```c
# alps\kernel-3.18\drivers\misc\mediatek\include\mt-plat\mt6797\include\mach\mt_battery_meter_table.h
// 充电IC温度检测上拉电阻配置
BATTERY_PROFILE_STRUCT battery_profile_tx[] // 合入不同温度下电池曲线的 DOD OCV
R_PROFILE_STRUCT r_profile_t1[] // 合入不同温度下电池曲线的电池内阻和OCV

# alps\kernel-3.18\drivers\misc\mediatek\include\mt-plat\mt6797\include\mach\mt_battery_meter.h
#define SOC_BY_HW_FG  // 定义默认使用 Fuel Gauge， FG算法
/*#define HW_FG_FORCE_USE_SW_OCV*/
/*#define SOC_BY_SW_FG*/
// 电池参数配置，部分值来源于电池曲线表
CUST_POWERON_DELTA_CAPACITY_TOLRANCE // 重启电量记录范围

# alps\kernel-3.18\drivers\misc\mediatek\include\mt-plat\mt6797\include\mach\mt_charging.h
// 充电控制，充电电流、温度等宏定义
```

### 文件节点
电池状态、充电状态等文件节点的创建路径：
```c
// Power Supply Class Node 
# alps\kernel-3.18\drivers\power\power_supply.h
# alps\kernel-3.18\drivers\power\power_supply_core.c
# alps\kernel-3.18\drivers\power\power_supply_sysfs.c
power_supply_show_property()
power_supply_attrs
# alps\kernel-3.18\drivers\power\power_supply_leds.c
```

### Healthd模块
Healtdh模块是一个单独的进程，这部分主要做两件事：1. 读取电池数据，上报（BatteryService.java）； 2. 绘制关机图标。

#### Main函数
healthd.cpp是Healthd模块的入口，也就是Main函数，如下：
```cpp
# alps\system\core\healthd\healthd.cpp
/*
 * 针对不同方式定义执行函数
 * android_ops  正常开机
 * charger_ops  关机充电
 * recovery_ops Recovery模式
 */
static struct healthd_mode_ops android_ops = {
    .init = healthd_mode_android_init,
    .preparetowait = healthd_mode_android_preparetowait,
    .heartbeat = healthd_mode_nop_heartbeat,
    .battery_update = healthd_mode_android_battery_update,
};

uevent_event() // uevent 事件处理
    uevent_kernel_multicast_recv(uevent_fd, msg, UEVENT_MSG_LEN) // 接收底层事件，并返回事件数量
    /*遍历事件，POWER_SUPPLY_SUBSYSTEM*/
    healthd_battery_update() // 电池信息更新入口，此处根据返回 Charging ？，设置 poll 唤醒周期
        gBatteryMonitor->update()   



main() // main函数,单独的进程
    healthd_mode_ops = &android_ops/&charger_ops/&recovery_ops; // 选择执行函数体
    healthd_init
        epoll_create(MAX_EPOLL_EVENTS); // 使用epoll进行IO复用, 在一个线程管理所以 fd
        /*
         * 创建、注册监听三个事件，加入 epoll fd，每个事件都有其句柄函数
         * gBinderfd ：监听Binder通信事件，句柄：binder_event（healthd_mode_android.cpp）
         * uevent_fd： 监听底层电池 event，句柄:uevent_event()
         * wakealarm_fd：监听wakealarm事件，句柄：wakealarm_event
         * 在监听到事件后，epoll 就会在句柄函数里面做相应的更新操作，如上 uevent_event()
         */
        healthd_mode_ops->init(&healthd_config)// healthd_mode_android_init()
        uevent_init()
        wakealarm_init()
        new BatteryMonitor();
    healthd_mainloop(); // main函数，while(1) 
        if (events[n].data.ptr) // epoll遍历事件fd，调用处理函数
                (*(void (*)(int))events[n].data.ptr)(events[n].events);
        healthd_mode_ops->heartbeat();
```

#### 正常开机
正常开机时电池信息更新：
![update_battery](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/mtk/bat_update_func.jpg)

正常开机部分源码分析：
```cpp
# alps\system\core\healthd\BatteryPropertiesRegistrar.cpp
BatteryPropertiesRegistrar::publish()//将"batteryproperties"这个Service加入ServiceManager
BatteryPropertiesRegistrar::notifyListeners() // 遍历 listener ，通知上层监听者，如 BatteryService
BatteryPropertiesRegistrar::registerListener() // 上层通过Binder注册回调
     healthd_battery_update();// healthd.cpp
BatteryPropertiesRegistrar::getProperty() //BatteryManager.java主动查询时的对应接口

# alps\system\core\healthd\healthd_mode_android.cpp
healthd_mode_android_battery_update
    gBatteryPropertiesRegistrar->notifyListeners(*props) 
    
healthd_mode_android_init()
    ProcessState::self()->setThreadPoolMaxThreadCount(0);// 线程池里最大线程数
    IPCThreadState::self()->disableBackgroundScheduling(true);// 禁用后台调度
    IPCThreadState::self()->setupPolling(&gBinderFd); // 将Binder通信fd加入epoll
    if (healthd_register_event(gBinderFd, binder_event)) //binder_event注册到gBinderFd
    /* 将"batteryproperties"加入ServiceManager */
    gBatteryPropertiesRegistrar->publish(gBatteryPropertiesRegistrar);

# alps\system\core\healthd\BatteryMonitor.cpp 
BatteryMonitor::update(void)
    initBatteryProperties() // 电池参数初始化
    /*获取文件节点数据封装于 BatteryProperties */
    path.appendFormat("%s/%s/online", POWER_SUPPLY_SYSFS_PATH, mChargerNames[i].string());
    ireadFromFile(path, buf, SIZE)
    ...
    /*
     * alps\system\core\healthd\healthd_board_default.cpp
     * 将电池实时信息记录到 kernel log 中
     */
    healthd_board_battery_update(&props);
    healthd_mode_ops->battery_update(&props) // healthd_mode_android.cpp中update
    
BatteryMonitor::getXX  // 获取电池状态和Health状况等
BatteryMonitor::dumpState()
BatteryMonitor::init() //获取文件节点值，初始化（譬如加上节点路径： /sys/class/power_supply）写入mHealthdConfig

```

#### 关机充电
关机充电部分主要就是更新电量、充电状态，更新UI。
```bash
# alps\system\core\healthd\healthd_mode_charger.cpp
dump_last_kmsg() // dump前记录最后一份log
/*绘制关机充电图标*/
draw_xx()
redraw_screen()
healthd_mode_charger_heartbeat() // 获取最新电池状态，更新
    handle_input_state(charger, now);
    handle_power_supply_state(charger, now);
    update_screen_state()  // 更新屏幕显示
healthd_mode_charger_init()
healthd_mode_charger_battery_update()
```

## Framework层
### Native层

```cpp
# alps\frameworks\native\services\sensorservice\BatteryService.cpp
// 定义BatteryService.h中创建的BatteryService类的成员函数

# alps\frameworks\native\services\batteryservice\BatteryProperties.cpp
/*
 * 容器Parcel读写电池相关信息
 * 必须与frameworks/base/core/java/android/os/BatteryProperties.java 同步
 */
BatteryProperties::readFromParcel()
BatteryProperties::writeToParcel()

# alps\frameworks\native\services\batteryservice\BatteryProperty.cpp
/*
 * Parcel read/write code must be kept in sync with
 * frameworks/base/core/java/android/os/BatteryProperty.java
 */
BatteryProperty::readFromParcel()
BatteryProperty::writeToParcel()

# alps\frameworks\native\services\batteryservice\IBatteryPropertiesListener.cpp
// BatteryService.java中BatteryListener的父类
batteryPropertiesChanged()

# alps\frameworks\native\services\batteryservice\IBatteryPropertiesRegistrar.cpp
// BatteryManager.java和BatteryService.java通过其获取 batteryproperties ，与healthd中同步
```
### Framework部分
```java
# alps\frameworks\base\services\core\java\com\android\server\BatteryService.java
onStart() {
    /*
     * 通过ServiceManager获取batteryproperties Service，
     * 然后将BatteryListener注册到batteryproperties中
     */
    IBinder b = ServiceManager.getService("batteryproperties"); 
    batteryPropertiesRegistrar.registerListener(new BatteryListener());
    publishBinderService("battery", mBinderService);
    publishLocalService(BatteryManagerInternal.class, new LocalService());
processValuesLocked     
    shutdownIfNoPowerLocked() // 低电 Unplugged 关机广播
    shutdownIfOverTempLocked() // 温度超出，关机广播
    sendIntentLocked() // 电池信息改变，信息广播
    
class BatteryListener
    batteryPropertiesChanged // 监听到电池信息改变，更新信息
        atteryService.this.update(props)
class Led // 开机充电 LED 控制类

# alps\frameworks\base\core\java\android\os\BatteryManager.java
queryProperty() // 主动到 healthd 查询电池信息
    IBinder b = ServiceManager.getService("batteryproperties");//获取batteryproperties Service  
    mBatteryPropertiesRegistrar = IBatteryPropertiesRegistrar.Stub.asInterface(b);//接口转化
    mBatteryPropertiesRegistrar.getProperty(id, prop) // 调用到Healthd BatteryPropertiesRegistrar.cpp

/******************************************************************
 * 还有很多其他文件为上面两个文件提供服务，没有去详细分析了
 * 如下简单介绍一下。
 *****************************************************************/

# alps\frameworks\base\services\core\java\com\android\server\am\BatteryStatsService.java
// 电池信息广播Intent（ACTION_BATTERY_CHANGED）用到的字符串和常量

# alps\frameworks\base\core\java\android\os\BatteryManagerInternal.java
# alps\frameworks\base\core\java\android\os\BatteryProperties.aidl
# alps\frameworks\base\core\java\android\os\BatteryProperties.java
// 电池信息读写代码，与BatteryProperties.cpp同步
# alps\frameworks\base\core\java\android\os\BatteryProperty.aidl
# alps\frameworks\base\core\java\android\os\BatteryProperty.java
// 电池信息读写代码，与BatteryProperties.cpp同步

# alps\frameworks\base\core\java\android\os\BatteryStats.java
 // 存取电池使用情况统计，包括wakelocks, processes, packages, and services等

# alps\frameworks\base\core\java\com\android\internal\os\BatteryStatsImpl.aidl
// .aidl为接口定义文件， 定义电池状态信息及相关操作方法。

# alps\frameworks\base\core\java\com\android\internal\os\BatteryStatsImpl.java
// 影响电池的所有信息及操作，时间以ms为单位
```

### APP部分
系统UI处理电流的部分路径主要如下：
```java
# alps\frameworks\base\core\java\com\android\internal\os\BatterySipper.java
# alps\frameworks\base\core\java\com\android\internal\os\BatteryStatsHelper.java
# alps\frameworks\base\packages\SystemUI\src\com\android\systemui\BatteryMeterDrawable.java
# alps\frameworks\base\packages\SystemUI\src\com\android\systemui\BatteryMeterView.java
// 创建系统广播接收器，接收电池信息广播，绘制电池状态图标

# alps\frameworks\base\packages\SystemUI\src\com\android\systemui\statusbar\policy\BatteryController.java
// 定义一个广播接收器并在构造器里注册接收电池信息广播，收到自己广播后回调修改pluged、level

# alps\frameworks\base\packages\SystemUI\src\com\android\systemui\power\PowerUI.java
// 创建系统广播接收器，接收电池信息广播，弹出低电警告等

# alps\frameworks\base\packages\SystemUI\src\com\android\systemui\qs\tiles\BatteryTile.java
// 定义电量百分比显示TextView类
```



# 关机充电流程
关机充电也是在kernel里面充电，充电控制流程与开机是一致的，前面也分析到了。这里补充一个MTK软件流程图。如下：
![charging flow](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/mtk/power%20off%20charging2.jpg)

# 总结
先留一个坑，等有时间了，再来绘制一个清晰易懂的流程框图。

