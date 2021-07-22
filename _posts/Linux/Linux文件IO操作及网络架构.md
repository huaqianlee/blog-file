title: "Linux文件I/O操作及网络架构"
date: 2014-11-17 20:15:42
categories:
- Linux Tree
- Misc
tags: [kernel,文件IO,网络]
---
图片摘自网络，这些图片清晰的描述出了文件I/O和网络操作的脉络。
<!--more-->
##网络交互模型
![网络交互模型](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/blog网络交互模型.jpg)

##read-recv-recvfrom
![read-recv-recvfrom](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/blogread-recv-recvfrom.jpg)

##write-send-sendto
![write-send-sendto](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/blogwrite-send-sendto.jpg)

##socket-bind-listen-accept-close-connect
![socket-bind-listen-accept-close-connect](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/blogsocket-bind-listen-accept-close-connect.jpg)
