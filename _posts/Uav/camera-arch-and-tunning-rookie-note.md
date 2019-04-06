title: "camera架构与调试-菜鸟笔记"
date: 2016-07-07 23:37:41
categories: Uav
tags: Qualcomm 
---
>菜鸟笔记，因为对camera不是很了解，肯定会有很多疏漏，也会记录一些现在不是很明白的杂乱信息，以便以后知识面扩展了后看到有所帮助。由于自己没有耐心图片一张张重画,就直接拍下了自己手写笔记的照片,笔记图片中的字很丑，将就将就

##VFE
VFE为Video Front End的简写，这属于硬件部分，对于高通通过Chromatix 工具，可以产生对此流程有用的tuning file，用于配置。 VFE 流程图如下：
![VFE FLOW](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vfe.png)

<!--more-->
###MIPI
现在的camera基本都采用MIPI接口， MIPI以一种采用差分方式按位传输数据的接口。只有四条引脚（DN、DP，CN、CP）。

###数据
根据自己的理解我大致将VFE根据数据格式分为四个部分：
* Raw RGB（也称为Bayer RGB）
* Sensor RGB
* Image RGB
* YUV

#### Raw RGB
Raw RGB为原始数据，分为Qcom raw 和 mipi raw， 现在基本都使用mipi  raw，mipi raw数据1pixel为10bits的数据(1 chanel)，即将所有数据按位重新排列，图像的行列应该为4的倍数。如下：
![raw bits](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/raw%20bits.png)
##### 所有pixel图像数据构成按照如下规律排列（表格中为某种颜色的亮度值）：
![rgb_all](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/rgb_all.jpg)
GB： 指靠近B的G. 其余同理
#####Raw RGB数据构成规则按照下表方式排列，对角线可以两两兑换.
![rgb](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/rgb.png)
####Raw RGB 有四种排列方式，如下：
![rgb_4](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/rgb_4.jpg)

#### Sensor RGB
Sensor RGB为camera Sensor处理过的数据，即上流程图demosaic之后的数据，1 pixel 为 3 Chanel，现在基本都为888格式的 RGB 24bits数据。
Sensor RGB图像数据构成按如下排列：
![sensor_rgb](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/sensor_rgb.jpg)

####Image RGB
Image RGB是Sensor RGB通过color correction转变过来的，会按照三种不同光源强度乘以不同的矩阵得到不同的Image RGB，这三种光源强度为：
D65 - daylight color temp 为 6500k
TL  -   3800~4000k
A    -   2800k
> 后两种记不清楚了， 简单搜索了一下，没有在网上找到准确的资源，先这样写着

#### YUV
YUV，分为三个分量，“Y”表示明亮度（Luminance或Luma），也就是灰度值；而“U”和“V” 表示的则是色度（Chrominance或Chroma）。是与RGB类似的颜色编码方法，主要用于计算机端。由Image RGB通过gamma处理而来，如下：
![gamma_note](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/gamma_note.jpg)


###LSC
LSC即为Lens  shading correction， 其主要就是修正边角较暗的地方，如下笔记：
![lsc_note](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/lsc_note.jpg)

###BLC
BLC即为black level correction，主要处理暗电流，笔记如下：
![exposure_dc](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/exposure_dc.jpg)

###domain
domain分为spatial domain和frequency domain， 笔记如下：
![domain_note](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/domain_note.jpg)

###CPP
VFE模块完成后则会进入CPP模块，cpp模块主要有如下两部分：
* WNR - wavelet noise reduction
* ASF -  Auto special Filter （-> sharpness）
exposure index 和 gain index 是cpp模块的trigger condition



附  图片一般会经过4层曝光处理，chromatix工具
![exposure_note](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/exposure_note.jpg)

附 Chromatix Tool
driver_info.txt (等同于dts中的信息)， 通过chromatix产生tuning file（cpp项的 exposure index和gain index很可能源于此文件）


###Driver
驱动中图像处理，笔记如下：
![frame](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/frame.png)

现在的cmos基本都是使用rolling shutter， 方式如下：
![cmos_rolling_shutter](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/cmos_rolling_shutter.jpg)


####附 糊涂笔记
VT clock ---> banding  （50HZ/60HZ/AUTO/OFF --->app上的配置）
![stripe](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/stripe.jpg)


####driver_info.txt
Chromatix Tool会用到的一个Sensor info文件，内容与<root_dir>\mm-camera\mm-camera2\media-controller\modules\sensors\sensor_libs\imx214\imx214_lib.c 相关，
```info
1. max frame rate  ---> depends on sensor register and project
2. min line count ---> value = 1, depends on sensor property # 1 line * 1 pixel  clock * cloumnum = min exposure time
3. max line count in max fps. # max line count = FL - offset
4. max line count  ---> FL * (maxfps/minfps) - offset
5.raw image width
6. raw image height
7. bayer pattern
8.bits per pixel
9. packed or not ---> 1: mipi; 0: others,depend on sensor
10~13. crop ---> crop掉无效边，top、right、bottom、left.
14~16 blacklevel ---> 厂商单位 12bits  / 16(2的4次方) ->8bit
```
