title: "一个 health service 不生效问题引出的一点知识"
date: 2019-05-16 23:57:34
categories: 
- Android Tree
- Native
tags: [Bug,Qualcomm]
---
从 Android P 开始，Google 开始推荐厂家再定制一个 health 。前不久遇到一个定制 health 中的信息未成功反应到 Framework 的问题，在分析解决问题的过程中，学习到了一点新知识，所以就在这篇文章里根据解决问题的流程做一个小小的记录。

> 问题：定制 health service 中的一些 health 信息未成功反应到 Framework。

> 已知：定制 health 和 Google healthd 进程都运行于设备中，定制 health 主要重写 healthd_board_battery_update 函数，会通过库文件引用原生代码（system/core/healthd/）中的实现。

# 初步方案
## 简单介绍
服务创建时都编写了一个 x.rc 文件，用来描述 health service 的一些特点，其中就包括其启动时机。如下：
```rc
# system/core/healthd/android.hardware.health@2.0-service.rc
/* sevice 类型的 setction 表示一个可执行程序（进程） */
service health-hal-2-0 /vendor/bin/hw/android.hardware.health@2.0-service or healthd.rc
	class hal 
	user system
	group system
	file /dev/kmsg w

```
> 启动顺序： hal-> core-> main -> later

<!--more-->
## 尝试性修改 health service 启动时机 
因为对 Framework 层的处理不熟悉，就根据经验判断定制 health 与 Google healthd 可能有时序冲突，对定制 health 做延迟启动处理，如下：
```
# device/<vendor>/health/xxx.rc 
- class hal 
+ class main 
```
经过测试，此方案可行，但是这种说不出 root cause 的解决方案难以让人接受，所以也就拉通代码继续研究。

# 最终方案
## 原理分析
### Framework 层
首先最大疑问就是 FW 层怎么判断使用哪一个 health 的内容。因 health 信息最终会更新到 BatteryService.java, 尝试在此文件中寻找答案，最终找到如下关键代码：
```java
# frameworks/base/services/core/java/com/android/server/BatteryService.java
static final class HealthServiceWrapper {
    private static final String TAG = "HealthServiceWrapper";
    public static final String INSTANCE_HEALTHD = "backup";
    public static final String INSTANCE_VENDOR = "default";
    // All interesting instances, sorted by priority high -> low.
    private static final List<String> sAllInstances =
            Arrays.asList(INSTANCE_VENDOR, INSTANCE_HEALTHD);
    ...
}
```
通过这段代码知道系统是根据 service 的实例名来决定使用哪一个 health。

### service 的实例名
#### 定制 health
通过查看如下代码得知定制 health 的实例名为 “default”。
```cpp
# device/vendor/health/HealthService.cpp
/*通过库和如下函数引入 Google healthd 部分*/
int main(void) {
    return health_service_main();
}
# hardware/interfaces/health/2.0/utils/libhealthservice/HealthServiceCommon.cpp
int health_service_main(const char* instance) {
    gInstanceName = instance;
    if (gInstanceName.empty()) {
        gInstanceName = "default"; // 空白时实例名
    }
    healthd_mode_ops = &healthd_mode_service_2_0_ops;
    LOG(INFO) << LOG_TAG << gInstanceName << ": Hal starting main loop...";
    return healthd_main();
}
```
#### Google healthd
通过查看如下代码得知 healthd 的实例名与定制 health 相同，所以在 Framework 层面，后加载的 service 生效。
```
# system/core/healthd/HealthServiceDefault.cpp
/* 此 service 实例名为 “default”*/
int main(void) {
    return health_service_main();
}

# system/core/healthd/HealthServiceHealthd.cpp
/* 实例名为 “backup”*/
int main() {
    return health_service_main("backup");
}

# system/core/healthd/Android.bp
/* HealthServiceDefault 重写了 HealthServiceHealthd，所以 healthd 使用的实例名为“default”*/
cc_binary {
    name: "android.hardware.health@2.0-service.override",
    defaults: ["android.hardware.health@2.0-service_defaults"],

    overrides: [
        "healthd",
    ],
}
```
## 解决方案
因为我们需要使用定制的 health，所以将原生的实例名改为“backup”，这样这个问题就得以解决了。

## 花絮
我也尝试给定制 health 新建一个实例名，但是未成功，后发现似乎新添实例名需要按如下方式配置一下。但因为时间和研究的动力不足就没有继续了。
```
   <hal format="hidl" optional="true">
       <name>xxx.xxx</name>
       <version>1.0</version>
       <interface>
           <name>xxx</name>
           <instance>default</instance>
           <instance>backup</instance> # 似乎可以这样添加实例名
       </interface>
   </hal>
```
