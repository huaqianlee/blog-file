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
I/i
i - Before cursor
I - Beginning of line

A/a
a - After cursor
A - End of line

O/o
o Next line
O Last line

Move around:  Use the cursor keys, or "h" to go left, "j" to go down, "k" to go up, "l" to go right.

### Insert Mode
y  yy 3yy 

y$: copy content from cursor to end of line.

d dd 3dd 
d$: cut content from cursor to end of line.

p: paste
u: Revoke
Ctrl + r : Redo

r: Replace
R: Continuous replacement
x : Delete one char


G Go last line
gg Go first line

Go specified line.
11G 
:11


^ Beginning of line
$ End of line

### Command Mode
:help 
:set nu (number)
:set mouse=a
:set nonu 
:set nohlsearch Cancel highlighting

:w filename , save as filename
:wq
    VIm  写隐藏文件， .swap ，保存时替换

:! (eg, :!ifconfig) Use shell commands temporarily in Vim.
:！which shutdown

:/  search
n next 
N  above

:s/old/new  , Replace first ‘old’ of current line.
:s/old/new/g  , Replace all 'old' of current line.
:%s/old/new  , Replace first 'old' of every line of current file.
:%s/old/new/g  ,Replace globally all 'old' of current file. 
:3,5s/old/new(/g),Replace (all) 'old' between 3 and 5 line.



### Visual Mode
v Character visual mode, operate in units of characters.
V Line visual mode, Operate in uinits of lines.
Ctrl + v Block visual mode, Operate in uinits of blocks.
    'I' Insert content in the upper left corner of the block.
    'Esc'  Press twice in succession, insert the same content at the beginning of the block line.
    'd' Delete the block.

