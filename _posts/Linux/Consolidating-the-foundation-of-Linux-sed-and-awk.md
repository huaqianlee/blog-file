title: 'Consolidating the foundation of Linux, sed and awk'
date: 2021-04-29 23:08:19
categories:
- Linux Tree
- Shell
tags:
---

# sed

`sed` is a stream editer for filtering and transforming text.

First of all, we need to know the following three points:
- replace command: `s`
- pattern space and hold space
- `man sed`

<!--more-->
## tips and example

### Basis
```bash
sed 's/old/new/' file

# -e , add the commands to be executed
sed -e 's/old/new/' -e 's/old/new/' file
# -> equals
sed 's/old/new/;s/old/new/' file

# add the contents of script-file to the commands to be executed
sed -f <script> file

# Replace and re-write the original file
sed -i 's/old/new/' 's/old/new/' file
```

### separator
```bash
# separator can be '!', '#','@' .... not only '/'
sed 's!/!abc!' file # replace '/' with 'abc'
```

### regex
```bash
sed 's/<regex>/new/' file
sed -r 's/<extended regex>/new/' file
head -5 /etc/passwd | sed 's/...//' # delete the first three characters of the first 5 lines
head -5 /etc/passwd | sed 's/s*bin//' # delete the first bin,sbin,ssbin... of the first 5 lines
grep root /etc/passwd | sed 's/^root//' # delete the root at start of line
sed -r 's/(a.*b)/\1:\1/' file # (a.*b):(a.*b), .* -> means 0 or more any char('.');  `\1` means the first ()
```

### Advanced sed

```bash
# /s/old/new/2 # replace the second match
# /s/old/new/g  # Globally replace
# /s/old/new/p # Print(Output) the replaced line(pattern space) one more time

# p, P, -n 
sed -n '/s/old/new/p' # Only output the replaced line, '-n' to stop the default output.
sed -n '/<regex>/p' 	  # Only output the <regex> line

# d, D
sed '/<regex>/d;=' # when encounter <regex> , delete the pattern space and exit the current sed motion, '=' print the line number


# /<regex>/s/old/new/g
# <line num>s/old/new/g
'/root/s/bash/!/' # replace bash with ! in the line including root. 
1,$s/old/new/g # replace from the first line to the last line
'/^bin/,$s/nologin/!/g' # replace from the bin start of line to the end of line 

# a[ppend],i[nsert],c[modify]
sed '<regex>/a <content>' # append <content> at the next line of <regex>
sed '<regex>/i <content>' # insert <content> at the previous line of <regex>
sed '<regex>/c <content>' # Modify the line of <regex> as <content>

# r,w
sed '<regex>/r <file>'	  # Read <file> and append to <regex>
sed '<regex>/w file"'     # Write the  <regex> line to file
sed -n '/s/old/new/w file.txt' # write the replaced lines to file.txt

# q -> quit, time summarize system resource usage 
time sed '10q' 		# Faster, read and print 10 lines and then quit
time sed -n '1,10p'	# Slower, read all and filter 10 lines

# n,N - Read the next line of input into the pattern space
sed 'N;s/<first line>\n<second line>/<new line>'  

# hold space, line break exists in default.
# h H # Copy pattern space to hold space
# g G # Copy hold space to pattern space
# x   # swith hold space and pattern space
#  4 ways to concatenate and print files in reverse
cat -n file | tac
cat -n file | sed -n '1h;1!G;$1x;$p'
cat -n file | sed -n '!G;h;$p'
cat -n file | sed -n 'G;h;$!d'
```
> Remeber to use `man sed`.


# awk

`awk` is a pattern scanning and processing language, likes a little system.

Fist of all, we need to know the following four points:
- record means line
- field means the content separeted by separator.
- How to write?
```bash
BEGAIN action: BEGIN{}
Main action: {}
END action: END{}
```
- `man awk`

## Tips and example

### Basis
```bash
# The separator is space or tab in default.
$0: Represents the entire line of text.
$1: Represents the first field.
$2: Represents the second field.
$n: Represents the n field.
$NF: Represents the last field.

awk '{print $1,$2,$3}' file # Separate each line with space and tab ,and print the first three field. 
awk -F ',' '{print $1,$2,$3}' file # Separate each line with ',' and print the first three field.
awk '/^menu/{print $0}' /boot/grub2/grub.cfg # print the line starting with 'menu'
awk -F "'" '/^menu/{print $2}' /boot/grub2/grub.cfg # print the second field(kernel version) of lines with "'"
awk -F "'" '/^menu/{print x++,$2}' /boot/grub2/grub.cfg # print kernel version with line number, x is 0 in default
```

## Built-in Variables
```bash
NF: The number of fields in the current input record
NR: The total number of input records seen so far
FS: The input field separator, a space by default, default separator is decided by this var.
OFS: The output field separator, a space by default 
FNR: The input record number in the current input file

# Get username
head -5 /etc/passwd | awk -F ":" '{print $1}' 
head -5 /etc/passwd | awk 'BEGIN{FS=":"}{print $1}'
head -5 /etc/passwd | awk 'BEGIN{FS=":";OFS="-"}{print $1,$2}' # username-$2

# Separete line with ':' and output fields
head -5 /etc/passwd | awk 'BEGIN{RS=":"}{print $0}'

# Add line number before fields
head -5 /etc/passwd | awk '{print NR,$0}'

awk '{print FNR,$0}' /etc/hosts /etc/hosts # Sort all file lines separately
awk '{print NR,$0}' /etc/hosts /etc/hosts # Sort all file lines uniformly

head -5 /etc/passwd | awk 'BEGIN{FS=":"}{print $NF}' # the last field of every record(line)
head -5 /etc/passwd | awk 'BEGIN{FS=":"}{print NF}'  # the total nubmer of fields of every record
```

## Expr

```bash
var = "name"
var = "string1" "string2"
var = $1 # the first field

# Array
arr[subscript]=vaule # subscript could be any character

for(var in arr)
	delete arr[var] # delete array

# Operator
++, --, +=, -=, *=, /+, %=, ^=
+, -, *, /, *, ^

# Comparison
< > <= >= == != ~ !~

# Logical
&& || ?

# Branch
if()
	awk
else if
	awk
[else
	awk
]

# Loop
while()
    awk

do {
    awk
}while()

for(;;) # same as c language
   awk

# Loop control
break
continue
```

### Score example
```bash
# Create score.txt
cat > score.txt <<EOF
student1 70 80 70 90 50
student2 70 80 70 90 50
student3 80 80 70 90 50
student4 60 80 70 90 50
student5 90 80 70 90 50
EOF

awk '{if($2>=80) print $1}' score.txt # output name got more than 80
awk '{if($2>=80) {print $1? print $2}}' score.txt # output name and the first score
head -1 score.txt | awk '{for(c=2;c<=NF;c++) print $c}'# output the first student's score
head -1 score.txt | awk '{for(c=2;c<=NF;c++) sum+=$c;print sum}'# output the total score of the first student
awk '{sum=0; for(c=2;c<=NF;c++) sum+=$c;print sum}' score.txt # output the total score of all students

# Store and print the sum of avarage score
awk '{ sum=0; for(column=2;column<=NF;column++) sum+=$column;avg[$1]=sum/(NF-1)}END{ for(student in avg) print student,avg[student]}' score.txt  

# Store all avarage score and get sum, print avarage of the sum of avarage score
awk '{ sum=0; for(column=2;column<=NF;column++) sum+=$column;avg[$1]=sum/(NF-1)}END{ for(student in avg) sum2+=avg[student];print sum2/NR}' score.txt
```

### Script

#### ARGC and ARGV
```bash
# ARGC : The num of argument
# ARGV : The arguments
cat > arg.awk <<EOF
BEGIN{
    for(x=0;x<ARGC;x++)
        print ARGV[x]
    print ARGC
}
EOF

awk -f arg.awk 1 2 3 4 5
```

#### Score example again 
```bash
cat > result.awk <<EOF
{
    sum = 0
    for( column = 2; column <= NF; column++ )
        sum+ = $column
    avg[$1] = sum / (NF - 1)

    if( avg[$1] >= 80 )
        letter = "A"
    else if( avg[$1] >= 70 )
        letter = "B"
    else
        letter = "C"
    
    print $1,avg[$1],letter

    letter_all[letter]++
}

END{
    for( student in avg )
        sum_all += avg[student]
    avg_all = sum_all / NR
    print "avg_all",$avg_all

    for( student in avg )
        if( avg[student] > avg_all )
            above++
        else if(avg[student] == avg_all)
            equal++
        else 
            below++

    print "above",above
    print "equal",equal
    print "below",below
    print "A:",letter_all["A"]
    print "B:",letter_all["B"]
    print "C:",letter_all["C"]
}
EOF

awk -f result.awk score.txt
```

# Function
```bash
# Numeric Functions
sin(),cos(),int(),rand(),srand()...

# Strings Funcitons
sub(r, s [, t]), index(s, t)

# Custom Functions, need to be before BEGIN
function func ( arg ) {
	awk
	return var
}

awk 'function double(str) {return str str} BEGIN{ print double("Hello awk!")}'
```