title: "Git常用及进阶命令总结"
date: 2015-06-11 22:10:41
categories: Git
tags: Tools
---
　　Git是Linux撞始人Linus Towards花一周写出来的分布式版本控制系统，大神终究是大神，这么牛逼的东西只需要一周。之前花了一百多刀买了Linus的原版自传《Just for fun》，基本上是他自己写的，很幽默，有兴趣可以看看。Linus很傲，但是傲得有资本，唯一能无视Jobs的现实扭曲力场，对Jobs的盛情邀请say no转身而去的人。　
　
　　言归正传，Git十分好用，应用也十分广泛,现在最好的代码托管网站Github就是基于git创建的，而且现在大多数公司及个人都在使用它进行代码管理，要熟练使用还是需要花一些苦功夫的，我现在也还只是会基本的应用，更深层次的使用还不熟悉。为了方便自己以后使用，将自己常用的一些命令加以总结，并Google了一些常用及进阶命令，一并列出，方便查询使用。

<!--more-->
##Git配置
```bash
git config --global user.name "huaqianlee"   
git config --global user.email "huaqianlee@gmail.com"
git config --global color.ui true
git config --global alias.co checkout # 配置别名，co 配为checkout 别名， 不过我没用
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global core.editor "mate -w"    # 设置Editor使用textmate
git config -l  # 列举所有配置
```
>用户的git配置文件~/.gitconfig

##Git常用及进阶命令
###常用命令
```bash
git help  #查看帮助，命令忘记了就靠它
git init    #初始化话目录为git仓库
git clean -fd  # 删除无用目录及文件
git clean -fX  # 删除无用文件
git clean # 删除所有untracked文件
```

###添加
```bash
git add file   #添加文件到暂存区
git add .        #将所有修改或者新加文件添加到暂存区   
```

###删除
```bash
git rm file         #删除文件
git rm <file> --cached  # 从版本库中删除文件，但不删除文件
```

###撤销回退
```bash
git checkout — xx  #撤销xx文件修改
git checkout .     #撤销工作区修改
git revert <$id>    # 恢复某次提交的状态，恢复动作本身也创建了一次提交对象
git revert HEAD     # 恢复最后一次提交的状态
git reset <file>    # 从暂存区恢复某一文件
git reset -- .      # 从暂存区恢复所有文件
git reset  –hard HEAD^/HEAD~  #回退到上一版本
git reset  –hard <commit_id>    #回退到指定版本
git reset HEAD file  #取消add文件
```

###提交
```bash
git commit  <file> #提交单个文件
git commit –m “description”   #提交暂存区到服务器
git commit -a           # 等同执行git add、 git rm及git commit
git commit -am "some comments"
git commit --amend      # 修改最后一次提交记录
```

###查看状态记录
```bash
git status        #查看仓库状态
git show ($id)  # 显示某次提交的内容
git log   (file)       #查看（文件）提交记录
git log -p <file>   # 查看每次详细修改内容的diff
git log -p -2       # 查看最近两次详细修改内容的diff
git log --stat      # 查看提交统计信息
git reflog       #查看历史版本号
git log -g #同上，用'log'格式输出
git log -- grep "name" # 搜索包含name的log 
git log record-ID  -l -p #查看指定ID记录，-l:显示一行，-p:显示详细修改
```

###查看差异
```bash
git diff <file>     # 比较当前文件和暂存区文件差异
git diff   #比较所有文件
git diff master..Andylee-Github/master #比较本地和远端仓库
git diff <$id1> <$id2>   # 比较两次提交之间的差异
git diff <branch1>..<branch2> #比较分支
git diff --staged   # 比较暂存区和版本库差异
git diff --cached   # 比较暂存区和版本库差异
git diff --stat     # 仅仅比较统计信息
```

###分支管理  
```bash
git branch  #查看本地分支
git branch  -r    # 查看远程分支
git branch  -a     #查看包括远程文件在内的所有分支 
git branch   <new_branch> # 创建新分支
git branch   -v           # 查看各个分支最后提交信息
git branch   --merged     # 查看已经被合并到当前分支的分支
git branch   --no-merged  # 查看尚未被合并到当前分支的分支

git checkout <branch>  #切换分支
git checkout –b <new_branch>#创建新分支，并切换到新分支
git merge dev    #在当前的分支上合并dev分支
git checkout -b <new_branch> <branch>  # 基于branch创建新的new_branch
git checkout  $id          # 把某次历史提交记录checkout出来，但无分支信息，切换到其他分支会自动删除
git checkout  $id -b <new_branch>  # 把某次历史提交记录checkout出来，创建成一个分支

git branch-d <branch>  # 删除分支
git branch-D <branch>  # 强制删除分支 (未被合并的分支被删除的时需要强制)

git merge <branch>               # 将branch分支合并到当前分支
git merge origin/master --no-ff  # 不要Fast-Foward合并，这样可以生成merge提交
git rebase master <branch>       # 将master rebase到branch，等同于：
#git checkout   <branch> + git rebase master + git checkout  master + git merge <branch>
```

###补丁应用
```bash
git diff > ../sync.patch         # 生成补丁
git apply ../sync.patch          # 打补丁
git apply --check ../sync.patch  # 测试补丁能否成功
```

###暂存管理
```bash
git stash  #暂存当前工作，恢复现场后可继续工作
git stash list  #查看暂存文件列表
git stash apply  #恢复暂存内容，暂存区不删除
git stash drop  #删除暂存文件
git stash pop  #恢复并删除文件
```

###远程分支管理
```bash
git pull                         # 抓取远程仓库所有分支更新并合并到本地
git pull --no-ff                 # 抓取远程仓库所有分支更新并合并到本地，不要快进合并
git fetch origin                 # 抓取远程仓库更新，加下一条指令等同于git pull
git merge origin/master          # 将远程主分支合并到本地当前分支
git checkout   --track origin/branch     # 跟踪某个远程分支创建相应的本地分支
git checkout   -b <local_branch> origin/<remote_branch>  # 基于远程分支创建本地分支，功能同上

git push                         # push所有分支
git push origin branch   # 将本地分支推到远程分支
git push –u origin branch   #推送本地分支到远程仓库，首次提交需要加-u 
git push origin <local_branch>   # 创建远程分支， origin是远程仓库名
git push origin <local_branch>:<remote_branch>  # 创建远程分支
git push origin :<remote_branch>  #先删除本地分支(git br -d <branch>)，然后再push删除远程分支
```

###远程仓库管理
```bash
git remote  #查看远程库的信息
git remote –v  #查看远程库的详细信息
git remote show origin           # 查看远程服务器仓库状态
git remote add origin git@github:robbin/robbin_site.git         # 添加远程仓库地址
git remote set-url origin git@github.com:robbin/robbin_site.git # 设置远程仓库地址(用于修改远程仓库地址)
git remote rm <repository>       # 删除远程仓库

git clone https://github.com/AndyLee-Github/cartboon.git   #从远程仓库中克隆
git clone --bare robbin_site robbin_site.git  # 用带版本的项目创建纯版本仓库
scp -r my_project.git git@git.csdn.net:~      # 将纯仓库上传到服务器上

mkdir robbin_site.git + cd robbin_site.git + git --bare init # 在服务器创建纯仓库
git remote add origin git@github.com:robbin/robbin_site.git    # 设置远程仓库地址
git push -u origin master                                      # 客户端首次提交
git push -u origin develop  # 首次将本地develop分支提交到远程develop分支，并且track
git remote set-head origin master   # 设置远程仓库的HEAD指向master分支
```

###命令设置跟踪远程库和本地库
```bash
git branch --set-upstream master origin/master
git branch --set-upstream develop origin/develop
```

>目前先这么多，后续再补充更高级的命令， 也可参考：[git进阶](http://www.imooc.com/article/1089)，[git资料整理](https://github.com/xirong/my-git)。
