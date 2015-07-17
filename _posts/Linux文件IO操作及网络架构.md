title: "Linux文件I/O操作及网络架构"
date: 2014-11-17 20:15:42
categories: Linux
tags: [kernel,文件IO,网络]
---
图片摘自网络，这些图片清晰的描述出了文件I/O和网络操作的脉络。
<!--more-->
##网络交互模型
![网络交互模型](http://7xjdax.com1.z0.glb.clouddn.com/blog网络交互模型.jpg)

##read-recv-recvfrom
![read-recv-recvfrom](http://7xjdax.com1.z0.glb.clouddn.com/blogread-recv-recvfrom.jpg)

##write-send-sendto
![write-send-sendto](http://7xjdax.com1.z0.glb.clouddn.com/blogwrite-send-sendto.jpg)

##socket-bind-listen-accept-close-connect
![socket-bind-listen-accept-close-connect](http://7xjdax.com1.z0.glb.clouddn.com/blogsocket-bind-listen-accept-close-connect.jpg)
