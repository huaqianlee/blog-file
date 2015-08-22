title: "Android中adb(Android Debug Bridge)命令的用法"
date: 2015-07-19 19:29:58
categories: Android
tags: [Tools,译文]
---
　　昨天写Android日志系统相关博客时发觉自己对adb命令认知十分不够，所以特意去[http://developer.android.com/tools/help/adb.html](http://developer.android.com/tools/help/adb.html)学习了一下,今天准备按照自己的理解加以修改总结并整理出一篇博文。

##概览
　　adb是Android Debug Bridge的简写，按字面意思理解就是在开发者和Android之间搭建的一个debug桥。adb是一个连接仿真实例或者Android设备的命令行工具，是一个客服端-服务器模式的程序，包括如下三部分：
　
　　1. 一个运行在开发用的Android手机或者仿真器上面的client，我们可以通过adb命令调用client。其他像ADT插件和DDMS也会创建client。
　
　　2. 一个运行在开发用的Android手机或者仿真器后台的server，这个server负责管理本设备上运行的client和daemon(守护进程)。
　
　　3. 一个在每个仿真器或者Android设备后台运行的daemon。
>adb tool 可以再<sdk>/platform-tools/中找到　

<!--more-->
##adb工具的构成关系
　　当启动adb client时，client会检查是否有server在运行，若无则启动一个server进程。server进程启动后，会绑定到TCP端口号为5037的端口，然后监听从adb clients发送来的命令（所有adb clients 使用同一端口5037与server通信）。然后，server通过扫描手机或仿真器用到的5555到5585之间的奇数端口号，在所有运行的实例之间建立连接。server在发现adb daemon的地方为那个端口建立连接。每个仿真器或者设备需给console连接提供一个偶数端口号，为adb连接提供一个奇数端口号。例如：
```bash
Emulator 1, console: 5554
Emulator 1, adb: 5555
Emulator 2, console: 5556
Emulator 2, adb: 5557
and so on...
```
>当server为所有仿真器创建了连接后,我们可以通过adb 命令进入这些实例,而且可以从任何client(或者script脚本)控制所有的仿真器.　

##adb调试
　　首先需要同USB将电脑和设备相连,然后在开发者模式中打开USB debugging。4.2以上的系统默认都是隐藏了开发者模式，所以需要去到**Setting>About phone>**菜单下点击**Build number**七次以显示开发者模式,然后到开发者模式菜单下打开USB debugging。

##语法
　　我们能通过设备的命令行(shell终端)或者script脚本发出adb命令。用法如下：
```bash
adb [-d|-e|-s <serialNumber>] <command>
```
>如果仅仅一个仿真器或设备被连接,这adb命令将自己发送本机.如果有多个的话,需要用-d -s 或 -e来指明目标设备.　

##adb命令详解
　
####目标设备
```bash
-d      #指向连接的USB设备,如果USB设备超过一个则返回错误
-e      #指向运行的仿真器,如果超过一个仿真器则返回错误
-s<serialNumber>  #指向指定的仿真器或设备,如emulator-5556,详见下查询仿真器或设备
```
　
####通用
```bash
devices   #打印所有连接的仿真器或设备,见下查询仿真器或设备
help    # 打印所有adb命令
version   #打印adb工具的版本号
```
　
####调试
```bash
logcat [option] [filter-specs]    #打印log
bugreport      #打印dumpsys,dumpstate及logcat日志
jdwp       #打印设备上的可用JDWP进程,可通过jdwp:<pid>连接指定JDWP进程,如:
                adb forward tcp:8000 jdwp:472
                jdb -attach localhost:8000|
```
　
####数据
```bash
install <apk>          #安装apk到仿真器或设备
pull <remote> <local>   #拷贝指定文件到PC
push <local> <remote>   #拷贝指定文件到设备
```
　
####端口和网络
```bash
forward <local> <remote>    #指定socket连接的PC端口号,仿真器或设备端口号,如下:
                                tcp:<portnum>
                                local:<UNIX domain socket name>
                                dev:<character device name>
                                jdwp:<pid>
ppp <tty> [parm]...  #通过USB运行PPP,不应该无故打开PPP连接
```
　
####脚本语言
```bash
get-serialno   #打印adb实体序列号,见下查询仿真器或设备
get-state    #打印仿真器或设备adb状态
wait-for-device     #阻塞程序直到设备online

#可以在后面添加其他命令,这样等设备以上线就执行,如下
adb wait-for-device shell getprop # 一连上就getprop
adb wait-for-device install <app>.apk #一连上就安装app
```
　
####Server
```bash
start-server  #检查是否有server运行,若无,则启动
kill-server   #终止server进程 
```
　
####Shell
```bash
shell #为仿真器或者设备打开一个远程shell终端,exit退出
shell [shellCommand] #打开一个远程终端,执行某指令后退出
```

###查询仿真器或者设备
　　在执行adb命令前,我们可以通过命令去查看仿真器或设备的连接清单，命令如下:
```bash
adb devices
```
　　执行这个命令后，adb将打印每个实例的状态信息：
- Serial number ：adb通过仿真器或设备的console端口号创建的一个独一无二的字符串，格式为“type-consolePort”，如：emulator-5554
　
- State ： 实例的连接状态，如下：　
 + offline ：未连接或没回应
 + device ：实例连接到adb server，不过并不意味着Android完全启动可操作的，因为文件系统启动过程中，adb也可连接
 + no device ：未连接

　每个实例的输出如下：
```bash
[serialNumber] [state]

#eg
adb devices
List of devices attached
emulator-5554  device
emulator-5556  device
emulator-5558  device
```
###发送命令到指定仿真器或设备
　　如果有多个仿真器或者设备同时运行，我们必须通过指定一个目标，否则将报错。我们可以通过-s来指定，用法如下：
```bash
adb -s <serialNumber> <command>  #serialNumber可以用adb devices查看

#eg
adb -s emulator-5556 install helloWorld.apk
```
　　如果有多个实例有效，只有一个仿真器，我们可以通过-e来指定仿真器。反之，若只有一个Android 设备，我们可以同-d来指定。

###安装app
　　adb工具提供了从pc拷贝apk并安装到指定仿真器或设备的命令，不过必须指定.apk文件的路径，如下
```bash
adb install <path_to_apk>
```
>Android studio/Eclipse也是通过adb安装apk的，不过其ADT插件已经封装了这个过程

###端口转发
　　我们可以用forward命令设置任意端口为forwarding端口，转发指定主机端口到仿真器或设备上的一个不同端口。也能设置转发到抽象的UNIX域sockets，如下：
```bash
adb forward tcp:6100 tcp:7100 #设置主机端口6100转发到目标端口7100

adb forward tcp:6100 local:logd 
```

###导入导出文件
 　　我们可以通过pull命令从仿真器或设备导出任意路径的文件，通过push导入文件到仿真器或设备的任意路径，如下：
```bash
#remote 仿真器或设备文件路径 local PC文件路径
adb pull <remote> <local> #导出文件
adb push <local> <remote> #导入文件
```

##通过无线使用adb
　　虽然我们通常连接USB来使用adb，但是我们也能通过WiFi来使用。
1. 让Android设备与PC处于同一WiFi网络环境，不过并不是所有的接入点都能成功，我们需要防火墙配置正确来支持adb。
　
2. 通过USB连接设备与PC。
　
3. 确定PC上adb运行在USB模式
```bash
$ adb usb
restarting in USB mode
```
4. 通过USB连接到设备
```bash
$ adb devices
List of devices attached
######## device
```
5. 重启PC adb,运行在tcpip模式
```bash
$ adb tcpip 5555
restarting in TCP mode port: 5555
```
6. 找到Android设备的ip地址, Settings -> About tablet -> Status -> IP address。
　
7. 连接设备
```bash
$ adb connect #.#.#.#
connected to #.#.#.#:5555
```
8. 移除USB线，确认设备连接
```bash
$ adb devices
List of devices attached
#.#.#.#:5555 device
```
如果连接丢失：
1. 确认PC机与Android设备是否处于同一WiFi网络环境。
2. 通过adb connect重现连接。
3. 重启adb host
```bash
adb kill-server
adb start-server
```
##其他命令
　　虽然官方文档已经介绍得挺详细了，但还是有一些命令没介绍到，如下：
```bash
adb uninstall <package name> #卸载指定app，参数为包名
adb uninstall -k <package name>   #卸载指定app，保留配置文件和缓存
adb shell dumpsys activity #列出activity栈(back stack)和任务(task)及其他组件信息和进程信息
adb shell dumpsys packages #(若出错，则dumpsy)列出一些系统信息和所有应用的信息。包括Features，Activity Resolver Table等。
adb shell pm list permissions #列出目标实例的所有权限
adb shell pm list packages  #列出目标设备上安装的所有app包名
adb shell pm list features  #列出目标设备上的所有feature

#使用adb命令启动一个Activity
adb shell am start PACKAGE_NAME/ACTIVITY_IN_PACKAGE  
adb shell am start PACKAGE_NAME/FULLY_QUALIFIED_ACTIVITY    
#eg 
adb shell am start -n me.huaqianlee.example/.MainActivity  
adb shell am start -n me.huaqianlee.example/me.huaqianlee.example.MainActivity

adb shell screencap -p | perl -pe 's/\x0D\x0A/\x0A/g' > screen.png #屏幕截图, 并使用perl命令保存截图

adb shell input keyevent 82 #解锁屏幕
```