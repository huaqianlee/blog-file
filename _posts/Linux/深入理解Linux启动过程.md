title: "深入理解Linux启动过程(译)"
date: 2015-08-21 21:23:41
categories: Linux
tags: 译文
---
>**第一篇完全译文，因为自己对技术和英文的热爱，所以决定翻译此文，水平有限，所以肯定会有不恰当的地方，欢迎移驾至原地址：http://www.ibm.com/developerworks/linux/library/l-linuxboot/**
注：因为想写一篇博文来阐述并理清Android启动的完全过程，发现了这篇文章，觉得写得十分好，帮我解答了很多疑惑。

##引言
Linux系统的启动过程由很多阶段组成，但是无论你是启动标准的x86桌面还是启动嵌入式PowerPC目标，许多流程都是惊人的相似的。这篇文章从初始化引导程序到第一个用户空间应用程序探索Linux启动进程。顺着这个流程，你将知道很多和启动相关的主题，比如：引导程序，内核解压, 初始RAM磁盘,以及其他Linux引导元素。
<!--more-->
早期，引导计算机启动需要插入一条带有引导程序的纸带或者手动控制带有地址/数据/控制开关的面板加载启动程序。今天的计算机
装备了简化启动进程的工具，不过并不一定使这个过程变得简单了。

我们先从Linux启动的顶层视图开始分析，以便你能有一个整体的认识。然后我们将回顾每一个分离的步骤。顺着这个流程的源码引用将帮助你浏览内核树结构，以便在以后深入分析。


##概述
图一将为你展示两万英里的视图。

**Figure 1. The 20,000-foot view of the Linux boot process**
![Figure 1](https://github.com/huaqianlee/blog-file/image/blogfigure1.gif)

当系统第一次启动或重启时，处理器将执行一个已知地方的代码。对应个人电脑，这个地方是存在主板上内存内的BIOS；对于嵌入式系统中的cpu，将会加载引导区去启动flash/ROM中已知地址的程序。无论怎样，结果是相同的。个人电脑提供了很多灵和性，BIOS必须觉得哪些设备是候补准备启动，稍后再详细讲。

当一个启动设备被发现，第一阶段引导程序被加载到RAM并执行。这一部分引导程序最大为512字节（1单位扇区大小），他的作用是去加载第二阶段引导程序。

当第二阶段引导程序被加载进RAM并执行，启动界面将被显示，并且Linux和可选的初始磁盘（临时文件系统）被加载进内存。当镜像被加载以后，控制权从第二阶段引导程序传递到内核镜像，内核镜像先自解压和初始化。在这一步，第二阶段引导程序将检查系统硬件，枚举硬件设备，挂载主设备，加载必须的内核模块。当这些完成时，用户空间的第一个程序(init)开始执行，这样就开始顶层系统初始化开始了。

上面这些是Linux启动的一个外壳，接下来我们开始更深层次的探索启动进程的细节。

##系统启动
系统启动依赖于引导Linux的硬件。在嵌入式平台，系统在启动或重启时会用到引导程序环境变量，比如：包括u-boot，redboot及lucent公司的MicroMonitor。嵌入式平台通常附带一个引导监视器。这些程序位于目标硬件的flash内存中一个特别的区域，为Linux内核镜像加载到flash内存提供方法，并在随后执行Linux内核。除了存储和启动Linux镜像外，引导监视器还会执行一些系统测试及硬件初始化。在一个嵌入式目标，引导监视器通常存在于第一步及第二步引导程序。

对于个人计算机，Linux从0xffff0地址的BIOS开始启动。BIOS的第一步是上电自检（POST）。上电自检的工作是检查硬件。BIOS的第二步是枚举和初始化本地设备。

鉴于BIOS的不同用途，BIOS主要由两部分组成：上电自检代码和运行服务。在上电自检完成后，上电自检代码从内存被清除，但是运行服务被保留并且对目标操作系统仍然有效。

要引导一个操作系统，BIOS运行时会按照CMOS的设置定义的顺序来搜索处于活动状态并且可以引导的设备。引导设备可以为软盘，CD-ROM，硬盘的分区，网络上的设备以及U盘。

Linux一般从MBR包含初级引导程序的硬盘启动。MBR是一个512字节的扇区，位于硬盘的第一扇区（0道0柱1扇区）。在MBR被加载到RAM中后，由BIOS去控制它。
```bash
提取MBR（主引导记录）

可以通过如下命令查看你的MBR：
# dd if=/dev/hda of=mbr.bin bs=512 count=1
# od -xa mbr.bin

dd命令：需要root权限，从/dev/hda（第一个集成驱动电路或IDE驱动器）中读取512字节内容并写到mbr.bin文件。
od命令：以hex和ASCII格式打印二进制文件
```

##第一阶段引导程序
初级引导程序位于512字节的MBR镜像，MBR镜像由一个小型分区表和代码组成（见Figure 2）。前446字节是初级引导程序代码，包括执行代码和错误信息。接下来的64字节是一个分区表，包含4个16字节的分区记录。MBR最后的两字节定义了一个magic数字（0xaa55）。这个magic数字用来校验检查MBR。

**Figure 2. Anatomy of the MBR**
![Figure 2](https://github.com/huaqianlee/blog-file/image/blogfigure2.gif)

初级引导程序主要就是找到并且加载第二阶段引导程序。其通过分区表寻找一个活动的分区。在找到一个活动的分区表后，其将扫描剩余的分区确定它们不是活动的。当这些被确定后，活动分区的启动启动记录将从设备加载到RAM并且执行。

##第二阶段引导程序
第二阶段引导程序其实叫着内核引导程序更加合适。因为其任务就是加载Linux内核和可选的初始磁盘。

在x86环境中，第一阶段和第二阶段引导程序结合一起叫着Linux引导程序（LILO）或者 GRand Unified Bootloader（GRUB）。因为LILO有一些在GRUB中已经被纠正的缺点，所有我们就分析GRUB。（如果想了解更多关于GRUB，LILO和相关主题的信息，请看文章最后的Resources）

GRUB最伟大的是其包含已知的所有Linux文件系统。GRUB不像LILO一样使用裸扇区，而能从ext2和ext3文件系统中加载Linux内核。它通过将两阶段的引导程序转换为三阶段的引导程序来实现此功能。第一阶段（MBR）启动能识别Linux内核镜像中包含的特殊文件系统的第1.5阶段引导程序。比如reiserfs_stage1_5（从Reiser日志文件系统加载） 或者 e2fs_stage1_5（从ext2或者ext3文件系统加载）。当第1.5阶段引导程序被加载并运行后，第2阶段引导程序就能被加载了。

```bash
CRUB阶段引导程序

/boot/grup路径包括第1阶段，第1.5阶段，以及第2阶段引导程序，以及一些交替引导程序（如：CR-ROMs 使用iso9660_stage_1_5）
```

随着第二阶段被加载，CRUB会根据需求显示一个可用的内核列表（定义在/etc/grub.con，以及/etc/grub/menu.lst和/etc/grub.conf的软连接）。你可以选中一个内核，并且可以用附加的内核参数改进它。另外，你还能通过shell终端命令行的方式手动控制整个启动过程。

```bash
GRUB中手动启动

通过grub命令行，你可以用initrd镜像启动一个指定的内核，如下：
grub> kernel /bzImage-2.6.14.2
  [Linux-bzImage, setup=0x1400, size=0x29672e]

grub> initrd /initrd-2.6.14.2.img
  [Linux-initrd @ 0x5f13000, 0xcc199 bytes]

grub> boot

Uncompressing Linux... Ok, booting the kernel.

如果你不知道需要启动的内核名字，只需要敲一个斜杠（"/"）并按Tab键。GRUB将显示内核镜像和initrd镜像列表。
```

第二阶段引导程序被加载进内存后，将查询文件系统，加载默认内核镜像和initrd镜像到内存。当所有镜像准备好后，将从第二阶段跳转到内核镜像。

##内核
随着内核镜像加载到内存并且从第二阶段引导程序获得控制权，内核阶段开始了。内核镜像不是一个可以执行的内核，而是一个被压缩的内核镜像。通常是用zlib工具压缩的一个zImage（被压缩的镜像，小于512kb）或者一个bzImage（大的压缩镜像，大于512kb）。在内核镜像的头部有一个小型程序routine，其做少量的硬件设置，然后自解压内核镜像并放到高端内存。如果存在初始磁盘镜像（initrd），routine将拷贝initrd以供稍后安装使用。然后routine将调用内核开始内核启动。

当bzImage（i1386的镜像）被调用，将从汇编程序“./arch/i386/boot/head.S”的start入口开始（见Figure 3）。这段程序做些基本的硬件设置然后调用“./arch/i386/boot/compressed/head.S”中的startup_32。startup_32设置一些基本的环境（如堆栈等），并且清除BBS（Block Started by Symbol - 以符号启始的区块）。然后调用一个c函数decompress_kernel（位于./arch/i386/boot/compressed/misc.c）解压内核镜像。当内核被解压到内存后，将调用另一个位于“./arch/i386/kernel/head.S”的startup_32函数。

```bash
decompress_kernel 输出

decompress_kernel函数执行时，通常会看到如下解压内核信息：

Uncompressing Linux... Ok, booting the kernel.
```

在这个新的startup_32函数（也叫清除程序或者进程0）中，会对页表进行初始化，并启用内存分页功能。然后会为任何可选的浮点单元（FPU）检测 CPU 的类型，并将其存储起来供以后使用。然后调用 start_kernel 函数（在 init/main.c 中），它会将您带入与体系结构无关的 Linux 内核部分。从本质上讲，这才是Linux内核的主要功能。

**Figure 3. Major functions flow for the Linux kernel i386 boot**
![Figure 3](https://github.com/huaqianlee/blog-file/image/blogfigure3.gif)

调用start_kernel函数之后，会调用一系列初始化函数来设置中断，执行进一步的内存配置，并加载初始RAM磁盘。最后将掉用kernel_thread（在arch/i386/kernel/process.c中）启动一个init函数，init函数是用户控件的第一个进程。最后，空闲进程将会开始执行并且进程调度器将获得控制权（当cpu调用cpu_idle后）。通过启用中断，抢占式的调度器就可以周期性地接管控制权，从而提供多任务处理能力。

在内核引导过程中，初始 RAM 磁盘（initrd）是由第 2 阶段引导程序加载到内存中的，它会被复制到 RAM 中并挂载到系统上。这个 initrd作为 RAM 中的临时根文件系统使用，并允许内核在没有挂载任何物理磁盘的情况下完整地实现引导。由于与外围设备进行交互所需要的模块可是 initrd 的一部分，因此内核可以非常小，但是仍然支持大量可能的硬件配置。在内核启动后，就可以正式装备根文件系统了（通过 pivot_root），此时会将 initrd 根文件系统卸载掉，并挂载真正的根文件系统。

initrd 函数让我们可以创建一个小型的 Linux 内核，其中包括作为可加载模块编译的驱动程序。这些可加载的模块为内核提供了访问磁盘和磁盘上的文件系统的方法，并为其他硬件提供了驱动程序。由于根文件系统是磁盘上的一个文件系统，因此 initrd 函数会提供一种启动方法来获得对磁盘的访问，并挂载真正的根文件系统。在没有硬盘的嵌入式目标中，initrd 可以是最终的根文件系统，或者也可以通过网络文件系统（NFS）来挂载最终的根文件系统。

##init进程
在内核被启动并初始化后，内核启动第一个用户空间应用程序。这是调用的第一个使用标准 C 库编译的程序。在此进程之前，还没有执行任何标准的 C 应用程序。

在桌面 Linux 系统上，启动的第一个程序通常是 /sbin/init。不过完全没必要这样，很少有嵌入式系统会需要使用 init 所提供的丰富初始化功能（通过 /etc/inittab 配置的）。很多情况下，我们可以直接调用一个简单的 shell 脚本来启动必需的嵌入式应用程序。

##总结
与 Linux 本身非常类似，Linux 的引导过程也非常灵活，可以支持众多的处理器和硬件平台。最初，为加载引导程序提供了一种简单的方法，不用任何花架子就可以引导 Linux。LILO 引导程序对引导能力进行了扩展，但是它却缺少文件系统的识别能力。最新一代的引导程序，例如 GRUB，允许 Linux 从多种文件系统（如从 Minix 到 Reiser）上进行引导。

##Resource
>这部分就不翻译了，安心当一个大自然的搬运工，不过将所有链接都做上去了的。

**Learn**
* [Boot Records Revealed](http://mirror.href.com/thestarman/asm/mbr/MBR_in_detail.htm) is a great resource on MBRs and the various boot loaders. This resource not only disassembles MBRs, but also discusses GRUB, LILO, and the various Windows? boot loaders.
* Check out the [Disk Geometry](http://www.rwc.uc.edu/koehler/comath/42.html) page to understand disks and their geometries. You'll find an interesting summary of disk attributes.
* A [live CD](http://en.wikipedia.org/wiki/LiveCD) is an operating system that's bootable from a CD or DVD without needing a hard drive.
* ["Boot loader showdown: Getting to know LILO and GRUB"](http://www.ibm.com/developerworks/linux/library/l-bootload.html) (developerWorks, August 2005) gives you a detailed look at the LILO and GRUB boot loaders.
* In the [Linux Professional Institute (LPI) exam prep](http://www.ibm.com/developerworks/linux/lpi/101.html?S_TACT=105AGX03&S_CMP=art) series of developerWorks tutorials, get a comprehensive introduction to booting a Linux system and many other fundamental Linux tasks while you prepare for system administrator certification.
* [LILO](http://www.freshmeat.net/projects/lilo/) was the precursor to GRUB, but you can still find it booting Linux.
* The [mkintrd](http://www.netadmintools.com/html/mkinitrd.man.html) command is used to create an initial RAM disk image. This command is useful for building an initial root file system for boot configuration that allows preloading of block devices needed to access the real root file system.
* At the [Debian Linux Kernel Project](http://debianlinux.net/linux.html), find more information on the Linux kernel, boot, and embedded development.
* In the [developerWorks Linux zone](http://www.ibm.com/developerworks/linux/), find more resources for Linux developers.
* Stay current with [developerWorks technical events and Webcasts](http://www.ibm.com/developerworks/offers/techbriefings/?S_TACT=105AGX03&S_CMP=art).

**Get products and technologies**
* The [MicroMonitor](http://www.linuxdevices.com/articles/AT8516113114.html) provides a boot environment for a variety of small target devices. You can use this monitor to boot Linux in an embedded environment. It has ports for ARM, XScale, MIPS, PowerPC, Coldfire, and Hitachi's Super-H.
* [GNU GRUB](http://www.gnu.org/software/grub/) is a boot shell filled with options and flexibility.
* [LinuxBIOS](http://www.linuxbios.org/index.php/Main_Page) is a BIOS replacement. Not only does it boot Linux, LinuxBIOS, itself, is a compressed Linux kernel.
* [OpenBIOS](http://www.openbios.org/) is another portable BIOS project that operates on a variety of architectures such as x86, Alpha, and AMD64.
* At [kernel.org](http://www.kernel.org/), grab the latest kernel tree.
* With [IBM trial software](http://www.ibm.com/developerworks/downloads/?S_TACT=105AGX03&S_CMP=art), available for download directly from developerWorks, build your next development project on Linux.

**Discuss**
* Check out [developerWorks blogs](http://www.ibm.com/developerworks/blogs/) and get involved in the [developerWorks community](http://www.ibm.com/developerworks/community).

