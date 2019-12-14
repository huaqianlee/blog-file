title: "Oh, the Git! - part 1"
date: 2019-11-17 23:38:05
categories: Git
tags: [Tools]
---
# Preface
Git has always been a must-have skill for developers, I will submize a series of blogs related to it, although I don't know too much about git now.

[Pro Git](https://git-scm.com/book/en/v2) is the best guide of git, I need to read it when I have plenty of time so that I can check for gaps.

# VCS(Version Control System)

## Central VCS
Central VCS mainly includes `SVN` and `CVS`, its newwork architecture is client-server.
![Central VCS](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/Central%20VCS.jpg)
<!-- more -->
Advantages:
+ Centralized version management.
+ File version management and branch management.

Disadvantages:
+ The client must remain connectec to the server at all times.

## Distributed VCS
Distributed VCS mainly includes `Git` and `Mercurial`,its network architecture is distributied.
![Distributed VCS](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/Distributed%20VCS.jpg)

Advantages:
+ Complete repositories on both server and client.
+ The client can manage the version independently.
+ Most operations without relying on the server.

# Config
## Config user
```bash
git config --[ local | global | system ] user.name "your_name"
git config --[ local | global | system ] user.email "your_email@domain.com"   # email notification

git config --local # Valid for the current repository, if no option defualts to local
git config --global # Valid for the current user.
git config --system # Valid for all user.
```
> local - .git/config.<br>global - ~/.gitconfig.<br>system - git installation path.

## Check configuration
```bash
git config --list --local # Highest priority
git config --list --global # Higher priority
git config --list --system # Low priority
```

## Clean configuration
```bash
git config --unset --local user.name
git config --unset --global user.name
git config --unset --system user.name
```

# Basic usage
## Init git repository 
```bash
cd <project>
git init

or 

git init <project>
```

## Work flow

Basic cmds:
```bash
git add [<file> | .]  # . : All files of current directory.
git commit [--allow-empty] [-m <msg>]
git push
```
> `git <cmd> --help` for the details.

Work flow:

![Work flow](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/vcs_work_flow.jpg)

# Tips
## Rename
We can rename one files as follows:
```bash
mv name new_name
git add new_name
git rm name
```
The better way:
```bash
git mv name new_name
```

## Log
```bash
git log --oneline -n<number> # -n : last <number> record 
git log --onelie --all -n5 --graph # --all: all branches. 
git log branch
```

## UI
We can check the information of repository through UI as long as we install `gitk`.
```bash
gitk # open graphical interface.
gitk file
```

## More tips
```bash
# info from remote repository.
author # who did the first commission, `git cherry-pick` won't change it
committer # who did the last commission.
tag # tag for project stage.

# cmds
git help --web cmd  # View cmd's help by web
git checkout -b <branch> # Create and checkout <branch>
git commit -am # git add + git commit -m, not suggested.
git reset --hard # clean staging area and working dirctory
git show # Shows one or more objects (blobs, trees, tags and commits).
git blame # Show what revision and author last modified each line of a file.
git stash # Stash the changes in a dirty working directory away.
git stash pop # Pop the stashed changes.
```
> `-` : single char options, like -m , -a;<br> `--`: multi char options, like --web, --hard; 










