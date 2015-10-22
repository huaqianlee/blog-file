title: "Android编译过程详解之一"
date: 2015-07-11 19:43:04
categories: Android
tags: [编译,源码分析,Qualcomm]
---
**　　Platform Information :
　　　System:    Ａndroid4.4.4 
　　　Platform:  Qualcomm msm8916
　　　Author:     Andy Lee
　　　Email:        huaqianlee@gmail.com**

**欢迎指出错误，共同学习，共同进步**

　　[Android编译过程详解之一](http://huaqianlee.me/2015/07/12/Android/Android%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%B8%80/)
　　[Android编译过程详解之二](http://huaqianlee.me/2015/07/12/Android/Android%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%BA%8C/)
　　[Android编译过程详解之三](http://huaqianlee.me/2015/07/12/Android/Andro%E7%BC%96%E8%AF%91%E8%BF%87%E7%A8%8B%E8%AF%A6%E8%A7%A3%E4%B9%8B%E4%B8%89/)
　　[Android.mk解析](http://huaqianlee.me/2015/07/12/Android/About-ActivityNotFoundException-Unable-to-find-explicit-activity-class-Android-mk%E8%A7%A3%E6%9E%90/)
　
　　Google给出的编译环境和构建方法见：[http://source.android.com/source/initializing.html](http://source.android.com/source/initializing.html)，过程见：[http://source.android.com/source/building.html](http://source.android.com/source/building.html)，不过这是解释怎么编译一个通用的系统，没有详细描述细节，而且需要翻墙。接下来我就准备跟着高通平台的编译过程来详细了解一下。

我平时的编译步骤如下：
　1. source setup.sh project-name debug/release　加载命令配置环境　
　2. ./go.sh  [target] or make  [target]　编译
<!--more-->　
接下来就按照步骤来详细分析一下流程：
##source setup.sh project-name debug
　　setup.sh是自定义的一个脚本文件，用来配置环境变量，其主要内容如下：
```bash
/*配置用到的jdk、jre*/
export JAVA_HOME=/workspace/bin/jdk1.6.0_37
export JRE_HOME=${JAVA_HOME}/jre 
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib 
export PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin:$PATH 

source build/envsetup.sh // 官网的第一步，加载命令，待会儿再详细解释

if [ -d /workspace/bin/eric-PAY4/links-8916 ];then
    cp -a /workspace/bin/eric-PAY4/links-8916 links
fi

if [ $# -lt 2 ];then # 如命令行参数输入错误，打印提示信息
    echo You can input like "source setup.sh s5_common [debug|release]"
    return 1;
fi

echo product=$1 var=$2 //打印输入选择 project-name  debug/release
if [ $2 = "debug" ];then　// 根据参数选择编译项
    choosecombo 2 msm8916_32 3 $1 
    return 0
fi
if [ $2 = "release" ];then
    choosecombo 1 msm8916_32 1 $1
    return 0
fi

echo "Your input is wrong please check again"
```
###source build/envsetup.sh
　　此命令是将envsetup.sh中的命令加载到环境变量，build位于Android源码路径根目录（本文提到所有路径都是以 Android 源码树作为背景的，“/”或顶层路径指的是源码树的根目录，与文件系统无关），主要命令如下：
```bash
- lunch:   指定编译项，即编译目标和编译类型（lunch <product_name>-<build_variant>）
- tapas:   同choosecombo，设置编译参数（tapas [<App1> <App2> ...] [arm|x86|mips|armv5] [eng|userdebug|user]）
- croot:   切换到根目录（Changes directory to the top of the tree.）
- m:       从源码树根目录开始make（Makes from the top of the tree.）
- mm:      编译当前目录下所有模块，但不包括依赖文件（Builds all of the modules in the current directory, but not their dependencies.）
- mmm:    编译指定目录下的所有模块，但不包括依赖文件（Builds all of the modules in the supplied directories, but not their dependencies.）
- mma:     编译当前目录下所有模块，包括依赖文件（Builds all of the modules in the current directory, and their dependencies.）
- mmma:    编译指定目录下的所有模块，包括依赖文件（Builds all of the modules in the supplied directories, and their dependencies.）
- cgrep:   在所有c/c++文件中查找（Greps on all local C/C++ files.）
- jgrep:   在所有java文件中查找（Greps on all local Java files.）
- resgrep: 在所有res/*.xml中查找（Greps on all local res/*.xml files.）
- godir:   跳转到包含某个文件的路径（Go to the directory containing a file.）
- printconfig：显示当前Build的配置信息
```
　　完整命令和关键源码如下：(英文为源码注释，中文部分是原本没有，自己根据理解添加的注释)
```bash
function get_abs_build_var()   # Get the value of a build variable as an absolute path.
function get_build_var()   # Get the exact value of a build variable.
function check_product()  # check to see if the supplied product is one we can build
function check_variant()  # check to see if the supplied variant is valid (variant：user userdebug eng)
function setpaths()   # sets ANDROID_BUILD_PATHS
function printconfig()   # 打印配置
function set_stuff_for_environment()   # 设置环境变量
function set_sequence_number()     # 设置序列号
function settitle()   # 设置标题
function addcompletions()    # 添加sdk/bash_completion中bash
function choosetype()    # 选择type （debug/release）
function chooseoemprj()    # 自定义，设置TARGET_PRODUCT，即project-name
function chooseproduct()    #  官方自带的设置TARGET_PRODUCT
function choosevariant()    # 设置variant (user userdebug eng)
function choosecombo()    # 设置并打印编译参数（choosetype、chooseproduct、choosevariant、chooseoemprj、set_stuff_for_environment）
function add_lunch_combo()    # 添加lunch项，多次调用，用来添加Android编译选项
function print_lunch_menu()    # 打印lunch列表
function lunch()    # 配置lunch
function _lunch()      # Tab completion for lunch.

# Configures the build to build unbundled apps.
# Run tapas with one ore more app names (from LOCAL_PACKAGE_NAME)
function tapas()     # 同choosecombo
function gettop    # 获取顶层路径
function m()    # 从顶层树开始编译
function findmakefile()    # 找到Makefile （Android.mk）
function mm()    # 从当前路径开始编译，不加依赖
function mmm()     # 从指定路径开始编译，不加依赖
function mma()    # 从当前路径看是编译，包括依赖
function mmma()     # 从指定路径开始编译，包括依赖
function croot()      # 切换到顶层路径
function cproj()     # 没看懂，切换到某一路径
function qpid()    # 输出进程号和名字 （simplified version of ps; output in the form <pid> <procname>）
function pid()     # 输出进程号和名字 
function systemstack()    # systemstack - dump the current stack trace of all threads in the system process to the usual ANR traces file
function stacks()
function gdbwrapper()
function gdbclient()
function sgrep()     # 查找c/h/cpp/S/java/xml/sh/mk文件
function gettargetarch    # 获取TARGET_ARCH
function jgrep()    # 查找java文件
function cgrep()    # 查找c/c++文件
function resgrep()    # 查找xml文件
function mangrep()     # 查找out目录中AndroidManifest.xml文件
function sepgrep()    # 查找out目录中sepolicy
function treegrep()                                
function mgrep()
function getprebuilt    # 获取ANDROID_PREBUILTS（编译工具）
function tracedmdump()
function runhat()     # communicate with a running device or emulator, set up necessary state, and run the hat command.
function getbugreports()
function getsdcardpath()
function getscreenshotpath()
function getlastscreenshot()
function startviewserver()
function stopviewserver()
function isviewserverstarted()
function key_home()
function key_back()
function key_menu()
function smoketest()
function runtest()    # simple shortcut to the runtest command
function godir ()    # 跳到指定目录
function set_java_home()    # Force JAVA_HOME to point to java 1.6 if it isn't already set
function pez     # Print colored exit condition

关键源码：
# Clear this variable.  It will be built up again when the vendorsetup.sh files are included at the end of this file.
unset LUNCH_MENU_CHOICES
function add_lunch_combo()
{
    local new_combo=$1   # 获取add_lunch_combo被调用时的参数
    local c
    for c in ${LUNCH_MENU_CHOICES[@]} ; do   #遍历LUNCH_MENU_CHOICES，第一次调用时为空
        if [ "$new_combo" = "$c" ] ; then    # 如果参数存在，则返回
            return
        fi
    done # 如果参数不存在，则添加
    LUNCH_MENU_CHOICES=(${LUNCH_MENU_CHOICES[@]} $new_combo)
}

# add the default one here  # 系统自动添加的默认编译项
add_lunch_combo aosp_arm-eng  # 调用add_lunch_combo()，传入参数
add_lunch_combo aosp_x86-eng
add_lunch_combo aosp_mips-eng
add_lunch_combo vbox_x86-eng

# 这段代码十分重要，主要在device目录查找vendorsetup.sh并加载，此文件主要添加自定义编译项，如：add_lunch_combo msm8916_32-userdebug 
# Execute the contents of any vendorsetup.sh files we can find.
for f in `test -d device && find device -maxdepth 4 -name 'vendorsetup.sh' 2> /dev/null` \
         `test -d vendor && find vendor -maxdepth 4 -name 'vendorsetup.sh' 2> /dev/null`
do
    echo "including $f"
    . $f  # 执行找到的脚本
done
unset f

addcompletions  调用 addcompletions()
```
因此可知，envsetup.sh主要有如下作用：
　1. 加载编译时需要的相应命令，如：help，lunch ，m，mm等。
　2. 添加系统默认编译项。
　3. 查找vendorsetup.sh文件，加载自定义编译项。
>注：有些Android版本中vendorsetup.sh文件在vendor目录　

　　如要添加自己的产品，需要在device目录下新建一个自己公司名，新建一个vendorsetup.sh，加入自己的编译项。了解了这一条指令，再来看一下执行结果，将会更有体会，因为我所有命令都写到开始的setup.sh文件中了，所以不用想官方那样多步配置编译，如下：
　　![Make](http://7xjdax.com1.z0.glb.clouddn.com/20150711MakeAndroid.png)

##lunch
　　lunch是在envsetup.sh中定义的一个命令，让用户选择编译项，用来定义product和编译过程中用到的全局变量。关于编译项，前面只是列出，并未详解，如msm8916_32-userdebug，msm8916_32为产品名，userdebug为编译类型，详细如下：
* eng: 工程机，

* user:最终用户机

* userdebug:调试测试机

* tests:测试机 。

　　在build\core\main.mk中有说明，Android源码中，每一个目标目录都有一个Android.mk，此文件中LOCAL_MODULE_TAGS就是来指定当前目标编译到哪个分类或者要不要编译。配置好后，可以通过lunch xxx 重选编译项，如：lunch msm8916_32-userdebug。

ok，接下来分析一下lunch function：
```bash
function lunch()
{
    local answer

    if [ "$1" ] ; then # lunch 后带参数
        answer=$1   
    else  # lunch后若不带参数，则打印所以target_product and variant 供用户选择
        print_lunch_menu
        echo -n "Which would you like? [aosp_arm-eng] "
        read answer
    fi

    local selection=

    if [ -z "$answer" ]
    then  
        selection=aosp_arm-eng # 如果用户在菜单中没有选择，直接回车，则为系统缺省的aosp_arm-eng
    elif (echo -n $answer | grep -q -e "^[0-9][0-9]*$") 
    then
        if [ $answer -le ${#LUNCH_MENU_CHOICES[@]} ] # 如果answer是选择菜单的数字，则获取该数字对应的字符串
        then
            selection=${LUNCH_MENU_CHOICES[$(($answer-1))]}
        fi
    elif (echo -n $answer | grep -q -e "^[^\-][^\-]*-[^\-][^\-]*$")  # 如果 answer字符串匹配 *-*模式(*的开头不能为-)
    then
        selection=$answer
    fi

    if [ -z "$selection" ]
    then
        echo
        echo "Invalid lunch combo: $answer"
        return 1
    fi

    export TARGET_BUILD_APPS=

    local product=$(echo -n $selection | sed -e "s/-.*$//")  # 将 product-variant模式中的product分离出来
    check_product $product  # 检查，调用关系 check_product()->get_build_var()->build/core/config.mk
    if [ $? -ne 0 ]
    then
        echo
        echo "** Don't have a product spec for: '$product'"
        echo "** Do you have the right repo manifest?"
        product=
    fi

    local variant=$(echo -n $selection | sed -e "s/^[^\-]*-//") # 将 product-variant模式中的variant分离出来
    check_variant $variant # 检查，看看是否在 (user userdebug eng) 范围内
    if [ $? -ne 0 ]
    then
        echo
        echo "** Invalid variant: '$variant'"
        echo "** Must be one of ${VARIANT_CHOICES[@]}"
        variant=
    fi

    if [ -z "$product" -o -z "$variant" ]
    then
        echo
        return 1
    fi

    #  导出环境变量，这很重要，因为后面的编译系统都依赖于这里定义的几个变量
    export TARGET_PRODUCT=$product
    export TARGET_BUILD_VARIANT=$variant
    export TARGET_BUILD_TYPE=release

    echo

    set_stuff_for_environment  # 设置环境变量， 在shell输入set可查看
    printconfig # 打印部分变量，调用关系printconfig()->get_build_var()->build/core/config.mk->build/core/envsetup.mk
}

# Tab completion for lunch.
function _lunch()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    COMPREPLY=( $(compgen -W "${LUNCH_MENU_CHOICES[*]}" -- ${cur}) )
    return 0
}
```



