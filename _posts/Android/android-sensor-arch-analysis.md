title: "Android传感器（Sensor）架构简析 (╯_╰)"
date: 2017-12-17 10:49:12
categories:
- Android Tree
- Misc
tags: [源码分析,MTK]
---
> 这真的是一篇简析。。。 (╯_╰)  本来准备详细分析整个 sensor 架构的，实在时间紧张，只能先简析了。

*Platform information： MTK6797（X20）+ Android 7.0*

# Android 支持的传感器
现在 Android 支持多达数十种的各种各样的传感器，支持的类型如下：

![Sensor_Type](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/mtk/sensor_type.jpg)

# Android Sensor 架构
<!--more-->
因为功耗和效率等原因，高通后期平台将 sensor 部分放在 aDSP 中，与如下分析十分不同。

Android 传感器系统架构如下：

![sensor_arch](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/mtk/sensor_arch.jpg)

传感器驱动一般会有如下五种数据传输形式：input event设备驱动、MISC驱动、SYS驱动、HWMON设备驱动以及ioctl。如下是一幅网上看到未知来源的图片，更清晰的描述了底层架构，如下：

![sensor_arch](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/mtk/sensor_arch.png)

# 源码分析
传感器源码架构大致相同，本文就来分析陀螺仪部分源码。

## Kernel 部分
传感器几乎都是采用 I2C 总线， 所以先分析一下 I2C 部分。

### I2C 总线配置
MTK 为GPIO、I2C等配置提供了 DCT 工具， 可以直接在 UI 里面配置好 I2C 相关定义（codegen.dws 文件中），配好后编译会自动生成一些相关的 DTS 文件和头文件（如 cust_i2c.dtsi）。

![i2c-dct](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/mtk/i2c_dct.jpg)
> 高通是直接在 dts 里面定义。另需要注意：一条 i2c 总线只支持一种速率，不同速率外设需要挂接到不同总线。

MTK 是在 DCT 配好 i2c 相关（lk 和 kernel 都需要配）,如果有兼容 sensor 则配置在 dts 中，如下：
```bash
# alps\kernel-3.18\arch\arm64\boot\dts\mt6797.dtsi
i2c0:i2c@11007000 {
	compatible = "mediatek,mt6797-i2c";
	id = <0>;
	reg = <0x11007000 0x1000>,
		<0x11000100 0x80>;
	interrupts = <GIC_SPI 84 IRQ_TYPE_LEVEL_LOW>;
	clocks = <&infrasys INFRA_I2C0>, <&infrasys INFRA_AP_DMA>;
	clock-names = "main", "dma";
	clock-div = <10>;
};


...
# alps\kernel-3.18\arch\arm64\boot\dts\aeon6797_6m_n.dts
/* 兼容 sensor 配置*/
i2c0@11007000 {
  cust_gyro@6b { // name@i2c_address
	compatible = "mediatek,xxx_gyro";
	reg = <0x6b>;// i2c 地址
	....
  };
}

cust_gyro@1 { //name@0  为 first sensor 参数
	compatible			= "mediatek,bmi160_gyro"; // 驱动解析识别字符
	i2c_num				= <1>;  // i2c channel，硬件决定
	i2c_addr			= <0x68 0 0 0>; 
	direction			= <6>; // 映射坐标，见下图
	power_id			= <0xffff>; // ldo id
	power_vol			= <0>; // ldo voltage
	firlen				= <0>; // 数据过滤长度， 通常为0
	is_batch_supported		= <0>; 
};
...
```
关于上面 dts 中 方向参数 direction 取值依据参考下图：

![mapping_coordinate](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/mtk/mapping_coordinate.jpg)


### Gyro Driver
```c
# alps\kernel-3.18\drivers\misc\mediatek\gyroscope\bmi160_gyro\bmi160_gyro.c
bmi160_gyro_init()
    get_gyro_dts_func()  // 从 dts 获取自定义的参数
    gyro_driver_add(bmi160_gyro_init_info)
    
struct gyro_init_info bmi160_gyro_init_info
    bmi160_gyro_local_init()
        i2c_add_driver(&bmg_i2c_driver)
        
static struct i2c_driver bmg_i2c_driver  
    bmi160_gyro_i2c_probe()
        // 初始化结构体
        hwmsen_get_convert() // 获得坐标映射转换值
        bmg_init_client() // 初始化设备，如 ID ， 范围，数据格式等
        misc_register() // bmg_open\bmg_release\bmg_unlocked_ioctl; 注册设备，for factory mode , engineer mode , and so on
        bmg_create_attr() // 创建platform_driver attr
        gyro_register_control_path()  // struct gyro_control_path，见下 Common 部分
        gyro_register_data_path() // struct gyro_data_path
        device_register()
        device_create_file()
```
### Gyro Common
```c
# alps\kernel-3.18\drivers\misc\mediatek\gyroscope\inc\gyroscope.h    
struct gyro_control_path {
	int (*open_report_data)(int open);
	int (*enable_nodata)(int en);
	int (*set_delay)(u64 delay);
	bool is_report_input_direct;
	bool is_support_batch;
	int (*gyro_calibration)(int type, int cali[3]);
	bool is_use_common_factory;
};

struct gyro_data_path {
	int (*get_data)(int *x, int *y, int *z, int *status);
	int (*get_raw_data)(int *x, int *y, int *z);
	int vender_div;
};    
    
# alps\kernel-3.18\drivers\misc\mediatek\gyroscope\gyroscope.c    
gyro_probe()
    gyro_real_driver_init()
    gyro_input_init() // 初始化 input dev
        input_register_device(dev)

gyro_driver_add()
    platform_driver_register()
    
# alps\kernel-3.18\drivers\misc\mediatek\gyroscope\gyrohub\gyrohub.c  // sensorhub   
```

```c
# alps\vendor\mediatek\proprietary\hardware\sensor\sensors.c
struct sensor_t sSensorList[] =
{
    {
        .name       = GYROSCOPE,
        .vendor     = GYROSCOPE_VENDER,
        .version    = 3, // 软件版本
        .handle     = ID_GYROSCOPE+ID_OFFSET, // sensor handle（识别 ID）
        .type       = SENSOR_TYPE_GYROSCOPE, // sensor 类型
        .maxRange   = GYROSCOPE_RANGE,//34.91f, // 数据最大范围
        .resolution = GYROSCOPE_RESOLUTION,//0.0107f, // 数据精度
        .power      = GYROSCOPE_POWER,//6.1f, // 电流消耗（mA）
        .minDelay   = GYROSCOPE_MINDELAY,   // 最小数据上报延迟
		.maxDelay   = 1000000,               // 最大延迟
        .flags      = SENSOR_FLAG_CONTINUOUS_MODE,
        .reserved   = {}
    },
    ...
}
open_sensors()
    init_nusensors()
```
# 附 
```bash
# shell 文件路径
/sys/bus/platform/drivers/xxx
```
驱动数据和控制流：

![flow](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/mtk/work_flow.jpg)
