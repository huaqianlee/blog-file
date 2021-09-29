title: "MIPI CSI 接口定义与协议层介绍"
date: 2021-09-22 12:49:10
categories:
- Multimedia
- Camera
tags: MIPI
---

在大数据早已普及的今日，尤其随着 5G 技术和移动设备的逐渐普及，各种有线或无线的传输技术也迎来了迅猛发展，内容日新月异、错综复杂，你又能窥探其中多少呢？本文将简单介绍高速影音传输技术 MIPI， 主要基于 CSI-2 。

MIPI（Mobile Industry Processor Interface， 移动产业处理器接口） Alliance， 即 MIPI 联盟发起并为移动应用处理器制定了开放标准和一种规范。主要是手机内部的接口（摄像头、显示屏接口、射频/基带接口）等标准化，从而减少手机内部接口的复杂程度及增加设计的灵活性。MIPI 联盟下面有不同的工作组，分别定义的一系列接口标准，比如 CSI（Camera Serial Interface， 摄像头串行接口）、DSI（Display Serial Interface，显示串行接口）、DigRF（射频接口）、SLIMBUS（麦克风、喇叭接口）等，其优点是更低功耗，更高数据传输数量和更小的空间。

# Definitions and Acronyms

<!-- more -->

| Name                  | Description                                                                                                    |
| --------------------- | -------------------------------------------------------------------------------------------------------------- |
| Lane                  | A unidirectional, point-to-point, 2- or 3-wire interface used for high-speed serial clock or data transmission |
| Packet                | A group of bytes organized in a specified way to transfer data across the interface                            |
| Payload               | Application data only – with all sync, header, ECC and checksum and other protocol-related information removed |
| SLM（Sleep Mode）     | a leakage level only power consumption mode                                                                    |
| VC（Virtual Channel） | Multiple independent data streams for up to four peripherals                                                   |
| BER                   | Bit Error Rate                                                                                                 |
| CCI                   | Camera Control Interface                                                                                       |
| CIL                   | Control and Interface Logic                                                                                    |
| CRC                   | Cyclic Redundancy Check                                                                                        |
| CSI                   | Camera Serial Interface                                                                                        |
| CSPS                  | Chroma Shifted Pixel Sampling                                                                                  |
| DDR                   | Dual Data Rate                                                                                                 |
| DI                    | Data Identifier                                                                                                |
| DT                    | Data Type                                                                                                      |
| ECC                   | Error Correction Code                                                                                          |
| EoT                   | End of Transmission                                                                                            |
| EXIF                  | Exchangeable Image File Format                                                                                 |
| FE                    | Frame End                                                                                                      |
| FS                    | Frame Start                                                                                                    |
| HS                    | High Speed; identifier for operation mode                                                                      |
| HS-RX                 | High-Speed Receiver                                                                                            |
| HS-TX                 | High-Speed Transmitter                                                                                         |
| I2C                   | Inter-Integrated Circuit                                                                                       |
| JFIF                  | JPEG File Interchange Format                                                                                   |
| JPEG                  | Joint Photographic Expert Group                                                                                |
| LE                    | Line End                                                                                                       |
| LLP                   | Low Level Protocol                                                                                             |
| LS                    | Line Start                                                                                                     |
| LSB                   | Least Significant Bit                                                                                          |
| LSS                   | Least Significant Symbol                                                                                       |
| LP                    | Low-Power; identifier for operation mode                                                                       |
| LP-RX                 | Low-Power Receiver (Large-Swing Single Ended)                                                                  |
| LP-TX                 | Low-Power Transmitter (Large-Swing Single Ended)                                                               |
| MSB                   | Most Significant Bit                                                                                           |
| MSS                   | Most Significant Symbol                                                                                        |
| PF                    | Packet Footer                                                                                                  |
| PH                    | Packet Header                                                                                                  |
| PI                    | Packet Identifier                                                                                              |
| PT                    | Packet Type                                                                                                    |
| PHY                   | Physical Layer                                                                                                 |
| PPI                   | PHY Protocol Interface                                                                                         |
| RGB                   | Color representation (Red, Green, Blue)                                                                        |
| RX                    | Receiver                                                                                                       |
| SCL                   | Serial Clock (for CCI)                                                                                         |
| SDA                   | Serial Data (for CCI)                                                                                          |
| SLM                   | Sleep Mode                                                                                                     |
| SoT                   | Start of Transmission                                                                                          |
| TX                    | Transmitter                                                                                                    |
| ULPS                  | Ultra low Power State                                                                                          |
| VGA                   | Video Graphics Array                                                                                           |
| YUV                   | Color representation (Y for luminance, U & V for chrominance)                                                  |


# CSI-2 Brief

CSI-2 替 MIPI 定义了两种高速数据传输接口（物理层选项）和一组控制接口的标准。
- D-PHY 物理层选项
- C-PHY 物理层选项
- CCI(Camera Control Interface)

## D-PHY
MIPI 联盟定义的常见的 D-PHY 接口支持高速（HS）和低速（LP）模式，为 1 路单向差分接口，分为：
- 2 组差分时钟（clk）
- 1 或者多组差分数据通道（data lanes)

![D-PHY CSI](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/D-PHY_CSI.png)

## C-PHY

另一种常见的 C-PHY 接口，为 1 或多路单向 3-wire 串行数据通道， 每路有自己的时钟。

![C-PHY CSI](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/C-PHY_CSI.png)

## M-PHY

聊到了 C-PHY 和 D-PHY，也顺便提一下 M-PHY， M-PHY 目前接触比较少, 其在功耗和性能方面有更多的考量，三种 PHY 的特性如下：

![PHY-Chars](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/PHY-Chars.png)

## CCI

参见如上两幅图片的 CCI 部分。D-PHY 和 C-PHY 的 CCI 接口是一组与 I2C 标准协议兼容的双向控制接口， 兼容 I2C 的高速模式（400 KHZ）和 7 位从设备地址，不支持多主设备模式。CCI 是 I2C 协议的一个子集，然后其在 I2C 上面定义了一个附加的数据协议层。详见 CSI-2 Spec。


# CSI-2 Layer Definitions

CSI-2 就协议的层级来看，大致可以分为 3 层：
- 物理层（PHY Layer）： 定义传输媒介、电器特性、IO 电路、同步机制、指定 SoT（Start of Transmission） 和 EoT（End of Transmission）信号等。如 M-PHY， D-PHY, C-PHY 等。
- 协议层（Protocol Layer）： 定义传输数据时，如何标记和交错多个数据流（Data Stream），以便接收端重建每个数据流。
- 应用层（Application Layer）： 对数据流进行处理，如分析，编解码。

![CSI2 Layer](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/CSI2_Layer.png)
 
# Multi-Lane Distribution and Merging

MIPI 会通过 CSI 的 LDF (Lane Distribution Function) 将数据平均且有序地分配到每一条 Lane。

D-PHY：

![D-PHY Distribution](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/D-PHY_Distribution.png)
![D-PHY Merging](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/D-PHY_Merging.png)

C-PHY:

![C-PHY Distribution](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/C-PHY_Distribution.png)
![C-PHY Merging](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/C-PHY_Merging.png)
 

# Multi-Lane Interoperability

一般会采用最通用硬件配置，譬如 D-PHY 的 4 组 Data Lan 和 1 组 Clock。但是有时也会存在发送端和接收端 Data Lan 不匹配的问题，如果使用不适当的配置，就会影响 MIPI 传输的性能。

譬如： M Lanes 的传输端， N Lanes 的接收端。

1. M <= N, 传输端小于等于接收端时，不会有性能问题。
![multi-lane n](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/multi-lane-n.png)

2. M > N, 传输断大于接收端时，就会有性能问题。
![multi-lane m](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/multi-lane-m.png)

# Protocol Layer

MIPI 协议层可以分为 3 级：
- 通道管理（Lane Management）： 将传输的数据流分配到一个或多个通道，并在接收端恢复原始数据流。
- LLP （Low Level Protocol）： 将数据里封装成不同形式的长包和短包。
- 封拆像素包（Pixel Packing/Unpacking）： 传输端将像素包拆为 bytes，接收端将 bytes 还原。

## Low Level Protocol

LLP （Low Level Protocol） 是一种面向字节、基于数据包的协议，支持使用短包和长包格式传输任意数据。主要特性如下：
- 8-bit
- 每 link 支持最多 4 个 VC （Virtual Channels）通道
- 数据的类型、像素深度和格式的描述符 （type，pixel depth and format）

## Packet Format

如下图所示，有长包和短包两种数据包结构，其格式和大小依赖于物理层的选择（D-PHY or C-PHY）。 每种物理层接口都是以退出低功耗状态（LPS， Low Power State）， 发送一个 SOT 短包作为开始，然后通过长包发送数据，最后以发送一个 EoT 短包，切换回低功耗状态为结束。

![llp overview](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/llp-overview.png)

### Long Packet Format
长包由 DT 值 0x10～0x37 进行标识， 详情见 Data Type(DT) 章节。

#### What does D-PHY Long Packet look like?

![D-PHY-LP](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/D-PHY-LP.png)

#### What does C-PHY Long Packet look like?
![C-PHY-LP](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/C-PHY-LP.png)

### Short Packet Format
D-PHY 和 C-PHY 的短包有一定的差异，短包与相应协议长包的包头（PH）相匹配，没有包脚（PF）和长包数据（Paket Filler）， 另需把包头的 WC 字段用短包数据替换，短包的数据由 DT 值 0x00～0x0F 标示。详情见 Data Type(DT) 章节。

对于帧同步短包，短包数据为帧号； 对于行同步短包，短包数据为行号；对于通用短包，短包数据为用户自定义。

#### What does D-PHY Short Packet look like?

![D-PHY-LP](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/D-PHY-SP.png)

#### What does C-PHY Short Packet look like?
![C-PHY-LP](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/C-PHY-SP.png)

## Data Identifier (DI)

DI 字节由 VC（Virtual Chanel) 和 DT (Data Type) 两部分组成。如下图：

![DI](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/DI.png)

## Virtual Chanel Identifier

虚拟通道标识符是为数据流中交错的不同数据流提供单独的通道，接收器会监控并拆分交错的数据流到合适的通道。 MIPI 联盟规定最多可以支持 4 路数据流，也就是 4 路 VC。外设中的虚拟通道标识符应该是可编程的，以允许主机处理器控制数据流的解复用方式。逻辑信道的原理如下图：

![VC](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/VC.png)

交错的数据流格式示例如下：

![Interleaved_Data](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/Interleaved_Data.png)
> 总共三组

## Data Type(DT)

DT 指定数据的格式和内容，支持最大 64 个 DT，总共有 8 种不同的类型，每种支持 8 个 DT，前两个类型代表短包，其余的代表长包。如下：

| Data Type    | Description                             |
| ------------ | --------------------------------------- |
| 0x00 to 0x07 | Synchronization Short Packet Data Types |
| 0x08 to 0x0F | Generic Short Packet Data Types         |
| 0x10 to 0x17 | Generic Long Packet Data Types          |
| 0x18 to 0x1F | YUV Data                                |
| 0x20 to 0x27 | RGB Data                                |
| 0x28 to 0x2F | RAW Data                                |
| 0x30 to 0x37 | User Defined Byte-based Data            |
| 0x38 to 0x3F | Reserved                                |

同步短包又分为帧同步和行同步：  

| Data Type    | Description                |
| ------------ | -------------------------- |
| 0x00         | Frame Start Code           |
| 0x01         | Frame End Code             |
| 0x02         | Line Start Code (Optional) |
| 0x03         | Line End Code (Optional)   |
| 0x04 to 0x07 | Reserved                   |

通用短包：  

| Data Type | Description                 |
| --------- | --------------------------- |
| 0x08      | Generic Short Packet Code 1 |
| 0x09      | Generic Short Packet Code 2 |
| 0x0A      | Generic Short Packet Code 3 |
| 0x0B      | Generic Short Packet Code 4 |
| 0x0C      | Generic Short Packet Code 5 |
| 0x0D      | Generic Short Packet Code 6 |
| 0x0E      | Generic Short Packet Code 7 |
| 0x0F      | Generic Short Packet Code 8 |

通用长包：  

| Data Type | Description                   |
| --------- | ----------------------------- |
| 0x10      | Null                          |
| 0x11      | Blanking Data                 |
| 0x12      | Embedded 8-bit non Image Data |
| 0x13      | Reserved                      |
| 0x14      | Reserved                      |
| 0x15      | Reserved                      |
| 0x16      | Reserved                      |
| 0x17      | Reserved                      |
> 接收端需要忽略 Null 和 Blanking Data 数据类型的包的内容， 空包（Null）没有任何意义，消隐包（Blanking Data）可以作为视频流帧之间的消隐行。
> 在帧的开头可能有 0 或多行嵌入数据，这部分被称之为帧头（FS），在帧的末尾可能有 0 或多行嵌入数据，这部分被称之为帧尾。如果行存在 Embedded 数据，则 DI 中需要包含其 DT。如下图：
> ![Embedded-Data](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/Embedded-Data.png)

## Error Correction Code (ECC) for D-PHY

包头的 ECC 允许纠正 DI 和 WC 的 1-bit 错误并为 D-PHY 检测 2-bit 错误，因此， ECC 的 D[7:6] 应该为 0。DI[7:0] 应映射到 ECC 输入的 D[7:0]，WC[7:0] 映射到 D[15:8]， WC[15:8] 映射到 D[23:16]。如下图：

![ECC Example](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/ECC-Example.png)

## Checksum Generation for C-PHY

![Checksum](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/Checksum.png)
> ECC 在 C-PHY 无效

## Packet Spacing

MIPI 数据包由 EoT， LPS， SoT 分隔开，在协议包之间必须有一个进入和退出 LPS（低功耗）的状态切换，称之为包间隔（Packet Spacing）。其不必是 8 位字的倍数，因为接收器将在下一个数据包的包头之前的 SoT 序列期间重新同步到正确的字节边界。

![Packet-Spacing](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/Packet-Spacing.png)

单包实例如下：
> 图中的 VVALID、HVALID和DVALID 为虚拟的帧同步(VSYNC)、行同步(HSYNC)和有效数据同步（DE，亦可称为数据使能信号）信号。

![Single-Packet](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/Single-Packet.png)

多包实例如下：  

![Multi-Packet](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/Multi-Packet.png)

从上图也可以看到，从 LLP 封包 Checksum、EoT、LPS、SOT，一直到 PH，正好处于行同步信号为低，这段区间就是每行的 Blanking 区间。

## Line and Frame Blanking

长包 EoF， 下一个长包 SoF，以及之间的 LPS 称之为 Line Blanking； 帧尾（FE）后的 EoT，下一帧帧头（FS）前的 SoT，以及之间的 LPS 称之为 Frame Blanking。

![Frame-Line-Blanking](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/Frame-Line-Blanking.png)

再从行同步和帧同步的角度，来看看帧尾和帧头之间的 LPS （VSYNC 区域），即 Frame Blanking，以及行尾行头之间的 Line Blanking，会更加容易理解。

![HSYNC-VSYNC-Blanking](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/HSYNC-VSYNC-Blanking.png)

## Frame and Line Synchronization Packets

帧头（FS）帧尾（FE）之间至少包含 1～n 个图像数据长包，0～n 个代表同步讯号的短包，也就是说行头（SoT）行尾（EoT）的短包是可以省略的。

## Frame Format Examples

YUV、RGB 和 RAW 数据的每一个长包包含 1 行图像数据。

通用帧格式实例如下，行头（SoT）行尾（EoT）的短包被省略，且帧头（FS）和第一个长包，以及最后一个长包和帧尾（FE）之间的 LPS 要尽可能的短，如下画圈部分。

![General-Frame-Format](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/General-Frame-Format.png)

数字隔行视频格式实例：

![Digital-Interlaced-Video](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/Digital-Interlaced-Video.png)

精确同步的数字隔行视频格式实例如下，未省略行头行尾的短包。

![Digital-Interlaced-Video-with-Accurate-Sync](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/Digital-Interlaced-Video-with-Accurate-Sync.png)

如下为高速模式下数据和时钟的关系图，可以清楚地了解到高低速序号， LPS 的转变过程。

![Data-Clock](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/Data-Clock.png)

## Data Interleaving

数据交错（Data Interleaving）主要有两种方式：1. 通过 DT 区分； 2. 通过 VC 区分。

### Data Type Interleaving

所有的包使用同一 VC，然后独立的 DT，共享帧头（FS）帧尾（FE）和行头（SoT）行尾（EoT）, 如下：

![Interleaved-Data-Transmission](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/Interleaved-Data-Transmission.png)

按包交错的格式如下：

![Packet-Interleaved-Transmission](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/Packet-Interleaved-Transmission.png)

按帧交错的格式如下：

![Frame-Interleaved-Transmission](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/Frame-Interleaved-Transmission.png)

### Virtual Channel Identifier Interleaving

每一个 VC 拥有自己的帧头（FS）和帧尾（FE），而且每一个 VC 还可以继续通过 DT 来扩展数据通路。

![VC-Interleaving](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/camera/VC-Interleaving.png)

# Data Formats

Primary 代表广泛采用的数据格式，MIPI 联盟规定发送端需要支持至少一个 primary 格式，接收端需要支持所有的 Primary 数据格式。

| Data Format                           | Primary | Secondary |
| ------------------------------------- | ------- | --------- |
| YUV420 8-bit (legacy)                 |         | S         |
| YUV420 8-bit                          |         | S         |
| YUV420 10-bit                         |         | S         |
| YUV420 8-bit (CSPS)                   |         | S         |
| YUV420 10-bit (CSPS)                  |         | S         |
| YUV422 8-bit                          | P       |           |
| YUV422 10-bit                         |         | S         |
| RGB888                                | P       |           |
| RGB666                                |         | S         |
| RGB565                                | P       |           |
| RGB555                                |         | S         |
| RGB444                                |         | S         |
| RAW6                                  |         | S         |
| RAW7                                  |         | S         |
| RAW8                                  | P       |           |
| RAW10                                 | P       |           |
| RAW12                                 |         | S         |
| RAW14                                 |         | S         |
| Generic 8-bit Long Packet Data Types  | P       |           |
| User Defined Byte-based Data (Note 1) | P       |           |

# Reference 
Specification for Camera Serial Interface 2 (CSI-2)。