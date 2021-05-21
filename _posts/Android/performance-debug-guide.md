title: Android 性能调试手册
date: 2020-10-10 23:17:46
categories: Android
tags: Performance
---


俗话说“雨过留痕，雁过留声”，之前因为工作需要折腾了小几个月的性能 BUG，还是得留下一点东西，这是第一篇：Android 性能调试手册，这篇文章简单聊聊工作中应该怎么进行性能分析。因为没有深入研究 Performance 相关内容，所以保留出错的权利。

# 0. 写在开头

在我司处理 Performance 问题时，大多数情况不会像顶级大厂那样优化每一帧，尽量榨干每一个硬件的性能。因为没有前人提供经验，全是自己总结的，如果存在有失偏颇的地方，你也只能看着。我理解的主要处理方式如下：

- 第一种，推不解。
  + gaps 小， 个人经验是 10% 以内即可以尝试推不解，譬如：问题机 Chrome 启动时间为 800 ms， 对比机为 750 ms。
  + 分析出时间消耗，列出与对比机的对比， 详细阐述差分部分，一般来说大部分差分是原生代码引起，或者 gaps 很小。

- 第二种嘛，当然就是想办法解决或优化了。

# 1. 怎么开始？
针对任何性能问题，我觉得第一步都先需要做如下三个确认：

0. 确认问题现象，最好自己复现一次。
1. 确认有没有大量 crash 发生。
2. 查看 kernel footprint（config）， 确认是否使用 perf config： msmxxx-perf_defconfig。

<!--more-->

# 2. systrace

我处理的这几十个性能问题中，超过 90% 都是和 APP 相关的，所以先来聊聊这方面的主要工具 systrace， 此篇文章主要讲讲调试方式，如果想了解怎么分析，可以看看我的第二篇文章 [APP 启动，触摸事件和 UI 绘制的简单分析示例](http://huaqianlee.github.io/2020/10/10/Android/breakdown_from_touch_input_to_drawing.html) 和官方文档。


## 2.1 Python 脚本

比较常用的方式是通过 Google 提供的 Python 脚本抓取 systrace， 我们可以在 SDK 或者 Android 源码中找到这个脚本，使用方式如下：
```bash
systrace.py gfx rs input view sched am wm camera dalvik freq idle load sync workq power mmc disk sm audio hal video app res binder_driver binder_lock -b 20480 -t 10 -o trace.html

# -b trace buffer 大小,单位为 kb，建议 20M，太小会信息不足，太大会因内存不足而抓取不了
# -t 持续时间，单位为秒，时间必须覆盖问题现场，但是也不能太长，不然内存不足
# -o Systrace 输出的文件路径


# 需要抓取的 tags,一般情况下，我们可以全选。不同的 Android SDK 其 tags 有所不同, 可以通过如下方式查看。
systrace.py --list-categories
gfx - Graphics
input - Input
view - View System
wm - Window Manager
am - Activity Manager
hal - Hardware Modules
res - Resource Loading
dalvik - Dalvik VM
power - Power Management
sched - CPU Scheduling
freq - CPU Frequency
idle - CPU Idle
...
```

## 2.2 atrace 

有些性能问题只有在不连接 USB 的时候才能重现问题,我们就需要利用 atrace 来获取离线的 systrace。

1. 确认如下先决条件是否满足：
```bash
a. adb root and adb remount is available
b. /system/bin/atrace is available
```
2. 抓取 systrace
```bash
adb root && adb remount
adb shell
atrace -z -b 40960 gfx input view wm am hal res dalvik rs sched freq idle load disk mmc -t 15 > /data/local/tmp/trace_output &
```
3. 断开 USB 并复现问题。
4. 重连 USB 确认 atrace 进程是否结束。
```bash
adb shell ps -t | grep atrace
```
5. atrace 如已完成，取出 dump。
```bash
adb pull /data/local/tmp/trace_output
```
6. 将 dump 转换为 systrace。
```
systrace.py --from-file trace_output -o output.html
```

## 2.3 traceview log

当我们需要深入剖析某一个进程的耗时时，我们可以通过 traceview 跟踪的程序的性能，查看每个方法执行的时间。

```bash
# <PROCESS> 填写进程名,如 AndroidManifest.xml 中声明的包名，通常都是主进程名.
1. adb shell am profile <PROCESS> start <FILE>
2. 再现问题。
3. adb shell am profile <PROCESS> stop
4. <FILE> 即为我们需要的 traceview log。

eg:
adb shell am profile com.android.gallery3d start /data/local/tmp/galler3d.trace
adb shell am profile com.android galler3d.stop
```

## 2.4 启动性能

当遇到 APP 启动问题时，我们可以使用 profiling 来帮助我们定位问题，首先我们需要在其 activity 中添加 profiling 的代码，如下：
```java
public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Debug.startMethodTracing("MainActivity Trace" ); //trace begin
    }
    @Override
    protected void onStart() {
        super.onStart();
        Debug.stopMethodTracing(); //trace end
    }
}
```

然后，我们就可以通过如下指令去获取 trace 帮助我们分析：
```bash
adb shell am start -n <Package Name>/<Package Name>.<Activity Name> --start-profiler <FILE>

eg：
adb shell am start -n com.example/com.example.MainActivity --start-profiler /data/local/tmp/example.trace
```

# 3. 性能模式

使系统运行于 performance 模式，查看一下问题是否存在。

```bash
adb shell root
adb shell setenforce 0
adb shell stop thermal-engine
adb shell rmmod core_ctl
# CPU 性能模式
adb shell "echo 1 > /sys/devices/system/cpu/cpu1/online"
adb shell "echo 1 > /sys/devices/system/cpu/cpu2/online"
adb shell "echo 1 > /sys/devices/system/cpu/cpu3/online"
...
adb shell "echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
adb shell "echo performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor"
adb shell "echo performance > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor"
adb shell "echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor"
...
# GPU 性能模式
adb shell "echo 1 > /sys/class/kgsl/kgsl-3d0/force_rail_on"
adb shell "echo 1 > /sys/class/kgsl/kgsl-3d0/force_clk_on"
adb shell "echo 1 > /sys/class/kgsl/kgsl-3d0/force_bus_on"
adb shell "echo 10000000 > /sys/class/kgsl/kgsl-3d0/idle_timer"
adb shell "echo performance > /sys/class/kgsl/kgsl-3d0/devfreq/governor"
adb shell "echo 0 > /sys/class/kgsl/kgsl-3d0/bus_split"
# DDR 性能模式
adb shell "echo 1 > /sys/kernel/debug/msm-bus-dbg/shell-client/mas"
adb shell "echo 512 > /sys/kernel/debug/msm-bus-dbg/shell-client/slv"
adb shell "echo 0 > /sys/kernel/debug/msm-bus-dbg/shell-client/ab"
adb shell "echo 16 * DDR max frequency > /sys/kernel/debug/msm-bus-dbg/shell-client/ib"
adb shell "echo 1 > /sys/kernel/debug/msm-bus-dbg/shell-client/update_request"
```
# 4. “死马当活马医”

写在“死马当活马医”的最前面，在使用如下这些方式时，记得**多和对比机对比**。

## 4.1 Thermal
获取 thermal-engine 的调试日志，查看是否有限制动作。
```
adb shell stop thermal-engine
adb shell thermal-engine --debug &
adb shell logcat -v time -s ThermalEngine > <FILE>
```

## 4.2 Perfd

Perfd 是 QCOM 开发的一个和性能相关的后台程序。默认情况下会开机自启动，其对机器性能至关重要，所以我们需要确保其已启动。
```bash
adb shell ps |grep perfd
root 4326 1 8704 844 futex_wait 7fa7af1984 S /system/vendor/bin/perfd
```

我们也可以打开 perfd 的调试日志，然后抓取 logcat 和 systrace， 以便获取更多的调试信息。

```bash
# 方法一：
adb pull /system/build.prop
echo "debug.trace.perf=1" >> build.prop
adb push build.prop /system/
adb shell chmod 0644 /system/build.prop
adb shell sync
adb shell reboot

# 方法二：
adb shell root
adb shell setenforce 0
adb shell setprop debug.trace.perf 1
adb shell stop perfd
adb shell start perfd
```


## 4.3 确认 ART 参数

### 4.3.1 pm.dexopt系统属性
```
$ adb shell getprop | grep "pm.dexopt"
[pm.dexopt.ab-ota]: [speed-profile]
[pm.dexopt.bg-dexopt]: [speed-profile]
[pm.dexopt.boot]: [verify]
[pm.dexopt.first-boot]: [quicken]
[pm.dexopt.inactive]: [verify]
[pm.dexopt.install]: [quicken]
[pm.dexopt.shared]: [speed]

# pm.dexopt.install
# 从性能上来说
verify < quicken < speed-profile < speed

# 编译和安装速度
verify > quicken > speed-profile > speed
```
> dexopt 宏： odex 开关

### 4.3.2 dalvik.vm 属性

可以通过调整堆内存的初始大小（dalvik.vm.heapstartsize）来优化性能，不过此方案需谨慎。
```Makefile
# device/qcom/msmxxx/msmxxx.mk
PRODUCT_PROPERTY_OVERRIDES += \
dalvik.vm.dex2oat-filter=interpret-only \
dalvik.vm.image-dex2oat-filter=speed\
dalvik.vm.heapminfree=4m \
dalvik.vm.heapstartsize=16m
```


## 4.4 系统负载

### 4.4.1 CPU

我比较喜欢结合如下两条命令进行分析，主要查看是否有异常进程，比如长时间暂用 CPU。
```bash
adb shell top -m 5
while true; do adb shell dumpsys cpuinfo; sleep 1; done | tee cpu_usage.txt 
```

### 4.4.2 内存与 IO

我主要使用如下内存和 IO 的工具，一般还需要结合 `top、ps` 等工具来一起定位导致内存泄漏的进程。
```bash
adb shell dumpsys meminfo
free
vmstat
iostat
pmap  PID

adb shell pull /d/ion                            # 可以检查heaps来确定cached ION memory.
adb shell cat /d/kgsl/proc/*/mem > kgsl_mem.txt  # 可以用例看每个processgfx所用的memory.
adb shel cat /proc/meminfo 
adb shell cat /proc/zoneinfo                     # 获得更准确的memoryinfo
adb shell cat /d/shrinker                        # 查看可以 free的memory 大小及其优先级.
adb shell cat /sys/class/kgsl/kgsl/page_alloc    # kgsl  /1024/1024 gfx 分配的size
adb shell cat /sys/kernel/debug/ion/heaps/system  # ION  total  /1024/1024
```


### 4.4.3 event

一般和系统相关的性能问题，我也会对比一下 event。
```bash
adb logcat -b events
```



## 4.5 Camera 相关

遇到 Camera 相关的问题，一般需要通过如下方式增加 trace。
```bash
1. adb root
2. adb shell "echo 1 > /d/tracing/events/camera/enable"
3. adb shell "echo 1 > /d/tracing/tracing_on"
4. 在对应界面添加 Trace.beginSection 和 Trace.endSection标签
```


# 5. 最后

如上是我试验过的一些调试方法，如下两篇高通文档中，有更多针对常见问题的调试方式和解决方案。

[80-np885-1_c_graphics_power_and_performance_overview.pdf](http://sorry-it-is-prietary/80-np885-1_c_graphics_power_and_performance_overview.pdf)  

[80-p0584-1_b_common-performance-issues-debugging-guide.pdf](http://sorry-it-is-prietary/80-p0584-1_b_common performance issues debugging guide.pdf)

# 6. 最最后

提供一份获取主要性能信息的脚本源码，如下：
```python
#=================================================================
# Script of capturing CPU, procrank, memory and top information with time interval.
mkdir PerfLogs
cd PerfLogs
rm ./*.txt
echo "Start..."
while :
do
echo "Perf"
MYDATE=`date +%y-%m-%d_%H:%M:%S`
echo $MYDATE
# Print current CPU frequency
# Modify below lines based on CPU core number.
echo ""
echo "${MYDATE}" >> cpuinfo_cur_freq.txt &
echo "cpu0 cur freq:`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`" >>
cpuinfo_cur_freq.txt &
echo "cpu1 cur freq:`cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq`" >>
cpuinfo_cur_freq.txt &
echo "cpu2 cur freq:`cat /sys/devices/system/cpu/cpu2/cpufreq/scaling_cur_freq`" >>
cpuinfo_cur_freq.txt &
echo "cpu3 cur freq:`cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_cur_freq`" >>
cpuinfo_cur_freq.txt &
echo "cpu4 cur freq:`cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq`" >>
cpuinfo_cur_freq.txt &
echo "cpu5 cur freq:`cat /sys/devices/system/cpu/cpu5/cpufreq/scaling_cur_freq`" >>
cpuinfo_cur_freq.txt &
echo "cpu6 cur freq:`cat /sys/devices/system/cpu/cpu6/cpufreq/scaling_cur_freq`" >>
cpuinfo_cur_freq.txt &
echo "cpu7 cur freq:`cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq`" >>
cpuinfo_cur_freq.txt &
echo "${MYDATE}" >> procrank.txt &
procrank >> procrank.txt &
echo "${MYDATE}" >> proc_meminfo.txt &
cat /proc/meminfo >> proc_meminfo.txt &
echo "${MYDATE}" >> meminfo.txt &
dumpsys meminfo >> meminfo.txt &
echo "${MYDATE}" >> top.txt &
top -t -m 8 -n 1 >> top.txt &
sleep 60 #60 seconds, you can modify the time interval.
done
```