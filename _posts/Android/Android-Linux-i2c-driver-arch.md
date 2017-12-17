title: "Android/Linux  I2C 驱动架构分析"
date: 2017-12-03 21:37:07
categories: Android
tags: [源码分析,MTK]
---
# 前言
分析传感器源码的时候，发现对 I2C 的驱动也有些忘记了，所以就再分析一下并形成这篇博文。


# 驱动架构
## I2C 驱动架构

![i2c-arch](http://7xjdax.com1.z0.glb.clouddn.com/android/mtk/i2c_arch.jpg)
<!--more-->

# 源码分析
```bash
# alps\kernel-3.18\drivers\i2c
```
## 重要的结构体
```bash
# alps\kernel-3.18\include\linux\i2c.h

/*
 * 表示一个 i2c 适配器，即挂接在 i2c 总线上的 i2c 控制器
 * i2c_adapter is the structure used to identify a physical i2c bus along
 * with the access algorithms necessary to access it.
 */
struct i2c_adapter {
	struct module *owner;
	unsigned int class;		  /* classes to allow probing for */
	const struct i2c_algorithm *algo; /* the algorithm to access the bus */
	struct device dev;		/* the adapter device */
	....

};

/*
 * 表示一个 i2c 设备驱动
 */
struct i2c_driver {
	unsigned int class;

	/* Standard driver model interfaces */
	int (*probe)(struct i2c_client *, const struct i2c_device_id *); // 匹配 i2c 设备（i2c_client）
	int (*remove)(struct i2c_client *);
    ...

	struct device_driver driver;   
	const struct i2c_device_id *id_table; // 此设备驱动服务的设备 ID

	int (*detect)(struct i2c_client *, struct i2c_board_info *);
	const unsigned short *address_list; // 此设备驱动支持的设备地址
	struct list_head clients;  // 挂接此设备驱动匹配成功 i2c_client
};

/*
 * 表示一个 i2c 设备
 */
struct i2c_client {
	unsigned short flags;		/* div., see below		*/
	unsigned short addr;		/* chip address - NOTE: 7bit	*/
					/* addresses are stored in the	*/
					/* _LOWER_ 7 bits		*/
	char name[I2C_NAME_SIZE];
	struct i2c_adapter *adapter;	/* the adapter we sit on	*/
	struct device dev;		/* the device structure		*/
	int irq;			/* irq issued by device		*/
	struct list_head detected;
#ifdef CONFIG_MTK_I2C_EXTENSION
	__u32 timing;			/* parameters of timings		*/
	__u32 ext_flag;
#endif
};

/*
 * 描述 i2c 设备信息
 */
struct i2c_board_info {
	char		type[I2C_NAME_SIZE];
	unsigned short	flags;
	unsigned short	addr;
	void		*platform_data;
	struct dev_archdata	*archdata;
	struct device_node *of_node;
	struct acpi_dev_node acpi_node;
	int		irq;
};


# alps\kernel-3.18\include\uapi\linux\i2c.h
/*
 * 表示一个 i2c 数据包
 */
struct i2c_msg {
	__u16 addr;	     /* slave address */
	__u16 flags;
#define I2C_M_TEN		0x0010	/* this is a ten bit chip address */
...
#define I2C_M_RECV_LEN		0x0400	/* length will be first received byte */
	__u16 len;		/* msg length				*/
	__u8 *buf;		/* pointer to msg data			*/
#ifdef CONFIG_MTK_I2C_EXTENSION
	__u32 timing;	/* parameters of timings		*/
	__u32 ext_flag;
#endif
};
```
> 

## 关键路径
```bash
# alps\kernel-3.18\arch\arm64\boot\dts\mt6797.dtsi
# alps\kernel-3.18\arch\arm64\boot\dts\aeon6797_6m_n.dts


# alps\kernel-3.18\drivers\i2c
i2c-core.c：i2c核心层，设备驱动和总线驱动的桥梁
i2c-dev.c：通用 i2c 设备驱动
busses：开源的 adapter 
algos：i2c 通信算法

# alps\kernel-3.18\include\linux\i2c.h
# alps\kernel-3.18\include\uapi\linux\i2c.h
```

## 总线驱动层
总线驱动层主要实现外设驱动部分，初始化硬件（i2c控制器）和提供操作硬件的方法，与 i2c-dev 相对应，其负责的部分通俗点讲就是：知道怎么发数据，但不知道发什么数据。
其关键流程如下：
1. 获取资源
2. 注册中断、使能时钟等初始化工作
3. 构建 i2c_adapter
4. 设置 i2c_adapter
5. 注册 i2c_adapter
>这部分源码就不在此文分析了，感兴趣的朋友可以参考外设系列

## 核心层（i2c-core）
构建一个 i2c 总线结构体,并且提供匹配方法和驱动用的结构体 ，如总线驱动层和设备驱动层的注册、注销等方法。此部分存在两个匹配过程：
1. i2c 总线下的设备（i2c_client）与设备驱动（i2c_driver）之间的匹配。
2. i2c控制器（i2c_adapter）与设备之间的匹配。
```bash
# alps\kernel-3.18\drivers\i2c\i2c-core.c
struct bus_type i2c_bus_type = {
	.name		= "i2c",  // 总线名
	.match		= i2c_device_match, // 匹配设备（i2c_client）与设备驱动（i2c_driver）
	.probe		= i2c_device_probe,  // 注册挂载 i2c
	.remove		= i2c_device_remove,
	.shutdown	= i2c_device_shutdown,
	.pm		= &i2c_device_pm_ops,
};

 __init i2c_init() // init 函数
    # kernel-3.18/drivers/base/bus.c
    bus_register(&i2c_bus_type) // 注册i2c总线  "/sys/bus/i2c"
    i2c_add_driver(&dummy_driver) // // 注册 i2c 驱动创建“/sys/bus/i2c/driver/dummy” 
        i2c_register_driver() // 注册 i2c 驱动
            driver_register(&driver->driver); // 注册设备驱动，创建上面的“dummy”设备文件
            INIT_LIST_HEAD(&driver->clients)
        
i2c_device_probe()
    i2c_verify_client(dev) // 获取 i2c_client
    to_i2c_driver(dev->driver) // 获取 i2c_driver
    driver->probe(client, i2c_match_id(driver->id_table,client)) // 调用设备驱动层 probe，查询外设（client）对应的 id
        
i2c_device_match()
	client = i2c_verify_client(dev)// 通过 dev 获取 i2c_client
	of_driver_match_device(dev, drv) // 通过 of 方式匹配
	acpi_driver_match_device(dev, drv) // acpi 方式匹配
	/* if 上述两种方式皆未成功 */	
	driver = to_i2c_driver(drv); //通过 drv 获取 i2c_driver
	i2c_match_id(driver->id_table, client) // 通过查询 id_table 匹配

i2c_master_send() // 发送一个 i2c 数据包
    // 构建 i2c_msg
    i2c_transfer()
        __i2c_transfer()  // 发送数据包到总线驱动层
i2c_master_recv()        

/* 通过动态获取|指定 bus number 注册 i2c 控制器 */
i2c_add_adapter()|i2c_add_numbered_adapter() 
    i2c_register_adapter(adapter)
    	dev_set_name(&adap->dev, "i2c-%d", adap->nr); // 设置 adapter 名字 “i2c-%d”
	    adap->dev.bus = &i2c_bus_type;
	    adap->dev.type = &i2c_adapter_type;
	    /*
	     * 注册设备,  默认创建的设备文件是: /sys/devices/i2c-%d 
	     * 若注册 adapter 时指定了父设备，则为：/sys/devices/platform/xxx/i2c-%d 
	     */
	    device_register(&adap->dev);
	    /*
	     * 扫描 __i2c_board_list 匹配 adapter 与 i2c 次设备信息，匹配成功则创建 i2c 设备 （i2c_client）
	     */
	    i2c_scan_static_board_info() 
	        i2c_new_device() // 注册 i2c 设备
	            i2c_dev_set_name(adap, client) //  设置次设备名" %d-%04x"
	            device_register(&client->dev) //  注册次设备"/sys/devices/platform/xxx/i2c-%d/%d-%04x“ 
 
# alps\kernel-3.18\include\linux\i2c.h
i2c_add_driver(driver) 
    i2c_register_driver(THIS_MODULE, driver)

```
> 注：主设备表示特定的驱动程序；次设备表示使用该设备驱动的设备  


## 设备驱动层（i2c-dev）
设备驱动层主要是封装主机 i2c 的基本操作，给上层提供接口，与总线驱动层相对应，其：知道发什么数据，但不知道怎么发。   
```bash
# alps\kernel-3.18\drivers\i2c\i2c-dev.c （也可以是其他设备驱动文件，如：ov9650.c等。）
static const struct file_operations i2cdev_fops = {
	.owner		= THIS_MODULE,
	.llseek		= no_llseek,
	.read		= i2cdev_read,
	.write		= i2cdev_write,
	.unlocked_ioctl	= i2cdev_ioctl,
	.open		= i2cdev_open,
	.release	= i2cdev_release,
};


i2cdev_read()
    i2c_master_recv()
    copy_to_user()
i2cdev_write()
    memdup_user()  // 分配内核空间，用户态到内核态的拷贝
        copy_from_user()
    i2c_master_send()
...
i2cdev_open()
    i2c_dev_get_by_minor()
    i2c_get_adapter()
    // 设置 i2c client

i2c_dev_init()
    register_chrdev(I2C_MAJOR, "i2c", &i2cdev_fops)
    i2cdev_attach_adapter() // 绑定存在的 i2c 控制器（adapter）
        adap = to_i2c_adapter(dev);
	    i2c_dev = get_free_i2c_dev(adap);
	    /* register this i2c device with the driver core */
	    i2c_dev->dev = device_create(..."i2c-%d")

```
# 用户空间
这里只看一种通用的通过 JNI 操作 i2c 设备的方案，i2c-dev 提供的接口通过 JNI 给 APP 使用，如下：
```bash
# jni
extern "C" {
JNIEXPORT jint JNICALL Java_xxxxxx_xxx_I2c_open()
JNIEXPORT jint JNICALL Java_xxxxxx_xxx_I2c_read()
JNIEXPORT jint JNICALL Java_xxxxxx_xxx_I2c_write()
...
}

# app
I2c.open(“/dev/i2c-x”)
...

public static class I2c {  
        ...
        public native int open(); 
        public native int read(); 
        public native int write();  
        ...
}  
```


   