title: "A little basic knowledge of the shell"
date: 2019-09-08 13:07:57
categories: Shell
tags:
---
I don't have a good idea what to share for ARTS this week. So I summarize a little knowledge of the shell.

## what is a shell
A shell is a software interface that is ofthen a command line interface that enables the user to interact with the computer. In linux, we can check all supported shell via the following way.
<!--more-->
```bash
lee@lee-server:~$ sudo cat /etc/shells
/bin/sh
/bin/bash
/sbin/nologin
/bin/dash
/bin/tcsh
/bin/csh
```
> bash( Bourne again shell) - rewrited sh, generate more functions.


## what is the differnce between script execution

### First situation
Execute as one child process, once the child process exists and back to parent shell, the related envs will disappear. Such as:
```bash
bash script_name.sh
./script_name.sh # Need to add execute permission in advance. like, chmod u+x script_name.sh
```
> envs: environmental variables.

### Second situation
Execute in the current shell. envs will always work before quit. Such as:
```bash
source script_name.sh
. script_name.sh
```

## Pip
The output of left cmd is used as the input to the right cmd. As follows:
```bash
lee@lee-server:/boot/grub$ cat | ps -f # Create one new process for every external cmd.
UID        PID  PPID  C STIME TTY          TIME CMD
lee      21193  4020  2 11:22 pts/3    00:00:00 bash -c cd "/boot/grub" && bash -i -c "cat | ps -f"
lee      21596 21193  4 11:22 pts/3    00:00:00 bash -i -c cat | ps -f
lee      21775 21596  0 11:22 pts/3    00:00:00 cat
lee      21776 21596  0 11:22 pts/3    00:00:00 ps -f
```

We should avoid to use built-in cmd in pip ,such as , ls , cd ,etc.
> built-in cmd: execute in the current shell. external cmd: create one new process, like top. 


## Input and output redirection
```bash
"<"   # input redirection.
">"   # output redirection
">>"  # output append redirection.
"2>"  # error output redirection.
"&>"  # all output redirection.

# input + output redirection, EOF part redirect as input f cat.
cat > file.txt <<EOF
Hello, Shell!
EOF 
# EOF can be any strings, it is only a conventional writing (End Of File)
```

## Variable
### Definition of variables
```bash
var=value
let var=value
l=ls
var=$(ls -l /etc) 
or
var=`ls -l /etc`
```
> quote: \$\{var\}, sometimes we can only use \$var, sometimes we can't, like, \$\{var\}test != $vartest.

### Scope of the variable
Variable only works in the current terminal or the current shell script. 

If we want to use it in the child process, we need to export it as follows:
```bash
export var(=xxx)
```
If we don't need it anymore, we need to clear it as follows:
```bash
unset var
```

### Env and others
```bash
set # display the current shell variable.
env # view all current env.
echo $var # view var.
echo $PS1 # The current prompt terminal
$?  # The return value of the previous cmd
$$  # the current process's PID
$0  # the current process name 
# Get the parameters passed to the current process
$1 $2 ... ${10} ... ${n}
# Initial for null variable
echo ${2}_   # if [ null ],then: _ else value_ fi
echo ${2-_}  # if [ null ],then: _ else value fi
```

## Config of linux
### All user's config
```bash
/etc/profile
/etc/profile.d/
/etc/bashrc
```

### Current user's config
```bash
~/.bash_profile
~/.bashrc
```

### Loading order
su - root
```bash
/etc/profile
~/.bash_profile
~/.bashrc
/etc/bashrc
```
> It is a better way to switch account.

su root
```bash
~/.bashrc
/etc/bashrc
```
