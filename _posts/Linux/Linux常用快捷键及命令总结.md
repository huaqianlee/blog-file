title: "Linux常用快捷键及命令总结"
date: 2014-12-21 20:10:01
categories:
- Linux Tree
- Misc
tags: Tools
---
　　或许我是一个geek范的人，又或许是想显得很有逼格， whatever， 反正我就喜欢Linux的命令行，喜欢黑黑的geek风，这样完全体现出了技术的酷炫。现将一些自己觉得很有用能让自己显得很牛的装X快捷键和指令总结如下，其中有一部分相当有用，使用后逼格瞬间提升，不信看文章最后的后记。

## Shell终端常用快捷键
　　当进行命令行操作时，使用快捷键将极大提高工作效率，如下：
```bash
Ctrl + U – 剪切光标前的内容
Ctrl + K – 剪切光标至行末的内容
Ctrl + Y – 粘贴
Ctrl + E – 移动光标到行末
Ctrl + A – 移动光标到行首
ALT + F – 跳向下一个空格
ALT + B – 跳回上一个空格
ALT + Backspace – 删除前一个单词
Ctrl + W – 剪切光标前一个单词
Ctrl + Insert – 复制
Shift + Insert – 粘贴
# 下面两个命令的用法，如： 在shell终端输入vi main.c进入vi界面后，想切换到命令行，可以通过Ctrl+Z
Ctrl + Z – 暂停应用程序
fg – 重新将程序唤到前台
```
<!--more-->
## 常用Shell命令
　　使用Linux，最酷炫的就是命令行操作，所以熟悉命令是必须，现将常用的Shell命令总结如下：

### 硬件相关命令
```bash
lscpu                   #查看的是cpu信息.
cat /proc/cpuinfo       #查看CPU信息详细信息
free -m                 #概要查看内存情况，单位MB  -g GB
cat /proc/meminfo       #查看内存详细信息
lsblk                   #查看硬盘和分区分布
df -h                   #查看各分区使用情况
cat /proc/partitions    #查看硬盘和分区
mount | column -t       #查看挂接的分区状态
lspci | grep -i 'eth'   #查看网卡硬件信息
ifconfig -a             #查看系统的所有网络接口
ethtool eth0            #如果要查看某个网络接口的详细信息，例如eth0的详细参数和指标
```

### 系统相关命令
-------------------------
#### 通用命令
```bash
cmd --help              #查看命令详细信息
man cmd                 #显示命令手册
whatis cmd              #查看命令简述
exit                    #退出终端
ping <remote host address> #ping网络状态
who                     #查看当前登陆用户名
su/sudo                 #获取管理员权限
su user                 #切换用户
uname                   #显示系统重要信息
shutdown -r             #关键并重启
```

#### 内核相关命令
```bash
uname -a                #查看版本当前操作系统内核信息）
cat /proc/version       #查看当前操作系统版本信息
cat /etc/issue          #查看版本当前操作系统发行版信息
cat /etc/redhat-release #同上
cat /etc/SuSE-release   #suse系统下才可使用
lsb_release -a          #用来查看linux兼容性的发行版信息
lsmod                   #列出加载的内核模块
```

#### 网络常用命令
```bash
ssh -l remote_username(root) remote_ip   #远程登录
scp -r dir/file (remote_username:)remote_ip:dir #从本地copy到远端
ifconfig                #查看所有网络接口的属性
iptables -L             #查看防火墙设置
service iptables status #查看防火墙状态
service iptables stop   #关闭防火墙
route -n                #查看路由表
netstat -lntp           #查看所有监听端口
netstat -antp           #查看所有已经建立的连接
netstat -s              #查看网络统计信息进程
netstat -at             #列出所有tcp端口
netstat -au             #列出所有udp端口
netstat -lt             #只列出所有监听tcp端口
```
#### 管理常用命令
```bash
top                     #查看系统所有进程的详细信息，比如CPU、内存等,信息很多！
df -lh                  #查看硬盘大小及使用率
mount                   #挂接远程目录、NFS、本地共享目录到linux下
hostname                #查看/修改计算机名
w                       #查看活动用户
id                      #查看指定用户信息
last                    #查看用户登录日志
cut -d: -f1 /etc/passwd #查看系统所有用户
cut -d: -f1 /etc/group  #查看系统所有组
crontab -l              #查看当前用户的计划任务服务
chkconfig –list         #列出所有系统服务
chkconfig –list | grep on #列出所有启动的系统服务程序
rpm -qa                 #查看所有安装的软件包
uptime                  #查看系统运行时间、用户数、负载    
/sbin/chkconfig --list  #查看系统自动启动列表
/sbin/chkconfig　–add　mysql #把MySQL添加到系统的启动服务组里面
```

#### 文件操作常用命令
```bash
ranger               #文件浏览系统，需要先安装ranger，超级方便，用了就知道
ls -lht                 #列出一个文件夹下所有文件及大小、访问权限
du -sh <dir>            #查看指定目录的大小 
du -lh <dir>            #查看指定目录及各文件的大小 
ln -s                   #建立软链接
ls -lh                  #以M为单位显示文件大小，去掉h，则单位为k
du -skh  file        #以M为单位显示文件大小 
rmdir <dir>          #删除目录
rm file              #删除文件
rm -r <dir>          #递归删除整个目录
cp (-r) source dest  #负责文件或文件夹
mv source dest       #移动或重命名文件文件夹
cat file             #查看file内容
tail (-n N) file     #查看文件末尾10行(N行)
less file            #分页查看文件, Ctrl+F 向前翻页   Ctrl+B 向后翻页
grep [option] "string" file #查找字符串 ,-i  不区分大小写
find <dir> -name file #查找文件,-iname 不区分大小写
split -l 300 large_file.log new_file_prefix  将文本文件分割为300行的n个新文件
split -b 10m server.log server_prefix    将二进制文件分割为10M的n个新文件
split -b 10m file.tar.gz file_   把文件file.tar.gz拆分成以“file_”为文件名前缀，大小为10M的文件
cat small_files* > large_file  合并拆分的文件
cat file_* > file.tar.gz   合并拆分的文件
```

#### 进程相关命令
```bash
htop                      #在终端以列表形式查看进程，需要安装htop，比ps好看好用太多了
pstree -p pid           #查看一个进程下的所有线程
pstree  -a              #显示所有进程的所有详细信息，遇到相同的进程名可以压缩显示。
ps -ef                  #查看所有进程
kill -9 pid             #杀死进程
kill all test           #杀死进程
kill -9 `pgrep test`    #杀死进程
./test.sh &             #使程序在后台运行
nohup ./test.sh &       #使程序在后台运行
```

#### 压缩解压缩 
```bash
gzip file1.txt file2.txt  #压缩文件 
gzip -d file1.txt #提取文件
zip -r dir.zip dir file  #将目录dir、文件file等压缩到zip包,
zip -re dir.zip dir file #创建zip包，且加密
unzip dir.zip            #解压
unzip -l dir.zip         #查看压缩包类容
tar -zcvf dir.tar.gz dir file    #将目录dir、文件file等压缩到tar包
tar -xvf dir.tar.gz       #解压
tar -tvf dir.tar.gz          #查看压缩文件
```

#### screen 命令
```bash
#screen命令，screen命令运行的服务不受shell终端影响，即使shell终端关闭仍存在
screen -S test          #创建一个名字为test的screen
screen -r test          #打开名字为test的screen
screen -r pid           #打开进程号为pid的screen
screen -ls              #列出所有的screen
ctrl + a,d              #当在一个screen时，退出screen
ctrl + a,n              #当在一个screen时，切换到下一个窗口
ctrl + a,c              #当在一个screen时，创建一个新的窗口
```

#### 远程拷贝
```bash
scp local_file remote_username@remote_ip:remote_dir    #拷贝本地文件到远程机器上
scp -r local_dir remote_username@remote_ip:remote_dir  #拷贝本地整个目录到远程机器上
```

### 软件包安装
　　如下为Ubuntu下的是命令，如果账户没有root权限的话，需要在前面添加sudo以获取root权限。其实不知道命令的话，只需要输入软件名，终端将会打印出下载安装的命令。
```bash
apt-get install package     #安装
apt-get update package      #更新
apt-get remove package      #删除    
apt-cache search package    #搜索软件包
dpkg -i package.deb         #安装deb包
```


## 后记
　　为了让大家相信使用了这些命令或快捷键确实会逼格提升，专门贴图两张，哈哈。。。
### 图一 执行htop（进程管理）
![htop](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/bloghtop.png)
### 图二 执行ranger （文件浏览）
![ranger](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/blogranger.png)

　　有很多命令引用自[Linux常用的shell命令](http://www.xprogrammer.com/1799.html)，感谢此文作者.
