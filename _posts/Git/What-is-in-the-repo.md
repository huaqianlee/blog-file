title: What is in the .repo?
date: 2020-10-17 11:20:25
categories:
- Tools
- Git
tags: [Tools,Repo]
---

[How does the repo of android source code work ?](http://huaqianlee.github.io/2019/09/15/Git/How-does-android-repo-work/)

# .repo 

通常情况下， Android 的 `.repo` 里面有如下内容：
```bash
$ ls .repo
manifests  manifests.git  manifest.xml  project.list  project-objects  projects  repo
```

# manifests

`manifests` 路径是项目 manifest 仓的 `git checkout`，其中的 `.git` 是 `manifest.git` 的软链接，追踪 `repo init --manifest-branch` 指定的分支。

```bash
.repo$ ls manifests/.git/
config       HEAD   index  logs     ORIG_HEAD    refs      shallow
description  hooks  info   objects  packed-refs  rr-cache  svn

.repo$ ls manifests.git/
branches  description  HEAD   info  objects      refs      svn
config    FETCH_HEAD   hooks  logs  packed-refs  rr-cache
```

不管远程分支名字是什么，`manifests` 的本地分支命名为 default。
```bash
.repo$ cat manifests/.git/HEAD 
ref: refs/heads/default  

.repo$ cat manifests.git/config  
# cat manifests/.git/config
[core]
	repositoryformatversion = 0
	filemode = true
[filter "lfs"]
	smudge = git-lfs smudge --skip -- %f
[remote "origin"]
	url = https://<url>/platform/manifest.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "default"]
	remote = origin
	merge = refs/heads/<remote_branch_name>
```

# manifests.git

`manifests.git` 是当前项目 `manifest` 仓的一个没有工作空间的 `checkout`，即只 `checkout` `.git` ，追踪`repo init --manifest-url` 指定的 Git 仓。不能手动修改这部分，如果需要修改的话，可重新运行 `repo init` 来更新设置。

## .repo_config.json

缓存 `manifests.git/config`，用来提升 `repo` 的速度。

# manifest.xml

`repo` 使用的 `manifest` ， 此文件由 `repo init --manifest-name` 指定链接到 `manifests` 中的哪一个文件，如下：  
```bash
manifest.xml -> manifests/<manifest-name>.xml # 指向用户希望用来同步源码的 manifest
```

<!--more-->
## Manifest format

以 [default.xml in Android](https://android.googlesource.com/platform/manifest/+/master/default.xml) 为例简单介绍下 manifest 的格式。 
> 详细格式介绍见 [repo Manifest Format](https://gerrit.googlesource.com/git-repo/+/master/docs/manifest-format.md) 。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <!-- 
    name: 独一无二的一个名字， 用作每个项目中 .git/config 的 remote name, 自动用于 git fetch, git remote, git pull and git push 等命令， 大多数时候我们会定义为 ‘origin’.
    alias: 别名，重写 name。
    fetch: 用作所有使用此 remote 的 Git URL 前缀，在后面加上项目名就形成了 ’git clone‘ 需要的链接。
    pushurl: ’git push‘ 的链接前缀，若未定义，则使用 ’fetch‘ 属性。
    review: ’repo upload‘ 的 Gerrit 服务器主机名，此服务器主要用来 review ，如果不指定，’repo upload‘ 命令无效。
    revision: Git 分支名 (e.g. master or refs/heads/master)，若定义，将重写下方 default revision.
   -->
  <remote  name="aosp"
           fetch=".."
           review="https://android-review.googlesource.com/" />
  <!--
    默认属性，remote 或 project 未定义则使用此处定义属性。

    remote: projects 的默认 remote name，在前面 remote 中定义
    revision: projects 的默认分支名
    dest-branch: 默认 review 分支名，不设置则使用 revison 属性作为默认分支  
    upstream: sha1 的来源 Git ref 名，有时我们只需要同步到某 Git ref 指定的 sha1，而不用在 `-c mode` 同步整个 ref 空间，则用 upstream 指定 ref ，revision 指定 sha1.
    sync-j: 同步时的默认并行线程数
    sync-c: true， 表示只同步当前 revision， 而不是整个 ref 空间.
   -->
  <default revision="master"
           remote="aosp"
           sync-j="4" />
  <!-- 
      
   -->
  <manifest-server url="http://android-smartsync.corp.google.com/android.googlesource.com/manifestserver" />
  <!-- 
    path: 当前 project 的 git 工作路径
    revision: Git 分支名，可以来自 refs/heads (e.g. just “master”)， “refs/heads/master”， Tags， SHA-1s，如果不设定，则由 remote 或者 default 中的属性决定.
    dest-branch: repo upload 的 review 分支名. 如果这里和 default 都没有指定此属性，则使用 revision 属性
    groups: project 所属组， 多个组用空格或逗号隔开，所有 projects 都默认属于 “all” ，”name:name“， ”path:path“  
    upstream: 指定 sha1 的 Git ref 名
    copyfile: 复制文件到指定位置
    linkfile: 链接文件到指定位置
   -->
  <project path="build/make" name="platform/build" groups="pdk" >
    <copyfile src="core/root.mk" dest="Makefile" />
    <linkfile src="CleanSpec.mk" dest="build/CleanSpec.mk" />
    <linkfile src="buildspec.mk.default" dest="build/buildspec.mk.default" />
    <linkfile src="core" dest="build/core" />
    <linkfile src="envsetup.sh" dest="build/envsetup.sh" />
    <linkfile src="target" dest="build/target" />
    <linkfile src="tools" dest="build/tools" />
  </project>
  <project path="build/bazel" name="platform/build/bazel" groups="pdk" >
    <linkfile src="bazel.WORKSPACE" dest="WORKSPACE" />
  </project>
  <project path="build/blueprint" name="platform/build/blueprint" groups="pdk,tradefed" />
  <project path="build/soong" name="platform/build/soong" groups="pdk,tradefed" >
    <linkfile src="root.bp" dest="Android.bp" />
    <linkfile src="bootstrap.bash" dest="bootstrap.bash" />
  </project>
  <project path="art" name="platform/art" groups="pdk" />
  <project path="bionic" name="platform/bionic" groups="pdk" />
...
  <project path="tools/treble" name="platform/tools/treble" groups="tools,pdk" />
  <project path="tools/trebuchet" name="platform/tools/trebuchet" groups="tools,cts,pdk,pdk-cw-fs,pdk-fs" />
  <repo-hooks in-project="platform/tools/repohooks" enabled-list="pre-upload" />
</manifest>
```  

## repo hook

[hook](https://android.googlesource.com/platform/tools/repohooks) 主要在允许执行步骤之前（例如在将提交上载到Gerrit之前），运行 linters，检查格式和运行单元测试。

> linter 的维基百科解释是：a tool that analyzes source code to flag programming errors, bugs, stylistic errors, and suspicious constructs.<br/>简单来说就是分析源码，查找问题。

如下是一个 Android 中的使用范例，在战’pre-upload'（即，`repo upload`） 阶段运行名为 ’platform/tools/repohooks‘ 的 hook 。
```xml
 <project path="tools/repohooks" name="platform/tools/repohooks" />
<repo-hooks in-project="platform/tools/repohooks" enabled-list="pre-upload" />
```

# project.list

`repo sync` 基于此文件内容增删 projects ，并更新对应的 `checkout` 工作路径。

```bash
.repo$ more project.list 
art
bionic
bootable/bootloader/edk2
bootable/recovery
build/blueprint
build/kati
build/make
build/soong
cts
dalvik
developers/build
...
device/qcom/common
device/qcom/sepolicy
...
```

# projects

存放 repo 克隆的 manifest 中指定的所有 project 的 git 仓库，repo 将基于此 git 仓库链接 .git 并创建工作路径，然后 checkout 对应分支，并更新 .repo/project.list。一些 git 将进一步拆分到如下的 project-objects。

```bash
.repo$ ls projects
art.git     dalvik.git       frameworks           packages              shortcut-fe.git  vendor
bionic.git  developers       hardware             pdk.git               system
bootable    development.git  kernel               platform_testing.git  test
build       device           libcore.git          prebuilts             toolchain
cts.git     external         libnativehelper.git  sdk.git               tools
```


# project-objects

可以在多个 `git chekcout` 中安全共享的 Git 对象，例如，可以将 foo/bar.git 的不同分支 `checkout` 到 foo/bar-master，foo/bar-release 等， 在 projects 下将为每一个分支创建路径，而  project-objects 下面将会只有一个路径。
```bash
.repo$ ls project-objects/
abl  device  kernel  platform  toolchain
```


# repo

完整的 Repo 工具，接收并处理 Repo-Launcher 转发的命令。
```bash
$ ls .repo/repo/
color.py    command.pyc  editor.py   error.pyc        git_config.py   gitc_utils.pyc  git_ssh  manifest_xml.py   pager.pyc     project.py    pyversion.pyc  repoc                  tests      wrapper.py
color.pyc   COPYING      editor.pyc  git_command.py   git_config.pyc  git_refs.py     hooks    manifest_xml.pyc  progress.py   project.pyc   README.md      subcmds                trace.py   wrapper.pyc
command.py  docs         error.py    git_command.pyc  gitc_utils.py   git_refs.pyc    main.py  pager.py          progress.pyc  pyversion.py  repo           SUBMITTING_PATCHES.md  trace.pyc
```

