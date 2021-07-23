title: "Android Selinux 权限及问题"
date: 2017-11-14 22:26:02
categories:
- Android Tree
- Security
tags: [App, MTK]
---


> 由于现做的是MTK平台，源码路径基于MTK， 不过高通大同小异

## 说明
Android 5.0以后完全引入了 SEAndroid/SELinux 安全机制，这样即使拥有 root 权限或 chmod 777 ，仍然无法再JNI以上访问内核节点。
> 其实在 Android 4.4 就有限制的启用此安全机制了。后面内容都按照 5.0  以后介绍，4.4 会有些许差异。

## SELinux Mode
SELinux 分为两种模式，Android 5.0 后所有进程都使用 enforcing mode。
```bash
enforcing mode: 限制访问
permissive mode: 只审查权限，不限制
```
<!--more-->
## SELinux Policy文件路径
```bash
# Google 原生目录 
external/sepolicy

# 厂家目录，高通将 mediatek 换为 qcom
alps\device\mediatek\common\sepolicy
alps\device\mediatek\<platform>\sepolicy
```
> 编译时将以合并的方式将厂家policy追加到Google原生。
     
## Log     
没有权限时可以在内核找到如下 log ：
```bash
# avc: denied  { 操作权限  }  for pid=7201  comm=“进程名”  scontext=u:r:源类型:s0  tcontext=u:r:目标类型:s0  tclass=访问类型 permissive=0

avc: denied {getattr read} for pid=7201 comm="xxx.xxx" scontext=u:r:system_app:s0 tcontext=u:r:shell_data_file:s0 tclass=dir permissive=0
```

## 权限修改
主要有三种方式，前两种只能用来测试，第三种是推荐的正式处理方式。
### adb在线修改seLinux
```bash
# Enforcing - 表示已打开 ，Permissive - 表示已关闭
getenforce;     //获取当前seLinux状态
setenforce 1;   //打开seLinux
setenforce 0;   //关闭seLinux
```
### kernel中关闭
```bash
# alps\kernel-3.18\arch\arm64\configs\xxx_defconfig
CONFIG_SECURITY_SELINUX=y // 屏蔽此配置项
```

### SELinux Sepolicy中添加权限
修改相应源类型.te文件（基本以源进程名命名），添加如下一行语句：
```bash
# 格式
allow  源类型 目标类型:访问类型 {操作权限}; // 注意分号

# 实例，具体写法参考源码
allow system_app shell_data_file:dir{getattr read write};
allow mediaserver tfa9897_device:chr_file { open read write }; 
allow system_server tfa9897_device:chr_file rw_file_perms; 

chr_file - 字符设备  file - 普通文件 dir - 目录
```
>通常很少修改Google default 的policy, 推荐更新mediatek 下面的相关的policy. 

### 新建节点
如果是自己新建的节点，需要在 sepolicy 路径下的 file_contexts 文件中做如下添加：
```bash
# 参考已有的格式
/dev/goodix_fp                 u:object_r:goodixfp_device:s0
```
>Android 5.0 修改的文件为device.te 和 file_contexts.be，而且device/mediatek/common/BoardConfig.mk 中的 BROAD_SEPOLICY_UNION 增加对应的xxxx.te。


## 编译
```bash
# 模块编译
mmm external/sepolicy
make -j24 ramdisk-nodeps & make -j24 bootimage-nodeps

# 整编
make -j24
```     
     
