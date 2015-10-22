title: "高通平台Android源码分析之Linux内核设备树(DT - Device Tree)"
date: 2015-08-19 22:11:46
categories: Android
tags: [源码分析,Qualcomm,kernel,译文,dts文件]
---
刚开始接触Android源码的时候，发现在kernel里面多了一种dts文件，因为当初自学Linux时和在第一家公司做物联网模型时都是用的比较老的内核，内核代码还比较混乱，没有采用dts这种方便简洁的格式。后面才知道这是因为Linus的一句”this whole arm thing is a fucking pain in ass“促进改革的，记得Linux早期代码里面板级细节都是在C文件中描述的，代码就显得十分臃肿和混乱。如此优化之后就显得简洁多了，并且也更易于学习、移植。
　
今天准备专门来分析一下内核设备树，主要按照如下三个方向来分析：
* Device Tree组成及用法；
* DTS文件解析常用api介绍；
* DTS文件的编译；
* 高通Android源码中dts文件引用流程；
<!--more-->

##Device Tree组成及用法
Device Tree由一系列node（节点）和property（属性）组成，节点本身可包含更多的子节点。属性是成对出现的name-value键值对。在device tree中主要描述如下信息：
* CPU的数量及类别
* 内存基地址和size
* 总线和桥
* 外设连接
* 中断
* GPIO
* CLOCK

Device Tree在内核的作用有点类似于描述出PCB上的CPU、内存、总线、设备及IRQ GPIO等组成的tree结构。然后经由bootloader传递给内核，内核再根据此设备树解析出需要的i2c、spi等设备，然后将内存、IRQ、GPIO等资源绑定到相应的设备。
>lk中通过tag传递到kernel，文件路径：bootable/bootloader/lk/app/aboot/aboot.c，由DEVICE_TREE宏开关控制

##DTS(device tree source)
dts文件是一种ASCII文本格式的device tree描述文件，其结构明了，第一次看到都能大概猜出其描述意图。在内核中arm部分，基本上一个.dts文件对应一个arm的machine，一般位于kernel/arch/arm/boot/dts。由于一个soc可能对应多个machine，
所以一般讲多个machine通用的部分提炼为一个.dsti文件，有点类似于头文件的作用，引用方式也类似：#include "xxx.dtsi"，dtsi文件也可以相互引用。

###dts中的基本元素
dts中的基本元素为节点和属性，节点可以包含属性和子节点，属性为name-value键值对，如下：
```dts
/ {
    node1 {
        a-string-property = "A string"; // 值为字符串
        a-string-list-property = "first string", "second string";// 值为字符数组
        a-byte-data-property = [0x01 0x23 0x34 0x56]; // 值为二进制
        child-node1 {
            first-child-property; 
            second-child-property = <1>; 
            a-string-property = "Hello, world";
        };
        child-node2 {
        };
    };
    node2 {
        an-empty-property; // 值为kog
        /* each number (cell) is a uint32 */
        a-cell-property = <1 2 3 4>;  // cells（由uint32组成）
        child-node1 {
        };
    };
};
```
上述dt并没有什么真实用途，没有描述任何东西。不过展示了dt的结构：
* 一个根节点："/"；
* 一对子节点："node1"和"node2"；
* 子节点的子节点："child-node"；
*  属性定义： 属性值可以为空、字符串、cells(整数组成)、数组及二进制等任意字节流；

属性中常用的字节流如下：
```bash
# 字符串，用双引号引用： 
string-property = "A string"; 
#cells(32 bits)，用尖括号引用分隔开的32bit无符号整数：
cell-property = <0xbeef 123 0xabcd1234>；
# 二进制数据，用方括号引用：
binary-property = [0x01 0x23 0x45 0x67];
# 通过逗号链接不同数据：
mixed-property = "a string", [0x01 0x23 0x45 0x67], <0x12345678>;
# 通过逗号创建字符串数组：
string-list = "red fish", "blue fish";
```

##Sample Machine
理解设备树怎么被用的最好办法，就是做一遍，接下来就通过一步一步构建描述一个简单machine的device tree来理解设备树。假设machine的硬件配置如下：
* 一个32bit的ARM CPU
* 处理器的local bus的内存映射分布了串口、spi总线控制器、i2c控制器、中断控制器和外部总线桥
* 256MB的SDRAM，基地址为0
* 2个串口基地址为：0x101f1000 和 0x101f2000
* GPIO控制器，基地址为0x101f3000
* spi控制器，基地址为0x10170000,从属设备：
  * MMC slot with ss pin attached to GPIO #1 (不能很好理解其意思，所以就不胡乱翻译了)
* External bus桥，从属设备：
  * smc smc91111 Ethernet设备，基地址为0x10100000
  * i2c控制器，基地址为0x10160000，从属设备：
    * Maxim DS1338时钟芯片，从设备I2C地址 1101000(0x58)
  * 64MB Nor flash,基地址为0x30000000

###初始化结构
首先，为machine创建一个框架结构，一个有效设备树的最简单的结构，如下：
```dts
/ {
    compatible = "acme,coyotes-revenge";
};
```
compatible指定系统的名字，格式： compatible = "< manufacturer>,< model>"（制造商，型号）。它非常重要，用来精确指定设备，并通过包含manufacurer(制造商)名字来避免冲突。因为操作系统通过compatible的值来决定machine怎么运行，所以使用正确的值是非常重要的。
　
理论上来说，compatible是操作系统所有数据标示machine的唯一标示符，os将通过顶层compatible寻找相应的值。

###CPUs
第二步，描述CPU的"cpus"节点，其包含每一个CPU描述信息的子节点，在这个例子中，CPU为一个双核的arm cortex A9处理器，所以其描述如下：
```dts
/ {
    compatible = "acme,coyotes-revenge";

    cpus {
        cpu@0 {
            compatible = "arm,cortex-a9"; // 格式同顶层节点，<manufacturer>,<model>
        };
        cpu@1 {
            compatible = "arm,cortex-a9";
        };
    };
};
```

###节点名
每一个节点必须有一个节点名，格式： < name>[@< unit-address>]。
* < name>：为最长31个字符的ascii字符串，一般用其代表的设备类型命名，ie. 一个3com Ethernet adapter的节点名：ethernet，不用3com509。
* unit-address： 描述设备的地址，一般情况下，其提供访问设备的基地址，节点的reg property也用此参数，见下文。

同层次兄弟节点的节点名必须是独一无二的，不过多个节点可以使用一样的通用name，只要地址不同就可以了。ie. serial@101f1000 & serial@101f2000

###Devices
每一个device在系统中由一个设备树节点描述，所以接下来，第三步是为设备填充树的节点。不过，现在我为新节点创建一个空节点，直到我们知道地址范围和如何处理irqs请求之后再填写相应内容。如下：
```dts
/ {
    compatible = "acme,coyotes-revenge";

    cpus {
        cpu@0 {
            compatible = "arm,cortex-a9";
        };
        cpu@1 {
            compatible = "arm,cortex-a9";
        };
    };

    serial@101F0000 {
        compatible = "arm,pl011";
    };

    serial@101F2000 {
        compatible = "arm,pl011";
    };

    gpio@101F3000 {
        compatible = "arm,pl061";
    };

    interrupt-controller@10140000 {
        compatible = "arm,pl190";
    };

    spi@10115000 {
        compatible = "arm,pl022";
    };

    external-bus {
        ethernet@0,0 {
            compatible = "smc,smc91c111";
        };

        i2c@1,0 {
            compatible = "acme,a1234-i2c-bus";
            rtc@58 {
                compatible = "maxim,ds1338";
            };
        };

        flash@2,0 {
            compatible = "samsung,k8f1315ebm", "cfi-flash";
        };
    };
};
```
在此tree中，在系统中为每一个device增加了节点，其层次结构反应了系统中的连接情况。ie. extern bus上的的设备憋创建为external bus节点的子节点，i2c设备被创建为i2c总线控制器的子节点。简单来说，tree中的层次结构代表了系统中的CPU视图。

目前，这个tree是无效的，因为它没有设备之间的连接信息，接下来再添加这些信息。
在这个tree中有几点需要注意：
* 每个设备节点都有一个compatible属性
* flash节点的compatible属性有两个字符串值。
* 如前所述，节点名反映设备类型，而非详细型号。

####compatible详解
设备树中每个节点都需要有compatible属性，compatible属性决定每一个设备驱动绑定哪一个设备。如上所介绍，compatible是一个字符串序列，第一个字符串指定精确设备，第二字符串指定兼容设备。

例如：Freescale MPC8349片上有一个根据国家半导体ns16550接口实现的串行设备，定义为：compatible = "fsl,mpc8349-uart", "ns16550". 第一个字符串指定精确设备，第二个指定国家半导体16550 uart兼容设备。
>ns16550没有制造商前缀（manufacturer）纯属历史原因，所有的compatible值应该带有制造商前缀。

这种做法允许将存在的设备驱动绑定到一类更新的设备，并且仍然能识别到精确的设备。
>警告：不要使用通配符赋值，如："fsl,mpc83xx-uart"等。为了兼容后续设备，一般会选择一个特定实现，如上的："ns16550"。

###设备寻址
关于设备寻址，设备树中通过如下属性encode地址信息：
```bash
reg ：每个可寻址的设备有一个reg cells.
格式：reg = <address1 length1 [address2 length2] [address3 length3] ... >
// 因为地址和地址长度是变量，所以父节点中定义#address-cells和#size-cells两个属性，声明每个域里会用到多少cell
#address-cells
#size-cells
```

#####CPU寻址
CPU节点寻址是寻址里面最简单的，每个CPU被一个独一无二的ID标记，没有size与CPU ids关联。如下：
```dts
    cpus {
        #address-cells = <1>;
        #size-cells = <0>; // 此两个属性表明子节点reg 值为一个没有size的uint32地址
        cpu@0 {
            compatible = "arm,cortex-a9";
            reg = <0>; // 值与节点名的unit-address相同
        };
        cpu@1 {
            compatible = "arm,cortex-a9";
            reg = <1>; 
        };
    };
```
>如果一个节点有reg属性，则节点名必须包含unit-address，并且取reg属性的第一个address值。

###有内存映像地址的设备
与cpu中只有address值不同，有内存映像地址的设备还需分配地址范围值，每个子节点reg元素定义地址长度值的数量由父节点的#size-cells指定。如下：
```dts
/ {
    #address-cells = <1>; // 值为 1 cell(32bits)
    #size-cells = <1>; // 每个长度值为 1 cell
    // 如果是64 bit machines， 则以上两值为2
    ...

    serial@101f0000 {
        compatible = "arm,pl011";
        reg = <0x101f0000 0x1000 >; 
        // 第一个参数为基地址，第二个参数为地址长度，此处表示serial的内存地址范围：0x101f0000~0x101f0fff
    };

    serial@101f2000 {
        compatible = "arm,pl011";
        reg = <0x101f2000 0x1000 >;
    };

    gpio@101f3000 {
        compatible = "arm,pl061";
        reg = <0x101f3000 0x1000
               0x101f4000 0x0010>; // GPIO设备被分配到两个地址范围
    };

    interrupt-controller@10140000 {
        compatible = "arm,pl190";
        reg = <0x10140000 0x1000 >;
    };

    spi@10115000 {
        compatible = "arm,pl022";
        reg = <0x10115000 0x1000 >;
    };

    ...

};
```

当然，并不是所有设备都直接和cpu相连，也有一些设备通过挂载到一条总线上和cpu相连。对于挂接到总线的设备，每个父节点为子节点定义地址域，如下：
```dts
external-bus {  //父节点
#address-cells = <2> // 子节点有2 cells基地址值，一个用于指定chip number，一个用于指定选中芯片基地址的偏移量
#size-cells = <1>; // 子节点有1 cell 地址长度

    ethernet@0,0 {
        compatible = "smc,smc91c111";
        reg = <0 0 0x1000>;
    };

    i2c@1,0 {
        compatible = "acme,a1234-i2c-bus";
        reg = <1 0 0x1000>;
        rtc@58 {
            compatible = "maxim,ds1338";
        };
    };

    flash@2,0 {
        compatible = "samsung,k8f1315ebm", "cfi-flash";
        reg = <2 0 0x4000000>;
    };
};
```

由于地址域被节点和其子节点一起定义，所以父节点可以为总线定义任何寻址方式。除了直接父亲以外的所有节点和子节点都不用关心本地的寻址域，不用关心地址从哪映射到哪。
>如不明白，请继续往下看，相信接下来的部分会帮你解惑

###无内存映像的设备
无内存映像的设备没有直接访问cpu的权限，父设备的驱动将间接访问cpu，其cpu一样reg属性会有一个地址值，但没有地址长度或范围，如下：
```dts
i2c@1,0 {
    compatible = "acme,a1234-i2c-bus";
    #address-cells = <1>;
    #size-cells = <0>;
    reg = <1 0 0x1000>;
    rtc@58 {
        compatible = "maxim,ds1338";
        reg = <58>;
    };
};
```

###地址转换
前面讲了怎么给设备分配本地地址，但没有说明怎么映射到cpu能直接访问的地址。接下来就详细分析一下这一部分：

根节点描述cpu地址空间视图，根节点的子节点不需要做任何显性的映射直接使用cpu的地址域。比如：serial@101f0000直接分配到地址0x101f0000.

而不是根节点的直接孩子的节点不使用cpu的地址域，为了能将其映射到cpu的内存地址，设备树就得对其地址进行转换，ranges属性就是用来实现这个目的的，加入ranges属性后如下：
```dts
/ {
    compatible = "acme,coyotes-revenge";
    #address-cells = <1>;
    #size-cells = <1>;
    ...
    external-bus {
        #address-cells = <2>
        #size-cells = <1>;
        ranges = <0 0  0x10100000   0x10000     // Chipselect 0, Ethernet
                         1 0  0x10160000   0x10000     // Chipselect 1, i2c controller
                         2 0  0x30000000   0x10000000>; // Chipselect 2, NOR Flash，此处参考文章地址空间大小少一个0，但我觉得不对，所以自己做了修改，下同，就不再说明

// 相信大家直接通过这个列表就能知道地址怎么转换的了，如下：

1. 偏移量为0的Chipselect0映射到0x10100000~0x1010ffff
2. 偏移量为0的Chipselect1映射到0x10160000~0x1016ffff
3. 偏移量为0的Chipselect2映射到0x30000000~0x3fffffff （此处参考文章写的0x10000000，但我觉得应该是0x3fffffff，原地址见博文最后引用）

        ethernet@0,0 {
            compatible = "smc,smc91c111";
            reg = <0 0 0x1000>;
        };

// i2c总线节点没有ranges参数，因为i2c总线上的设备不需映射到cpu地址域，cpu直接通过i2c就能访问i2c设备
        i2c@1,0 {
            compatible = "acme,a1234-i2c-bus";
            #address-cells = <1>;
            #size-cells = <0>;
            reg = <1 0 0x1000>;
            rtc@58 {
                compatible = "maxim,ds1338";
                reg = <58>;
            };
        };

        flash@2,0 {
            compatible = "samsung,k8f1315ebm", "cfi-flash";
            reg = <2 0 0x10000000>; // 此处参考文章写的0x4000000， 但我觉得为0x10000000 - 256MB
        };
    };
};
```

ranges参数的值是一个地址转换列表，每一个条目由如下几部分组成：
* 子节点地址：由子节点的#address-cells值决定
* 父节点地址：由父节点的#address-cells值决定
* 子节点地址空间的大小 ：由子节点的#size-cells值决定

如果ranges参数为空，则表示子节点地址和父节点地址1:1映射。你可能会有疑问，既然1:1映射，为什么还要通过地址转换来获得地址空间。一些总线（比如PCI）有完全不同的地址空间细节需要暴露给操作系统。其他带DMA的设备需要知道设备在总线上的真实地址。有时设备需要组合在一起去共享相同的可编程物理地址映射。是否需要通过1:1映射依赖于操作系统和硬件设计的很多信息。

缺乏ranges参数意味着，一个设备只能被其父节点访问而不能被cpu直接访问。

###中断
中断信号可以来自machine的任何设备，中断信号在设备树中被描述为节点之间的links。主要有如下4中属性：
* interrupt-controller：一个空属性，定义节点为中断控制器；
* \#interrupt-cells：表明连接此中断控制器的interrupts属性cell大小（类似于#address-cells和#size-cells）；
* interrupt-parent：指定节点设备所依附的中断控制器的phandle，若没有此参数，则从父节点继承；
* interrupts：中断说明符列表，节点通过此方法指定中断号、触发方式等；

一个中断说明符描述指定中断输入设备的相关信息，由#interrupt-cells指定中断说明符cell数量。设备可能一个或多个中断源。一个中断设备的说明符完全取决于绑定的中断控制器设备。  定义一个中断源需要多少cells由中断控制器决定。加入中断相关属性后如下：
```dts
/ {
    compatible = "acme,coyotes-revenge";
    #address-cells = <1>;
    #size-cells = <1>;
    interrupt-parent = <&intc>;  // intc->interrupt-controller，作为系统默认的interrupt-parent属性，子节点重写则覆盖

    cpus {
        #address-cells = <1>;
        #size-cells = <0>;
        cpu@0 {
            compatible = "arm,cortex-a9";
            reg = <0>;
        };
        cpu@1 {
            compatible = "arm,cortex-a9";
            reg = <1>;
        };
    };

    serial@101f0000 {
        compatible = "arm,pl011";
        reg = <0x101f0000 0x1000 >;
        interrupts = < 1 0 >; // 指定中断源
    };

    serial@101f2000 {
        compatible = "arm,pl011";
        reg = <0x101f2000 0x1000 >;
        interrupts = < 2 0 >;
    };

    gpio@101f3000 {
        compatible = "arm,pl061";
        reg = <0x101f3000 0x1000
               0x101f4000 0x0010>;
        interrupts = < 3 0 >;
    };

    intc: interrupt-controller@10140000 {  // 中断控制器
        compatible = "arm,pl190";
        reg = <0x10140000 0x1000 >;
        interrupt-controller;
        #interrupt-cells = <2>; // 中断说明符有2 cells，此例中cell 1表示中断号，cell 2 表示触发方式
    };

    spi@10115000 {
        compatible = "arm,pl022";
        reg = <0x10115000 0x1000 >;
        interrupts = < 4 0 >; // 注：设备还可以使用多个中断号，假如此spi使用两个，则：interrupts = <0 4 0>, <1 5 0>;
    };

    external-bus {
        #address-cells = <2>
        #size-cells = <1>;
        ranges = <0 0  0x10100000   0x10000     // Chipselect 0, Ethernet
                  1 0  0x10160000   0x10000     // Chipselect 1, i2c controller
                  2 0  0x30000000   0x10000000>; // Chipselect 2, NOR Flash

        ethernet@0,0 {
            compatible = "smc,smc91c111";
            reg = <0 0 0x1000>;
            interrupts = < 5 2 >;
        };

        i2c@1,0 {
            compatible = "acme,a1234-i2c-bus";
            #address-cells = <1>;
            #size-cells = <0>;
            reg = <1 0 0x1000>;
            interrupts = < 6 2 >;
            rtc@58 {
                compatible = "maxim,ds1338";
                reg = <58>;
                interrupts = < 7 3 >;
            };
        };

        flash@2,0 {
            compatible = "samsung,k8f1315ebm", "cfi-flash";
            reg = <2 0 0x10000000>;
        };
    };
};
```

另， 关于cell含义在内核中的相关文档有详细描述，比如arm gic 中断：
```text
# Documentation/devicetree/bindings/arm/gic.txt
The 1st cell is the interrupt type; 0 for SPI interrupts, 1 for PPI  
interrupts.  

The 2nd cell contains the interrupt number for the interrupt type.  
SPI interrupts are in the range [0-987].  PPI interrupts are in the  
range [0-15].   

The 3rd cell is the flags, encoded as follows:  
       bits[3:0] trigger type and level flags.  
               1 = low-to-high edge triggered  
               2 = high-to-low edge triggered  
               4 = active high level-sensitive  
               8 = active low level-sensitive  
       bits[15:8] PPI interrupt cpu mask.  Each bit corresponds to each of  
       the 8 possible cpus attached to the GIC.  A bit set to '1' indicated  
       the interrupt is wired to that CPU.  Only valid for PPI interrupts.  
```

###设备特有数据
除了上面讲的常用属性，任意需要的属性和子节点都可以被加入到设备树，不过新device-specific属性应将制造商名作为前缀命名，以避免与标准的属性冲突；
>其实还有一些要求，不过主要针对内核开发者的，而我还没有那个水平，就没详细看了 


###特殊节点
####aliases节点
一个specific节点通常以完全路径的形式引用，如：/external-bus/ethernet@0,0 ， 但是这样太复杂了，不利于阅读。所以通常会用以一个短的别名命名的aliases节点去指定设备的完全路径，如下：
```dts
aliases {
    ethernet0 = &eth0;  
    serial0 = &serial0;
};
```
>注：property = &Label 不同于如上中断phandle引用的phandle = <&Lable>

####chosen节点
chosen节点不指明真实的设备，其为硬件和操作系统数据传输服务，如：启动参数。通常chosen节点在dts源文件中写为空，在启动时再填充，在例中增加如下：
```dts
chosen {
        bootargs = "root=/dev/nfs rw nfsroot=192.168.1.1 console=ttyS0,115200";
    };
```

##DTC (device tree compiler)
DTC将.dts编译为.dtb的工具。DTC的源代码位于内核的scripts/dtc目录，在Linux内核使能了Device Tree的情况下，编译内核的时候主机工具dtc会被编译出来，对应scripts/dtc/Makefile中的“hostprogs-y := dtc”。
在Linux内核的arch/arm/boot/dts/Makefile中，描述了当某种SoC被选中后，哪些.dtb文件会被编译出来，如与VEXPRESS对应的.dtb包括：
```bash
dtb-$(CONFIG_ARCH_VEXPRESS) += vexpress-v2p-ca5s.dtb \  
        vexpress-v2p-ca9.dtb \  
        vexpress-v2p-ca15-tc1.dtb \  
        vexpress-v2p-ca15_a7.dtb \  
        xenvm-4.2.dtb  
```
在Linux下，我们可以通过make dtbs命令单独编译Device Tree文件。因为arch/arm/Makefile中含有一个dtbs编译target，如下：
```mk
# Build the DT binary blobs if we have OF configured
ifeq ($(CONFIG_USE_OF),y)
KBUILD_DTBS := dtbs
endif
```
###Device Tree Blob (dtb)
dtb是dts被DTC编译后生成的二进制格式Device Tree描述，可由Linux内核解析。系统设计时通常会单独留下一个很小的flash空间存放.dtb文件，bootloader在引导kernel的过程中，会先读取该.dtb到内存。

###Binding
对于Device Tree中的结点和属性具体是如何来描述设备的硬件细节的，内核里有相应的文档，位于：Documentation/devicetree/bindings目录，其下又分为很多子目录。


##dts解析API
>注：此部分基本完全摘自参考文档

在Linux的BSP和驱动代码中，解析dts的API通常被以“of_”作为前缀，它们的实现代码位于内核的drivers/of目录。接下来就介绍一下常用的API。

**int of_device_is_compatible(const struct device_node *device,const char *compat);**

判断设备结点的compatible 属性是否包含compat指定的字符串。当一个驱动支持2个或多个设备的时候，这些不同.dts文件中设备的compatible 属性都会进入驱动 OF匹配表。因此驱动可以透过Bootloader传递给内核的Device Tree中的真正结点的compatible 属性以确定究竟是哪一种设备，从而根据不同的设备类型进行不同的处理。如drivers/pinctrl/pinctrl-sirf.c即兼容于"sirf,prima2-pinctrl"，又兼容于"sirf,prima2-pinctrl"，在驱动中就有相应分支处理：
```c
if (of_device_is_compatible(np, "sirf,marco-pinctrl"))  
      is_marco = 1;  
struct device_node *of_find_compatible_node(struct device_node *from,
         const char *type, const char *compatible);
```
根据compatible属性，获得设备结点。遍历Device Tree中所有的设备结点，看看哪个结点的类型、compatible属性与本函数的输入参数匹配，大多数情况下，from、type为NULL。

**int of_property_read_u8_array(const struct device_node *np, const char *propname, u8 *out_values, size_t sz);
int of_property_read_u16_array(const struct device_node *np, const char *propname, u16 *out_values, size_t sz);
int of_property_read_u32_array(const struct device_node *np, const char *propname, u32 *out_values, size_t sz);
int of_property_read_u64(const struct device_node *np, const char *propname, u64 *out_value);**

读取设备结点np的属性名为propname，类型为8、16、32、64位整型数组的属性。对于32位处理器来讲，最常用的是of_property_read_u32_array()。如在arch/arm/mm/cache-l2x0.c中，透过如下语句读取L2 cache的"arm,data-latency"属性：
```c
of_property_read_u32_array(np, "arm,data-latency",  
      data, ARRAY_SIZE(data));  
```
在arch/arm/boot/dts/vexpress-v2p-ca9.dts中，含有"arm,data-latency"属性的L2 cache结点如下：
```c
L2: cache-controller@1e00a000 {  
        compatible = "arm,pl310-cache";  
        reg = <0x1e00a000 0x1000>;  
        interrupts = <0 43 4>;  
        cache-level = <2>;  
        arm,data-latency = <1 1 1>;  
        arm,tag-latency = <1 1 1>;  
}  
```

有些情况下，整形属性的长度可能为1，于是内核为了方便调用者，又在上述API的基础上封装出了更加简单的读单一整形属性的API，它们为int of_property_read_u8()、of_property_read_u16()等，实现于include/linux/of.h：
```c
static inline int of_property_read_u8(const struct device_node *np,  
                                       const char *propname,  
                                       u8 *out_value)  
{  
        return of_property_read_u8_array(np, propname, out_value, 1);  
}  
 
static inline int of_property_read_u16(const struct device_node *np,  
                                       const char *propname,  
                                       u16 *out_value)  
{  
        return of_property_read_u16_array(np, propname, out_value, 1);  
}  
 
static inline int of_property_read_u32(const struct device_node *np,  
                                       const char *propname,  
                                       u32 *out_value)  
{  
        return of_property_read_u32_array(np, propname, out_value, 1);  
}  
```


**int of_property_read_string(struct device_node *np, const char *propname, const char **out_string);
int of_property_read_string_index(struct device_node *np, const char    *propname, int index, const char **output);**

前者读取字符串属性，后者读取字符串数组属性中的第index个字符串。如drivers/clk/clk.c中的of_clk_get_parent_name()透过of_property_read_string_index()遍历clkspec结点的所有"clock-output-names"字符串数组属性。
```c
const char *of_clk_get_parent_name(struct device_node *np, int index)  
{  
        struct of_phandle_args clkspec;  
        const char *clk_name;  
        int rc;  
 
        if (index < 0)  
                return NULL;  
 
        rc = of_parse_phandle_with_args(np, "clocks", "#clock-cells", index,  
                                        &clkspec);  
        if (rc)  
                return NULL;  
 
        if (of_property_read_string_index(clkspec.np, "clock-output-names",  
                                  clkspec.args_count ? clkspec.args[0] : 0,  
                                          &clk_name) < 0)  
                clk_name = clkspec.np->name;  
 
        of_node_put(clkspec.np);  
        return clk_name;  
}  
EXPORT_SYMBOL_GPL(of_clk_get_parent_name);  
```


**static inline bool of_property_read_bool(const struct device_node *np, const char *propname);**

如果设备结点np含有propname属性，则返回true，否则返回false。一般用于检查空属性是否存在。

**void __iomem *of_iomap(struct device_node *node, int index);**
通过设备结点直接进行设备内存区间的 ioremap()，index是内存段的索引。若设备结点的reg属性有多段，可通过index标示要ioremap的是哪一段，只有1段的情况，index为0。采用Device Tree后，大量的设备驱动通过of_iomap()进行映射，而不再通过传统的ioremap。

**unsigned int irq_of_parse_and_map(struct device_node *dev, int index);**
透过Device Tree或者设备的中断号，实际上是从.dts中的interrupts属性解析出中断号。若设备使用了多个中断，index指定中断的索引号。
还有一些OF API，这里不一一列举，具体可参考include/linux/of.h头文件。

##高通Android源码中dts文件
###AndroidBoard.mk
Android编译过程（如想了解更多可参考：[Android编译过程详解](http://huaqianlee.me/2015/07/11/Android/Android%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%B8%80/)）中会解析到device\qcom\msm8916_32\AndroidBoard.mk，此文件中选择了kernel的默认配置文件，如下：
```mk
# device\qcom\msm8916_32\AndroidBoard.mk

#----------------------------------------------------------------------
# Compile (L)ittle (K)ernel bootloader and the nandwrite utility
#----------------------------------------------------------------------
ifneq ($(strip $(TARGET_NO_BOOTLOADER)),true)

# Compile
include bootable/bootloader/lk/AndroidBoot.mk

$(INSTALLED_BOOTLOADER_MODULE): $(TARGET_EMMC_BOOTLOADER) | $(ACP)
    $(transform-prebuilt-to-target)
$(BUILT_TARGET_FILES_PACKAGE): $(INSTALLED_BOOTLOADER_MODULE)

droidcore: $(INSTALLED_BOOTLOADER_MODULE)
endif

#----------------------------------------------------------------------
# Compile Linux Kernel
#----------------------------------------------------------------------
ifeq ($(KERNEL_DEFCONFIG),)
    KERNEL_DEFCONFIG := msm8916_defconfig  //选择msm8916_defconfig文件为默认配置文件
endif

include kernel/AndroidKernel.mk

$(INSTALLED_KERNEL_TARGET): $(TARGET_PREBUILT_KERNEL) | $(ACP)
    $(transform-prebuilt-to-target)
```
###msm8916_defconfig
此文件中主要是一些编译开关，包括dts文件的编译开关，如下：
```mk
# kernel\arch\arm\configs\msm8916_defconfig
...
CONFIG_ARCH_MSM=y
CONFIG_ARCH_MSM8916=y  // dts文件的编译开关，当然也在其他地方用到，如加载板级文件：obj-$(CONFIG_ARCH_MSM8916) += board-8916.o
...
```

###Makefile
dts文件目录的mk文件决定需要加载哪些dts文件，这些文件最终打包到dt.img，再经由mkbootimg工具和其他镜像一起打包到boot.img。关键源码如下：
```mk
# kernel\arch\arm\boot\dts\qcom\Makefile
...
// 我们的代码针对每一个项目新建了一个dts文件，然后通过此文件去include了相关dts文件，所以下面都被屏蔽掉了
dtb-$(CONFIG_ARCH_MSM8916) += msm8916-qrd-skuh-$(OEM_PROJECT_NAME).dtb  
#msm8916-sim.dtb
#msm8916-rumi.dtb
#msm8916-cdp.dtb
#msm8916-cdp-smb1360.dtb
#msm8916-mtp.dtb
#msm8916-512mb-mtp.dtb
#msm8916-mtp-smb1360.dtb
#msm8916-512mb-mtp-smb1360.dtb
#msm8916-512mb-qrd-skui.dtb
#msm8916-qrd-skuh.dtb
#msm8916-qrd-skuhf.dtb
#msm8916-qrd-skui.dtb
#msm8916-512mb-qrd-skuh.dtb
#msm8939-sim.dtb
#msm8939-rumi.dtb
#msm8939-qrd-skuk.dtb
#msm8939-cdp.dtb
#msm8939-cdp-smb1360.dtb
#msm8939-mtp.dtb
#msm8939-mtp-smb1360.dtb
...
```
###dts中的platform info
msm8916-cdp.dts文件中定义平台信息，如下：
```dts
# kernel\arch\arm\boot\dts\qcom\msm8916-cdp.dts
#include "msm8916-cdp.dtsi"
#include "msm8916-memory.dtsi"

/ {
    model = "Qualcomm Technologies, Inc. MSM 8916 CDP";
    compatible = "qcom,msm8916-cdp", "qcom,msm8916", "qcom,cdp";
    qcom,board-id = <1 0>;
};
...
```

不过我们在每个项目的dts文件中重新定义了平台信息，如下：
```dts
# kernel\arch\arm\boot\dts\qcom\msm8916-qrd-skuh-$(OEM_PROJECT_NAME).dts 
#include "msm8916-qrd-skuh.dtsi"
#include "msm8916-memory.dtsi"

/ {
    model = "Qualcomm Technologies, Inc. MSM 8916 QRD SKUH changcheng l783";
    compatible = "qcom,msm8916-qrd-skuh", "qcom,msm8916-qrd", "qcom,msm8916", "qcom,qrd";
    qcom,board-id = <0x1000b 0> , <0x1000b 4>;
};
...
```

###Reference
我的这篇博文只是写了一些基本的东西，主要参考下面这些文档，并且很多内容直接翻译自下面的文档，如果想了解更多请查阅如下引用文档：
[kernel\Documentation\devicetree](http://pan.baidu.com/s/1c0mBcek)：*源码中的文档，很有参考价值，其实需要的基本能在里面找到，我已上传至百度云，可以click下载查看*
http://devicetree.org/Device_Tree_Usage ：*很多内容译自此处*
[Power_ePAPR_APPROVED_v1.0.pdf](http://pan.baidu.com/s/1c0c195I)：*进阶文档，因为官网总是不能成功访问，所以在我百度网盘存了一份，分享给大家*
http://blog.csdn.net/21cnbao/article/details/8457546 

