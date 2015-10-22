title: "About ActivityNotFoundException Unable to find explicit activity class && Android.mk解析"
date: 2015-07-12 14:06:35
categories: Android
tags: [Bug,编译]
---
　　[Android编译过程详解之一](http://huaqianlee.me/2015/07/12/Android/Android%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%B8%80/)
　　[Android编译过程详解之二](http://huaqianlee.me/2015/07/12/Android/Android%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%BA%8C/)
　　[Android编译过程详解之三](http://huaqianlee.me/2015/07/12/Android/Andro%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%B8%89/)
　　[Android.mk解析](http://huaqianlee.me/2015/07/12/Android/About-ActivityNotFoundException-Unable-to-find-explicit-activity-class-Android-mk%E8%A7%A3%E6%9E%90/)

##ActivityNotFoundException 　
　　最近将Android从4.4移植到5.1时，添加一个从拨号界面输入\*#360\*#进入battery info查看界面的功能时（如感兴趣，详情见[Android电池监控系统(bms)之一电池系统架构](http://huaqianlee.me/2015/06/06/Android/Android%E7%94%B5%E6%B1%A0%E7%9B%91%E6%8E%A7%E7%B3%BB%E7%BB%9F-BMS-%E4%B9%8B%E7%94%B5%E6%B1%A0%E7%B3%BB%E7%BB%9F%E6%9E%B6%E6%9E%84/)），activity跳转部分代码如下： 
```java
        else if(input.equals(BATTERY_INFO))
        {//added by lihuaqian
            try {
                ComponentName Component = new ComponentName("com.android.settings","com.android.settings.BatteryOemInfo"); 
                Intent intent = new Intent();
                intent.setComponent(Component);
                intent.setAction(Intent.ACTION_VIEW);   
                context.startActivity(intent);
                return true;
            } catch (ActivityNotFoundException e) {
                Log.d(TAG, "no activity to battery cmd."); 
                //e.printStackTrace();   
            }
        }
```
　　遇到如下问题：
```bash
　　ActivityNotFoundException : Unable to find explicit activity class; have you declared this activity in your AndroidManifest.xml?
```
<!--more-->
　　我将流程检查了一遍又一遍，都完全没有问题，Google了很久也无结果。后灵光一现：是否Setting这个apk根本就没有安装成功，所以才导致找不到Activity。
　
**于是，我首先通过命令 adb install -r Setting.apk 手动安装，但总是提示安装失败，这时已有些小小兴奋，因为感觉自己快找到原因了。**
　
**然后，我将apk push进手机相应文件系统路径，重启，通过logcat打印log，后发现关键信息，如下：**
```bash
 Failed to parse /system/priv-app/Settings: Signature mismatch for shared user : SharedUserSetting{2a5b4702 android.uid.system/1000} 
```
通过此log信息可知：系统没有能成功安装此apk，原因是app签名不匹配。 这样就找到了问题的根源。 向应用软件部同事了解情况后得知，是因为此项目客户指定Signature。
　
**所以，接下来我就有两种选择：**
- 自己整编整个系统，然后刷机，但是整编时间太长，所以放弃。
- 将修改代码给出软件同事，让其帮忙编一apk。（我选择了此方式，然后测试OK了）　

**当然，这种问题主要是做系统级APP，需要用到root权限或运行于系统进程时时才会遇到，其他一般都是如下几个情况：**
1. 如log中提示，没有在AndroidManifest.xml中定义此Activity。
2. 包名或者类名书写错误，不统一。
3. 自己定义的包名或者类名与系统自带类重复。

##Android.mk解析
　　因为上面问题时由签名引起的，所以就深入看了一下什么地方指定签名，后发现在APP目录中的Android.mk中制定。Android.mk将source打包为如下几种modules：
　　　1. APK程序
  　　　　一般的Android程序，编译打包生成apk文件
　　　2. JAVA库
  　　　　java类库，编译打包生成jar文件
　　　3. C\C++应用程序
 　　　　可执行的C\C++应用程序
　　　4. C\C++静态库 
　　　　编译生成C\C++静态库，并打包成.a文件，静态库则可被链接到动态库。
　　　5. C\C++动态库　　
　　　　编译生成共享库（动态链接库），并打包成.so文， 只有动态库才能被install or copy到apk。
　
　　在 Android Build 系统中，编译以模块（而不是文件）作为单位，每个模块都有一个唯一的名称，一个模块的依赖对象只能是另外一个模块，而不能是其他类型的对象。对于已经编译好的二进制库，如果要用来被当作是依赖对象，那么应当将这些已经编译好的库作为单独的模块。对于这些已经编译好的库使用 BUILD_PREBUILT 或 BUILD_MULTI_PREBUILT。例如：当编译某个 Java 库需要依赖一些 Jar 包时，并不能直接指定 Jar 包的路径作为依赖，而必须首先将这些 Jar 包定义为一个模块，然后在编译 Java 库的时候通过模块的名称来依赖这些 Jar 包。

 下面为Qualcomm Settings中的Android.mk （带“Lee:”为我自己加入以详解Android.mk）:

```bash
//通常以如下两行开头
LOCAL_PATH:= $(call my-dir)   // 用于定位源码路径，my-dir即当前路径
 /*CLEAR_VARS-清理除LOCAL_PATH外的很多LOCAL_XX变量,因变量皆为全局变量，清理后避免相互影响。*/
include $(CLEAR_VARS)

/*链接外部JAVA包*/
LOCAL_JAVA_LIBRARIES := bouncycastle conscrypt telephony-common ims-common // 当前模块依赖的 Java 共享库
LOCAL_STATIC_JAVA_LIBRARIES := android-support-v4 android-support-v13 jsr305 // 当前模块依赖的 Java 静态库

/**
  *user:       该模块只在user版本下才编译
  *eng:        该模块只在eng版本下才编译
  *debug:    该模块只在debug版本下才编译
  *optional:  该模块在所有版本下都编译,默认标签
  * development:  该模块在development版本下编译
 **/
LOCAL_MODULE_TAGS := optional //定义该模块什么情况被编译

Lee: LOCAL_MODULE    :=    //名字唯一不含空格，编译的目标对象，即名字
Lee: LOCAL_C_INCLUDES         //包含c/c++需要的头文件路径
Lee: LOCAL_SRC_FILES：当前模块包含的所有源代码文件。
Lee: LOCAL_STATIC_LIBRARIES：当前模块在静态链接时需要的库的名称。
Lee: LOCAL_SHARED_LIBRARIES：当前模块在运行时依赖的动态库的名称。
Lee: LOCAL_CFLAGS：提供给 C/C++ 编译器的额外编译参数。
Lee: LOCAL_PACKAGE_NAME：当前 APK 应用的名称。
Lee: LOCAL_CERTIFICATE：签署当前应用的证书名称。

/**
  *编译模块的源码
 **/
LOCAL_SRC_FILES := \
        $(call all-java-files-under, src) \
        src/com/android/settings/EventLogTags.logtags \
        src/com/android/cabl/ICABLService.aidl

/**
  *编译模块的资源路径
 **/
LOCAL_RESOURCE_DIR := $(LOCAL_PATH)/res

LOCAL_SRC_FILES += \
        src/com/android/location/XT/IXTSrv.aidl \
        src/com/android/location/XT/IXTSrvCb.aidl \
        src/com/android/display/IPPService.aidl
LOCAL_PACKAGE_NAME := Settings //apk名
LOCAL_CERTIFICATE := platform  // 此处定义签名
LOCAL_PRIVILEGED_MODULE := true//声明apk放到system/priv-app

Lee:LOCAL_CFLAGS +=$(OEM_CFLAGS)  // 声明customer（客户文件）中定义的相关宏，以便c/c++中#if defined 

/**
  * external/proguard - 抑制apk反编译的，对class混淆处理的代码路径
  * proguard.flags 指定不需要混淆处理的native方法和变量
 **/
LOCAL_PROGUARD_FLAG_FILES := proguard.flags//加载当前路径proguard.flags文件

include frameworks/opt/setupwizard/navigationbar/common.mk //包含指定

/**
  *BUILD_STATIC_LIBRARY:  编译为静态库
  *BUILD_SHARED_LIBRARY : 编译为动态库 
  *BUILD_EXECUTABLE:    编译为Native C可执行程序
  * BUILD_PACKAGE:  编译为apk
 **/
include $(BUILD_PACKAGE) //编译为apk

# Use the following include to make our test apk.
ifeq (,$(ONE_SHOT_MAKEFILE))
include $(call all-makefiles-under,$(LOCAL_PATH)) #表示需要编译该目录下文件，系统在当前路径查找Android.mk来编译
endif
Lee:还有很多其他定义和语法，这里就不一一分析，不过从变量名就能窥知一二
```
###编译类型的说明
####eng 
- 默认类型，该编译类型适用于开发阶段。
- 安装包含 eng, debug, user，development 标签的模块
- 安装所有没有标签的非APK模块
- 安装所有产品定义文件中指定的APK模块

####user  
- 该编译类型适合用于最终发布阶段。
- 安装所有带有 user 标签的模块
- 安装所有没有标签的非 APK 模块
- 安装所有产品定义文件中指定的 APK 模块，APK 模块的标签将被忽略

####userdebug
该编译类型适合用于debug阶段。该类型和user一样，另：
- 会安装包含debug标签的模块
- 编译出的系统具有root访问权限

　　build/core/config.mk中已经定义好了各种类型模块的编译方式。所以要执行编译，只需通过常量的方式引入对应的 Make 文件即可。详见[Android编译过程详解之二](http://huaqianlee.me/2015/07/12/Android/Android%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%BA%8C/)，例如，要编译一个 APK 文件，只需要在 Android.mk 文件中，加入“include $(BUILD_PACKAGE)。
　
　　除此以外，Build 系统中还定义了一些便捷的函数以便在 Android.mk 中使用，如下：
```bash
$(call my-dir)：获取当前文件夹路径。
$(call all-java-files-under, <src>)：获取指定目录下的所有 Java 文件。
$(call all-c-files-under, <src>)：获取指定目录下的所有 C 语言文件。
$(call all-Iaidl-files-under, <src>) ：获取指定目录下的所有 AIDL 文件。
$(call all-makefiles-under, <folder>)：获取指定目录下的所有 Make 文件。
$(call intermediates-dir-for, <class>, <app_name>, <host or target>, <common?> )：获取 Build 输出的目标文件夹路径。
```
###LOCAL_CERTIFICATE 
　　分析了Android.mk,再来详细说说我之前问题相关的一个属性：LOCAL_CERTIFICATE ，用于指定签名是使用的key，如不指定默认testkey。
　
分析这个属性就先得谈谈此apkAndroidManifest.xm了中的sharedUserId属性说起，如下：
```bash
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="com.android.settings"
        coreApp="true"
        android:sharedUserId="android.uid.system">
```
　　通过将sharedUserId配置为"android.uid.system"，即让程序运行在系统进程，而运行在系统进程则需要目标系统的platform key，Android.mk中的 LOCAL_CERTIFICATE := platform  即是声明相应签名key文件。key文件的源码路径在 build\target\product\security。通过这样处理的apk则只能在自己编译的系统里面才能使用，如若装到其他Android系统会提示："Package ... has no signatures that match those in shared user android.uid.system"。
　
　　另，android:sharedUserId属性不仅仅可以把apk放到系统进程中，也可以配置多个APK运行在一个进程中，这样可以共享数据，就会很有用处。就像我上面的Settings.apk。

在Android.mk中,LOCAL_CERTIFICATE可设置的值如下：
* LOCAL_CERTIFICATE := platform
* LOCAL_CERTIFICATE := shared
* LOCAL_CERTIFICATE := media　
然后，需要在APK源码的AndroidManifest.xml文件中的manifest节点添加如下内容：
* android:sharedUserId="android.uid.system"
* android:sharedUserId="android.uid.shared"
* android:sharedUserId="android.media"　
 在Android源码的build/target/product/security/目录下有如下的4对KEY：
    1. media.pk8与media.x509.pem；
    2. platform.pk8与platform.x509.pem；
    3. shared.pk8与shared.x509.pem；
    4. testkey.pk8与testkey.x509.pem；　

其中，"*.pk8"文件为私钥，"*.x509.pem"文件为公钥，这需要了解非对称加密方式。


