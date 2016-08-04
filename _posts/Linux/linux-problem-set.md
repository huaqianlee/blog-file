title: "linux系统使用问题集"
date: 2016-01-04 21:40:23
categories: Linux
tags: 
---
##问题一 ubuntu 密码正确进不了系统
**现象：**
即使密码输入正确也不能进入系统。
**原因：**
设置环境变量时出错，影响到系统。
**解决：**
开机时按住shift 进入 recovery 模式，选第二个恢复模式，12.04的界面是fsck和root选项在同一页，先选fsck解除写限制（按下fsck后等几秒即可），再选root，vi /etc/profile， vi /etc/environment 恢复下环境变量，再重新登录。

<!--more-->

