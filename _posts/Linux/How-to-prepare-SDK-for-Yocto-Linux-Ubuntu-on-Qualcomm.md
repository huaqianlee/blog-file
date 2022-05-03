title: How to prepare SDK for Yocto Linux/Ubuntu on Qualcomm
date: 2021-12-25 22:30:32
categories:
- Linux Treejnk
- Ycoto
tags:
---

# What does SDK mean in current context?

很多时候，我们需要闭源一部分源码， 然后再把整个源码仓库共享给指定人员。这个源码仓库就称之为 SDK。

# How to make SDK based on Yocto build system

根据目前的调查结论，基于 Yocto 编译系统做 SDK 主要有如下三种方式，本文主要介绍第一种方式，也会稍微介绍下第二、三种方式。

- 将闭源部分源码做成 prebuilt 包;
- 重写 `do_install` 任务直接安装闭源部分源码生成的 deb 包;
- 将源码编译成二进制并替换，修改 Makefile 文件。

最开始倾向于以 2、3 的方式来做 SDK， 深入调查后发现 1 才是最合适的方式，原因有三：
- 高通有开发一个基于 `qprebuilt.bbclass` 类来实现的半成品 prebuilt 功能， 而且高通的闭源源码也是按照这种方式处理的。
- 直接安装预编译的 deb 包是一个糟糕的决定，会给以后带来很多不确定性和不可追溯性。
- 编译二进制并替换的方式在 Yocto 中逻辑更为复杂，且不符合官方推荐的标准做法。

## Create Prebuilt tarball

制作预编译包是官方比较推荐的一种方式，详细过程请查看 “Lessons and Gains of making prebuilt sdk” 部分。现以 RB5 LU 为例将准备步骤简单总结如下，其分为两种情况：
- 可以生成中间产物，用中间产物创建；
- 不能生成中间产物，直接取最终产物创建。

> 我们也可以跳过第一种情况，直接按照第二种方式准备所有模块的预编译包，可以直接跳过如下第 2 步。

1. 找到并修改闭源代码对应的 bb 文件, 添加如下两行代码。

```sh
# RB5 LU 需要修改如下文件：
# poky/meta-qti-bsp-prop/classes/qprebuilt.bbclass
# poky/meta-qti-bsp-prop/recipes-bsp/sensors/sensors-see_git.bb
# poky/meta-qti-bt/recipes/bt-app/bt-app_git.bb
# poky/meta-qti-bt/recipes/bt-cert/bt-cert_git.bb
# poky/meta-qti-bt/recipes/bthost-ipc/bthost-ipc_git.bb
# poky/meta-qti-bt/recipes/fluoride/fluoride_git.bb
# poky/meta-qti-bt/recipes/libbt-vendor/libbt-vendor_git.bb
# poky/meta-qti-camera-prop/recipes/camx/camx_0.1.bb
# poky/meta-qti-camera-prop/recipes/camx/camxlib_0.1.bb
# poky/meta-qti-camera-prop/recipes/camx/chicdk_0.1.bb
# poky/meta-qti-gst-prop/recipes/secure-gst/secure-gst.bb
# poky/meta-qti-robotics-prop/recipes/imud/imud.bb
# poky/meta-qti-sensors-prop/recipes/sensors/sensors-see-qti_git.bb

RM_WORK_EXCLUDE += "${PN}" # 也可以添加所有模块到 local.conf， 譬如： RM_WORK_EXCLUDE += "camx chicdk ..."
inherit qprebuilt # 如果 bb 文件已经继承了此类，就不需要增加此行
```
<!--more-->
2. 进入对应模块 "non-stripped" 或者 “stripped” 路径，执行如下脚本生成预编译包。

```sh
# create_prebuilt_targz.sh
# create tarball
#!/bin/bash

set -e

# Ensure that PWD should be in subdir prebuilt/non-stripped/ of recipe WORKDIR
# e.g: apps_proc/build-qti-distro-ubuntu-fullstack-debug/tmp-glibc/work/aarch64-oe-linux/libgpt/1.0-r0/prebuilt/stripped/
function check_pwd()
{
    # If we want to put this script into "stripped", we need to modify the following ‘if’ condition.
    if [ "$(basename $PWD)" != "non-stripped" ]; then
        echo "please change into subdir prebuilt/stripped/ of recipe WORKDIR"
        return 1
    fi
}


function get_targz_name()
{
    WORKDIR=${PWD/prebuilt*/}
    echo WORKDIR=$WORKDIR

    PV_BASE=$(basename $WORKDIR)
    PV=${PV_BASE/-*/}
    echo PV=$PV
    PN_DIR=$(dirname $WORKDIR)
    PN=$(basename $PN_DIR)
    echo PN=${PN}
    PACKAGE_ARCH_DIR=$(dirname ${PN_DIR})
    PACKAGE_ARCH_BASE=$(basename ${PACKAGE_ARCH_DIR})
    PACKAGE_ARCH=${PACKAGE_ARCH_BASE/-oe-linux/}
    echo PACKAGE_ARCH=$PACKAGE_ARCH
    PREBUILT_TARGZ_NAME=${PN}_${PV}_${PACKAGE_ARCH}.tar.gz
    echo PREBUILT_TARGZ_NAME=${PREBUILT_TARGZ_NAME}
    if [ -z "${PREBUILT_TARGZ_NAME}" ]; then
        return 1
    fi
}

check_pwd
echo OK
get_targz_name
tar cvfz ${PREBUILT_TARGZ_NAME} *
```

3. 部分模块没有中间产物，可以按照如下方式准备预编译包。
```sh
# 1. Get files based on one of the two following ways
ar vx sensors-see-qti_0-r0_arm64.deb
tar -xvf data.tar.xz -C data/
# or
cp build-qti-distro-ubuntu-fullstack-debug/tmp-glibc/sysroots-components/aarch64/sensors-see-qti/* data/

# 2. Get licenses
cp build-qti-distro-ubuntu-fullstack-debug/tmp-glibc/deploy/licenses/sensors-see-qti data/__LIC__

# 3. Make tarball
tar -cjvf sensors-see-qti_git_aarch64.tar.gz data/*
```

4. 拷贝预编译包到预编译路径。
```sh
# RB5 prebuilt path
cp *.tar.gz apps_proc/prebuilt_HY11
```

5. 删除源码，清理`git`记录。

6. 编译确认，可能会遇到编译错误，我们需要按照步骤 1~3 准备对应的预编译包。
```sh
# 如下是 RB5 的修改参考。
# Modified script
create_prebuilt_targz.sh
poky/meta-qti-bsp-prop/classes/qprebuilt.bbclass
poky/meta-qti-bsp-prop/recipes-bsp/sensors/sensors-see_git.bb
poky/meta-qti-bt/recipes/bt-app/bt-app_git.bb
poky/meta-qti-bt/recipes/bt-cert/bt-cert_git.bb
poky/meta-qti-bt/recipes/bthost-ipc/bthost-ipc_git.bb
poky/meta-qti-bt/recipes/fluoride/fluoride_git.bb
poky/meta-qti-bt/recipes/libbt-vendor/libbt-vendor_git.bb
poky/meta-qti-camera-prop/recipes/camx/camx_0.1.bb
poky/meta-qti-camera-prop/recipes/camx/camxlib_0.1.bb
poky/meta-qti-camera-prop/recipes/camx/chicdk_0.1.bb
poky/meta-qti-gst-prop/recipes/secure-gst/secure-gst.bb
poky/meta-qti-robotics-prop/recipes/imud/imud.bb
poky/meta-qti-sensors-prop/recipes/sensors/sensors-see-qti_git.bb

# prebuilt package
prebuilt_HY11/bt-app_git_aarch64.tar.gz
prebuilt_HY11/bt-cert_git_aarch64.tar.gz
prebuilt_HY11/bttransport_1.0_aarch64.tar.gz
prebuilt_HY11/camx_0.1_aarch64.tar.gz
prebuilt_HY11/chicdk_0.1_aarch64.tar.gz
prebuilt_HY11/fluoride_git_aarch64.tar.gz
prebuilt_HY11/gstreamer1.0-plugins-qtivdec_1.0_aarch64.tar.gz
prebuilt_HY11/hci-qcomm-init_git_aarch64.tar.gz
prebuilt_HY11/imu-ros2node_0.1_aarch64.tar.gz
prebuilt_HY11/imud_1.0_aarch64.tar.gz
prebuilt_HY11/libbt-vendor_git_aarch64.tar.gz
prebuilt_HY11/sensors-see-qti_0-r0_aarch64.tar.gz
prebuilt_HY11/sensors-see-qti_git_aarch64.tar.gz
prebuilt_HY11/sns-imud-ros_1.0_aarch64.tar.gz
prebuilt_HY11/vslam_1.0_aarch64.tar.gz
```


## Install deb directly

安装预编译的 deb 包这种方式的主要步骤是：
1. 找到所有闭源部分编译生成的 deb 包。
2. 删除闭源部分源码和 git 历史记录。
3. 编写一个 bb 文件去安装所有预编译的 deb 包。

`bb` 文件的写法可以参考如下：
```sh
# install-deb.bb
SUMMARY = "Recipe for installing deb package"
DESCRIPTION = "It installs own deb package"
HOMEPAGE = ""
LICENSE = "CLOSED"

DEPENDS += "dpkg-native"

inherit bin_package

SRC_URI += " \
    file://own_xxx_aarch.deb;unpack=0 \
" # ';unpack=0' to turn off the unpacking motion

do_install_append() {
    touch ${STAGING_DIR_NATIVE}/var/lib/dpkg/status
    ${STAGING_BINDIR_NATIVE}/dpkg  --instdir=${D}/ \
    --admindir=${STAGING_DIR_NATIVE}/var/lib/dpkg/ \
    --force-architecture arm -i ${WORKDIR}/own_xxx_aarch.deb  # '--force-architecture' to specify architecture
}

FILES_${PN} += " \
    /usr/bin/ \
    /etc/     \
    /...      \
"
```
> 小提示： 可以根据编译的错误日志找到完整的文件列表。


## Compile and replace with binary

编译二进制并替换的方式的主要步骤如下：

1. 编译源码，拷贝闭源部分生成的二进制文件替换对应源码。
2. 修改步骤 1 对应类 Makefile 文件，以便直接打包二进制而不用再去编译源码。
3. 编译通过，并与原始编译结果对比，确保没有文件缺失。

此方式没有深入研究，所以就这样稍微介绍下了。

# Lessons and Gains of making prebuilt sdk

要准备`prebuilt sdk`， 第一步需要搞明白的就是 `qprebuilt.bbclass` 文件，代码一开始就有如下简要注释说明这个类文件的作用。
```sh
# 路径：apps_proc/poky/meta-qti-bsp-prop/classes/qprebuilt.bbclass

# For recipe inheriting 'qprebuilt', this class allows to:
#    - Generate prebuilt package(s) from 'installed' files
#      (content of ${D}) and place them in DEPLOY_DIR_PREBUILT.
#    - Use prebuilt package instead of fetching and compiling
#      the source, when PREBUILT_SRC_DIR is defined.
```

简单总结起来，这个基类主要做如下三件事， 其他模块（bb 文件）可以继承此基类从实现 `prebuilt` 的功能，详情可以查看源码注释。
1. 如果 `prebuilt` 包不存在，则创建 `prebuilt` 包。
2. 编译依赖文件。
3. 如果 `prebuilt` 包已存在，则使用 `prebuilt` 包并跳过编译。

但是实测发现，上述 1 并未成功执行， 2 和 3 可以成功执行。
> 2021/12/15: 当前时间节点的 SOM 基线此功能还是一个半成品，不适用与所有模块，需要做一些修改，详见下文。

## Locating problem with enhanced log

按照如下方式在 `qprebuilt.bbclass` 文件中添加或修改日志定位问题点。

```sh
bb.plain(msg): Writes msg as is to the log while also logging to stdout.
bb.note(msg): Writes "NOTE: msg" to the log. Also logs to stdout if BitBake is called with "-v".
bb.debug(level, msg): Writes "DEBUG: msg" to the log. Also logs to stdout if the log level is greater than or equal to level. See the "-D" option in the BitBake User Manual for more information.
bb.warn(msg): Writes "WARNING: msg" to the log while also logging to stdout.
bb.error(msg): Writes "ERROR: msg" to the log while also logging to stdout.
bb.fatal(msg): This logging function is similar to bb.error(msg) but also causes the calling task to fail.
```
> 注： `bb，bbclass` 文件大部分内容是用 python 编写，可以直接用如上方式打印日志，如果是 **BASH** 脚本的话请使用：`bbnote "msg",bbdebug level "msg", bbwarn "msg", bberror "msg", bbfatal "msg"`。

另外，我们也可以在编译的时候指定 `Debug` 等级打开默认的日志，譬如：
```bash
# -DD sets the debug level to 2 to open all debug logs.
bitbake -fc -DD compile $1 # `$1` 指编译的 bb
```

## No files to create tarball

打开增强日志后，发现关键信息 "No files to create tarball"， 似乎当尝试去创建预编译包时，找不到对应的中间产物。

```sh
build_hlos.log:19539:NOTE: Running task 5461 of 5555 (/home/user/host/code_space/poseidonhw/PoseidonHW-rb5165-lu1.0-dev/apps_proc/poky/meta-qti-camera-prop/recipes/camx/chicdk_0.1.bb:do_generate_prebuilt)
build_hlos.log:19584:NOTE: recipe chicdk-0.1-r0: task do_generate_prebuilt: Started
build_hlos.log:19586:WARNING: chicdk-0.1-r0 do_generate_prebuilt: **No files to create archive** /home/user/host/code_space/poseidonhw/PoseidonHW-rb5165-lu1.0-dev/apps_proc/build-qti-distro-ubuntu-fullstack-debug/tmp-glibc/work/aarch64-oe-linux/chicdk/0.1-r0/prebuiltdata/HY11_chicdk_0.1_aarch64.tar
```

## do_generate_prebuilt

如上日志由 `qprebuilt.bbclass` 中的 `do_generate_prebuilt` 打印， 关键源码如下。 
```py
# apps_proc/poky/meta-qti-bsp-prop/classes/qprebuilt.bbclass
# Please find what does these sentences mean in the following quote information, which named bitbatke user manual.
SSTATETASKS += "do_generate_prebuilt"
do_generate_prebuilt[dirs] = "${D}"
do_generate_prebuilt[cleandirs] = "${PREBUILT_DIR} ${PREBUILT_DATA_DIR}"
do_generate_prebuilt[sstate-inputdirs] = "${PREBUILT_DATA_DIR}"
do_generate_prebuilt[sstate-outputdirs] = "${DEPLOY_DIR_PREBUILT}"
do_generate_prebuilt[stamp-extra-info] = "${MACHINE_ARCH}"
do_generate_prebuilt[doc] = "Create a prebuilt package"
do_generate_prebuilt[vardeps] = "${@gen_prebuiltvar(d)}"

python do_generate_prebuilt() {
    import shutil
    ...

    for ppackage in ppackages:
        for variant in pbvariants:
            files = d.getVar(variant + "_PREBUILT_FILES_" + ppackage)
            bb.warn("No files to create archive %s-%s-%s" %(files, variant, ppackage))
            stripped = d.getVar("PREBUILT_STRIP_" + ppackage)
            tarball = "%s/%s_%s_%s_%s.tar" % (prebuiltdatadir, variant, ppackage, pv, arch)
            base = prebuiltdir

            # If no file specified quitely quit
            if files:
                files = files.split() # Split files to create tarball
            else:
                bb.debug(1, "No files to create archive %s" %(tarball))
                continue
            ...

python () {
    ...

    if found:
        # Use prebuilt, discard build operations
        for task in d.getVar('PREBUILT_DISCARDED_TASKS').split():
            ...
        bb.build.addtask('do_install_prebuilt', 'do_populate_sysroot', 'do_install', d) # do_install_prebuilt to replace building with installing prebuilt package
        ...
    elif d.getVar('DEPLOY_DIR_PREBUILT'):
        # Create prebuilt tarball(s)
        bb.build.addtask('do_generate_prebuilt', 'do_package', 'do_install', d)
}
```
> `d.getVar()` comes from `apps_proc/poky/bitbake/lib/bb/tests/data.py`.
> [bitbatke user manual](https://www.yoctoproject.org/docs/2.2.4/bitbake-user-manual/bitbake-user-manual.html)
> [dirs]: Directories that should be created before the task runs. Directories that already exist are left as is. The last directory listed is used as the current working directory for the task.
> [vardeps]: Specifies a space-separated list of additional variables to add to a variable's dependencies for the purposes of calculating its signature. Adding variables to this list is useful, for example, when a function refers to a variable in a manner that does not allow BitBake to automatically determine that the variable is referred to.
> [umask]: The umask to run the task under.

首先 `qprebuilt.bbclass` 会去 `$workspace/prebuilt_HY11` 路径查找是否存在预编译包。如若存在，则直接加载并跳过编译；如若不存在，则编译并调用 `do_generate_prebuilt` 创建预编译包。而当前情况是尝试创建预编译包时发现文件为空。到这一步，逻辑就比较清楚了，接下来需要去搞清楚中间产物是什么，然后为什么 Python 脚本找不到这些文件。

## What file is used to create tarball

从 `qprebuilt.bbclass` 文件的如下注释和源码可以知道中间产物是 `all 'installed' files (content of ${D})`， 即通过打包所有 ‘installled (${D})’ 的文件生成 Prebuilt 包。

```py
# apps_proc/poky/meta-qti-bsp-prop/classes/qprebuilt.bbclass

# ### Creating prebuilt package(s)
#
# By default, a prebuilt package is generated with all 'installed'
# files (content of ${D}).
#
# It's possible to strip binaries before packaging by setting
# PREBUILT_STRIP_${PN} variable to "1", default is "0".
#
# It's possible to create several prebuilt packages with different
# content, using PREBUILT_PACKAGES and PREBUILT_FILES_package-name
# variables.
#
# E.g. libvendor-1.8.bb - PN="libvendor" ARCH="aarch64"
#
# PREBUILT_PACKAGES = "${PN}-full ${PN}-stripped ${PN}-minimal"
# PREBUILT_FILES_${PN}-full = "/"
# PREBUILT_FILES_${PN}-stripped = "/"
# PREBUILT_STRIP_${PN}-stripped = "1"
# PREBUILT_FILES_${PN}-minimal = "${bindir} ${libdir}"
# PREBUILT_STRIP_${PN}-minimal = "1"
#
# This will create three archives:
#   libvendor-full_1.8_aarch64.tar.gz
#   libvendor-stripped_1.8_aarch64.tar.gz (stripped content)
#   libvendor-minimal_1.8_aarch64.tar.gz  (stripped content)
#
# These prebuilt packages can then be distribuded to customers.
#
# Note - by default:
# PREBUILT_PACKAGES = "${PN}"
# PREBUILT_FILES_${PN} = "/"

python do_generate_prebuilt() {
    ...

    prebuiltdir = os.path.join(d.getVar('PREBUILT_DIR'), "non-stripped")
    prebuiltstrippeddir = os.path.join(d.getVar('PREBUILT_DIR'), "stripped")
    prebuiltdatadir = d.getVar('PREBUILT_DATA_DIR')
    inputdir = d.getVar('D') # Get ${D}
    licensedir = os.path.join(d.getVar('LICENSE_DIRECTORY'), pn)

    # Copy ${D}
    shutil.copytree(inputdir, prebuiltdir, True)

    # Add license
    shutil.copytree(licensedir, prebuiltdir + "/__LIC__", False)

    # fork and strip
    shutil.copytree(prebuiltdir, prebuiltstrippeddir, True)
    strip_dir(d, prebuiltstrippeddir)
    ...
    stripped = d.getVar("PREBUILT_STRIP_" + ppackage)

    # compress files in "non-stripped" in default
    base = prebuiltdir
    ...
    # If this package is stripped, compress files in "stripped" 
    if stripped and stripped != "0":
        base = prebuiltstrippeddir
}

fakeroot python do_install_prebuilt() { # fakeroot gives the root permission to current process
    # Install license
    cmd = "cp -r %s/__LIC__ %s/%s" % (dest, licensedir, pn)
    (retval, output) = oe.utils.getstatusoutput(cmd)
}
```
从如上源码可以看到，中间产物（包括 License 文件）都被拷贝到了 "non-stripped" 路径， 并 strip(移除调试符号表等信息) 然后拷贝到 "stripped" 路径中。如果当前 package 是 stripped 的，就打包 “stripped” 路径下的文件，否则默认打包 “non-stripped” 路径下的文件。

添加日志进行确认，打印`prebuilt`相关的文件和路径。
```sh
# code
python do_generate_prebuilt() {
    ...
    bb.warn("added by lee to confirm D %s-%s: %s-%s" % (inputdir, prebuiltdir, licensedir, prebuiltstrippeddir))
}

# log output
WARNING: camx-0.1-r0 do_generate_prebuilt: added by lee to confirm D '/home/.../apps_proc/chicdk/tmp-glibc/work/aarch64-oe-linux/camx/0.1-r0/image'-'/home/.../apps_proc/chicdk/tmp-glibc/work/aarch64-oe-linux/camx/0.1-r0/prebuilt/non-stripped': '/home/.../apps_proc/chicdk/tmp-glibc/deploy/licenses/camx'-'/home/.../apps_proc/chicdk/tmp-glibc/work/aarch64-oe-linux/camx/0.1-r0/prebuilt/stripped'
```

至此，基本搞明白中间产物是什么东西了，但当我尝试去编译产物中找对应的文件或路径时，发现怎么都找不到。

## What is 'D'

广告插播， ‘D’ 变量在打包的时多次出现，可是看到它的时候一脸懵逼，所以按照如下方式做了一下基本的确认。
```sh
# Searching in code
$ grep -rHn "'D'" apps_proc/poky
os.environ['D'] = self.target_rootfs

# Searching in Yocto explanation
Meanwhile, DESTDIR is a path within the Build Directory. However, when the recipe builds a native program (i.e. one that is intended to run on the build machine), that program is never installed directly to the build machine's root file system.
```

## Why the file required by tarball does not exist

针对找不到中间产物这个问题，我的猜想是被编译系统清理了， 所以我从三个方向去寻找其缘由，然后三个方向的结果皆印证了我的猜想。

首先，我随便选了一个模块通过如下命令去监控其在编译过程中的产物，最终发现在编译过程会生成相关文件，但是在编译快结束的时候所有文件又被删除掉了。
> 关于怎么知道监控哪一个路径，参见“What file is used to create tarball”章节日志输出。

```sh
watch -n 1 ls -lh apps_proc/chicdk/tmp-glibc/work/aarch64-oe-linux/chicdk/0.1-r0
```

同时，我也尝试从编译日志去找到一些信息， 然后发现了如下关键信息：
```sh
NOTE: recipe chicdk-0.1-r0: task do_rm_work: Started
NOTE: recipe chicdk-0.1-r0: task do_rm_work: Succeeded
```

通过代码查看对应函数，发现此函数的作用是删掉中间产物，关键部分源码如下：
```py
# apps_proc/poky/meta/classes/rm_work.bbclass
do_rm_work () {
    ...

    cd ${WORKDIR}
    for dir in *
    do
        # Retain only logs and other files in temp, safely ignore
        # failures of removing pseudo folers on NFS2/3 server.
        if [ $dir = 'pseudo' ]; then
            rm -rf $dir 2> /dev/null || true
        elif ! echo "$excludes" | grep -q -w "$dir"; then
            rm -rf $dir
        fi
    done
}
```

然后呢， 我也到 [Yocto](https://www.yoctoproject.org/docs/2.5/ref-manual/ref-manual.html#ref-tasks-rm_work) 官网去查找相关信息，找到了如下描述：

```sh
7.1.25. do_rm_work¶
Removes work files after the OpenEmbedded build system has finished with them. You can learn more by looking at the "rm_work.bbclass" section.

6.115. rm_work.bbclass¶
The rm_work class supports deletion of temporary workspace, which can ease your hard drive demands during builds.
...

    INHERIT += "rm_work"
...    
Here is an example:
    RM_WORK_EXCLUDE += "busybox glibc"
```

从官方文档上面的内容也顺便找到了解决方案：在 bb 文件或者 local.conf 按照如下方式修改去拒绝删除。
```py
# add the following to bb file to prevent removing
RM_WORK_EXCLUDE += "${PN}"

# or add the following statement which included your module in local.conf
RM_WORK_EXCLUDE += "camx chicdk ..."
```

## Still "No files to create tarball"

现在预编译包的生成逻辑搞清楚了， 中间产物也保留了， 但是 "No files to create tarball" 问题仍然存在，通过如下代码可以知道，脚本是判断`variant_PREBUILT_FILES_ppackage (HY11__PREBUILT_FILES__chicdk)` 变量或者说路径下面是否有编译文件存在。

```py
python do_generate_prebuilt() {
    ...
    # Create prebuilt archive(s)
    for ppackage in ppackages:
        for variant in pbvariants:
            files = d.getVar(variant + "_PREBUILT_FILES_" + ppackage)
            tarball = "%s/%s_%s_%s_%s.tar" % (prebuiltdatadir, variant, ppackage, pv, arch)
            # If no file specified quitely quit
            if files:
                files = files.split()
            else:
                bb.debug(1, "No files to create archive %s" %(tarball))
                continue
    ...
}
```

从如下代码逻辑来看，似乎`prebuilt`的每个环节都没问题都能逻辑自洽，但是为什么不能自动创建预编译包呢？ 由于看不明白`do_generate_prebuilt[vardeps] = "${@gen_prebuiltvar(d)}"`这种写法，‘不知道’一律当做高通没做好处理，然后时间紧迫，就选择另一种手动的方式来实现了，稍后会介绍。现在来写总结的时候发现，当时应该多加些日志，尝试把 `variant_PREBUILT_FILES_ppackage` 变量改为正确的路径试试，或许会更好些， 不过呢，可能意义也不太大，因为后面还有更多`半成品`的问题遇到。

```py
# 1. apps_proc/poky/meta-qti-bsp-prop/conf/machine/qcs610-odk-64.conf
# Supported prebuilt varaints
PREBUILT_VARIANTS = "HY11 HY22"

# 2. apps_proc/poky/meta-qti-bsp-prop/classes/qprebuilt.bbclass
# Default prebuilt package
PREBUILT_PACKAGES ?= "${PN}" # PN means the recipe name.

gen_prebuiltvar(d):
    ret = []
    ppackages = (d.getVar("PREBUILT_PACKAGES") or "").split()
    pbvariants = (d.getVar("PREBUILT_VARIANTS") or "").split()
    # e.g. HY11_PREBUILT_PACKAGES, HY22_PREBUILT_PACKAGES
    for variant in pbvariants:
        ret.append(variant + "_PREBUILT_PACKAGES")

    # e.g. HY11_PREBUILT_FILES_<package>
    for ppackage in ppackages:
        for variant in pbvariants:
            ret.append(variant + "_PREBUILT_FILES_" + ppackage)

    return " ".join(ret)

# Generate Prebuilt tarball
do_generate_prebuilt[doc] = "Create a prebuilt package"
do_generate_prebuilt[vardeps] = "${@gen_prebuiltvar(d)}"

python do_generate_prebuilt() {
    files = d.getVar(variant + "_PREBUILT_FILES_" + ppackage)
}
```
## "from chicdk was already stripped"

免费赠送一个警告消除，有点强迫症和精神洁癖，所以有些小东西如果不整透彻，心里会增加小疙瘩，譬如如下日志。

```sh
WARNING: chicdk-0.1-r0 do_package: QA Issue: File '/usr/lib/rfsa/adsp/libdsp_streamer_binning.so' from chicdk was already stripped, this will prevent future debugging! [already-stripped]
```

本着心里小疙瘩能少则少的原则，调查一番后，发现在`local.conf`中添加`INSANE_SKIP_${PN}_append = “already-stripped”`可以消除此警告。`${PN}`代表报名，即 bb 文件名。
```sh
INSANE_SKIP_chicdk_append = "already-stripped"
```

## Prepare prebuilt package

### Script to package

既然高通已有的东西不足以成功生成预编译包，我就选择自己准备脚本根据代码逻辑去创建预编译包。脚本内容如下, 将此脚本放置于 "non-stripped" 或者 “stripped” 路径，执行即可创建与编译包，然后执行如下最后两步，此部分源码 SDK 化即完成了。
- 将预编译包放到`apps_proc/prebuilt_HY11`路径下；
- 删除源码。
> 关于选择 "non-stripped" 还是 “stripped” 路径来打包这个问题， 个人理解，如果是做需要再次开发的 SDK，或许 "non-stripped" 更为合适。

```sh
# create_prebuilt_targz.sh
# create tarball
#!/bin/bash

set -e

# Ensure that PWD should be in subdir prebuilt/non-stripped/ of recipe WORKDIR
# e.g: apps_proc/build-qti-distro-ubuntu-fullstack-debug/tmp-glibc/work/aarch64-oe-linux/libgpt/1.0-r0/prebuilt/stripped/
# If we want to put this script into "stripped", we need to modify the following if condition.
function check_pwd()
{
    if [ "$(basename $PWD)" != "non-stripped" ]; then
        echo "please change into subdir prebuilt/stripped/ of recipe WORKDIR"
        return 1
    fi
}


function get_targz_name()
{
    WORKDIR=${PWD/prebuilt*/}
    echo WORKDIR=$WORKDIR

    PV_BASE=$(basename $WORKDIR)
    PV=${PV_BASE/-*/}
    echo PV=$PV
    PN_DIR=$(dirname $WORKDIR)
    PN=$(basename $PN_DIR)
    echo PN=${PN}
    PACKAGE_ARCH_DIR=$(dirname ${PN_DIR})
    PACKAGE_ARCH_BASE=$(basename ${PACKAGE_ARCH_DIR})
    PACKAGE_ARCH=${PACKAGE_ARCH_BASE/-oe-linux/}
    echo PACKAGE_ARCH=$PACKAGE_ARCH
    PREBUILT_TARGZ_NAME=${PN}_${PV}_${PACKAGE_ARCH}.tar.gz
    echo PREBUILT_TARGZ_NAME=${PREBUILT_TARGZ_NAME}
    if [ -z "${PREBUILT_TARGZ_NAME}" ]; then
        return 1
    fi
}

check_pwd
echo OK
get_targz_name
tar cvfz ${PREBUILT_TARGZ_NAME} *
```

删除源码的时候， 有时会遇到如下的编译错误，这是因为其他模块对此模块的某些文件有依赖， 遇到这种情况只需要将对应文件保留即可。被依赖的文件一般是解释性脚本文件或者 API 库的头文件，保留不会影响 SDK 的闭源动作。
```sh
python: can't open file '/home/.../apps_proc/src/vendor/qcom/proprietary/chi-cdk/tools//buildbins/buildbins.py': [Errno 2] No such file or directory
camxlib/0.1-r0/temp/run.do_autogen.5102:1 exit 1 from 'python /home/.../apps_proc/src/vendor/qcom/proprietary/chi-cdk/tools//buildbins/buildbins.py --target=code --gen-code-dir=/home/.../apps_proc/src/vendor/qcom/proprietary/chi-cdk/api//generated/'
```

本以为，从此就顺风顺水，天随人愿，大功告成了，可惜现实反手又是一记响亮的耳光。很多模块并没有明确的依赖关系以及 "non-stripped" 或者 “stripped” 产物，而是各种分离的文件系统置于编译输出目录的不同路径。

### Purely manual copy

仰望着`Ycoto`陡峭的学习曲线，以及闭源源码仓库的各种复杂依赖关系，再加上时间紧迫，我放弃了理清编译系统的处理方式然后修复它们，而是懒惰地选择了手动拷贝并打包对应的文件。

#### Find the bb files

第一步是找到对应模块的 bb 文件，一般通过所有源码所在路径可以找到其对应的 bb 文件（即模块名），通过模块名则可以推测出预编译包的名字。但是更多的时候，由于依赖关系，以及某一路径下面的源码被多个模块使用的情况存在，比较快速的一个确认方式是：直接将对应的源码删掉，然后根据日志找出所有的 bb 文件名。

#### Get the accurate tarball name from log

当对预编译包的名字不确定时，我们可以在编译日志中找到对应模块的预编译包名，譬如 `sensors-see` 在编译日志中打印的预编译包名如下。
```sh
sensors-see-qti_git.bb: Looking for: /home/.../apps_proc/prebuilt_HY11/`sensors-see-qti_git_aarch64.tar.gz`
```

#### Get prebuilt files

除了少数模块可以生成 "non-stripped" 和 “stripped” 目录外，大部分模块并没有明显的预编译产物。针对这种情况，目前发现的比较快捷的方式主要有两种：
- 从 Deb 中解压
- 从编译目录里面找到其对应文件

然后再拷贝对应的 license 文件夹并命名 __LIC__, 最后一起打包为预编译包，以 `sensors-see` 为例总结如下：
```sh
# 1. Get files based on one of the two following ways
ar vx sensors-see-qti_0-r0_arm64.deb
tar -xvf data.tar.xz -C data/
# or
cp build-qti-distro-ubuntu-fullstack-debug/tmp-glibc/sysroots-components/aarch64/sensors-see-qti/* data/

# 2. Get licenses
cp build-qti-distro-ubuntu-fullstack-debug/tmp-glibc/deploy/licenses/sensors-see-qti data/__LIC__

# 3. Make tarball
tar -cjvf sensors-see-qti_git_aarch64.tar.gz data/*
```

### Build from prebuilt package

按照如上方式准备预编译包后，大部分模块都能成功地工作，之前取预编译包，不再编译源码，但是少部分模块会继续编译源码并报错。针对报错的模块，我们需要修改其 bb 文件，按照如下方式去继承 `qprebuilt` 类。
```sh
inherit qprebuilt
```

# Summary

Okay， 谢谢阅读。