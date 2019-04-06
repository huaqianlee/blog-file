title: "PX4之外设代码结构及流程-IMU"
date: 2017-03-29 22:08:54
categories: Uav
tags: [PX4]
---
最新PX4的代码库有很大的改变，使用了一个轻量级的、统一的驱动抽象层：DriverFramework。 POSIX和 QuRT的驱动都写入这个驱动框架当中。

本文以MPU9250为例简单分析一下外设的相关代码，其余外设亦相似的。

## 代码结构及流程
最新代码库中，MPU9250的代码结构及流程如下：
   
 ![流程图](https://github.com/huaqianlee/blog-file/blob/master/image/uav/px4/IMU_CODE_STR.png)
<!--more-->
 sensor.cpp文件比较重要，Sensor数据的应用都要在此文件中实现，其中的主要方法如下：
 
![Sensor方法](https://github.com/huaqianlee/blog-file/blob/master/image/uav/px4/sensorcpp.jpg)

## 附 
以前px4是可以直接通过外部的库访问外设，新版本保留了原代码架构，但不清楚是否应用，怎么应用，路径如下：
```bash
-> src\platforms\qurt\fc_addon\
-> xxx_lib.so
```   

## 经验之谈
通过search搜关键字搜出内容太多时， 通过px4.config、mainapp.config等文件来筛选源代码。







   