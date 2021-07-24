title: "How does the repo of android source code work ?"
date: 2019-09-15 17:40:17
categories:
- Tools
- Git
tags: [Tools,Repo]
---
在 `android` 源码中，主要用 [**Repo**](https://android.googlesource.com/tools/repo) 和 [**Git**](https://git-scm.com/) 来进行版本管理。`Repo` 是一个由谷歌构建，运行在 Git 之上的仓库管理工具，其让多项目管理变得更容易，尤其对于基本的网络操作，譬如，下载由上百个项目组成的 Android 源码。

# Repo 的组成和基本使用
## Repo launcher 
`Repo` 的第一部分，其是一个 `Python` 脚本，主要用来获取完整的 `Repo` 工具并转发接收到的命令 .
## Repo Tool
`Repo` 的第二部分，由 `Repo launcher` 下载到 `$srcDir/.repo/repo`，其是主要功能部分，处理 `Repo launcher` 转发的命令。
<!-- more -->
## 官方的获取方式
```bash
mkdir ~/bin
PATH=~/bin:$PATH

curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

or

sudo apt-get install repo
```

## 官方源码下载方式
```bash
repo init -u https://android.googlesource.com/platform/manifest -b android-4.0.1_r1
repo sync [-c --no-tags]
```

# Repo 怎么工作
下载代码时 `repo` 主要工作流程如下：
1. `repo init` 在当前路径创建 `.repo` 文件夹并克隆 [repo 的 git 仓库](https://android.googlesource.com/tools/repo)到 `.repo/repo`（即 `Repo Tool`）。
2. 以 [`--bare`](https://git-scm.com/book/en/v2/Git-on-the-Server-Getting-Git-on-a-Server#_getting_git_on_a_server) 方式克隆 `-u` 选项指定的 `git` 仓库（没有工作空间的仓库）到 `.repo/manifests.git`。 
3. 创建 `.repo/manifests` 目录，创建 `.repo/manifests/.git` 到 `.repo/manifests.git` 的符号链接，将 `manifests` 转换为 Git 仓库。 
4. **Checkout** `-b` 选项指定的分支，并创建 `.repo/manifests` 目录中的指定文件（通过 `-m` 指定，通常默认为 `.repo/manifests/defualt.xml`）的符号链接 `.repo/manifest.xml`。
5. `repo sync` 将 `manifest.xml` 和 `local_manifest.xml` 中每一个 `project` 的 `git` 仓库克隆到 `.repo/projects`。
6. 通过链接到相应空仓库的 `.git` 创建工作路径， **checkout**  `manifest` 中指定的分支，并更新 `.repo/project.list`。 
> 项目存在的情况下， 一般执行 `git pull [--rebase]`来下载更新源码。

`repo init`的大体流程上如下:
```
 repo init -u $URL -b $BRANCH -m $MANIFEST
  --------------------
  mkdir .repo; cd .repo
  git clone https://android.googlesource.com/tools/repo
  git clone --bare $URL manifests.git
  mkdir -p manifests/.git; cd manifests/.git
  for i in ../../manifests.git/*; do ln -s $i .; done
  cd ..
  git checkout $BRANCH -- .
  cd ..
  ln -s manifests/$MANIFEST manifest.xml 
```
> 我们可以通过 `repo --trace init ...` 来追踪执行过程  

# VCS(Version Control System) 的使用
## 常见工作流程
1. repo start 创建一个新的 topic 分支
2. git add
3. git commit
4. repo upload (or: git push origin HEAD:refs/for/branch)

## 常见工作命令
|Command|Description|
|:-|:-|
|repo init|	Initializes a new client.|
|repo sync|	Syncs the client to the repositories.|
|repo start|	Starts a new branch.|
|repo status|	Shows the status of the current branch.|
|repo upload|	Uploads changes to the review server.|
|git add|	Stages the files.|
|git commit|	Commits the staged files.|
|git branch|	Shows the current branches.|
|git branch [branch]|	Creates a new topic branch.|
|git checkout [branch]|	Switches HEAD to the specified branch.|
|git merge [branch]|	Merges [branch] into current branch.|
|git diff|	Shows diff of the unstaged changes.|
|git diff --cached|	Shows diff of the staged changes.|
|git log|	Shows the history of the current branch.|
|git log m/[codeline]..|	Shows the commits that aren't pushed.|

## help

```bash
man repo
repo help
repo help <cmd>
repo <command> --help
```

# Topic Branch

一般我会在本地创建不同的 topic 分支来维护不同的修改，

## Creating topic branches
```bash
$ repo start branchname .
```

## To check new branch
```bash
$ repo status .
```

## To assign the branch to a particular project
```bash
$ repo start branchname project
```

## 切换分支
```bash
$ git checkout branchname
```

## To see a list of existing branches
```bash
$ git branch
or...
$ repo branches
```

# Reference
[stack overflow.](https://stackoverflow.com/questions/6149725/how-does-the-android-repo-manifest-repository-work)  
[Source Control Tools.](https://source.android.com/setup/develop)