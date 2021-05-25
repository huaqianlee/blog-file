title: 'Consolidating the foundation of Linux, shell'
date: 2021-04-29 23:08:16
categories: Linux
tags:
---

# Basic

Here is [A little basic knowledge of shell](http://huaqianlee.github.io/2019/09/08/Linux/A-little-basic-knowledge-of-the-shell/).

## env
```bash
$USER
$UID
$PATH

set | more # check the variables including shell-local variables(including shell functions)
env | less # check the variables except shell-local variables(including shell functions)
```

## Parameters

Here is a cheetsheet about parameters of shell.

| Parameters | Comments                              |
|------------|---------------------------------------|
| $0         | script name                           |
| $<n>       | the <n>th parameter                   |
| $#         | nums of parameters                    |
| $@         | All parameters, could be a list       |
| $*         | All parameters, but behave as a whole |
| $$         | PID of the current progress           |
| $?         | return of last cmd                    |
| $!         | PID of the last background cmd        |


<!--more-->

## Expression

Here is some expression cheatsheet.

|         | Expression         | Comments                           |
|---------|--------------------|------------------------------------|
| Integer | -eq                | equal to                           |
|         | -ne                | not equal to                       |
|         | -gt                | greater than                       |
|         | -lt                | less than                          |
|         | -ge                | greater than or equal to           |
|         | -le                | less than or equal to              |
| String  | -z "$str1"         | str1 is empty or not               |
|         | -n "$str1"         | str1 is not empty or not           |
|         | "$str1" == "$str2" | str1 equals to str2 or not         |
|         | "$str1" != "$str2" | str1 doesn't equals to str2 or not |
|         | "$str1" =~ "$str2" | str1 includes str2 or not          |
| File    | -f $filename       | is file                            |
|         | -e $filename       | does file exist                    |
|         | -d $filename       | is directory                       |
|         | -s $filename       | is not empty file                  |
|         | ! -s $filename     | is empty file                      |
| Logical | -o, \|\|           | or                                 |
|         | -a, &&             | and                                |
> `man bash`

# Syntax

Here is some  usages of syntax and things.

## Array

```bash
IPS=(192.168.1.1 192.168.1.2 192.168.1.3)
# all values:
echo "${IPS[@]}"

# nums
${#IPS[@]}

# The first
${#IPS[0]}
$IPS


# get subscript
a=('a' 'b' 'c'): for i in ${!a[@]}; do echo $i; done
0
1
2
```

## Branch

```bash
if [ ]; then
	:
elif; then
	:
else
	:
fi

# How to Judge if the curren user is  root
if [ $UID = 0 ]; then
	echo ""
fi

name="aa"

case $name in    
    "aa")
    echo "name is $name"    
    ;;    
    "")
    echo "name is empty"    
    ;;    
    "bb")
    echo "name is $name"    
    ;;    
    *)
    echo "other name"    
    ;;

esac # reverse case
```

## Loop

```bash
for filename in `ls *.txt` # $(ls *.txt)
do
    mv $filename $(basename $filename .txt).sh
done

for ((;;))
do
	:
done

while [test]
do
	:
done

while : 

until # Contrary to while

break
continue


for name in /etc/profile.d/*.sh
do
    if [ -x $name ] ; then
        . $name
    fi
done

for index in {1..50}
do
    context
done

# C style:
for ((i=0 ; i<10; i++));do
    echo -n "$i"
done

for i in $@; do
    context
done

for i in {5..15..3};do # From 5 to 15 , print 5 + 3n
    echo "$i"
done

while [ "$input" != "yes" ]
do
    read -p "Please input yest to exit this loop:" input
    sleep 1
done

for x in `seq 1 5`; do # or `seq 10`
	echo $x
done

while ((a<=LIMIT)); do
    echo "$a "
    ((a += 1))
done

# shift to handle the parameters
while [ $# -ge 1 ]
do
    if [ "$1" = "help" ] ; then

    fi

    shift # shift 1 parameter to the left until there is only one
done
```

## Function

```bash
function func() {
	:
}

func() {
	:
}

return=$(func)
return=$?

```


## Special symbols

Here is just some special symbols.

```bash
\   # reverse
;   # ls;cat a.txt 
''  # Does not parse variable, likes '$var'
""  # Parsing the variable and replace with its value 
` ` ,$() #  execute command, but '$()' is better
\n\r\t
\$\" \\
()
(())
${} # for variable

[] # test or array
[[]] # test expression 

<, > 
{}
{0..9}
+-*/%
><=
&& || !
#
: # empty command
.
~ # home
,
*
*?
$
|
&
_
`"'
```

## Operation

```bash
# =, +, -, *, /, **, %

let "var=value" 
# equals to
(( var=value ))
(( a++ ))
$(( 4 + 5 ))
num=`expr 4 + 5`
```

## Exit

```bash
# If 'exit 0' exists in func, this won't quit the current script.
exit 0 # Nomal exit; Non-zero abnormal exit.
exit # Return the return value of the previous command
$? # Get the return value

return 0  # recomanded in function
```

## test

```bash
# man test

# test equals to []
test -f file 
# equals to
[ -e file]

[ 5 -gt 4 ]
```

## Variable

Here is four ways to use variable better.
- Prefer local variables in function
- Make global variables readonly
- Always refferred a variable with "${var}"
- Env for ${ALL_CAPS}, local variables for ${lower_case}

```bash
# local var 
checkpid() {
	local i

	for i in "$*"; do
		[ -d "/proc/$i" ] && return 0 # return is recommanded in function, exit 0 works well too
	done

	return 1
} 

export var
unset var


# readonly for the static variable that could be modified
readonly MY_PATH=/home/lee/bin

# If $1 is empty, take init_value as the initial value
name=${1:-init_value}
```

## Singnal and trap

```bash
# kill -l to list all signals
while :
do
    # capture signal 15 (default) and send 'echo signal 15'
    trap "echo signal 15" 15    
    sleep 1
    # capture signal 2 and send 'echo signal C-C'
    trap "echo signal C-C" 2    
    sleep 1
    echo $$ # print the current PID
done
```

## regex

```bash
# Meta character:
'.' - Single char except linebreak
'*' - The char before it appears any times
'[]' - Any char in []
'^' - Start of line
'$' - End of line
'\' - Reverse

# Extended Meta character:
'+' - The expr(char) before it appeard more than one times
'?' - The expr before it appeard 0 or 1 time
'|' - or


`find -regex pattern`

sed -i "s/oldstring/newstring/g" `grep oldstring test/ -rl`
grep '^lee'  # start with lee
grep 'bash$' /etc/passwd # end with bash
grep '^root|bash$' passwd


touch /tm/{1..9}.txt 

find *txt -exec rm -v {} \;

# Cut with space and get the first string
grep <pattern> <path> | cut -d " " -f 1

cut -d ":" -f7 /etc/passwd | uniq -c # count shells
cut -d ":" -f7 /etc/passwd | sort | uniq -c | sort -r
```

## IO

```bash
command < input-file > output-file	# rewrite
command >> output-file 			# appending
```

## '!' event designators

When the letter that follows is not space, line break, enter, = , (, it means substitution, likes the pointer of c language. 

```bash
# like the pointer of c language, ${!C} = "Hello"
B="Hello";C="B";value=${!C};echo result: $value
# or
B="Hello";C=B;value=${!C};echo result: $value

!n # the <n>th command of 'history'
!-n # the <n>th command from the bottom of 'history'
!!  # equals to !-1, a alias, 'sudo !!, !!<missing char>'
!$ # parameters of last command
!str  # the latest command that starts with str
!?str # the latest command that includes str
```


# Template

Pay attention to accumulation and form your own set of templates.

1. function
2. source script
3. `type` to understand function
4. $() to get the output of command and function.
5. function and 'here documents' to quote.
6. bash -x
7. msg function to print log

```bash 
msg ()
{
	echo "MSG:$(date): $*"
}

cmd << delimiter
	Here Document
delimiter

# <<- to remove tab at start of lines
cmd <<- delimiter
	Here Document
delimiter

cat << EOF > output.sh
    echo "This is output"
    echo $1
EOF

cat << "EOF" > output.sh
echo "This is output"
echo $1 # keep output '$1'
EOF
```

## Comment

Here is three ways to comment.

```bash
# 1. 
\#
# 2. 
:'

'
# 3. 
: << EOF

EOF
# or
cat >> EOF > /dev/null

EOF
```

## Encapsulation

```bash
error() {
    printf "${red}!!! %s${reset}\\n" "${*}" 1>&2
}


cat <<HELPMSG
usage $0 [OPTION]... [ARGUMENT]...

HELPMSG

# Single-quote heredocs leading tag to prevent interpolation of text between them.
cat <<'MSG'

MSG

help_wanted() {
[ "$#" -ge "1" ] && [ "$1" = '-h' ] || [ "$1" = '--help' ] || [ "$1" = "-?" ]
}

# function
# one function for one thing
if help_wanted "$@"; then
    usage
    exit 0
fi
```

## tips

Here is some better ways to write shell script.

1. Prefer local variables in function
2. Make global variables readonly
3. Always refferred a variable with "${var}"
4. Env for ${ALL_CAPS}, local variables for ${lower_case}
5. Printf is preferable to echo.
6. And some others as follows.

```bash
# Use = instead of == for String Comparisons
value1="tecmint.com"
value2="fossmint.com"
if [ "$value1" = "$value2" ]

# Use Double Quotes to Reference Variables
for name in "$names"; do
        echo "$name"
done

eval # execute arguments as a shell command(multiple commands)

cp | mv test.sh{,.bk}
cp | mv test.sh.bk{,}

echo {file1,file2}\ :{\ A," B",' C'}
file1 : A file1 : B file1 : C file2 : A file2 : B file2 : C
# Space needs to appear with \, ", '.



`set -e` # Add at the beginning, exit if any error occurs
# Despite error, still continue to execute some commands 
<cmd> || true
# or 
set +e ; <cmd>

# Add at the beginning, print the excute process
# bash -x myscript.sh
# If you only want debug output in a specific section of the script, put set -x before and set +x after the section.
set -x 
# Display undefined variable
set -u 
# don't hide errors within pipes, stop the whole pipes when anyone fails
set -o pipefail 
# abort on nonzero exitstatus
set -o errexit   
# abort on unbound variable
set -o nounset   

nohup foo | cat & # if foo must be started from a terminal and run in the background.
```

## shellcheck

Always check for syntax errors by running the script with `bash -n myscript.sh`, or use `shellcheck`.

```bash
 apt-get install shellcheck

 shellcheck xxx.sh
```

## whiptail

Display dialog boxes from shell scripts.

```bash

#!/bin/bash
whiptail --yesno "would you like to continue?" 10 40
RESULT=$?
if [ $RESULT = 0 ]; then
  echo "you clicked yes"
else
  echo "you clicked no"
fi
```

## Suggestions

```bash
# Avoid:
rm -rf -- "${dir}"

# Good:
rm --recursive --force -- "${dir}"


# Don?t use:

  cd "${foo}"
  [...]
  cd ..
# but

  (
    cd "${foo}"
    [...]
  )
# pushd and popd may also be useful:

  pushd "${foo}"
  [...]
  popd
```