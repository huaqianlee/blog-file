title: 原来你是这样的 VCS！
date: 2020-11-13 00:01:38
categories: Git
tags: [Tools,Repo]
---

> 本文的动态图皆来自于莉迪亚·哈莉（Lydia Hallie） 的文章 [CS Visualized: Useful Git Commands](https://dev.to/lydiahallie/cs-visualized-useful-git-commands-37p1)。

# VCS 的发展历史

首先，我们来聊聊 VCS， Version Control System， 即版本控制系统的发展历史。  

## Manual VCS
最初的时候，大家都是通过复制目录来进行版本管理，如下图：  

![manual vcs](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/manual_vcs.png)  

这样做的缺点显而易见：  
- 难以维护
- 难以回溯

<!--more-->
## Central VCS

然后呢，就有了 svn ， 一种集中式版本控制系统，效率一下提升了很多，不过呢仍然有诸多不便，最明显的就是客户端功能较弱。  

![central_vcs](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/central_vcs.jpeg)

- 集中的版本管理服务器
- 支持版本管理与分支管理
- 客户端需要保持与服务器相连

## Distributed VCS

再到后面，Linus 同学就出马了， 不得不说大神就是大神，一直是只能膜拜的存在， 开发了 linux 不说，觉得已有的 VCS 不好用，就自己花了一周多的时间开发了划时代的 git，一种分布式版本控制系统。  

![distributed_vcs](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/distributed_vcs.jpeg)

- 服务端和客户端都有完整的版本库
- 客户端可以在本地进行版本管理
- 能在本地进行回溯等大多数操作

# Git work flow

 在工作流程方面来说的话， 我把 Git 看着四个层级，第一呢， working directory， 即工作区， 第二呢 staging area ，即暂存区，第三呢 local repository， 即本地仓库，第四呢，remote repository ，即远程仓库。  

当我们在本地做了修改，`git add` 之后，内容就提交到了暂存区，即 `index` 文件，`git commit` 之后呢，就提交到了本地仓库，`git push` 之后，就推到了远程仓库。  

反过来，我们可以通过 `git fetch/clone` 从远程仓库取到本地仓库，然后本地仓库的东西可以通过 `git reset --soft` 还原到暂存区，而暂存区的内容可以通过 `git restore --staged` 移交到工作区，工作区的修改我们可以通过 `git checkout/restore` 遗弃掉。  

![git_workflow](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_workflow.png)

# Git tips

接下来，针对我们比较常用的部分分享一些 tips。  

## Documentation

[官方文档](git-scm.com)是我们第一时间应该关注的部分，可以看到上面不仅有教程，还有 cheat sheet 和视频，基本上我们想要的都可以从上面找到的。  

![git_official_doc](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_official_doc.png)


## man

学过 Linux 的都应该比较熟悉这个命令，我们不可能记住所有的命令以及它们的用法，使用的时候就可以通过 `man` 命令去确认相关信息，  Git 这个文档不知道是谁写得，名字取得十分有特色：the stupid  content tracker。  

![man_git](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/man_git.png)

另外一些比较常用的 help 命令：  
```bash
git help        # 常用命令
git help -a     # 所有命令
git help -g     # 常用教程

git <command> --help
git help <command> # 指定命令
```


##  git config

`git config` 命令呢用来配置我们常用的 gitconfig 文件，分为 local，global，sytem 。  

```bash
git config --local      # 当前 git 仓, .git/config
git config --global     # 当前用户, ~/.gitconfig
git config --system     # 当前电脑的所有用户, git 安装路径
```
> Priority: local > global > system

##  git log

`git log` 算使用频率十分高的一个命令，用来查看提交历史。  

```bash
git log --oneline --all -n5 --graph # oneline 代表单行显示， all 代表显示所有分支， graph 代表以图表展示
git log <branch>        # 查看指定分支
```

![git_log](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_log.png)



##  gitk

有时候用命令行的图形化查看提交历史不是那么形象，就可以通过 gitk 来直观的查看。  

![gitk](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/gitk.png)

##  git diff

```bash
git diff [-- filename]          # 比较工作区与暂存区
git diff HEAD                   # 比较工作区与 HEAD
git diff --cached | --staged    # 比较暂存区与 HEAD

git diff HEAD HEAD~1 | HEAD^ / HEAD~2 | HEAD^^ | HEAD^2
# '^2'表示第二个父亲（譬如两个分支 merge 到一起，merged 的分支）, '~2' 表示父亲的父亲
```

## git checkout

`git checkout` 呢主要就是基于当前基点创建新建一个指针，或者基于暂存区更新工作区。  

```bash
git checkout -b <branch> [base SHA-1] # 创建并切换分支
git checkout . | [--] filename # 基于暂存区更新工作区
git checkout SHA-1 # 以分离头指针形式切换到 SHA-1
```

## git merge

### Fast-forward (--ff)
![git_merge_ff](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_merge_ff.GIF)

### No-fast-foward (--no-ff)
![git_merge_noff_confict](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_merge_noff_confict.GIF)

### Merge Conflicts
![git_merge_noff](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_merge_noff.GIF)

## git reset

将本地仓库的 HEAD 指针指向指定的 commit。
```bash
git reset --soft|hard|mixed <commit> [file]
--soft: HEAD 指向 <commit>, 工作区和暂存区不变化
--hard: 所有都指向 <commit>
--mixed: 缺省值,HEAD 和暂存区指向 <commit>
```

### git reset --hard

![git_reset_hard](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_reset_hard.GIF)

### git reset --soft

![git_reset_soft](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_reset_soft.GIF)

## git rebase

`git rebase` 也就是变基操作， 指定父指针进行变基，基本用法如下：

```bash
git rebase [-i] start_sha-1 [end_sha-1]
# start_sha-1: 变基 commit 的父亲
# a. 如果有 end_sha-1, 则变基生成一个分离头指针。
# b. 如果没有 end_sha-1, 则先变基生成一个分离头指针,然后将HEAD 以及分支名等指向此分离头指针。
```
当我们以 `git rebase -i` 的形式执行了变基操作后，就会弹出如下的交付界面，最新的 commit 列在最下面， 所有的操作，下面都有注释，个人觉得比较常用的是 `p, r, s,e,d` 这几个。  

![git_rebase_i](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_rebase_i.png)

### rebase branch

![git_rebase_ff](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_rebase_ff.GIF)

### rebase - drop

![git_rebase_drop](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_rebase_drop.GIF)

### rebase - squash

![git_rebase_squash](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_rebase_squash.GIF)


## git stash

stash 翻译过来就是存储的意思，可以理解为栈，当我们开发过程中突然插入了其他紧急情况时，可以把修改推入栈顶，完成任务后再出栈。  
```bash
git stash           # 存储当前修改
git stash list      # 查看所有存储的修改
git stash pop       # 推出最新存储的修改
git stash apply     # 用最新存储的修改,但是不推出,仍然保存在栈顶
```

## git remote
```bash
git remote add origin remote.git        # 关联远程仓库

# 指定远程分支名
git branch --set-upstream-to=<upstream>
git branch --track <branchname>
git branch -u <upstream>                # -u = set-upstream

# 设置本地分支名为远程分支名,并 push
git push -u origin --all                # push 所有分支
git push set-upstream origin branch 

git pull <remote> <branch>              # 指定 merge 的远程和本地分支
```

## git submodule

```bash
git clone --recursive git://github.com/foo/bar.git

# for already existed
git submodule update --init --recursive
git mv old/path/to/module new/path/to/module
```

## Search history 

```bash
git log --all --grep='search content'

git grep 'search content' $(git rev-list --all)
git rev-list --all | xargs git grep 'search content'
```

##  LearnGitBranching

[pcottle/learnGitBranching](https://learngitbranching.js.org/?NODEMO=&locale=zh_CN)是一个比较好用的在线 Git 练习网站。  

![learninggitbranch](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/learninggitbranch.png)


##  .gitconfig
[Template: dotfiles/.gitconfig](https://github.com/csswizardry/dotfiles/blob/master/.gitconfig) 是一个比较全的 gitconfig 模板，我们可以参考这个模板设计自己的 gitconfig，譬如如下是我的 gitconfig。  
 
![gitconfig](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/gitconfig.png)


# .git directory

我创建了一个简单的演示 demo，做了几次提交，创建了些文件夹和文件，如下：  

![git_demo_tree](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_demo_tree.png)


## .git/HEAD
`HEAD` 相当于是一个指针，指向当前工作的分支或者 commit。  

![git_head](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_head.png)


## .git/index

`index` 就是我们所说的暂存区，其主要由如下四部分内容组成，不过我们可以不用太关心。  
- 一个 12 字节的标头
- 排序的 index 条目
- 通过签名识别的扩展名
- 160 位 SHA-1

通过下图我们可以看到 `index` 是一个二进制文件，我们很难从其内容中看出什么东西。  

![git_index](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_index.png)

不过 `Git` 提供了 `ls-files` 命令来查看暂存区中的内容。  

![git_ls_files](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_ls_files.png)

## .git/config

最高优先级的 local configuration, 同一台电脑上的多个项目可以通过此文件进行差异化配置.  

![git_config](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_config.png)


##  .git/refs
这个文件夹里面存储的就是所有的 commit ‘指针’文件。  

![git_refs](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_refs.png)


##  .git/logs

此文件夹存放的是变更历史，可以看到 HEAD 指针， 分支，远程分支的内容都是一样的，只是远程分支的 message 一直是 ‘update by push’。  

![git_logs](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_logs.png)


##  .git/objects

此文件夹存放所有的对象，即我们管理的内容。  

![git_objects](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_objects.png)

##  commit, tree,blob

`commit, tree, blob` 是 Git 的三个基本单元, 比如我的 Demo 的提交历史如下.  

![git_log_demo](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_log_demo.png)

我们可以通过 `git cat-file -p` 查看 Git 对象的内容，通过 `git cat-file -t` 查看 Git 对象的类型。

### 从第二个 commit (726c6c0) 看进去

![git_commit_content1](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_commit_content1.png)

### 从 HEAD 看进去

![git_commit_content2](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_commit_content2.png)

为了节约空间，任何相同内容的文件 ， 在 Git 看来都是同一个 blob  享元模式 ，享元模式是应用编程比较常见的一个概念，（Flyweight Pattern）主要用于减少创建对象的数量，以减少内存占用和提高性能。感兴趣的下来可以去了解下。享元模式和单例模式有点类似，不过它是针对对象，而单例模式是针对类。譬如相同字符串，只分配一次内存，地址一样，指向同一个对象，可以节省内存。
根目录下的 `README.md` 和 `doc/README.md` 文件内容相同，所以 Git 只存储一份，

## Detached HEAD

分离头指针，这个在实际开发中也比较容易见到，比如我的当前提交历史如下：  

![git_demo_log_graph](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_demo_log_graph.png)

通过 `git checkout 8c19a38` 切到分离头指针。  

![git_detached_head](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_detached_head.png)

`git commit -am` 如下修改。   

![git_detached_head_diff](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_detached_head_diff.png)


`git commit` 后的状态如下图，在切换分支时如果我们不用分支或者 tags 关联此 commit，这部分内容就会被 git 回收掉。 不过很多时候分离头指针在 Git 里还是大有用处的，比如在 rebase 的时候。  

![git_detached_head_push](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/git_detached_head_push.png)

# Repo work flow

一般开始编码工作之前我都会通过 `repo start` 创建对应的 `Git Topic branch`， 完成开发工作后合入主分支，或者直接提交。  
```bash
- A - B - C - D - master .
            \
            E - F - G - topic234
After merge:
- A - B - C - D - master^ - master
            \                /
            E - F - G - topic234
```

![repo_workflow](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/repo_workflow.png)

# Repo tips
repo 的 tips 内容很简单，就下图的这些命令：
- 给所有仓创建 topic 分支
- 清除本地修改，保持和远程仓库一致
- 回退到指定时间点
- 本地镜像多套代码

![repo_tips](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/repo_tips.png)

# .repo directory

![repo_dirctory](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/repo_dirctory.png)

##  repo

repo 由 launcher 和 tool 两部分组成， launcher 是一个 python 脚本，也就是我们用到的 repo ， tool 由其下载 ， tool 也是一系列 python 脚本，我们平时执行 `repo xxx` 命令时，会把后面的参数转发给 tool ，由 tool 来执行。

![repo_launcher_tool](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/repo_launcher_tool.png)


##  repo init

`repo init` 执行流程转换为命令形式如下：  
```bash
--------------------
mkdir .repo; cd .repo
git clone https://gerrit.googlesource.com/git-repo
git clone --bare $URL manifests.git
mkdir -p manifests/.git; cd manifests/.git
for i in ../../manifests.git/*; do ln -s $i .; done
cd ..
git checkout $BRANCH -- .
cd ..
ln -s manifests/$MANIFEST manifest.xml
```

##  repo sync

1. 克隆 manifest.xml 中指定的 git 仓库到 .repo/projects。
2. 基于.repo/projects 中的裸仓库创建工作路径及其中 .git 链接。
3. checkout manifest 中指定的分支到工作路径,并更新 .repo/project.list。


##  manifests

### manifests repo

![repo_manifest](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/repo_manifest.png)

### manifest format

![repo_manifest_format](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/repo_manifest_format.png)


##  repo hook

Repo 提供了一种机制，使用自定义的 python 模块 hook 运行时的特定阶段。所有 hook 都位于一个 git 项目中，该项目基于 mainifests 在 `repo init` 时 checkout 。`repo hook` 在执行步骤之前(例如提交到Gerrit之前)运行 linters, 检查格式及进行单元测试, linter 简单来说就是分析源码，查找问题的工具。
  
[Android 项目](https://android.googlesource.com/platform/tools/repohooks) 中可以找到一个完整的示例。它可以很容易地被任何基于 repo 的项目使用，并不特定于Android。如下是一个 mainifest 设置范例。  

```bash
<project path="tools/repohooks" name="platform/tools/repohooks" />
<repo-hooks in-project="platform/tools/repohooks" enabled-list="pre-upload" />
```

##  project.list

repo 跟踪的所有仓库:    

![repo_project_list](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/repo_project_list.png)

##  projects, project-objects
- projects: manifest 中指定的所有 project 的 git 裸仓库,repo 将基于此 git 仓库生成工作区。
- project-objects:可以在多个本地 git 中安全共享的 Git 对象。

i.e. : 将 foo/bar.git 的不同分支 checkout 到本地 foo/bar-master,foo/bar-release 等, 在 projects 下将为每一个分支创建路径,而 project-objects 下面将会只有一个路径。  

![projects_objects](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/media/projects_objects.png)



