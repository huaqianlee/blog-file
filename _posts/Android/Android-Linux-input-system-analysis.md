title: "Android(Linux) 输入子系统解析"
date: 2017-11-23 22:42:04
categories: Android
tags: [源码分析,MTK]
---
Android 源码分析系列综述博文： [Android 系统源码分析综述](http://huaqianlee.github.io/2017/11/21/Android/A-summary-of-Android-source-analysis/)


# 前言
Android/Linux 输入设备总类繁杂，常见的有按键、键盘、触摸屏、鼠标、摇杆等，之前其驱动都是采用字符设备、misc 设备处理的，但是如此多的设备就导致驱动混乱，所以 Linux 引入了输入子系统在字符设备等上抽象出一层来统一输入设备的驱动。本文就基于 MTK Android 7.0 源码来分析一下输入子系统。

# 输入子系统架构
输入子系统的系统架构如下图所示：
![input_system_arch](http://7xjdax.com1.z0.glb.clouddn.com/android/mtk/%E7%B3%BB%E7%BB%9F%E6%9E%B6%E6%9E%84%E8%AE%BE%E8%AE%A1.png)
> Framework 层以上只是简单跟了一下源码，没有深入查看

<!--more-->

## Hardware层
硬件层主要就是按键、触摸屏、Sensor等各种输入设备。

## Kernel层
Kernel 层主要分为三层，如下：
1. Input 设备驱动层: 采集输入设备的数据信息，通过 Input Core 的 API 上报数据。
2. Input Core（核心层）：为事件处理层和设备驱动层提供接口API。
3. Event Handler（事件处理层）：通过核心层的API获取输入事件上报的数据，定义API与应用层交互。

Kernel 层重要的数据结构如下：

数据结构 | 定义位置 | 简述
---|---|---
struct input_dev | input.h|Input 设备驱动中实例化
struct evdev<br>struct mousedev<br>struct keybdev | evdev.c<br>mousedev.c<br>keybdev.c|Event Handler 层逻辑 input 设备的数据结构
struct input_handler |Input.h|Event handler 的结构，handler 层实例化
Struct input_handle|Input.h|用于创建驱动层 input_dev 和 handler 链表的链表项结构

### 数据结构部分
```h
# alps\kernel-3.18\include\linux\input.h
/* 输入设备的语言描述 */
struct input_dev {  // 代表一个输入设备
    const char *name;  // 设备名字，sys 文件名
    struct input_id id; // 与 handler 匹配，总线类型、厂商、版本等信息
    
    /* 输入设备支持事件的位图（bitmap）*/
    unsigned long evbit[BITS_TO_LONGS(EV_CNT)]; // 所有事件
    unsigned long keybit[BITS_TO_LONGS(KEY_CNT)]; // 按键事件
    unsigned long relbit[BITS_TO_LONGS(REL_CNT)]; // 相对位移事件
    ...
    unsigned int keycodemax;  // 支持按键值个数
    unsigned int repeat_key; // 最近一次按键值，用于连击


    int (*setkeycode)()   // 修改当前 keymap
    int (*getkeycode)()   // 检索keymap
	...
	unsigned long key[BITS_TO_LONGS(KEY_CNT)];// 设备当前按键状态
	...
	int (*open)()
	int (*flush)();// 处理传递给设备的事件，如：LED事件和声音事件
    ...
    
    struct input_handle __rcu *grab; // 当前占用该设备的 input_handle
    
	struct list_head	h_list; // handle 链表，链接此input_dev
	struct list_head	node; //  链入 input_dev_list
	...
}

/* 事件处理，类似于中断处理函数 */
struct input_handler {

	void *private;

	void (*event)(); // 处理设备驱动报告的事件
	int (*connect)();  // 连接 handler 和 input_dev
	void (*disconnect)(); // 断开连接
	void (*start)();  // 启动指定 handle 的 handler 函数

	const char *name; // handler 名

	const struct input_device_id *id_table; // 输入设备id列表，匹配 input_dev

	struct list_head	h_list; // 链入handle 链表
	struct list_head	node;  // 链入 input_handler_list
};

/* 
 * 连接 input_dev 和 handler 的桥梁
 * 一个 input_dev 可以对应多个 handler ， 一个 handler 也可以对应多个dev
*/
struct input_handle {

	int open; // 设备打开次数（上层访问次数）
	const char *name;

	struct input_dev *dev;  // 所属 input_dev
	struct input_handler *handler; // 所属 handler

	struct list_head	d_node; // 链入对应 input_dev 的 h_list
	struct list_head	h_node; // 链入对应 handler de h_list
};

# alps/kernel-3.18/include/uapi/linux/input.h
/* 事件载体，输入子系统的事件包装为 input_event 上传到 Framework*/
struct input_event {
 struct timeval time; // 时间戳
 __u16 type;  // 事件类型
 __u16 code;  // 事件代码
 __s32 value;  // 事件值，如坐标的偏移值
};

```


### Input 设备驱动层
这部分主要实现各种输入设备的自己硬件相关的驱动并上报事件，这部分驱动基本遵循如下流程：
1) 声明实例化input_dev 对象
2) 注册 input_dev
    - input_allocate_device() 给设备分配空间，设置dev （实现于 input.c）
    - 通过 input_register_device() 注册 （实现于 input.c）
3) 硬件初始化，中断初始化，定义中断处理程序
4) 设置input_dev对象
5) 定义中断处理程序，上报事件


由于我自己有个外设系列源码分析，这里就不详细查看相关源码了，主要分析输入子系统的通用部分。设备驱动路径：
```bash
alps\kernel-3.18\drivers\input
```

### Input Core

```c
# alps\kernel-3.18\drivers\input\input.c
input_init()
    class_register(&input_class); // 注册为输入设备类，创建 input_class
    input_proc_init(); // 创建 proc/bus/input 路径下设备文件
        proc_mkdir("bus/input", NULL);
        proc_create("devices"..&input_devices_fileops);  // 
		proc_create("handlers"..&input_handlers_fileops);	    
    register_chrdev_region(MKDEV(INPUT_MAJOR, 0),INPUT_MAX_CHAR_DEVICES, "input");

input_register_device() // 通过 input core 注册 input_dev ，为设备驱动所调用 
    __set_bit(EV_SYN, dev->evbit); // 设为 EV_SYN/SYN_REPORT 事件，所有设备默认支持
    __clear_bit(KEY_RESERVED, dev->keybit); // KEY_RESERVED 事件不支持上传到用户空间
    ... // 设置 input_dev 
    device_add(&dev->dev); // 将 input_dev 注册到 sysfs
    list_add_tail(&dev->node, &input_dev_list); // 将 input_dev 加入input_dev_list
	list_for_each_entry(handler, &input_handler_list, node)
		input_attach_handler(dev, handler);   // 配对并 connect handler 和 input_dev
		
input_attach_handler()	
    input_match_device(handler, dev) // 配对handler 和 input_dev
    handler->connect(handler, dev, id); // connect
    
    
input_register_handler  // 注册一个 input_handler 
	INIT_LIST_HEAD(&handler->h_list);
	list_add_tail(&handler->node, &input_handler_list);
	list_for_each_entry(dev, &input_dev_list, node)
		input_attach_handler(dev, handler);  // 同上
		
input_event() // 上报新事件
    input_handle_event()/input_repeat_key()
      input_get_disposition // 处理事件类型
        input_pass_values()
            input_to_handler()
                handler->events() // 对应 evdev.c 中 evdev_event()
            input_start_autorepeat() // 根据需要启动或停止自动重复上报
            input_stop_autorepeat(dev)
      input_handle_abs_event()      
        input_abs_set_val(dev, ABS_MT_SLOT, mt->slot) // 刷新等待槽事件
input_start_autorepeat() // 启动定时器，自动重复上报

/* 类似于 input_event() , 不过忽略已经被捕获的事件和非拥有 dev 注入事件 */
input_inject_event() 
    input_handle_event()

input_open_device
    handle->open++
    dev->open(dev) // 设备 open


input_dev_suspend()    
...

# alps\kernel-3.18\include\linux\input.h
input_report_xx() // 上报事件，如键值
	input_event()
input_sync // 同步事件
	input_event()

/*********************************************************************
 * 基于 input system 封装了一层轮询设备，为需要轮询的设备驱动提供支持
 *********************************************************************/
# alps\kernel-3.18\include\linux\input-polldev.h
struct input_polled_dev

# alps\kernel-3.18\drivers\input\input-polldev.c
input_register_polled_device()
    NIT_DELAYED_WORK(&dev->work, input_polled_device_work);
input_open_polled_device()
input_polldev_set_poll()

```

###  Event Handler
Event Handler 层以通用的 evdev.c 为例来解析，上层和 Kernel 层的交互在此文件完成。
```c 
# alps\kernel-3.18\drivers\input\evdev.c
static struct input_handler evdev_handler = {   // input_handler
	.event		= evdev_event,
	.events		= evdev_events,
	.connect	= evdev_connect,
	.disconnect	= evdev_disconnect,
	.legacy_minors	= true,
	.minor		= EVDEV_MINOR_BASE,
	.name		= "evdev",
	.id_table	= evdev_ids,
};
truct file_operations evdev_fops = {  // 对应于上层的操作函数
	.owner		= THIS_MODULE,
	.read		= evdev_read,
	.write		= evdev_write,
	.poll		= evdev_poll,
	.open		= evdev_open,
	...
}
struct evdev_client {
	unsigned int head;
	unsigned int tail;
    ....
	struct wake_lock wake_lock;
	struct list_head node;
	struct input_event buffer[];  // 事件存储 buffer
};

evdev_init()
    input_register_handler(&evdev_handler) // 定义于 input.c
    
evdev_connect()    
    struct evdev *evdev;
    /* 设置evdev */
    dev_set_name(&evdev->dev, "event%d", dev_no); // 根据设备号命名handler
    /* 完成dev 和 handler 的连接关系*/
    evdev->handle.dev = input_get_device(dev);
    evdev->handle.handler = handler;
    ...
    
    cdev_init(&evdev->cdev, &evdev_fops); //绑定 File 操作函数 
    device_add(&evdev->dev);//注册设备到内核，会在 /dev/input 生成设备
    
evdev_event()
    evdev_events()
        evdev_pass_values()
            __pass_event() // 将事件加入 evdev_client， 并加入EV_SYN
            wake_up_interruptible(&evdev->wait) // 唤醒，让上层读取事件数据（存于 evdev buffer）
            
evdev_flush()
    input_flush_device() // input.c
    
evdev_write()   // 上层写入数据
    input_event_from_user()
    input_inject_event()
evdev_read()   //  上层读取数据
    
/* 内核与用户空间交互函数实现 */    
# alps\kernel-3.18\drivers\input\input-compat.c 
input_event_from_user()
    copy_from_user()  
input_event_to_user()    
    
```
## Framework 层
Framework 层涉及面太广，内容也多，我现在阅读这部分上层源码也有些吃力，再加上时间原因，只简单跟读了几个关键文件。以后抽时间再跟读一下源码，产出一篇博客。
```java
/* native 部分关键路径*/
# alps\frameworks\native\services\inputflinger
# alps\frameworks\native\libs\input
/* 从设备文件（/dev/input）获取信息）*/
# alps\frameworks\native\services\inputflinger\EventHub.cpp
# alps\frameworks\native\services\inputflinger\InputManager.cpp
/* 从 EventHub 获取事件信息*/
# alps\frameworks\native\services\inputflinger\InputReader.cpp
/* 分发事件信息*/
# alps\frameworks\native\services\inputflinger\InputDispatcher.cpp
# alps\frameworks\native\services\inputflinger\InputListener.cpp


/* framework 部分关键路径*/
# alps\frameworks\base\services\core\java\com\android\server\input
# alps\frameworks\base\services\core\java\com\android\server\wm

# alps\frameworks\base\services\core\java\com\android\server\input\InputManagerService.java
# alps\frameworks\base\services\core\java\com\android\server\wm\WindowManagerService.java
```


## 附 　Shell 操作路径
在 Kernel 层生成三个路径及相关设备文件，如下
```bash
# /sys/class/input/
event0  event11 event4 event7 input0  input11 input4 input7
event1  event2  event5 event8 input1  input2  input5 input8
event10 event3  event6 event9 input10 input3  input6 input9

# /dev/input 
event0 event10 event2 event4 event6 event8
event1 event11 event3 event5 event7 event9

# /proc/bus/input  
devices handlers
# cat devices  查看总线上的已经注册上的输入设备
I: Bus=0019 Vendor=0000 Product=0000 Version=0000
N: Name="ACCDET"
P: Phys=
S: Sysfs=/devices/virtual/input/input0
U: Uniq=
H: Handlers=gpufreq_ib event0
B: PROP=0
B: EV=3
B: KEY=40 0 0 0 0 0 0 1000000000 c000001800000 0

...

I: Bus=0019 Vendor=0000 Product=0000 Version=0001
N: Name="fingerprint_key"
P: Phys=
S: Sysfs=/devices/virtual/input/input2
U: Uniq=
H: Handlers=gpufreq_ib event2
B: PROP=0
B: EV=3
B: KEY=2000100000000000 180001f 8000000000000000

...

cat handlers // 查看注册的handler
N: Number=0 Name=gpufreq_ib
N: Number=1 Name=evdev Minor=64
```