title: "高通 PMIC 架构简析"
date: 2015-06-24 21:53:03
categories: Android
tags: [源码分析,Qualcomm]
---
> pmic ic: pm8916     80-NL239-4_A_MSM8916_PMIC_SW_Driver_Overview.pdf　
 

## PMIC IC PM8916 overview
### pmic device is classified into the following functionalities 
```bash
a . input power management
b . output power management
c . genera housekeeping
d . user Interface 
e . IC Interface 
f . configurable pins - functions within other categories(Multipurpose pins (MPP) and General Purpose Input Output (GPIO)).
```

<!--more-->
### pm8916 functional block diagram
![hw](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/pmicd1.jpg)


### boot architecture
![boot_arch](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/pmicd2.jpg)
     
RPM - resource power manager

![rpm](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/pmicd3.jpg)



## Software Architecture
### Linux PMIC software architecture
![sw_arch](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/qcom/pmicd4.png)

