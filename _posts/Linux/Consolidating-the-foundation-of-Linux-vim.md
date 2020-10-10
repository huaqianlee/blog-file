title: "Consolidating the foundation of Linux, vim"
date: 2020-02-06 11:45:32
categories: Linux
tags: [Tools,Vim]
---
## vim

Global config.

```bash
vi /etc/vimrc
```

<!-- more -->
## Mode

### Normal Mode

#### Enter insert mode

```bash
I/i
i - Before cursor
I - Beginning of line

A/a
a - After cursor
A - End of line

O/o
o - Next line
O - Last line

cw -  Replace from the cursor to eh end of the word

```

#### Moves

```bash
# Move around
Use the arrow cursor keys , or "h" to go left, "j" to go down, "k" to go up, "l" to go right.


0 - Go to the first column
^ - Go to the first non-blank character of the line
$ - Go to the last column
g_ - Got to the last non-blank character of line
fa - Go to next occurence of the letter `a` on the line.
    , - Find the next occurrence
    ; - Find the previous occurrence
t, - Go to just before the character `,`
3fa - Find the 3rd occurrence of `a` on this line
F/T - Like `f` and `t` but backward


G -  Go last line
gg -  Go first line

# Go specified line.
NG  - Go to line N
:N  - Go to line N

w - Go to the start of the following word
e - Go to the end of this word

% - Go to the corresponding (, {, [

* - Go to next occurrence of the word under the cursor
# - Go to previous occurrence of the word under the cursor


# search for pattern
/pattern  
n next 
N  above
```

#### Copy/Paste

```bash
y -  Copy the content from the current cursor to next cursor. Controled by arrow keys or `h\j\k\l`
yy -  Copy the current line 
3yy - Copy the following three lines.
y$ -  Copy content from cursor to end of line.

d  -  Delet the content from the current cursor to next cursor. Controled by arrow keys or `h\j\k\l`
dd  -  Delete (and copy) the current line
d$ -  Cut content from cursor to end of line.

p -  Paste
```

#### Modify

```bash
r -  Replace
R -  Continuous replacement
x  -  Delete one char

dt" - Remove everything until `"`

```

#### Undo/Redo

```bash
u -  Undo
Ctrl + r  -  Redo
```

#### Repeat commands

1. `.` will repeat the last command.  
2. `N<command>` will repeat the command N times  

```bash
# examples
2dd  -  will delete 2 lines
3p  -  will paste the text 3 times
100idesu [ESC]  -  will write “desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu desu”
.  -  Just after the last command will write again the 100 “desu”.
3.  -  Will write 3 “desu” (and not 300, how clever).
```

#### Combination command

```bash
<start position><command><end position>
0y$ means

0  -  go to the beginning of this line
y  -  yank from here
$  -  up to the end of this line

ye - yank from here to the end of the word
y2/foo - yank up to the second occurrence of “foo”.
...

# These command can only be used after an operator in visual mode
<action>a<object> 
<action>i<object>

action: d (delete), y (yank), v (select in visual mode)
object:  `w` a word, `W` a WORD (extended word), `s` a sentence, `p` a paragraph. But also, natural character such as `", ', ), }, ]`.

Suppose the cursor is on the first o of `(map (+) ("foo"))`.

vi" -  will select foo.
va"  -  will select "foo".
vi)  -  will select "foo".
va)  -  will select ("foo").
v2i)  -  will select map (+) ("foo")
v2a)  -  will select (map (+) ("foo"))
```


### Insert Mode

`Insert Mode` is edit mode, there is nothing to write.


### Command Mode

```bash
:help
:help <command>

:set nu (number)
:set nonu

:set mouse=a

:set hls[earch]    # highlight seaching result
:set nohlsearch  # Cancel highlighting

:e <patch/to/file>  # Open file.
:saveas <patch/to/file> # Save to/as <patch/to/file>
:w filename , save as filename
:q! # Quit without saving
:qa! # Quit even if there are modified hidden buffers
:wq, :x, or ZZ # Save and quite,(:x only save if necessary)
    Vim  写隐藏文件 .swap ，保存时才替换

# vi x.file y.file    
:bn # Show next file(buffer)
:bp # Show previous file(buffer)
```

### Use shell commands temporarily in Vim.
```bash
# Convenient to copy patch information, etc.
:! (eg, :!ifconfig) 
:！which shutdown
```

### Replace

```bash
:s/old/new      # Replace first ‘old’ of current line.
:s/old/new/g    # Replace all 'old' of current line.
:%s/old/new     # Replace first 'old' of every line of current file.
:%s/old/new/g   # Replace globally all 'old' of current file.
:3,5s/old/new(/g) # Replace (all) 'old' between 3 and 5 line.
```

### Visual Mode

```bash
# enter visual mode
v # Character visual mode, operate in units of characters.
V # Line visual mode, Operate in uinits of lines.
Ctrl + v # Block visual mode, Operate in uinits of blocks.

# operating cmd
'I'     # Insert content in the upper left corner of the block.
'Esc'   # Press behind `I` in succession, insert the same content at the beginning of the block line.
'd'     # Delete the block.
```


## More
> \#Todo. Select rectangular blocks: <C-v>


# CMDs

```
# fun cmds
:h!
:h 42
```
