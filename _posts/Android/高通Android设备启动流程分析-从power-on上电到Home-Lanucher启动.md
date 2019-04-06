title: "高通Android设备启动流程分析(从power-on上电到Home Lanucher启动)"
date: 2015-08-23 22:07:48
categories: Android
tags: [源码分析,Qualcomm]
---
*Platform Information :
　System:    Ａndroid5.1 
　Platform:  Qualcomm msm8916
　Author:     Andy Lee
　Email:        huaqianlee@gmail.com*

**如有错误欢迎指出，共同学习，共同进步**
　
在我第一次接触Android得时候，我就很想知道Android设备在按下电源键后是怎么启动到主界面的，但是到现在为止也没有完全理清这个过程，所以就决定从按下power键开始来分析一下这个流程。虽然Android基于Linux内核开发的一个操作系统，但是在init进程后Android附加了很多其他操作，所以其启动流程还是有比较大的差别的，关于Linux系统的启动流程可以参考我的另一篇博文：[深入理解linux启动过程](http://huaqianlee.github.io/2015/08/21/Linux/%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3Linux%E5%90%AF%E5%8A%A8%E8%BF%87%E7%A8%8B/)。

因为我现在工作中用到的是高通的源码，并且高通也是目前Android手机的主流芯片，所以我就按照高通的msm8916来分析了，不过其他的也应该大同小异。
　
首先来看一下官方给出的Android系统架构：
<!--more-->　
![arch](https://github.com/huaqianlee/blog-file/https://github.com/huaqianlee/blog-file/https://github.com/huaqianlee/blog-file/image/blogandroidarchitecture.jpg)
　
当按下电源开关后，主要执行了如下步骤：
　
![boot](https://github.com/huaqianlee/blog-file/https://github.com/huaqianlee/blog-file/https://github.com/huaqianlee/blog-file/image/blogbootflow.png)
　
另，在内核启动了第一个进程后，init->home lanucher的详细流程如下：
　
![boot](https://github.com/huaqianlee/blog-file/https://github.com/huaqianlee/blog-file/https://github.com/huaqianlee/blog-file/image/blog0_1273850759wbAp.gif)
>注：此图取自网络，觉得描述得很详细，故附上

接下来就按照引导程序、内核启动、init进程、系统服务、Home Lanucher这样的顺序来分析Android启动的code。

##引导程序
引导程序在Android操作系统开始运行前的一个小程序，其主要为内核启动服务。引导程序执行的第一段代码，因此它是针对特定的主板与芯片的。设备制造商要么使用很受欢迎的引导程序比如redboot、uboot或者开发自己的引导程序，它不是Android操作系统的一部分。引导程序是OEM厂商或者运营商加锁和限制的地方。

引导程序分两个阶段执行。第一个阶段，检测外部的RAM以及加载对第二阶段有用的程序；第二阶段，引导程序设置网络、内存等等。这些对于运行内核是必要的，为了达到特殊的目标，引导程序可以根据配置参数或者输入数据设置内核。

###power-on及系统启动
当按下电源键或者系统重启之后，引导芯片代码PBL（Primary Boot Loader，类似于x86的BIOS）从预定义的地方（固化在ROM）开始执行，PBL由高通做好了的烧写在芯片中，PBL将启动设备、支持紧急下载等，然后加载引导程序sbl1，然后跳转到sbl1执行。

###处理器启动地址
MSM8916芯片内部有很多不同的处理器，如下：

|子系统|处理器|启动地址|
|:-----:|:------:|:-------:|
|APPS|Cortex-a53|0xfc010000|
|RPM|Cortex-m3|0x00200000/0x0|
|Modem|MSS_QDSP6|可配置的|
|Pronto|ARM9<sup>TM|0x0/0xffff0000/硬件重映射|

###启动栈
|组件|处理器|加载源地址|执行地址|功能|
|:-----:|:------:|:-------:|:------:|:-------:|
|APPS PBL|Cortex-A53|NA|APPS ROM|启动设备，检测接口，支持紧急下载，通过L2TCM加载和校验SBL1 ELF段,加载校验RPM code RAM|
|SBL1|Cortex-A53|eMMC|L2 TCM(segment1)/OCIMEM/RPM code RAM(segment2)|初始化内存子系统（总线，DDR，时钟，CDT），加载校验TZ、Hyperviser、RPM_FW、APPSBL镜像，通过USB2.0和Sahara协议memory dump，看门狗调试retention（如：L2 flush），RAM dump到eMMC/SD卡等的支持，大容量存储支持，USB驱动支持，USB充电，温度检测，PMIC驱动的支持，配置DDR以及crash调试的flush L1/L2/ETB支持等相关配置|
|QSEE/TZ|Cortex-A53|eMMC|LPDDR2/3|等同于TZBSP，设置运行时安全环境，配置xPU，支持fuse驱动，校验子系统镜像，丢弃RESET调试功能|
|QHEE（Hypervisior）|Cortex-A53|eMMC|LPDDR2/3|Hypervisor镜像负责设置VMM，配置SMMU以及控制xPU存取|
|RPM_FW|Cortex-M3|eMMC|RPM code RAM|电源资源管理|
|APPSBL/启动管理器和系统加载器|Cortex-A53|eMMC|LPDDR2/3|启动画面，加载校验内核|
|HLOS|Cortex-A53|eMMC|LPDDR2/3|引导HLOS镜像，例如a53 HLOS内核镜像，Pronto镜像等|
|Modem PBL|MSS_QDSP6|NA|Modem ROM Hexagon<sup>TM  TCM|设置Hexagon  TCM，从LPDDR2/3拷贝MBA到Hexagon  TCM并校验|
|MBA|MSS_QDSP6|eMMC|Hexagon TCM|校验modem镜像，xPU为modem和memory dump保护DDR|

>**eMMC** ：Embeded Multi Media Card，内嵌式记忆体，内部存储
**APPS PBL**：Application Processor Primary Boot Loader，应用处理器初级引导程序
**SBL1**：Secondary Boot Loader Stage1，第二引导程序阶段一（此处写阶段一是因为早期高通芯片分为几个阶段，但现在都由sbl1实现）
**TZ**：TrustZone
**PRM_FW**：Resource Power Manager Firmware，电源资源管理固件
**HLOS**：High-Level Operating System，高级操作系统
**Modem PBL**：Modem Primary Boot Loader，调制解调器侧初级引导程序
**MBA**：Modem Boot Authenticator，调制解调器侧引导校验程序


###引导代码流程
![](https://github.com/huaqianlee/blog-file/https://github.com/huaqianlee/blog-file/https://github.com/huaqianlee/blog-file/image/blogbootcodeflow.png)

1. 系统上电或者MSM8916 AP侧CPU重启。

2. Cortex-A53中APPS PBL执行，从启动设备中加载校验是sbl1镜像，然后跳转到sbl1中执行。

3. sbl1初始化ddr，从启动设备中加载校验QSEE/TZ、QHEE、RPM_FW、APPSBL镜像到DDR。

4. sbl1将控制权给QSEE/TZ，QSEE/TZ将设置一个安全环境，配置xPU，并支持fuse驱动。

5. QSEE传递控制权给QHEE，QHEE负责设置VMM，配置SMMU和xPU存取控制。

6. QHEE通知RPM开始执行RPM固件。

7. QHEE将控制器传递给HLOS APPSBL，APPSBL将初始化系统。

8. HLOS APPSBL加载和校验HLOS内核。

9. HLOS内核通过PIL.Modem加载MBA和modem镜像到DDR，然后继续启动进程。

10. HLOS通过PIL加载外围设备镜像Pronto到DDR，在通过TZ校验。

###第一阶段引导程序和第二阶段引导程序
由PBL加载的sbl1是第一阶段引导程序，APP SBL为第二阶段引导程序。这两部分代码的作用在上面**启动栈**和**引导代码流程**中已有一个简单的描述，如果想了解更多请参考我另外两篇博文：

[Android源码bootable解析之bootloader LK(little kernel)](http://huaqianlee.github.io/2015/07/25/Android/Android%E6%BA%90%E7%A0%81bootable%E8%A7%A3%E6%9E%90%E4%B9%8BLK-bootloader-little-kernel/)
[高通平台Android源码bootloader分析之sbl1(一)](http://huaqianlee.github.io/2015/08/15/Android/%E9%AB%98%E9%80%9A%E5%B9%B3%E5%8F%B0Android%E6%BA%90%E7%A0%81bootloader%E5%88%86%E6%9E%90%E4%B9%8Bsbl1-%E4%B8%80/)

##内核
Android的内核就是用的Linux的内核，只是针对移动设备做了一些优化，所有Android内核与linux内核启动的方式差不多。内核主要设置缓存、被保护存储器、计划列表，加载驱动等。当内核完成这些系统设置后，它首先在系统文件中寻找”init”文件，然后启动root进程或者系统的第一个进程。这部分可以参考我的另一篇博文：

[深入理解linux启动过程](http://huaqianlee.github.io/2015/08/21/Linux/%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3Linux%E5%90%AF%E5%8A%A8%E8%BF%87%E7%A8%8B/)

##init进程
init进程时Android的第一个用户空间进程，是所有进程的父进程。init进程主要有两个任务，一是挂载目录，比如/sys、/dev、/proc，二是读取解析init.rc脚本，将其中的元素整理成自己的数据结构（链表）。

init进程实现路径： system\core\init

###init.c
首先来看一下init进程的实现代码init.c， 其关键代码如下：
```c
# system\core\init\init.c
int main(int argc, char **argv)
{
    ...
    /* Get the basic filesystem setup we need put
      * together in the initramdisk on / and then we'll
      * let the rc file figure out the rest.
      */
    mkdir("/dev", 0755);
    mkdir("/proc", 0755);
    mkdir("/sys", 0755);

    mount("tmpfs", "/dev", "tmpfs", MS_NOSUID, "mode=0755");
    mkdir("/dev/pts", 0755);
    mkdir("/dev/socket", 0755);
    mount("devpts", "/dev/pts", "devpts", 0, NULL);
    mount("proc", "/proc", "proc", 0, NULL);
    mount("sysfs", "/sys", "sysfs", 0, NULL);

    ...

    property_init(); // 初始化属性服务，主要为属性文件分配存储空间

    get_hardware_name(hardware, &revision); // 从虚拟文件/proc/cpuinfo中获取hardware及revision，后面init.rc中的hardware变量值从此获取

    process_kernel_cmdline(); // 导入命令行参数并用属性值设置内核变量， /proc/cmdline

    ...

    selinux_initialize();// 初始化selinux安全机制

    init_parse_config_file("/init.rc"); // 解析init.rc文件，主要生成action和service链表

    /* 解析完init.rc配置文件后，会得到一系列的Action，action_for_each_trigger函数用来将Action加入action_queue，有关init.rc、action等内容下面再分析*/  
    action_for_each_trigger("early-init", action_add_queue_tail);  // 添加“early-init”action

    queue_builtin_action(wait_for_coldboot_done_action, "wait_for_coldboot_done");
    queue_builtin_action(mix_hwrng_into_linux_rng_action, "mix_hwrng_into_linux_rng");
    queue_builtin_action(keychord_init_action, "keychord_init");
    queue_builtin_action(console_init_action, "console_init");

    /* execute all the boot actions to get us started */
    action_for_each_trigger("init", action_add_queue_tail); // 添加“init”action

    queue_builtin_action(mix_hwrng_into_linux_rng_action, "mix_hwrng_into_linux_rng");
    queue_builtin_action(property_service_init_action, "property_service_init");  // 启动属性服务
    queue_builtin_action(signal_init_action, "signal_init");

    /* Don't mount filesystems or start core system services if in charger mode. */
    if (is_charger) {
        action_for_each_trigger("charger", action_add_queue_tail);
    } else {
        if (is_ffbm) {
            action_for_each_trigger("ffbm", action_add_queue_tail);
        } else {
            action_for_each_trigger("late-init", action_add_queue_tail); // 添加“late-init”action
        }
    }
    /* run all property triggers based on current state of the properties */
    queue_builtin_action(queue_property_triggers_action, "queue_property_triggers");

    for(;;) { // 无限循环，建立init子进程
        ...
        execute_one_command(); // 执行节点command，zygote service也在此启动，稍后再详细分析
        restart_processes(); // 重启进程
        
        # 监听属性服务事件
        ufds[fd_count].fd = get_property_set_fd();
        ufds[fd_count].events = POLLIN; // 属性事件

        ufds[fd_count].fd = get_signal_fd();
        ufds[fd_count].events = POLLIN;  // 子进程事件

        ufds[fd_count].fd = get_keychord_fd();
        ufds[fd_count].events = POLLIN; // keychord热键事件
        ...

#if BOOTCHART
      // bootchart是一个性能统计工具，用于搜集硬件和系统的信息，并将其写入磁盘，以便其他程序使用
#endif
        nr = poll(ufds, fd_count, timeout); // 等待下一个命令提交
        # 处理具体消息
        handle_property_set_fd(); // 处理属性命令
        handle_keychord(); // adb使能时处理keychord
        handle_signal(); // 处理子进程挂掉发来的信号，service重启
        ...
    }
```

###init.rc

####.rc文件的语法
init.rc文件是Android的有特定格式和规则的脚本文件，位于：system\core\rootdir\init.rc，称为Android的初始化语言。当进入adb shell后，我们能在根目录看到一个只读的虚拟内存文件init.rc，源文件init.rc被打包在boot.img中ramdisk.img中。其有四类声明：
1. Action - 动作
2. Command - 命令
3. Service - 服务
4. Option - 选项

该语言规定，Action和Service是以一种“小节”（Section）的形式出现的，其中每个Action小节可以含有若干Command，而每个Service小节可以含有若干Option。小节只有起始标记，却没有明确的结束标记，也就是说，是用“后一个小节”的起始来结束“前一个小节”的。

脚本中的Action大体上表示一个“动作”，它用一系列Command共同完成该“动作”。Action需要有一个触发器（trigger）来触发它，一旦满足了触发条件，这个Action就会被加到执行队列的末尾。Action的形式如下：
```bash
on  <trigger>
 <command1>
 <command2>
 ......
```

Service表示一个服务程序，会在初始化时启动，当服务退出时init进程会视情况重启服务。因为init.rc脚本中描述的服务往往都是核心服务，所以（基本上所有的）服务会在退出时自动重启。Service的形式如下：
```bash
service <name> <pathname> [<arguments>]*
 <option>
 <option>
  ......
```

其实，除了Action和Service，init.rc中还有一种小节：import小节。该小节类似java中的import或者c中的头文件，导入其他.rc脚本文件。如下：
```bash
import /init.environ.rc
import /init.usb.rc
import /init.${ro.hardware}.rc
import /init.trace.rc
```

####init.rc
init.rc脚本的主要内容如下：
```bash
# system\core\rootdir\init.rc

# 导入相关.rc文件
import /init.environ.rc
import /init.usb.rc
import /init.${ro.hardware}.rc # hardware变量的值在上面讲的main函数中获取
import /init.${ro.zygote}.rc #导入zygote服务.rc脚本文件
import /init.trace.rc
import /init.ideanfc.preinstall.rc

on early-init # 设置init进程以及它创建的子进程的优先级，设置init进程的安全环境
on init # 设置全局环境，为cpu accounting创建cgroup(资源控制)挂载点
...
# Load properties from /system/ + /factory after fs mount.
on load_all_props_action
    load_all_props

on late-init
    trigger early-fs # 触发early-fs动作
    trigger fs # 触发fs动作，挂载mtd分区
    trigger post-fs
    trigger post-fs-data
    trigger load_all_props_action
    ...
    trigger early-boot
    trigger boot

on post-fs # 改变系统目录的访问权限
on post-fs-data # 改变/data目录以及它的子目录的访问权限
on boot # 初始化基本网络、内存管理等
    ...
    chown radio system /sys/power/wake_lock // 修改文件用户组
    chown radio system /sys/power/wake_unlock
    chmod 0660 /sys/power/wake_lock // 修改文件操作权限
    chmod 0660 /sys/power/wake_unlock
    ...
    class_start core # 开启核心服务


service healthd /sbin/healthd # 电源管理服务
service servicemanager /system/bin/servicemanager # 系统服务管理器，管理所有的本地服务，比如位置、音频、Shared preference等等
    class core  # 声明为core核心服务
    user system
    group system
    critical
    onrestart restart healthd #重启电池管理服务
    onrestart restart zygote # 重启zygote服务作为应用进程, 定义在文件头import的zygote.rc脚本中
    onrestart restart media # 重启音频服务
    ...
```
>servicemanager主要注册获取服务，源码路径：frameworks\base\cmds\servicemanager\Service_manager.c。

####回调函数

Action包含的不同command对应不同func回调函数，具体对应情况可查看Keywords.h，如下：
```h
# system\core\init\keywords.h
int do_chroot(int nargs, char **args); //对应于KEYWORD最后一个参数
int do_chdir(int nargs, char **args);
...
int do_write(int nargs, char **args);
int do_copy(int nargs, char **args);
int do_chown(int nargs, char **args);
int do_chmod(int nargs, char **args);
...
KEYWORD(capability,  OPTION,  0, 0)
KEYWORD(chdir,       COMMAND, 1, do_chdir)
KEYWORD(chroot,      COMMAND, 1, do_chroot)
KEYWORD(class,       OPTION,  0, 0)
KEYWORD(class_start, COMMAND, 1, do_class_start)
KEYWORD(class_stop,  COMMAND, 1, do_class_stop)
KEYWORD(class_reset, COMMAND, 1, do_class_reset)
KEYWORD(console,     OPTION,  0, 0)
...
KEYWORD(user,        OPTION,  0, 0)
KEYWORD(wait,        COMMAND, 1, do_wait)
KEYWORD(write,       COMMAND, 2, do_write)
KEYWORD(copy,        COMMAND, 2, do_copy)
KEYWORD(chown,       COMMAND, 2, do_chown)
KEYWORD(chmod,       COMMAND, 2, do_chmod)
...
```

####init.rc脚本文件的解析
关于init.rc脚本文件的解析，就不详细描述了，只列出关键文件和关键函数，如下：
```c
# system\core\init\init.c
init_parse_config_file("/init.rc"); // 解析init.rc文件
  data = read_file(fn, 0);
  parse_config(fn, data); // 真正的解析函数

# system\core\init\init_parser.c ，被parse_config调用
lookup_keyword() //查找关键字
kw_is() // 一个宏，查表lookup_keyword返回关键字，对应上keywords.h中的KEYWORD
parse_new_section() // section起始行，解析service、on小节，import小节汇成一个链表
state.parse_line() // 从属于section的子行
init_parse_config_file(import->filename) //解析import小节
```

####core服务和main服务
boot子阶段会通过class_start对应的回调函数do_class_start开启core服务和main服务，这两类服务通过如下两句表明身份：
```rc
class core # 声明section为core服务
class main # 声明section为main服务
```
##### core服务
|core类型的服务|对应的可执行文件|说明|
|:--------------:|:------------:|:-------:|
|ueventd|/sbin/ueventd||	
|logd|/system/bin/logd|| 
|healthd|/sbin/healthd|电源管理服务|	 
|console|/system/bin/sh||	 
|adbd|/sbin/adbd||	 
|servicemanager|/system/bin/servicemanager|service manager service服务，Android的核心之一，zygote在此服务中加载|
|vold	|/system/bin/vold|||

##### main服务
|main类型的服务|对应的可执行文件|说明|
|:--------------:|:------------:|:-------:|
|netd|/system/bin/netd||
|debuggerd|/system/bin/debuggerd||
|ril-daemon|/system/bin/rild||	 
|surfaceflinger|/system/bin/surfaceflinger||	 
|zygote|/system/bin/app_process|Android创建内部创建新进程的核心服务|
|drm|/system/bin/drmserver||	 
|media|/system/bin/mediaserver|| 
|bootanim|/system/bin/bootanimation|| 
|installd|/system/bin/installd||
|flash_recovery|/system/etc/install-recovery.sh	||
|racoon|/system/bin/racoon||	 
|mtpd|/system/bin/mtpd||	 
|keystore|/system/bin/keystore||	 
|dumpstate|/system/bin/dumpstate||	 
|sshd|/system/bin/start-ssh||
|mdnsd|/system/bin/mdnsd|||

##属性服务
众所周知在windows中有一个注册表机制，在注册表中提供了大量的key-value属性。在Android(或Linux)中也有类似的机制：属性服务（property service）。init在启动的过程中会启动属性服务（Socket服务），并且在内存中建立一块存储区域，用来存储这些属性。当读取这些属性时，直接从这一内存区域读取，如果修改属性值，需要通过Socket连接属性服务完成。在init.c文件中main函数通过property_service_init_action调用了start_property_service函数来启动属性服务。

属性文件是由系统依次读取位于不同目录的配置文件，关于属性文件的解析也涉及到很多内容，这里就不去详细分析了，关键函数和路径如下：
```bash
# system\core\init\property_service.c
void start_property_service(void)
const char* property_get(const char *name)

# bionic/libc/bionic/system_properties.c
const prop_info *__system_property_find(const char *name)
static int init_property_area(void)
static int send_prop_msg(prop_msg *msg)
int __system_property_set(const char *key, const char *value)

# bionic\libc\include\sys\_system_properties.h ,定义了相关属性文件
#define PROP_PATH_RAMDISK_DEFAULT  "/default.prop"
#define PROP_PATH_SYSTEM_BUILD     "/system/build.prop"
#define PROP_PATH_SYSTEM_DEFAULT   "/system/default.prop"
#define PROP_PATH_VENDOR_BUILD     "/vendor/build.prop"
#define PROP_PATH_LOCAL_OVERRIDE   "/data/local.prop"
#define PROP_PATH_FACTORY          "/factory/factory.prop"
```

另，我们可以在adb shell中通过getprop获取所有属性名，或者通过getprop < 根属性名>获取具体属性值，如下：
```bash
# 获取所有属性值
C:\Users\Administrator>adb shell
shell@msm8916_32:/ $ getprop
getprop
[DEVICE_PROVISIONED]: [1]
[audio.dolby.ds2.enabled]: [true]
[audio.offload.buffer.size.kb]: [64]
[audio.offload.gapless.enabled]: [true]
[audio.offload.min.duration.secs]: [30]
[av.offload.enable]: [true]
[bluetooth.hfp.client]: [1]
...

# 获取指定属性具体属性值
shell@msm8916_32:/ $ getprop ro.build.product
getprop ro.build.product
msm8916_32
```

##Zygote
Zygote是Android中非常重要十分核心的一个服务，将由其去运行系统服务及孵化Activity进程等，接下来就好好分析一下Zygote。

在Java中，不同的虚拟机实例会为不同的应用分配不同的内存，每一个实例都有它自己的核心库类文件和堆对象的拷贝。但Android系统如果为每一个应用启动不同的Dalvik虚拟机实例，就会消耗大量的内存以及时间。因此，为了克服这个问题，Android系统创造了”Zygote”。Zygote让Dalvik虚拟机共享代码、低内存占用以及最小的启动时间成为可能。Zygote是一个虚拟器进程，在系统引导的时候启动。Zygote预加载以及初始化核心库类。通常，这些核心类是只读的，也是Android SDK或者核心框架的一部分。

###Zygote的启动
首先，先看一下Zygote在相关zygote.rc文件中的定义：
```bash
service zygote /system/bin/app_process -Xzygote /system/bin --zygote --start-system-server # 此处定义了启动zygote时会启动那些进程
    class main
    socket zygote stream 660 root system
    onrestart write /sys/android_power/request_state wake
    onrestart write /sys/power/state on
    onrestart restart media
    onrestart restart netd
```

当init.c中解析了rc文件后，rc文件中定义class_start命令对应do_class_start函数将启动服务(包括Zygote)进程，关键源码如下：
```bash
# system\core\init\builtins.c
int do_class_start(int nargs, char **args)
{
        /* Starting a class does not start services
         * which are explicitly disabled.  They must
         * be started individually.
         */
    service_for_each_class(args[1], service_start_if_not_disabled); // 从service_list链表找到class_name和参数一致的，然后调用service_start_if_not_disabled启动服务
    return 0;
}

static void service_start_if_not_disabled(struct service *svc)
{
    if (!(svc->flags & SVC_DISABLED)) {
        service_start(svc, NULL);  //启动服务
    } else {
        svc->flags |= SVC_DISABLED_START;
    }
}

# system\core\init\init.c
void service_start(struct service *svc, const char *dynamic_args)
{
    ...
    /* 检查需要开启进程的可执行文件是否存在，如：Zygote路径/system/bin/app_process */
    if (stat(svc->args[0], &s) != 0) {
        ERROR("cannot find '%s', disabling '%s'\n", svc->args[0], svc->name);
        svc->flags |= SVC_DISABLED;
        return;
    }
    ...
    pid = fork(); // 创建子进程，父进程为init创建的service进程
    ...
    execve(svc->args[0], (char**) arg_ptrs, (char**) ENV); // 执行进程，如/system/bin/app_process
    ...
    if (properties_inited())
        notify_service_state(svc->name, "running"); // 设置服务为running状态
}
```

经过上述流程，app_proces等进程就被启动起来了就进入到app_process相关code了，如下：
```cpp
# frameworks\base\cmds\app_process\app_main.cpp
int main(int argc, char* const argv[])
{
    ...
    AppRuntime runtime(argv[0], computeArgBlockSize(argc, argv));
    ...
    if (zygote) {
        runtime.start("com.android.internal.os.ZygoteInit", args);
    }
    ...
}

# frameworks\base\core\jni\AndroidRuntime.cpp
/* 开始Android运行， 打开虚拟机，调用"static void main(String[] args)"*/
void AndroidRuntime::start(const char* className, const Vector<String8>& options)
{
    ...
    /* start the virtual machine */
    JniInvocation jni_invocation;
    jni_invocation.Init(NULL);
    JNIEnv* env;
    if (startVm(&mJavaVM, &env) != 0) {
        return;
    }
    onVmCreated(env);
    ...
    /*
     * Register android functions.
     */
    if (startReg(env) < 0) {
        ALOGE("Unable to register all android natives\n");
        return;
    }
    ...
    /*
     * Start VM.  This thread becomes the main thread of the VM, and will
     * not return until the VM exits.
     */
    char* slashClassName = toSlashClassName(className);
    jclass startClass = env->FindClass(slashClassName);
    jmethodID startMeth = env->GetStaticMethodID(startClass, "main","([Ljava/lang/String;)V"); //获取静态main方法
    env->CallStaticVoidMethod(startClass, startMeth, strArray); // 调用main方法
```
这样就真正进入了Zygote进程了，如下：
```bash
# frameworks\base\core\java\com\android\internal\os\ZygoteInit.java
public static void main(String argv[]) {
    // Start profiling the zygote initialization.
   SamplingProfilerIntegration.start();
   ...
    registerZygoteSocket(socketName);  // 为Zygote注册服务器套接字（server socket）
    ...
    preload(); // 调用preloadClassed()：加载一系列类的文本文件（“preloaded-classes”），位于/frameworks/base
                       调用preloadResources():  加载本地主题、布局以及android.R文件中包含的所有东西
    ...
    startSystemServer(abiList, socketName); // 准备参数，通过Zygote孵化新 system server 进程
    runSelectLoop(abiList); // 运行Zygote进程选中的loop，此函数中不断接受新的connections，并读取command执行
    ...

```

到了这个阶段，就可以看到启动动画了。前面分析了Zygote的流程，可以总结为如下一张图：
![from internet](https://github.com/huaqianlee/blog-file/https://github.com/huaqianlee/blog-file/https://github.com/huaqianlee/blog-file/image/blogZygote.jpg)

在rc文件中有通过onrestart定义需要重启的动作或服务，这块就不去详细分析了，只将重启流程中的关键函数和路径列出：
```bash
# system\core\init\init.c
queue_builtin_action(signal_init_action, "signal_init"); //main函数中
static int signal_init_action(int nargs, char **args) //此函数调用singal_init

# system\core\init\signal_handler.c
void signal_init(void)
static void sigchld_handler(int s)
int get_signal_fd()
void handle_signal(void)
static int wait_for_one_process(int block) // 此函数中将发出restarting信号，然后init.c中的main函数收到此信号后将重启相应进程
```

##Home Lanucher启动
上ZygoteInit.java中mian函数在loop之前会调用一个关键函数startSystemServer，其除了准备一些参数外还将fork进程。其中就包括SystemServer，在SystemServer中最终会调用到ActivityManagerService，然后Home Lanucher就由ActivityManagerService中的方法来启动。关键源码和路径如下：
```bash
# frameworks\base\services\java\com\android\server\SystemServer.java
# frameworks\base\services\core\java\com\android\server\am\ActivityManagerService.java
public void systemReady(final Runnable goingCallback) {
     // Start up initial activity.
     mBooting = true;
     startHomeActivityLocked(mCurrentUserId, "systemReady");
}
boolean startHomeActivityLocked(int userId, String reason) {
    setDefaultLauncher(); // 第一次开机时设置
    mStackSupervisor.startHomeActivity(intent, aInfo, reason); // 开启homeActivity
}
```

花了这么长的时间，终于把这个流程走完了。 不过还是有很多地方偷懒了，没有详细研究，只了解了一个大概，然后做了记录。如有错误请谅解！

##Reference
在我分析启动流程时，主要参考引用了如下地址，后3篇博文对init.c和init.rc分析得十分详细，感兴趣可以参考一下这几篇博文。
[Android官网](http://developer.android.com/index.html)
[Android设备启动流程](http://android.jobbole.com/67931/)
[Android 4.4的init进程](http://my.oschina.net/youranhongcha/blog/469028)
[Android情景分析之详解init进程](http://blog.csdn.net/hu3167343/article/details/38299969)
[Androidinit过程详解](http://www.cnblogs.com/nokiaguy/archive/2013/04/14/3020774.html)

>本文边分析边记录而成，由于时间原因，很多地方没有详细分析，简单看了一下就跳过。可能会有很多描述不清楚甚至错误的地方，欢迎指出，共同学习，共同进步。

