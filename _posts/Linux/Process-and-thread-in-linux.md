title: "Process and thread in linux"
date: 2019-08-31 17:35:46
categories: Linux
tags:
---
> 没有太多时间去查看详细源代码，所以仍然有很多不清晰或者理解不到位的地方，后续将 Linux 相关知识学习得更深入的时候再来更新一次。  

# 进程与线程
在 Linux 中，进程和线程几乎没有什么区别，主要的区别就是线程共享同样的虚拟内存地址空间。对于 kernel 来说，进程和线程都是一个可运行的 task 。

线程创建函数 pthread_create() 会调用 clone(), 而进程创建函数 fork() 最终也是调用 clone()。我们查看[clone](https://linux.die.net/man/2/clone)函数的介绍时，可以看到 clone() 的参数 flags 用来指明子‘进程’和父‘进程’共享什么，所以可以说进程就是不共享任何东西的一个典型线程（一个不成熟的观点，不一定正确）。
![process_thread_to_task](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/linux/process_thread_to_task.jpeg)  
> 摘录线程库发展史：Linux threading libraries evolution: Linux Threads, NGPT, NPTL. The library is part of gilbc, programmer interface is POSIX pthreads.  


# 线程模型
<!--more-->
Linux 中的线程是 “1-1” 模型, 而不是 “1-N” 或者 “M-N” 模型。下面简单介绍一下线程模型。

## “1-1” 模型

将每个用户级线程映射到一个内核级线程（即 task）。
优点：
消耗更少的资源，比如内存（虚拟的和物理的）和 内核对象（object）。并且也会更少地上下文切换，从而提高性能，在理想情况下，当你拥有和运行线程一样多的处理器的时候，将可能几乎没有上下文切换。
缺点：
可能是延迟更大：如果池中的所有线程都忙，并且您添加了新的短任务，则可能需要等待很长时间才能开始执行。

## “1-N” 模型
将多个用户级线程映射到一个内核级线程,早期 OS 的线程实现方式。
优点: 
内核不干涉线程的任何生命活动和上下文切换。线程的管理在用户空间进行,因而效率比较高;
缺点: 
一个进程中的多个线程只能调度到一个CPU，这种约束限制了可用的并行总量，并且如果某个线程 block 了，其他线程都只能等着。

## “M-N” 模型
在线程池里，将 M 个用户线程映射到 N 个内核线程 (M >= N)，可以算结合上面两种方法的优势，但会牺牲一些额外的用户模式调度。





