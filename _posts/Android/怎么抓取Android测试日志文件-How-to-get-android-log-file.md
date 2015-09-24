title: "怎么抓取Android日志文件"
date: 2015-07-19 11:43:04
categories: Android
tags: Log
---
　　[Android日志系统详解](http://huaqianlee.me/2015/07/18/Android-Logging-system-Android%E6%97%A5%E5%BF%97%E7%B3%BB%E7%BB%9F%E8%AF%A6%E8%A7%A3/)
　　[How to debug with Android logging](http://huaqianlee.me/2015/07/18/%E6%80%8E%E4%B9%88%E7%94%A8Android%E6%97%A5%E5%BF%97%E7%B3%BB%E7%BB%9F%E6%9B%B4%E5%A5%BD%E5%9C%B0%E5%8E%BB%E8%B0%83%E8%AF%95-How-to-debug-with-Android-logging/)
　　[怎么抓取Android日志文件](http://huaqianlee.me/2015/07/19/%E6%80%8E%E4%B9%88%E6%8A%93%E5%8F%96Android%E6%B5%8B%E8%AF%95%E6%97%A5%E5%BF%97%E6%96%87%E4%BB%B6-How-to-get-android-log-file/)

　　前两篇blog分别介绍了Android logging系统及编程时怎么应用，关于kernel中的log系统，前面只是大概提及了一下，下次再详细分析。相信大家都知道调试时需要打开USB调试模式，接下来就分析一下怎么抓取日志文件。

##logcat命令详解
　　logcat是最常用的命令之一，其语法如下；
<!--more-->
```bash
shell@android:/ $ logcat --help
logcat --help
Usage: logcat [options] [filterspecs]
options include:
  -s              Set default filter to silent.
                  Like specifying filterspec '*:s'
  -f <filename>   Log to file. Default to stdout
  -r [<kbytes>]   Rotate log every kbytes. (16 if unspecified). Requires -f
  -n <count>      Sets max number of rotated logs to <count>, default 4
  -v <format>     Sets the log print format, where <format> is one of:

                  brief process tag thread raw time threadtime long

  -c              clear (flush) the entire log and exit
  -d              dump the log and then exit (don't block)
  -t <count>      print only the most recent <count> lines (implies -d)
  -g              get the size of the log's ring buffer and exit
  -b <buffer>     Request alternate ring buffer, 'main', 'system', 'radio'
                  or 'events'. Multiple -b parameters are allowed and the
                  results are interleaved. The default is -b main -b system.
  -B              output the log in binary

filterspecs are a series of  <tag>[:priority]

where <tag> is a log component tag (or * for all) and priority is:
  V    Verbose
  D    Debug
  I    Info
  W    Warn
  E    Error
  A    Assert 

'*' means '*:d' and <tag> by itself means <tag>:v

If not specified on the commandline, filterspec is set from ANDROID_LOG_TAGS.
If no filterspec is found, filter defaults to '*:I'

If not specified with -v, format is set from ANDROID_PRINTF_LOG
or defaults to "brief"
```

部分重要参数详解如下:
```bash
[filterspecs]  以<tag>[:priority]序列形式显示指定priority及其以上，指定tag的日志，未指定tag的部分则按默认输出日志

-b <buffer>
    用于指定要操作的日志缓冲区:system,events,radio,main.系统默认的是system和main 。该选项可以出现多次，以指定多个日志缓冲区。例:
  adb logcat -b system -b main -b events -b radio -s MyActivity:i
     日志输出会指明当前查看的日志缓冲区如：
     --------- beginning of /dev/log/radio
     --------- beginning of /dev/log/events
     --------- beginning of /dev/log/system
     --------- beginning of /dev/log/main

-v <format>  设置log打印格式
    brief — 显示prority/tag,产生日志的进程ID,和日志消息(默认格式)。
    process — 显示priority,产生日志的进程ID,和日志消息
    tag — 显示prority/tag,和消息
    thread — 显示priority,线程ID和日志消息
    raw — 只显示消息
    time — 显示日期时间,priority/tag,产生日志的进程Id,和日志消息
    long — 显示所有信息,日志消息另起一行显示,且每个日志间空一行
```

##log文件抓取方式
```bash
#实时打印
logcat main # APP日志
logcat radio # 射频通话部分日志
logcat events # 系统事件日志
logcat system # 系统日志
tcpdump # 网络通信方面log抓取
QXDM  #高通平台有,主要是Modem射频网络相关的log,同radio但更强大,没怎么接触,不熟悉

#状态信息
adb shell cat /proc/kmsg # kernel日志,每cat一次清零
adb shell dmesg # kernel日志,开机信息.(var/log/demsg)
adb shell dumpstate # 系统状态信息,比较全面,如:内存,CPU,log缓存等。可以帮助我们确定是否有内存耗光之类的问题
adb shell dumpsys # 系统service相关信息
adb bugreport # 包括上面所有状态信息
```
>Shell，Linux，Dos都支持通过“adb shell logcat > filename.txt”的形式将打印信息写入到文件　

　　dumpstate会打印很多有用的信息,我们也可以执行单独命令打印想要的部分信息,如通过“/system/bin/top -n 1 -d 1 -m 30 -t”获取CPU信息，但我现在对这个用得还不多,不是很熟悉,就不多说了,贴部分内容以供参考.
```bash　
Build: JZO54K

Build fingerprint: 'Xiaomi/mione_plus/mione_plus:4.1.2/JZO54K/4.12.5:user/release-keys'

Bootloader: unknown

Radio: msm

Network: (unknown)

Kernel: Linux version 3.4.0-perf-g1ccebb5-00148-g5f2009a (builder@taishan) (gcc version 4.6.x-google 20120106 (prerelease) (GCC) ) #1 SMP PREEMPT Fri Dec 27 16:52:36 CST 2013

Command line: console=ttyHSL0,115200,n8 androidboot.hardware=qcom kgsl.mmutype=gpummu vmalloc=400M androidboot.emmc=true androidboot.serialno=d02b34a3 syspart=system1 androidboot.baseband=msm



------ UPTIME (uptime) ------

up time: 05:07:48, idle time: 09:38:57, sleep time: 00:10:10

[uptime: 0.1s elapsed]



------ MEMORY INFO (/proc/meminfo) ------

MemTotal:         508016 kB

MemFree:           36688 kB

Buffers:           12100 kB

Cached:            84336 kB

SwapCached:            0 kB

Active:           327208 kB

Inactive:          62316 kB

Active(anon):     294644 kB
```

##后记
　　写这篇blog主要是因为前两篇有些内容没有表达出来，而在强迫症驱使下完成的。因为自己现在经验尚浅，可能有很多不完善和错误的地方，欢迎大家指出。另，如果想通过logcat直接打印kernel日志的话,可以参考[http://blog.csdn.net/ryfjx6/article/details/7096018](http://blog.csdn.net/ryfjx6/article/details/7096018)。