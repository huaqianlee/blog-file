title: "Linux内核完全注释之80x86内存管理"
date: 2017-03-24 22:28:51
categories: Linux
tags: Linux内核完全注释
---
[Linux内核完全注释PDF下载](http://pan.baidu.com/s/1kVgED6n)

如下图所示，80x86从逻辑地址到物理地址变换使用分段和分页两种机制。
![](http://7xjdax.com1.z0.glb.clouddn.com/linux/book/add_change.png)
<!--more-->
![](http://7xjdax.com1.z0.glb.clouddn.com/linux/book/addr_resolution.png)

如果没有开启分页机制，则处理器会直接将线性地址映射到物理地址。分段机制用来完成虚拟（逻辑）地址到线性地址的转换，分页主要用来将线性地址（很多时候比物理地址大，让应用编程不用受内存空间限制）转换到物理地址。段描述符等会存于硬盘等存储介质，物理地址由其决定获得。

分段机制、分页机制应用如下：
![](http://7xjdax.com1.z0.glb.clouddn.com/linux/book/vir_addr_map.png)

![](http://7xjdax.com1.z0.glb.clouddn.com/linux/book/line_phy.png)
每个页面固定 4KB大小，并且对齐于4K地址边界。因此 x86 4GB被划分为2^20（1M）个页面。        
Linux0.11中 把每个进程最大可用虚拟内存空间定义为64MB，因此每个进程的逻辑地址加上 任务号*64MB（Linux0.11中算出来范围约为8G，最大任务数126，但人工定义为64个即4G），即可转换为线性空间中的地址。
每个进程代码在逻辑空间分布如下：
![](http://7xjdax.com1.z0.glb.clouddn.com/linux/book/progress_add.png)
