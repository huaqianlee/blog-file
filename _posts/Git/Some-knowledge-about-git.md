title: "Oh, the Git! - Basic"
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
+ Supports file version management and branch management.

Disadvantages:

+ The client must remain connected to the server at all times.

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
git add [<file> | .]  # . : All unstracked files of current project.
git commit [--allow-empty] [-m <msg>]
git commit --amend # apend the current staging area to last commit.
git push
```

Work flow:

![Work flow](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/vcs_work_flow.jpg)

# Tips

I list some commands I often use as follows.

## help

```bash
git help 
git help -a/-g 
git <command> --help
git help <command>
```

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

## log

```bash
git log --oneline -n<number> # -n : last <number> record 
git log --onelie --all -n5 --graph # --all: all branches. 
git log <branch> # check specified branch
```

## diff

```bash
git diff [-- filename] # woking directory compares to staging area.
git diff HEAD # woking directory compares to HEAD
git diff --cached | --staged  # staging area compares to HEAD

git diff HEAD  HEAD~1 | HEAD^ / HEAD~2 | HEAD^^ | HEAD^2
# '^2' means the second parent
# '~2' means the parent of its parent
# A node can contain multiple sub-nodes (checkout multiple branches)
# A node can have multiple parent nodes (multiple branches merged)
```
> `--` of `-- filename` is to disambiguate. 

## checkout

```bash
git checkout -b <branch> # Create and checkout <branch>
git checkout # Switch branches or restore working tree files
git checkout . | [--] filename  # Restore current git or specified files. 
git checkout SHA-1 # Switch to SHA-1, detached HEAD situation.
git checkout -b new_branch  base_branch_or_commit # Create and swith new_branch based on branch or commit.
```

## reset

```bash
git reset HEAD [-- filename]# HEAD and Staging area ponit to HEAD, unstage files.
git reset --hard # clean staging area and working dirctory, 

git reset --soft|hard|mixed <commit>
--soft: HEAD points to the specified commit, staging area and woking directory keep as they are. 
--hard: HEAD, Staging area and woking directory point to the specified commit.
--mixed: default option, HEAD and Staging area point to the specified commit, woking directory keep as it is.
```

## rebase

```bash
git rebase -i sha-1
# restore commits
# 
```

## stash

```bash
git stash # Stash the changes in a dirty working directory away.
git stash list # List all stash modifications.
git stash pop # Pop the lateset stashed changes.
git stash apply # Apply the lateset stashed changes, and keep it in list.
```

## branch

```bash
git branch -v # Check all local branches.
git branch -av # Check all branch included remote branches.
git branch -d | -D brnach 
git branch branch_name old_branch | sha1  # Create branch_name based on sha1
git checkout -b new_branch old_branch | sha1
```

## UI
We can check the information of repository through UI as long as we install `gitk`.
```bash
gitk # open graphical interface.
gitk file
```

## More
```bash
# info from remote repository.
author # who did the first commission, `git cherry-pick` won't change it
committer # who did the last commission.
tag # tag for project stage.

# cmds
git help --web cmd  # View cmd's help by web
git tag [-d] <tagname> [<commit>] # Create [delete] a tag reference in refs/tags/.
git commit -am # git add + git commit -m, not suggested.
git reflog # record when the tips of branches and other references were updated in the local repository

git show # Shows one or more objects (blobs, trees, tags and commits).
git blame # Show what revision and author last modified each line of a file.

git cat-file -t # Check type of object.
git cat-file -p # Check content of object
find [dir] -type f # Find all files in current/[dir] directory.
```
> `-` : single char options, like -m , -a;<br> `--`: multi char options, like --web, --hard; 


# .gitignore

[github/gitignore](https://github.com/github/gitignore).
```bash
# c.gitignore
# Prerequisites
*.d

# Object files
*.o
*.ko
*.obj
*.elf

# Linker output
*.ilk
*.map
*.exp

# Precompiled Headers
*.gch
*.pch

# Libraries
*.lib
*.a
*.la
*.lo

# Shared objects (inc. Windows DLLs)
*.dll
*.so
*.so.*
*.dylib

# Executables
*.exe
*.out
*.app
*.i*86
*.x86_64
*.hex

# Debug files
*.dSYM/
*.su
*.idb
*.pdb

# Kernel Module Compile Results
*.mod*
*.cmd
.tmp_versions/
modules.order
Module.symvers
Mkfile.old
dkms.conf
```