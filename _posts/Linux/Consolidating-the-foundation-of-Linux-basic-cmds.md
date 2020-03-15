title: "Consolidating the foundation of Linux, basic cmds"
date: 2020-02-06 11:43:20
categories: [Linux,Shell]
tags: Tools
---
## Command Interface

We can enter command interface via the following ways.
1. Excute `init 3` with root. 
> init run at runlevel 3.  
2. Hotkey: Ctrl + ALt + F1/2/3/...

### init
`init` is the first process, it is Commonly located on `/sbin/init`, if kernel can't find `init`, it will try to run `/bin/sh`, if the operation fails , the OS will fail to start successfully. 

`init` has 7 runlevels, we can check the default runlevel and runlevels in `/etc/inittab`. As follows:
```
# Default runlevel. The runlevels used are:
#   0 - halt (Do NOT set initdefault to this)
#   1 - Single user mode(root)
#   2 - Multiuser, without NFS (The same as 3, if you do not have networking)
#   3 - Full multiuser mode(standard runlevel)
#   4 - unused(secure mode)
#   5 - X11(user interface)
#   6 - reboot (Do NOT set initdefault to this)
#
id:5:initdefault:
```

<!--more-->
### Command-related Directoriesran
```
/etc - configuration file directory
/bin - command directory
/sbin -  management command directory
/usr/bin & /usr/sbin Other commands pre-installed on the system
```

## Help Commands
This part is very important, we can learn all the commands with the following help commands.
### man(manual)
`man` has 9 setctions, we can check them via `man man`, as follows:
```
MANUAL SECTIONS
The standard sections of the manual include:

       1      User Commands

       2      System Calls

       3      C Library Functions

       4      Devices and Special Files

       5      File Formats and Conventions

       6      Games et. Al.

       7      Miscellanea

       8      System Administration tools and Daemons

       9      Kernel routines
```

Manual sections are used to distinguish different parameters. For example, when there is a parameter with the same name, that the category is different. we can specify by sections.
```bash
man (1) man # default is 1
```

When we do not know the classification, all manuals can be got as follows.
```bash
man -a passwd
```

### help
Before introducing this command, we need to figure out two concepts. As follows:
1. Builtin commands : come with shell.
2. External commands : the others.

We can figure out what type a command belongs to depend on the following way:
```bash
type <command>  # print the type of command

example:
[lee@lee-server bin]$ type ls
ls is aliased to `ls --color=auto'

[lee@lee-server bin]$ type cd
cd is a shell builtin
```

Different types of commands have different execution formats, as follows:
Builtin commands:
```bash
help <command>
help cd
```

External commands:
```bash
<command> --help
ls --help
```

### info
`info` is more detailed command than `help.`
```bash
info <command>
info ls
```

## Basic commands
### Switch Account
```bash
su - <usr>
```

### pwd
`man pwd`:
```bash
NAME
       pwd - print name of current/working directory

SYNOPSIS
       pwd [OPTION]...

DESCRIPTION
       Print the full filename of the current working directory.

       -L, --logical
              use PWD from environment, even if it contains symlinks

       -P, --physical
              avoid all symlinks

       --help display this help and exit

       --version
              output version information and exit

       NOTE:  your  shell may have its own version of pwd, which Commonly supersedes the version described here.  Please refer to your shell’s
       documentation for details about the options it supports.

```

### ls
Basic usage:
```bash
[lee@lee-server bin]$ ls /home / /home/*
[sudo] password for lee: 
/:
bin  boot  dev	etc  home  lib	lost+found  media  misc  mnt  net  opt	proc  root  sbin  selinux  srv	sys  tmp  usr  var

/home:
lee  lost+found

/home/lee:
bin  blog  Desktop  Documents  Downloads  lee  mbr2.bin  mbr.bin  Music  Pictures  Public  script  server  Templates  Videos

/home/lost+found:
```

Common options:
```bash
-a, --all
      do not ignore entries starting with .
-l    use a long listing format
-r, --reverse
      reverse order while sorting
-R, --recursive
      list subdirectories recursively
-t    sort by modification time
```

### cd
```bash
cd - # change to $(OLDPWD)
```

### mkdir
```bash
mkdir - Create the DIRECTORY(ies), if they do not already exist.
rmdir - Remove the DIRECTORY(ies), if they are empty.

Option:
-p, --parents   create/remove DIRECTORY and its ancestors; e.g., `mkdir/rmdir -p a/b/c' is
                    similar to `mkdir/rmdir a/b/c a/b a'

rm  - Remove (unlink) the FILE(s).

Option:
  -f, --force           ignore nonexistent files, never prompt
  -r, -R, --recursive   remove directories and their contents recursively
```

### cp
Common options:
```bash
-a, --archive
        same as -dR --preserve=all; 保留源文件所有信息
-p     same as --preserve=mode,ownership,timestamps; 保留源文件时间
-R, -r, --recursive
        copy directories recursively
-v, --verbose
        explain what is being done
```



### cat 
```bash
cat - Concatenate FILE(s), or standard input, to standard output.

head - output the first part of files
        With no FILE, or when FILE is -, read standard input. 
    -n   output the fist n lines instead of the first 10(default value)

tail - output the last part of files
    -n  output the last n lines instead of the last 10(default value)
    -f  output appended data as the file grows, eg, get the logs.

wc - print newline, word, and byte counts for each file
    -l, --lines
        print the newline counts


more - More is a filter for paging through text one screenful at a time.
less
```

### Compression and decompression
Common commands:
```bash
# compression rate increases in turn.
tar 
gzip
bzip2
```

Commond suffix:
```bash
.tar.gz 
.tar.bz2 
.tgz

Compress:

```bash
tar -c  
tar czf ，integrate gzip，fast but low compression rate.  common suffix is '.tar.gz'
tar cjf , integrate bzip2 , slow but high compression rate. Common suffix is '.tar.bz2'
```

Extract:
```bash
tar xf -C <out_dir> 
    zxf
    jxf
```


### Wildcard
```bash
*  any string
？ one char,  filea, fileb  not fileab
[xyz]  one of xyz
[a~z]  range between a and z
[!xyz] or [^xyz] not one of xyz
```