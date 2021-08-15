title: 'Consolidating the foundation of Linux, useful shell script'
date: 2020-11-09 23:58:16
categories: 
- Linux Tree
- Shell
tags:
---

## Last cmd is successfull or not

```bash
function last_cmd_status()
if [ $? -eq 0 ] # Space at out of '[]'
then
    echo "success"
elif [ $? -eq 1 ]
then
    echo "failed,code is 1"
else
    echo "other code"
fi
```

<!--more-->

## The most-used command in history so far
```bash
history | awk 'BEGIN {FS="[ \t]+|\\|"} {print $3}' | sort | uniq -c | sort -nr | head

find -iname "xxx[abcd]*" -type f -mtime +1  # (File's data was last modified n*24 hours ago.)
```

## Receive input from user

```bash
#!/bin/bash

echo -n "Enter Something:"
read something

echo "You Entered: $something"
```


## ./test.sh X=44 Y=100

```bash
#!/bin/bash

for arg in "$@"
do
    index=$(echo $arg | cut -f1 -d=) # cut X,Y
    val=$(echo $arg | cut -f2 -d=) # cut value behind '='
    case $index in
        X) x=$val;;
        Y) y=$val;;
        *)
    esac
done
((result=x+y))
echo "X+Y=$result"
```

## concatenation strings

```bash
#!/bin/bash

string1="Ubuntu"
string2="Pit"
string=$string1$string2
echo "$string is a great resource for Linux beginners."
# "UbuntuPit is a great resource for Linux beginners." to the screen.
```


## Slicing Strings

```bash
#!/bin/bash
Str="Learn Bash Commands from UbuntuPit"
subStr=${Str:0:20}
echo $subStr

${VAR_NAME:S:L}. Here, S denotes starting position and L indicates the length.
```


## Extracting Substrings Using Cut

```bash
#!/bin/bash
Str="Learn Bash Commands from UbuntuPit"
#subStr=${Str:0:20}

subStr=$(echo $Str| cut -d ' ' -f 1-3)
echo $subStr
```

## Function with return

```bash
#!/bin/bash

function Greet() {
    str="Hello $name, what brings you to UbuntuPit.com?"
    echo $str
}

echo "-> what's your name?"
read name

val=$(Greet)
echo -e "-> $val"
```

## Create Directories

```bash
#!/bin/bash
echo -n "Enter directory name ->"
read newdir
cmd="mkdir $newdir"
eval $cmd

You can also pass the command to execute inside backticks(") as shown below.

`mkdir $newdir`
```


## Create a Directory after Confirming Existence

```bash
#!/bin/bash
echo -n "Enter directory name ->"
read dir
if [ -d "$dir" ]
then
echo "Directory exists"
else
`mkdir $dir`
echo "Directory created"
fi
```


## Reading files

```bash
#!/bin/bash
file='editors.txt'
while read line; do
echo $line
done < $file
```

## Deleting files

```bash
#!/bin/bash
echo -n "Enter filename ->"
read name
rm -i $name
```

## Appending to Files

```bash
#!/bin/bash
echo "Before appending the file"
cat editors.txt
echo "6. NotePad++" >> editors.txt
echo "After appending the file"
cat editors.txt
```

## Test File Existence

```bash
#!/bin/bash
filename=$1
if [ -f "$filename" ]; then
echo "File exists"
else
echo "File does not exist"
fi
```

## Send Mails from Shell Scripts

```bash
#!/bin/bash
recipient="admin@example.com"
subject="Greetings"
message="Welcome to UbuntuPit"
`mail -s $subject $recipient <<< $message`
```

## Parsing Date and Time

```bash
#!/bin/bash
year=`date +%Y`
month=`date +%m`
day=`date +%d`
hour=`date +%H`
minute=`date +%M`
second=`date +%S`
echo `date`
echo "Current Date is: $day-$month-$year"
echo "Current Time is: $hour:$minute:$second"
```

## Sleep

```bash
#!/bin/bash
echo "How long to wait?"
read time
sleep $time
echo "Waited for $time seconds!"
```

## The Wait Command

```bash
#!/bin/bash
echo "Testing wait command"
sleep 5 &
pid=$!
kill $pid
wait $pid
echo $pid was terminated.
```


## Displaying the Last Updated File

```bash
#!/bin/bash

ls -lrRt | grep ^- | awk 'END{print $NF}'
# "^-" : '-' is start of lines, so means files.
```

## Adding Batch Extensions

```bash
#!/bin/bash
dir=$1
for file in `ls $1/*`
do
    mv $file $file.UP
done
```

## Print Number of Files or Directories
```bash
#!/bin/bash

if [ -d "$@" ]; then
echo "Files found: $(find "$@" -type f | wc -l)"
echo "Folders found: $(find "$@" -type d | wc -l)"
else
echo "[ERROR] Please retry with another folder."
exit 1
fi
```


## Cleaning Log Files

```bash
#!/bin/bash
LOG_DIR=/var/log
cd $LOG_DIR

cat /dev/null > messages # file in /var/log
cat /dev/null > wtmp
echo "Logs cleaned up."
```

## Backup Script Using Bash

backup the files which were modified in 24 hours.

```bash
#!/bin/bash

BACKUPFILE=backup-$(date +%m-%d-%Y)
archive=${1:-$BACKUPFILE}

find . -mtime -1 -type f -print0 | xargs -0 tar rvf "$archive.tar"
echo "Directory $PWD backed up in archive file \"$archive.tar.gz\"."
exit 0
```


## Check Whether You're Root

```bash
#!/bin/bash
ROOT_UID=0

if [ "$UID" -eq "$ROOT_UID" ]
then
echo "You are root."
else
echo "You are not root"
fi
exit 0
```

## Removing Duplicate Lines from Files

```bash
#! /bin/sh

echo -n "Enter Filename-> "
read filename
if [ -f "$filename" ]; then
sort $filename | uniq | tee sorted.txt
else
echo "No $filename in $pwd...try again"
fi
exit 0
# The above script goes line by line through your file and removes any duplicative line. It then places the new content into a new file and keeps the original file intact.
```

## System Maintenance

```bash
#!/bin/bash

echo -e "\n$(date "+%d-%m-%Y --- %T") --- Starting work\n"

sudo apt-get update

sudo apt-get upgrade

# upgrade ubuntu
apt list --upgradable
sudo apt-get dist-upgrade
# Official recommendation
sudo do-release-upgrade # -d

apt-get -y autoremove
apt-get autoclean
# Clean all
sudo apt-get clean


dpkg --get-selections |grep linux
uname -r
sudo apt-get remove linux-image-xxxx

sudo apt-get remove --purge $name  
sudo apt-get autoremove --purge $name


dpkg --get-selections | grep 'name'

sudo apt-get purge

# Clean up residual data
dpkg -l |grep ^rc|awk '{print $2}' |sudo xargs dpkg -P 

uname -r
apt-cache policy linux-image-*
dpkg --list | grep linux-image
sudo apt install linux-image-5.4.0-26-generic 
sudo apt-get install linux-headers-5.4.0-26-generic

echo -e "\n$(date "+%T") \t Script Terminated"
```

## checkpid

```bash
checkpid() {
	local i

	for i in "$*"; do
		[ -d "/proc/$i" ] && return 0 
	done

	return 1
}
```
