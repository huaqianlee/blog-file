title: "Android编译过程详解之三"
date: 2015-07-12 16:43:04
categories: Android
tags: 编译
---
　　[Android编译过程详解之一](http://huaqianlee.me/2015/07/11/Android%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%B8%80/)
　　[Android编译过程详解之二](http://huaqianlee.me/2015/07/12/Android%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%BA%8C/)
　　[Android编译过程详解之三](http://huaqianlee.me/2015/07/12/Andro%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%B8%89/)
　　[Android.mk解析](http://huaqianlee.me/2015/07/12/About-ActivityNotFoundException-Unable-to-find-explicit-activity-class-Android-mk%E8%A7%A3%E6%9E%90/)

　　前两个篇基本完全涉及到了整个编译过程，接下来着重分析一下和公司产品相关的mk文件。有两个路径前面没有怎么提到过，如下：      
```bash
build/target/product # 当前产品配置的mk文件，如：需要包含哪些apk在此产品中
build/target/board  # 硬件芯片配置的mk文件，如：GPU、是否支持浮点运算等
```
　　除以上两个路径外，对产品定义的文件通常位于device目录下，还可以定义在vender目录下（不过Google已不建议如此做了），device目录下根据公司名和产品名分为两级目录，这个上文已经介绍过。通常一个产品定义如下四个文件：
- AndroidProducts.mk 
- 产品版本定义文件（一般针对不同应用环境存在多个，如：msm8916_32.mk）
- BoardConfig.mk
- verndorsetup.sh

## AndroidProducts.mk
<!--more-->
此文件定义PRODUCT_MAKEFILES ，用来导入产品版本配置文件列表，如下：
```bash
1. build\target\product\AndroidProducts.mk  ＃定义默认产品配置文件
ifneq ($(TARGET_BUILD_APPS),)　＃根据TARGET_BUILD_APPS确定编译那些APP，TARGET_BUILD_APPS由上文envsetup.sh中的命令指定
PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/aosp_arm.mk \
    $(LOCAL_DIR)/full.mk \
    $(LOCAL_DIR)/generic_armv5.mk \
    $(LOCAL_DIR)/aosp_x86.mk \
    $(LOCAL_DIR)/full_x86.mk \
    $(LOCAL_DIR)/aosp_mips.mk \
    $(LOCAL_DIR)/full_mips.mk
else
PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/core.mk \
    $(LOCAL_DIR)/generic.mk \
    $(LOCAL_DIR)/generic_x86.mk \
    $(LOCAL_DIR)/generic_mips.mk \
    $(LOCAL_DIR)/aosp_arm.mk \
    $(LOCAL_DIR)/full.mk \
    $(LOCAL_DIR)/aosp_x86.mk \
    $(LOCAL_DIR)/full_x86.mk \
    $(LOCAL_DIR)/aosp_mips.mk \
    $(LOCAL_DIR)/full_mips.mk \
    $(LOCAL_DIR)/vbox_x86.mk \
    $(LOCAL_DIR)/sdk.mk \
    $(LOCAL_DIR)/sdk_x86.mk \
    $(LOCAL_DIR)/sdk_mips.mk \
    $(LOCAL_DIR)/large_emu_hw.mk
endif
<!--more-->
2. device\qcom\msm8916_32\AndroidProducts.mk  # 自定义产品配置文件，内容如下：
　PRODUCT_MAKEFILES := \
	　$(LOCAL_DIR)/msm8916_32.mk
```
##产品版本定义文件
对于我用到文件则为msm8916_32.mk，主要定义此产品版本要编入哪些东西，主要变量如下：
###产品版本定义文件定义变量
|常量|说明|
|----|----|
|PRODUCT_NAME|最终用户将看到的完整产品名，会出现在“关于手机”信息中|
|PRODUCT_MODEL|产品的型号，这也是最终用户将看到的|
|PRODUCT_LOCALES|该产品支持的地区，以空格分格，例如：en_GB de_DE es_ES fr_CA|
|PRODUCT_PACKAGES|该产品版本中包含的 APK 应用程序，以空格分格，例如：Calendar Contacts|
|PRODUCT_DEVICE|该产品的工业设计的名称|
|PRODUCT_MANUFACTURER|制造商的名称|
|PRODUCT_BRAND|该产品专门定义的商标（如果有的话）|
|PRODUCT_PROPERTY_OVERRIDES|对于商品属性的定义|
|PRODUCT_COPY_FILES|编译该产品时需要拷贝的文件，以“源路径 : 目标路径”的形式|
|PRODUCT_OTA_PUBLIC_KEYS|对于该产品的 OTA 公开 key 的列表|
|PRODUCT_POLICY|产品使用的策略|
|PRODUCT_PACKAGE_OVERLAYS|指出是否要使用默认的资源或添加产品特定定义来覆盖|
|PRODUCT_CONTRIBUTORS_FILE|HTML 文件，其中包含项目的贡献者|
|PRODUCT_TAGS|该产品的标签，以空格分格|
###msm8916_32.mk
此文件除了引入定义以上变量以外，还有如下关键代码：　
```bash
$(call inherit-product, device/qcom/common/common.mk) # 继承common.mk，此文件定义了很多值为配置文件、脚本文件的常量

-include $(QCPATH)/common/config/rendering-engine.mk # （字体渲染引擎开关）font rendering engine feature switch
-include $(TOP)/customer/oem_common.mk # 自定义，引入一些定制变量
```
##BoardConfig.mk
　　该文件用来配置硬件主板，它其中定义的都是设备底层的硬件特性。例如：该设备的主板相关信息，Wifi 相关信息，还有 bootloader，内核，radioimage 等信息。对于该文件的示例，请参看 Android 源码树已经有的文件。
##vendorsetup.sh
　　该文件中作用是通过 add_lunch_combo 函数在 lunch 函数中添加一个菜单选项。该函数的参数是产品名称加上编译类型，中间以“-”连接，例如：add_lunch_combo full_lt26-userdebug。/build/envsetup.sh 会扫描所有 device 和 vender 二 级目 录下的名称 为"vendorsetup.sh"文件，并根据其中的内容来确定 lunch 函数的 菜单选项。


##后记
　　只有代码不会说谎，此文可能过时, 不过可以给你一个大致的脉络，然后再跟一下代码，就ok了。另，如需了解模块mk文件，参考我的另一篇博文：[Android.mk解析](http://huaqianlee.me/2015/07/12/About-ActivityNotFoundException-Unable-to-find-explicit-activity-class-Android-mk%E8%A7%A3%E6%9E%90/)。我写这系列博客，主要参考了Google官网和另外两篇网上Google出来的文章，地址见下References，感谢Google，感谢另两篇文章的作者。
　　　
##References
[http://source.android.com/source/initializing.html](http://source.android.com/source/initializing.html) （需翻墙）
[http://source.android.com/source/building.html](http://source.android.com/source/building.html) （需翻墙）
[http://www.cnblogs.com/mr-raptor/archive/2012/06/07/2540359.html](http://www.cnblogs.com/mr-raptor/archive/2012/06/07/2540359.html)
[http://www.ibm.com/developerworks/cn/opensource/os-cn-android-build/](http://www.ibm.com/developerworks/cn/opensource/os-cn-android-build/)
