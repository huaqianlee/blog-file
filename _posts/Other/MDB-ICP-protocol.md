title: "纸币器和MDB协议"
date: 2017-11-08 22:22:45
categories: Other
tags: Protocol
---
## MDB协议
### 简介
MDB/ICP协议为一个主从接口的串口通信标准的协议， 规定波特率为9600bps，总线有唯一主机（vending machine controller, VMC）和最多32个从机外设，每个外设设有唯一的地址和命令，且由主机初始化。

电源上电、总线复位或外设收到一个复位命令，所对应的外设都被禁止。在顺序初始化外设期间，VMC通过外设的应答来选择被外设所支持的特征。

>协议推荐所以主控制器VMC和外设都需支持所有低等级标准

<!--more-->

### 通信格式
#### 字节格式
一个字节定义为11位：1个起始位+8个数据位+1个模式位+1个停止位。
- VMC发送数据到外设：模式位 = 1 表示为地址字节， = 0 表示为数据字节
- 外设发送数据到VMC：模式位 = 1 表示所有字节发送完成

#### 块格式
##### 主到从
主控制器VMC发送给从机的数据格式：1个地址字节+n个数据字节+1个校验和节（最大不超过36个字节）。地址字节由 高5位外设地址+低三位外设命令组成。

主控制器响应外设时发送 ：ACK（应答）、NAK（不应答）、RET（重发）。5ms超时不响应相当于NAK。如从机5ms无响应，VMC应重发相同或不同命令， 知道从机响应或达到最大响应时间（硬币器2S、纸币器5S）。在此期间VMC应该同时访问其他外设。

**主控器VMC可以通过拉低发送线100ms以上对总线进行复位。**

#### 从到主
从机发送到主控制器的数据格式：1数据块+1字节校验和（最大不超过36字节）。

从机外设响应主控制器发送数据时，主控制器VMC在5ms无响应时间内必须响应ACK、NAK或RET。否则外设需要重发数据或者在下一次会话时附加上数据。

#### 校验和
校验和为所有地址及数据字节的累加和（不包含校验和字节）。

#### 总线复位
主控器VMC可以通过上拉激活发送线100ms以上对所有外设进行复位，复位后外设处于上电复位状态。

#### 一些标准
响应码：
```bash
ACK - 00H   RET - AAH   NAK -  FFH
```

外设地址：
```bash
Address             Definition  
-------------------------------------------------
00000xxxB    (00H)  Reserved for VMC 
00001xxxB    (08H)  Changer  
00010xxxB    (10H)  Cashless Device #1  
00011xxxB    (18H)  Communications Gateway 
00100xxxB    (20H)  Display  
00101xxxB    (28H)  Energy Management System 
00110xxxB    (30H)  Bill Validator  
00111xxxB    (38H)  Reserved for Future Standard Peripheral
01000xxxB    (40H)  Universal Satellite Device #1 
01001xxxB    (48H)  Universal Satellite Device #2 
01010xxxB    (50H)  Universal Satellite Device #3 
01011xxxB    (58H)  Coin Hopper or Tube - Dispenser 
01100xxxB    (60H)  Cashless Device #2
01101xxxB    (68H)  Reserved for Future Standard Peripherals
...
11011xxxB    (D8H)  Reserved for Future Standard Peripherals
11100xxxB    (E0H)  Experimental Peripheral #1
11101xxxB    (E8H)  Experimental Peripheral #2 
11110xxxB    (F0H)  Vending Machine Specific Peripheral #1 
11111xxxB    (F8H)  Vending Machine Specific Peripheral #2
```
