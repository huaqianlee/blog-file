title: "Android日志系统(logging system)详解"
date: 2015-07-18 13:43:04
categories: Android
tags: [Log,译文]
---
　　[Android日志系统详解](http://huaqianlee.github.io/2015/07/18/Android/Android-Logging-system-Android%E6%97%A5%E5%BF%97%E7%B3%BB%E7%BB%9F%E8%AF%A6%E8%A7%A3/)
　　[How to debug with Android logging](http://huaqianlee.github.io/2015/07/18/Android/%E6%80%8E%E4%B9%88%E7%94%A8Android%E6%97%A5%E5%BF%97%E7%B3%BB%E7%BB%9F%E6%9B%B4%E5%A5%BD%E5%9C%B0%E5%8E%BB%E8%B0%83%E8%AF%95-How-to-debug-with-Android-logging/)
　　[怎么抓取Android日志文件](http://huaqianlee.github.io/2015/07/19/Android/%E6%80%8E%E4%B9%88%E6%8A%93%E5%8F%96Android%E6%B5%8B%E8%AF%95%E6%97%A5%E5%BF%97%E6%96%87%E4%BB%B6-How-to-get-android-log-file/)

　　不管是做Android应用还是做Android中间层和底层，Logging系统都是必须要了解的；因为Android不像单片机程序UCOS那么简单,可以很方便的单步调试。所以，就准备用一篇blog来分析一下logging system。

##概览
　　Android提供了一个灵活的logging系统，允许应用程序和系统组件等整个系统记录logging信息，它是独立于Linux Kernel的一个logging系统，kernel是通过"pr_info"、"printk"等存储，通过“dmesg”或“cat  /proc/kmsg”获取。不过，Android logging 系统也是将信息存在内核缓存区。其结构如下：　
　
　　　　![image by Tetsuyuki Kobabayshi](https://github.com/huaqianlee/blog-file/blob/master/image/blogAndroid-logging-system.png)
<!--more-->　
Logging system由如下几部分组成：
- 实现loging信息存储的kernel驱动和缓存区
- C，C++和Java 类添加与读取log
- 一个单独浏览log信息的程序（logcat）
- 能够查看和过滤来自主机的log信息（通过Android Studio 或者 DDMS）

其在kernel中为系统的不同部分提供了四个不同log缓存区，可以通过/dev/log查看这些不同的设备节点，如下：
```bash
/dev/log/mian ： 主应用程序log，除了下三个外，其他用户空间log将写入此节点，包括System.out.print及System.erro.print等
/dev/log/events ： 系统事件信息，二进制log信息将写入此节点，需要程序解析
/dev/log/radio ： 射频通话相关信息，tag 为"HTC_RIL" "RILJ" "RILC" "RILD" "RIL" "AT" "GSM" "STK"的log信息将写入此节点
/dev/log/system ： 低等级系统信息和debugging,为了防止mian缓存区溢出,而从中分离出来　
```

log中的每条信息主要由四部分组成，如下：
- Tag
- 时间戳
- log信息level(或者event的优先级)
- log信息

##Android logger
　　logging的kernel driver部分被称作"logger"，其为系统日志提供支持，代码路径: kernel/drivers/staging/android/logger.c，此文件对4种logging缓存区加以支持。

###驱动
　　Log的读写是通过正常Linux文件读写方式完成的，write path被很好的优化过，所以能很快的open()、write()及close()，这样就避免了logging在系统中有太多的开销，影响速度。
　
#####Reading
　　在用户空间，一个正常的read操作通常读取从log读取一个条目，每read一次返回一个log条目或者阻塞等待下一个log条目。设备可以打开非阻塞模式。每一个read请求应该至少请求LOGGER_ENTRY_MAX_LEN (4096)长度的数据。
　
####Writing
　　当系统写数据到log时，driver将为每一个log条目保存pid（进程ID），tgid（线程组ID），timestamp（时间戳），这些信息将出现在用户空间的level，tag和message中。
　
####Ioctl
　　Ioctl函数支持如下cmd：

```bash
- LOGGER_GET_LOG_BUF_SIZE ： log条目缓存区的大小
- LOGGER_GET_LOG_LEN ： log数据的长度
- LOGGER_GET_NEXT_ENTRY_LEN： 下一log条目的大小
- LOGGER_FLUSH_LOG ： 清除log数据
- LOGGER_GET_VERSION ： 获得logger版本
- LOGGER_GET_VERSION ： 设置logger版本
```

###设备节点
　　当一个用户空间执行的程序用合适的主设备号和次设备号打开设备节点后，设备节点就处于活动状态，这些设备节点如下：
```bash
root@msm8916_32:/ # ls -al dev/log
ls -al dev/log
crw-rw-rw- root     log       10,  61 1970-01-09 02:14 events
crw-rw-rw- root     log       10,  62 1970-01-09 02:14 main
crw-rw-rw- root     log       10,  60 1970-01-09 02:14 radio
crw-rw-rw- root     log       10,  59 1970-01-09 02:14 system
```
##系统和应用程序logging
　　所有的log信息在Java类中定义并做相应处理，最终一个格式化的消息通过C/C++库传递到内核驱动程序,然后再将消息存储在适当的缓冲区中。
###App  log
　　App通过导入android.util.Log包来引入Log类，然后通过log方法写不同优先级的相关信息到log。Java类定义传递到log方法的tag为字符串常量，log方法通过这些字符串来获知信息的重要性，这样，当我们用log查看工具（如logcat）时，就可以过滤tag或者优先级来获取我们想要的信息。如下：
```bash
root@msm8916_32:/ # logcat
logcat
--------- beginning of system
I/Vold    (  265): Vold 2.1 (the revenge) firing up
D/Vold    (  265): Volume sdcard1 state changing -1 (Initializing) -> 0 (No-Media)
D/Vold    (  265): Volume uicc0 state changing -1 (Initializing) -> 0 (No-Media)


D/Vold    (  265): Volume usbotg state changing -1 (Initializing) -> 0 (No-Media)

D/Vold    (  265): Volume uicc1 state changing -1 (Initializing) -> 0 (No-Media)
I/Cryptfs (  265): Check if PFE is activated on Boot
E/Cryptfs (  265): Bad magic for real block device /dev/block/bootdevice/by-name/userdata
E/Cryptfs (  265): Error getting crypt footer and key
I/irsc_util(  316): irsc tool created:0xb70ff688
I/irsc_util(  316): Starting irsc tool
I/irsc_util(  316): Trying to open sec config file
```
###Event log
　　Event logs是在android.util.EventLog.class中创建二进制log信息。Log条目由二进制tag代码和二进制参数构成。Event logs 文件存储在system/etc/event-log-tags中，通过cat system/etc/event-log-tags能查看其信息。如下：
```bash
root@msm8916_32:/ # cat system/etc/event-log-tags
cat system/etc/event-log-tags
42 answer (to life the universe etc|3)
314 pi
1003 auditd (avc|3)
2718 e
2719 configuration_changed (config mask|1|5)
2720 sync (id|3),(event|1|5),(source|1|5),(account|1|5)
2721 cpu (total|1|6),(user|1|6),(system|1|6),(iowait|1|6),(irq|1|6),(softirq|1|6)
2722 battery_level (level|1|6),(voltage|1|1),(temperature|1|1)
2723 battery_status (status|1|5),(health|1|5),(present|1|5),(plugged|1|5),(technology|3)
2724 power_sleep_requested (wakeLocksCleared|1|1)
2725 power_screen_broadcast_send (wakelockCount|1|1)
2726 power_screen_broadcast_done (on|1|5),(broadcastDuration|2|3),(wakelockCount|1|1)
2727 power_screen_broadcast_stop (which|1|5),(wakelockCount|1|1)
2728 power_screen_state (offOrOn|1|5),(becauseOfUser|1|5),(totalTouchDownTime|2|3),(touchCycles|1|1)
2729 power_partial_wake_state (releasedorAcquired|1|5),(tag|3)
2730 battery_discharge (duration|2|3),(minLevel|1|6),(maxLevel|1|6)
2740 location_controller
```
###System log
　　framework层的许多类通过使用system log 来与app的log信息区分开来。System log在android.util.Slog.clash中实现。

###log命令行工具
　　log命令行工具能用来给任意程序穿件log条目，此工具是内建与toolbox的多功能程序。在adb shell中输入log则会提示其用法，如下：
```bash
C:\Users\Administrator>adb shell
root@msm8916_32:/ # log
log
USAGE: log [-p priorityChar] [-t tag] message
        priorityChar should be one of:
                v,d,i,w,e
```
>toolbox: 具有管理内存、备份和数据清除功能的一个系统文件，用来对手机性能进行设置，需要root权限，能被软件调用。　

###logwrapper
　　logwrapper工具是用来捕捉stdout信息的，当需要从本地应用捕捉stdout信息到log时，它将十分有用。源码路径：system/core/logwrapper/logwrapper.c；用法如下：
```bash
root@msm8916_32:/ # logwrapper
logwrapper
Usage: logwrapper [-a] [-d] [-k] BINARY [ARGS ...]

Forks and executes BINARY ARGS, redirecting stdout and stderr to
the Android logging system. Tag is set to BINARY, priority is
always LOG_INFO.

-a: Causes logwrapper to do abbreviated logging.
    This logs up to the first 4K and last 4K of the command
    being run, and logs the output when the command exits
-d: Causes logwrapper to SIGSEGV when BINARY terminates
    fault address is set to the status of wait()
-k: Causes logwrapper to log to the kernel log instead of
    the Android system log
```
###Logcat命令
　　我们可以通过logcat命令查看log，这个命令文件在文件系统的system/bin目录下，所以我们可以到文件系统中执行logcat，或者直接adb logcat，都能查看log。adb用法可以查看[adb.html](http://developer.android.com/guide/developing/tools/adb.html)(需翻墙，等什么时候有空以中文形式移到blog来)。
- 每一个有tag和优先级的log信息
- 可以通过tag和log等级过滤log信息
- 可以通过系统属性指定程序将stdout和stderr内容写入日志

##在启动阶段默认打开Logcat
　　Android logging和kernel logging是完全不同的两种日志系统，另补充一点，kernel日志支持直接在用户空间向/dev/kmsg写入log条目。[groups.google.com](http://groups.google.com/group/android-kernel/browse_thread/thread/87d929863ce7c29e/f8b0da9ed6376b2f?pli=1)中介绍了如何在启动阶段launch Logcat，如下：
```bash 
it can be launched via init.rc as below.. 

service logcat /system/bin/logcat -f /dev/kmsg 
       oneshot 
```
>不推荐这样做，这样会增加打印开销，使系统卡顿　

##Reference　　
[http://elinux.org/Android_Logging_System](http://elinux.org/Android_Logging_System) (大部分内容译自此文档)
[http://developer.android.com/guide/developing/tools/adb.html](http://developer.android.com/guide/developing/tools/adb.html)
[http://groups.google.com/group/android-kernel/browse_thread/thread/87d929863ce7c29e/f8b0da9ed6376b2f?pli=1](http://groups.google.com/group/android-kernel/browse_thread/thread/87d929863ce7c29e/f8b0da9ed6376b2f?pli=1)