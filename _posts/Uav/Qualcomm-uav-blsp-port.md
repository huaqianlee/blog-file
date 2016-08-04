title: "高通无人机8074 BLSP接口说明"
date: 2016-04-27 00:11:58
categories: Uav
tags:
---
## 概述
BLSP是高通对于低速接口的一种管理方式，8074 平台含有两个BLSP(BAM Low-Speed Peripheral) 块，对应于12个BLSP端口。 每一个BLSP块含有最多六个Qualcomm Universal Peripheral (QUP)或六个Uart cores，通过相关手册查询到每个外设属于BLSP多少。结构框图如下：
![BLSP](http://7xjdax.com1.z0.glb.clouddn.com/BLSP.png)
>1. BAM（Bus Access Manager）is used to move data to/from the peripheral buffers;  2.每个BLSP外设静态连接到一对BAM管道，BLSP支持BAM 和non-BAM-based 数据传输。

<!--more-->
每一个QUP可以被配置为I2C， SPI, UART, UIM接口等，如下：
![blsp_pin](http://7xjdax.com1.z0.glb.clouddn.com/blsp_pin.jpg)

##自定义BLSP口，配置TZ
这些端口在aDSP和应用处理器之间共享。为了让BLSP端口独立使用，我们可以在TrustZone（TZ）中定义BLSP 端口的分配，没有权限的子系统访问BLSP 端口将导致系统崩溃。 高通默认已经做好了配置。在DspAL中， 提供了一组设备文件路径映射到硬件，无人机用到的相关口已经在TZ中配置好了，如下：
```bash
SPI:  /dev/spi-[1~12]  对应于   BLSP[1~12]上的SPI设备
I2C: /dev/iic-[1-12]      对应于   BLSP[1~12]上的I2C设备
UART: /dev/tty-[1-4]
# UAV 8074 最多支持4个串口设备，每一个串口设备对应一个BAM设备， 
```
如果要自定义新的端口，需按于如下方式配置：
### 计算APPS BLSP值
![apps-BLSP](http://7xjdax.com1.z0.glb.clouddn.com/apps_blsp.jpg)
根据倒数第二列（对应于BAM pipe）计算出结果如下：
APPS BLSP1 : 0x00C3000C   [ Format : 0x00 (Apps BLSP1 QUP) ( Apps BLSP1 UART) ]
APPS BLSP2 : 0x00F30F33   [ Format : 0x00 (Apps BLSP2 QUP) ( Apps BLSP2 UART) ]
> Apps列对应Y，则表明BLSPx配为Uart或QUP，下同。

### 计算ADSP BLSP值
![adsp-BLSP](http://7xjdax.com1.z0.glb.clouddn.com/adsp_blsp.jpg)
ADSP BLSP1 = 0x0003FF00   [ Format : 0x00 (Adsp BLSP1 QUP) ( Adsp BLSP1 UART) ]
ADSP BLSP2 = 0x00FC00CC  [ Format : 0x00 (Adsp BLSP2 QUP) ( Adsp BLSP2 UART) ]

### 通过计算的值在TZ中配置 
路径：trustzone_images\core\hwengines\bam\8974\bamtgtcfgdata_tz.h
 
BLSP1:
```bash
Replace the highlighted values with ADSP BLSP1 and APPS BLSP1
 
bam_sec_config_type bam_tgt_blsp1_secconfig =
{
    {
#ifdef FEATURE_DRONE_CUSTOMIZATION_1 
#ifdef BAM_TZ_DISABLE_SPI
        {0x00C3000C   , TZBSP_VMID_AP, 0x0, TZBSP_VMID_AP_BIT},       // APPS BLSP1
        {0x0003FF00   , TZBSP_VMID_LPASS, 0x0, TZBSP_VMID_LPASS_BIT}, // ADSP BLSP1
        {0x00000000, TZBSP_VMID_MSS, 0x0, TZBSP_VMID_MSS_BIT},
#else
        {0x00C3000C   , TZBSP_VMID_AP, 0x0, TZBSP_VMID_AP_BIT},       // APPS BLSP1
        {0x0003FF00   , TZBSP_VMID_LPASS, 0x0, TZBSP_VMID_LPASS_BIT}, // ADSP BLSP1
        {0x00000000, TZBSP_VMID_MSS, 0x0, TZBSP_VMID_MSS_BIT},
        {0x00300000, TZBSP_VMID_TZ, 0x0, TZBSP_VMID_TZ_BIT}
      
#endif /*BAM_TZ_DISABLE_SPI*/
...
}
 ```
 
BLSP2:
```bash 
bam_sec_config_type bam_tgt_blsp2_secconfig =
{
    {
#ifdef FEATURE_DRONE_CUSTOMIZATION_1 
        {0x00F30F33   , TZBSP_VMID_AP, 0x0, TZBSP_VMID_AP_BIT},       // APPS BLSP2
        {0x00FC00CC  , TZBSP_VMID_LPASS, 0x0, TZBSP_VMID_LPASS_BIT}   // ADSP BLSP2
#else
        {0x003C0FFF, TZBSP_VMID_AP, 0x0, TZBSP_VMID_AP_BIT},
        {0x00C3F000, TZBSP_VMID_LPASS, 0x0, TZBSP_VMID_LPASS_BIT}
#endif
...
}
```

## 怎么工作
在启动期间，aDSP将加载BLSP配置文件初始化串口设备。为了是能运行时配置，可在/usr/share/data/adsp/blsp.config中定义串口设备和BAM端口的映射，bam*对应于BLSP*。如：
```bash
tty-1 bam-9
tty-2 bam-6
tty-3 bam-8
tty-4 bam-2
```
如果串口设备只用TX和RX，需要在最后一行加入 "[2-wire]"作为标示，否则默认为四线：TX，RX，CTS和RTS。

> 1. 串口根据需要配置，不一定所有都配置；2. 如果运行时指定路径文件不存在或者加载失败，如上所示的默认配置将被使用；3. /usr/share/data/adsp/blsp.config最好设置为只读模式。


## Reference
80-NA157-24  Low-Speed Peripherals Overview.pdf
80-NB849-1 Rev. J  APQ8074A PQ8074AB Device Specification.pdf
80-H9580-1-J_QUALCOMM SNAPDRAGON FLIGHT DEVELOPER GUIDE.pdf
80-NU767-1 G Linux BAM Low-Speed Peripherals Configuration and Debug Guide  .pdf