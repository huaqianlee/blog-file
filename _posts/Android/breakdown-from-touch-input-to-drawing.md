title: APP 启动，触摸事件和 UI 绘制的简单分析示例
date: 2020-10-10 23:17:21
categories: Android
tags: Performance
---

“雨过留痕，雁过留声”的第二篇：APP 启动，触摸事件和 UI 绘制的简单分析示例，此文通过 systrace 分析一个示例 APP 的启动、触摸事件和 UI 绘制的流程和时间消耗。本文的示例 APP （[SimpleApplication.apk](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/SimpleApplication.apk)）只有一个简单的按钮， 点击按钮时会改变屏幕的颜色。同样因为没有深入研究 Performance 相关内容，所以保留出错的权利。
> 如果对第一篇感兴趣，请查看： [Android 性能调试手册](http://huaqianlee.github.io/2020/10/10/Android/performance_debug_guide.html).

# 0. 写在开头

我一开始看到 systrace 文件时，是一脸懵逼的，所以在开始正文之前先简单说一下 systrace 文件中的一些基本信息，如下：

- `Frames`: 一个圆圈代表一帧。  
    + 绿色：正常；
    + 黄色、红色： 异常，如卡顿、掉帧(Jank) 等，可能是它的渲染时间超过了 16.67ms（60fps）。
    + 点击圆圈可查看详细信息
- `Alerts`: 右侧标签,跟踪记录中出现的问题以及这些问题导致出现卡顿的频率
- `system_server  iq`: 第一帧的触发
- `gfx3d_clk` : GPU 频率
- `iq in systemsever` : 触发中断
- `bindApplication, activityStart ...`： 表示冷启动， 热启动不会有这些信息。
- `surfaceflinger`->`UI Thread`->`HIDL::IComposerClient:setPowerMode_2_2:client`: 代表 LCD 上电时间  
> 一般使用 Chrome 打开 systrace.html， 右上角的 `？`  也可以提供一些基本的帮助

# 1. 获取 systrace

```bash
a. python systrace.py gfx input view sched am wm dalvik freq idle power video app -b 40960 -t 10 -o traceout.html

Explaination of these categories:
gfx - Graphics
input - Input
view - View System
wm - Window Manager
am - Activity Manager
hal - Hardware Modules
res - Resource Loading
dalvik - Dalvik VM
power - Power Management
sched - CPU Scheduling	
freq - CPU Frequency
idle - CPU Idle

b. Motion: Click icon of SimpleApplication to open it, click first time to change background as white, click sencond time to change background as black.
```

<!--more-->

# 2. 找到点击事件														
														
查看 `system_server` 的 `iq` 去定位点击事件发生的时间，如下：
														
![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image1.png)														
														
查看 InputResponse 确认点击事件，如下：

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image2.png)

# 3. 查看 UI thread 和 Frames
	
粗略看一下 `Frames`，发现有一个红色的 frame，红色表示 jank， 即卡顿。

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image3.png)

上诉红点也就是代表帧率少于了 60 fps，我们需要去点击红色的圆点查看详细信息，并查看下 `UI thread`，看看是否有无用的耗时或者阻塞发生。此案例中有 11 ms 左右的 sleep，如下：

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image4.png)
									
														
# 4. 查看线程状态													
														
## 4.1 Orange: Uninterruptible sleep, I/O Block														
	
此状态表示线程正在等待硬盘 I/O 操作完成，如果有太多的橙色阻塞状态，通常存在低内存的问题。此案例中阻塞状态很短，判断为正常状态，如下：

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image5.png)

## 4.2 Blue: runnable														

表明线程处于可运行状态，等待 CPU 调度。如果线程处于可运行状态时间太长，通常 CPU 忙于调度，需要查看这些时间 CPU 忙于哪些任务。比较常见的问题场景如下：

- 后台任务太多。
- CPU 被限频。
- 任务运行于特定的 cpuset，而此 CPU 已经满载。

此案例中处于可运行状态的时间很短，如下：

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image6.png)


## 4.3 Green: running														

接下来查看下线程的运行的时间，如果耗时异常，通常需要注意如下场景：
- 是否被限制频率。
- 线程跑在大核上还是小核上。
- 是否频繁切换线程状态。
- 此线程是否运行在错误的核上面。

此案例中线程运行在大核上，即频率最高的 CPU7，亦无其他异常，如下：
![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image7.png)

## 4.4 White: Sleeping

此状态表示线程无事可做，处于休眠状态，一个概率比较大的情况是被　mutex 阻塞。

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image8.png)

## 4.5 Summary														

如上所示，我们可以看到大部分时间是消耗在运行状态，且没有频繁切换状态，所以这部分问题不是太大，当然如果想要追求更佳的性能，我们可以针对上面说的场景做更深入的调查。

# 5. 启动时间														
														
从系统角度来看，在 `Activity` 完成 `onCreate/onStart/onResume`阶段后，`ViewRootImpl` 将调用两次 `performTraversals` 去初始化 Egl、measure、layout、draw等，最后完成界面显示。

个人认为很难在 systrace 中获得准确的 APP 启动时间，但是我们可以在 activityResume 之后选择一个点来估算相对准确的时间。如下：

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image9.png)

Launcher 调用 startingWindow 去等待第一帧的绘制，如下：

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image10.png)

在如下指定位置，第一帧绘制已经完成。										

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image11.png)

在 SystemSever 中查看绘制流程。

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image12.png)
														
# 6. systrace 中的 input
														
InputReader 获取 input 事件，然后移交给 InputDispatcher. InputDispatcher 再将输入事件传递给对应的 App，然后请求 Vsync 去绘制第一帧。
- InputReader 负责从 EventHub 读取 Input 事件，然后将其移交给 InputDispatcher 进行事件分发。
- InputDispatcher 打包并分发事件。
- OutboundQueue 存有将分派到相应 AppConnection 的事件
- WaitQueue 记录已分派到 AppConnection，但 App 仍在处理尚未返回处理成功的事件。 如果主线程 freezed 而无法处理输入事件，则 WaitQueue 的值将递增。
- PendingInputEventQueue 记录应用程序需要处理的 Input 事件。
- deliveryInputEvent 标识被输入事件唤醒的 App UI 线程。

## 6.1 Input response

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image13.png)

## 6.2 OutboundQueue and WaitQueue

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image14.png)

## 6.3 Native threads which Reads and dispatchs input event

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image15.png)

## 6.4 PendingInputEventQueue

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image16.png)
![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image17.png)


## 7. 查看 CPU 信息

主要检查 CPU 使用率、C-stage、时钟频率和时钟频率的限制，以及每个核正在跑什么应用。SimpleApplication 主要运行在大核 cpu7 上，有时运行在中核上， 都是最大频率。所以 CPU 部分没有什么问题。

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image18.png)

# 8. 第一次点击事件

前面主要是通过全局视图和启动视图来分析 systrace，下面将分析单击事件。但是我将跳过与前面类似的分析步骤， 只重点查看一些可能会影响 UI 切换速度的差异点。

## 8.1 CPU 情况
												
SimpleApplication 在现阶段也主要运行在大核 cpu7 上且以最大频率运行，但是部分时间运行在限频状态下的大核和中核，如果需要对其进行优化，这是需要考虑的一点。

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image19.png)
			
## 8.2 UI thread

第一次单击时睡眠太久，也许这是一个可以优化的点。

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image20.png)

# 9. 结论	

## 9.1  启动阶段
- 存在卡顿，可能需要查看下是否存在异常的耗时或阻塞的代码。
- UI 线程的状态还不错，如果要提高性能，可以尝试检查下内存状态和后台任务。

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image21.png)

## 9.2 第一次点击事件														
- CPU 频率有在某些阶段被限制，我们可以尝试对其进行优化。
- 第一次点击时睡眠太久，也许这是一个可以优化的地方。 为了对其进行优化，我们需要检查 SimpleApplication 的代码，是否被互斥锁阻塞，等等。

![image](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/Performance/image22.png)