title: "How to debug with Android logging"
date: 2015-07-18 15:43:04
categories:
- Android Tree
- Misc
tags: Log
---
　　[Android日志系统详解](http://huaqianlee.github.io/2015/07/18/Android/Android-Logging-system-Android%E6%97%A5%E5%BF%97%E7%B3%BB%E7%BB%9F%E8%AF%A6%E8%A7%A3/)
　　[How to debug with Android logging](http://huaqianlee.github.io/2015/07/18/Android/%E6%80%8E%E4%B9%88%E7%94%A8Android%E6%97%A5%E5%BF%97%E7%B3%BB%E7%BB%9F%E6%9B%B4%E5%A5%BD%E5%9C%B0%E5%8E%BB%E8%B0%83%E8%AF%95-How-to-debug-with-Android-logging/)
　　[怎么抓取Android日志文件](http://huaqianlee.github.io/2015/07/19/Android/%E6%80%8E%E4%B9%88%E6%8A%93%E5%8F%96Android%E6%B5%8B%E8%AF%95%E6%97%A5%E5%BF%97%E6%96%87%E4%BB%B6-How-to-get-android-log-file/)


　　Android logging system为logging系统提供了一个Java类android.util.Log，也提供了一个c/c++的log库，在kernel中有四个设备节点，详细见：[Android日志系统详解](http://huaqianlee.github.io/2015/07/18/Android/Android-Logging-system-Android%E6%97%A5%E5%BF%97%E7%B3%BB%E7%BB%9F%E8%AF%A6%E8%A7%A3/)。其系统架构如下：
　　　![image by simon](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/blogaplogd.jpg)
>此图与4.0以上的系统有些差异,新版Android增加了log_system

<!--more-->
##Java日志接口
　　此接口一般应用于编写APP时。
###Logging类
类名：android.util.Log，路径：frameworks/base/core/java/android/util/Log.java。主要方法如下：
```
Log.v();
Log.d();
Log.i();
Log.w();
Log.e();
Log.a();
```
Log信息显示等级从高到底分别为：ERROR，WARN，INFO，DEBUG，VERBOSE。VERBOSE除了开发期间，是不应该被编译进APP的，DEBUG应该编译但在runtime被忽略，ERROR，WARN和INFO logs则一直被保留。更加详细的内容见 ：[Log.html](http://developer.android.com/reference/android/util/Log.html)。
>一个好的习惯是在自己的类中定义一个TAG常量，如：private static final String TAG = "MyActivity";然后通过Log.i(TAG，"I am "+name);　

###Demo

```bash
package me.huaqianlee.demo;
import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;
import android.util.Log; 

private static final String TAG = "MyActivity";

public class Demo extends Activity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        TextView tv = new TextView(this);
        tv.setText("Hello, I am andy lee!");
        setContentView(tv);

        Log.i(TAG, "this is a log.i message");
        Log.v(TAG, "this  is a log.v message");
        Log.d(TAG, "this  is a log.d message");
        Log.w(TAG, "this  is a log.w message");
        Log.e(TAG, "this  is a log.e message");
        Log.a(TAG, "this  is a log.a message");
    } 
}
```

##C/C++日志接口
　　此接口一般应用于JNI和HAL层。
###Logging代码
　　Log信息的等级同上，关键代码如下：
```bash
#include <cutils/log.h> //路径：system/core/include/cutils/log.h
/*公共日志宏*/
ALOGV 
ALOGD 
ALOGI 
ALOGW 
ALOGE

/*条件日志宏*/
ALOGV_IF 
ALOGD_IF  
ALOGI_IF  
ALOGW_IF  
ALOGE_IF 

// 在system/core/include/log/log.h(被cutils/log.h包含)中定义如下：
#define CONDITION(cond)     (__builtin_expect((cond)!=0, 0))

#ifndef ALOGV_IF
#if LOG_NDEBUG
#define ALOGV_IF(cond, ...)   ((void)0)
#else
#define ALOGV_IF(cond, ...) \
    ( (CONDITION(cond)) \
    ? ((void)ALOG(LOG_VERBOSE, LOG_TAG, __VA_ARGS__)) \
    : (void)0 )
#endif
#endif
```
>1. 应该首先在c文件中定义LOG_TAG。
>2. 在Android.mk中添加：LOCAL_SHARED_LIBRARIES := liblog libcutils

###Demo
```bash
#include <stdio.h> 
#include <cutils/log.h> /* log header file*/
#include <cutils/properties.h>

/* define log tag */
#ifdef LOG_TAG
#undef LOG_TAG
#define LOG_TAG "app"
#endif
int main()
{
    ALOGV("Verbose: _app");
    ALOGD("Debug: _app");
    ALOGI("Info: _app");
    ALOGW("Warn: _app");
    ALOGE("Error: _app");
    printf("I am andy lee！\n");
    return 0;
}
```
##Android上的log格式
　　　Log信息的格式及详解如下：
```bash
tv_sec   tv_nsec     priority     pid    tid     tag     messageLen       Message

tag: 标签
tv_sec & tv_nsec: 日志的时间戳
pid: 打印日志的进程ID
tid: 打印日志的线程ID
Priority： 日志等级（或优先级），取值如下
  V — Verbose (lowest priority)
  D — Debug
  I — Info
  W — Warning
  E — Error
  A — Assert
```

##Reference

[http://log4think.com/debug-android-logging/](http://log4think.com/debug-android-logging/)
[http://developer.android.com/reference/android/util/Log.html](http://developer.android.com/reference/android/util/Log.html)
