title: Ubuntu 卡死了怎么办？
date: 2019-11-25 22:42:53
categories:
- Linux Tree
- Misc
tags: Issues
---
在使用 Ubuntu 的时候，有时候会遇到卡死的问题，然后电脑完全不能使用。这时候怎么办呢，我通常是通过如下两种方式进行处理：  

## `Kill process`

当我们明确知道什么进程导致系统卡死的时候，譬如文件管理器，我们可以通过如下两种方式进入字符终端找到假死的进程然后 kill 掉。  
1. `Ctrl + Alt + F1` 进入，`Ctrl + Alt + F7`  回到 UI 。
2. `ssh user@ip` 远程登入。

杀死进程的方式，我常用的有三种，如下：
1. `Top` 或者 `htop` 找到造成假死的进程并 `kill`。
2. 通过名字或者进程 PID 去杀进程。
```bash
ps -A |grep nautilus  # 查看文件管理器的 PID
kill PID

# 以名字的形式杀掉进程
killall nautilus 
```

## `Log out`

注销桌面重新登录：  
```bash
sudo pkill Xorg
或者
sudo restart lightdm
```