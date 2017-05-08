title: "PX4 for Snapdragon Flight"
date: 2017-03-25 19:45:25
categories: Uav
tags: 
 - PX4
---
>公司刚好有基于8074的无人机主板,虽然与官方snapdragon board有些差异,但也差不多,本文就是自己在此板上跑px4的阶段笔记,写的比较简单粗糙. 

# 快速驱动无人机升空
主要通过PX4+QGroundcontrol+DX9的方式，手机APP+Qgroundcontrol+DX9也类似,只是将遥控器换成了APP(Android版地址: [DroneControl](https://github.com/ATLFlight/drone-controller))，准备好环境，有问题主要参考如下三个地址：

[PX4编译和执行](https://github.com/ATLFlight/ATLFlightDocs/blob/master/PX4.md#stable-releases)

[PX4开发手册](https://dev.px4.io)

[QGroundcontrol开发手册](https://donlakeflyer.gitbooks.io/qgroundcontrol-developers-guide/content/)

## 连接无人机
首先PC通过WiFi连上无人机，通过xshell或者putty ssh远程登录无人机。

<!--more-->
## 运行PX4
执行命令./px4 mainapp.config ，如下：
```bash
root@linaro-developer:/home/linaro# ./px4 mainapp.config 
sh: 1: cannot create /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor: Directory nonexistent
commands file: mainapp.config

______  __   __    ___ 
| ___ \ \ \ / /   /   |
| |_/ /  \ V /   / /| |
|  __/   /   \  / /_| |
| |     / /^\ \ \___  |
\_|     \/   \/     |_/

px4 starting.

INFO  [sdlog2] [blackbox] /root/log/sess018
INFO  [sdlog2] [blackbox] recording: log001.px4log
INFO  [dataman] Unkown restart, data manager file '/home/linaro/dataman' size is 47640 bytes
INFO  [mavlink] mode: Normal, data rate: 1000000 B/s on udp port 14556 remote port 14550
Sleeping for 1 s; (1000000 us).
pxh> INFO  [mavlink] using network interface wlan0, IP: 192.168.1.1
INFO  [mavlink] with broadcast IP: 192.168.1.255

pxh> 

```
## 运行QGroundcontrol
### 启动QGroundcontrol
我们使用的Snapdragon板好像只能支持QGroundControl V2.7.1 （[QGroundControl-V2.7.1下载](http://pan.baidu.com/s/1sl2fXhF)），启动QGroundcontrol。
![lanuch](http://7xjdax.com1.z0.glb.clouddn.com/start_qground.jpg)

### 连接无人机
1. File > Settings > CommLinks
![](http://7xjdax.com1.z0.glb.clouddn.com/com_link1.jpg)

2. 点击ADD 添加新的远端连接
![](http://7xjdax.com1.z0.glb.clouddn.com/com_link2.jpg)

3. 点击ADD 添加目标主机
![](http://7xjdax.com1.z0.glb.clouddn.com/com_link3.jpg)

4. 完成，如下
![](http://7xjdax.com1.z0.glb.clouddn.com/com_link.jpg)

5. 连接无人机，就在上一界面点击connect或者到主界面右上角点击connect连接
![](http://7xjdax.com1.z0.glb.clouddn.com/connect.jpg)

### 连接遥控器
1. File > Settings > Controllers
![](http://7xjdax.com1.z0.glb.clouddn.com/controller.jpg)

2. Enable controllers, 选择相应遥控器，设为Manual，并进行校准，如下
![](http://7xjdax.com1.z0.glb.clouddn.com/controller1.jpg)

### 机身设置及校准
进入setup界面，根据提示进行设置校准，完成后项目将显示绿色小圆点或者边框，我使用的板子POWER部分不能校准成功，如下：

![](http://7xjdax.com1.z0.glb.clouddn.com/setup_ok.jpg)
### 控制起飞
1. 点击 ARM SYSTEM 起桨，可通过遥控器控制 
![take_off](http://7xjdax.com1.z0.glb.clouddn.com/fly.jpg)

2. 点击 DISARM SYSTEM 停桨
![land](http://7xjdax.com1.z0.glb.clouddn.com/fly_end.png)

### 分析
Analyze界面可以实时挂载mavilink数据包等信息

![data](http://7xjdax.com1.z0.glb.clouddn.com/analyze.jpg)

### 打开自己想要的窗口

![window](http://7xjdax.com1.z0.glb.clouddn.com/tool_qg.jpg)

# 快速支持MPU6500
PX4代码默认支持mpu9250，如若想直接支持行空所使用的mpu6500,可对MPU9250.hpp文件做如下修改：
```bash
# 路径：Firmware\src\lib\DriverFramework\drivers\mpu9250\MPU9250.hpp
#define MPU_WHOAMI_9250			0x70 //0x71   modified by lihuaqian
```
>不过这样修改的话需要自己重新移植地磁驱动

如若出现温度异常，需要临时修改可以测试的话，可以做如下类似修改：
```bash
//if (fabsf(temp_c - _last_temp_c) > 2.0f) {
if (fabsf(temp_c - _last_temp_c) > 30.0f) { //modified by lihuaqian for debug
```

# 测试马达
## 修改CODE
PX4代码中有测试马达的代码，不过需要做如下小小修改：
```bash
#路径： Firmware\src\examples\hwtest\hwtest.c
...
actuators.timestamp = hrt_absolute_time();
+ orb_publish(ORB_ID(actuator_armed), arm_pub_ptr, &arm); //added by lihuaqian
orb_publish(ORB_ID(actuator_controls_0), actuator_pub_ptr, &actuators);
...
```
>注：同路径下的CMakeLists.txt，添加模块和执行命令

## 修改CMAKE文件
需要做如下修改：
```bash
# Firmware\cmake\configs\posix_eagle_legacy_driver_default.cmake
...
platforms/posix/work_queue


# added start by lihuaqian
examples/px4_simple_app
examples/hwtest  // 添加马达测试module
)
...

#Firmware\cmake\configs\qurt_eagle_legacy_driver_default.cmake
#
# FC_ADDON drivers
#
platforms/qurt/fc_addon/rc_receiver
platforms/qurt/fc_addon/uart_esc // 若没有，需加上

```
## 运行马达测试程序
首先运行px4，然后输入ex_hwtest，则测试程序开始循环控制马达工作，如下：
```
pxh> ex_hwtest
WARN  [ex_hwtest] DO NOT FORGET TO STOP THE DEFAULT CONTROL APPS!
WARN  [ex_hwtest] (run <commander stop>,)
WARN  [ex_hwtest] (    <mc_att_control stop> and)
WARN  [ex_hwtest] (    <fw_att_control stop> to do so)
WARN  [ex_hwtest] usage: http://px4.io/dev/examples/write_output
WARN  [ex_hwtest] Actuator armed
WARN  [ex_hwtest] count 0
WARN  [ex_hwtest] count 1
WARN  [ex_hwtest] count 2
WARN  [ex_hwtest] count 3
WARN  [ex_hwtest] count 4
WARN  [ex_hwtest] count 5
WARN  [ex_hwtest] count 6
...
```
>通过输入“help”， 可以查看支持哪些命令。



# 附 
参考路径：

[PX4 Github](https://github.com/ATLFlight)

[PX4编译和执行](https://github.com/ATLFlight/ATLFlightDocs/blob/master/PX4.md#stable-releases)

[PX4开发手册](https://dev.px4.io)


[QGroundcontrol开发手册](https://donlakeflyer.gitbooks.io/qgroundcontrol-developers-guide/content/)
