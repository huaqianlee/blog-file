title: 'Consolidating the foundation of Linux, vim tips'
date: 2020-11-19 21:55:12
categories:
- Linux Tree
- Vim
tags: [Tools,Vim]
---
# Vim Tips

Here is [Consolidating the foundation of Linux, vim](http://huaqianlee.github.io/2020/02/06/Linux/Consolidating-the-foundation-of-Linux-vim/), and I write this tips for my vim configuration, record my commonly used commands in the form of a memo, Here is [My vim configuration](https://github.com/huaqianlee/dotfiles/tree/main/vim).

<!--more-->

| #                              | Commands                                                                       | Comment                                                                                              |
| ------------------------------ | ------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------- |
| **Basis:**                     |                                                                                |                                                                                                      |
|                                | `apt install vim-gtk3 , or vim-gnome`                                          | Install gvim                                                                                         |
|                                | `?ve[rsion]`                                                                   | Print the vim information                                                                            |
|                                | `/etc/vim/vimrc`<br>`/usr/share/vim/vim81`                                     |                                                                                                      |
|                                | `vimdiff`, `gvimdiff`, `:vert diffsplit`                                       | diff comparision                                                                                     |
| **Help:**                      |                                                                                |                                                                                                      |
|                                | `vimtutor`                                                                     | vim tutor with shell                                                                                 |
|                                | `:help user-manual`                                                            | User manual overview                                                                                 |
|                                | `:help usr_02.txt`                                                             | User manual                                                                                          |
|                                | `:help index`                                                                  | All commands for each mode                                                                           |
|                                | `:help insert-index/visual-index/...`                                          | All commands for insert/visual/... mode                                                              |
|                                | `:help -t`                                                                     | `vim -t {tag}`                                                                                       |
|                                | `:help E37`                                                                    | 'error inf E37...' explanation                                                                       |
|                                | `:help <command>`                                                              | Command's manual                                                                                     |
|                                | `:help w`                                                                      | Common commands                                                                                      |
|                                | `:help c_Ctrl-D`                                                               | Command-line Editing commands                                                                        |
|                                | `:help vimrCtrl-intro`                                                         | vimrc introduction                                                                                   |
|                                | `:r $VIMRUNTIME/vimrc_example.vim`                                             | Read vimrc example                                                                                   |
|                                | `Ctrl-A` or `Tab`                                                              | Automaticly transfer $VIMRUNTIME as `:r /usr/share/vim/vim80/`                                       |
|                                | `:help helphelp`                                                               | Help on help files                                                                                   |
|                                | `help help`                                                                    | help on help commands                                                                                |
| **Command Line Editing:**      | `: / ? !` ...                                                                  |                                                                                                      |
|                                | `:help ex-edit-index`                                                          | All commands for command-line                                                                        |
|                                | `/` `?`                                                                        | Forward or reverse search,  `n, N` - next/previous                                                   |
|                                | `:s`                                                                           | replace , ':help :s' to check the detail                                                             |
|                                | `:e[dit]`                                                                      | edit or reload                                                                                       |
|                                | `:w`,`:r`                                                                      | Write , Read                                                                                         |
|                                | `Ctrl-D`, `Tab`                                                                | AutoComplete the cmd or filename                                                                     |
|                                | `:saveas <path/to/file>`                                                       | Save to <path/to/file>                                                                               |
|                                | `:x, ZZ , :wq`                                                                 | Save and quit (:x only save if necessary)                                                            |
|                                | `:q!`                                                                          | Quit without saving, also: :qa! to quit even if there are modified hidden buffers                    |
|                                | `:bn/bp`                                                                       | Next/previous file buffer                                                                            |
|                                | `:[%]s/old/new/[gcI]`                                                          | Replace,`%` - whole file, `gc` globally and confirm, `I` - ?                                         |
|                                | `:3,5s/old/new/g`                                                              | Replace from 3 to 5 line                                                                             |
|                                | `:set hls[earch]/nonhls`                                                       | highlight all matching phrases or not                                                                |
|                                | `:set [no]ic, 'ignorecase'`                                                    | ignore upper/lower case when searching or not                                                        |
|                                | `\c`                                                                           | Ignore capital, likes `/ignor\c`,`:s/old\c/new/g`                                                    |
|                                | `:set [no]is, 'incsearch'`                                                     | show partial matches for a search phrase or not                                                      |
|                                | `sp[lit] vsp`                                                                  | `:help split`,Split screen horizontal or vertical                                                    |
|                                | `：vertical res/res + num`                                                     | Set the width or height                                                                              |
|                                | `Ctrl-W + Ctrl-W/HJKL`                                                         | Move between/among splitted screens                                                                  |
|                                | `Ctrl-W _`(resp. `Ctrl-W \|`)                                                  | Maximise the size of the split (resp. vertical split)                                                |
|                                | `Ctrl-W +`(resp. `Ctrl-W -`)                                                   | Grow (resp. shrink) split                                                                            |
|                                | `Ctrl-W =`                                                                     | Evenly allocate size                                                                                 |
|                                | `:set [no]scb, 'scrollbind'`                                                   | Sync the screens which this option is set                                                            |
|                                | `:Ctrl-D`                                                                      | Show a list of commands                                                                              |
|                                | `<TAB>`                                                                        | Complete , likes `:edi[t]`,`:!fin[d]` and others. like name                                          |
|                                | `:set showmode`                                                                | Tell you which mode you are on the last line                                                         |
|                                | `:r !ls`                                                                       | Put ls's output below the cursor                                                                     |
|                                | `:r <file>`                                                                    | Put the contents of file below the cursor                                                            |
|                                | `:map Y y$`                                                                    | Map `Y` command yank to the end of line, map shortcut                                                |
|                                | `:set [no]nu[mber]`                                                            | Hider/display line number                                                                            |
|                                | `:set mouse=[all]`                                                             | Enable mouse usage (all modes)                                                                       |
|                                | `:se[t]`                                                                       | Show all options that differ from their default value                                                |
|                                | `:se[t] all`                                                                   | Show all but terminal options.                                                                       |
|                                | `:set ft?`                                                                     | Check filetype of the current file                                                                   |
| **Normal Mode:**               | `ESC Ctrl-[  Ctrl-C`...                                                        | Back to Normal Mode                                                                                  |
|                                | `:help normal-index`                                                           | All commands for normal mode                                                                         |
|                                | `[n]command`                                                                   | Excute n times command, likes `10itest`, insert 10 test                                              |
|                                | `Ctrl-D/Ctrl-U`,`hjkl`                                                         | Move down or up,...                                                                                  |
|                                | `0,^,$,g_`                                                                     | Go to the first/last column or non-blank character                                                   |
|                                | `[N]G, :N`                                                                     | Go to line N                                                                                         |
|                                | `gg`,`G`                                                                       | Go to the start of the file, to last line                                                            |
|                                | `w, e , b` `2w,3e`                                                             | Go to the start/end of next word, start of previous word                                             |
|                                | `W,E,B`                                                                        | Go to the start/end of next/previous Group                                                           |
|                                | `fa/F`,`,` `;`                                                                 | Go to next/previous 'a' on the line,`3fa` go to 3rd 'a', `,` `;` next/previous                       |
|                                | `t,/T` `,` `;`                                                                 | Go to before/after `,`, `,` `;` next/previous                                                        |
|                                | `%`                                                                            | Go to next corresponding item, likes `([{}],#ifdef/#endif`)                                          |
|                                | `*,#`                                                                          | Go to next/previous occurence of the word, `:set hls` will highlight them                            |
|                                | `x`,`J`                                                                        | Delete char, rm line break                                                                           |
|                                | `Ctrl-A`                                                                       | Increment the number                                                                                 |
|                                | `Shift-~`                                                                      | Case conversion                                                                                      |
|                                | `U/u`,`Ctrl-R`                                                                 | Undo all latest changes on one line or undo one changes, redo changes                                |
|                                | `Ctrl-O`,`Ctrl-I`                                                              | Go to older/newer cursor possitons,support switching files                                           |
|                                | `Ctrl-]`                                                                       | jumps to the location of the tag given by the word under the cursor                                  |
|                                | `Ctrl-T`                                                                       | (pop tag) takes you back to the preceding position                                                   |
|                                | `Ctrl-G`                                                                       | Prints the current file name, the cursor position, etc.                                              |
|                                | `Te(gt gT),Ve[!],He[!]`                                                        | Create a Tab/Vertical/Horizontal page, gt/gT - next/previous, `!` -> switch split place              |
| **EX commands:**               |                                                                                |                                                                                                      |
|                                | `:help ex-cmd-index`                                                           | All commands for ex-cmd                                                                              |
|                                | `man vim`                                                                      |                                                                                                      |
|                                | `:!<command>` `:！which shutdown`                                              | Excute shell command                                                                                 |
|                                | `Ctrl-Z` `fg`                                                                  | Pause vim, back to vim                                                                               |
|                                | `vim -pO/o[N] files...`                                                        | Open N/one(when N is omitted) tab page for each file,`o` Horizontal, `O`-Vertical                    |
|                                | `vim -n`                                                                       | No swap file will be used                                                                            |
|                                | `Ctrl-Shift-C`,`Ctrl-Shift-V`                                                  | Copy and Paste, supports outside of vim                                                              |
| **Insert Mode:**               | `a i r s` ...                                                                  | Enter Insert Mode                                                                                    |
|                                | `:help insert-index`                                                           | All commands for insert mode                                                                         |
|                                | `r,R gR`                                                                       | Replace mode,`gR`:visual mode replace                                                                |
|                                | `Ctrl-N, Ctrl-P`                                                               | Completion,complete the word from start of word                                                      |
| **Visual Mode:**               | `v V Ctrl-V Ctrl-Q` ...                                                        | Enter visual Mode, CTRL-Q insteads Ctrl-V(used to paste) in Insert and Command-line mode.            |
|                                | `:help visual-index`                                                           | All commands for visual mode                                                                         |
|                                | `v/V/Ctrl-V`                                                                   | Select char/line/block                                                                               |
|                                | `Ctrl-V` + `Shift-I` + `ESC`                                                   | Add same content at beginning of all lines of block                                                  |
|                                | `Ctrl-V` + [`$`] + `Shift-A` + `ESC`                                           | Add same content at the end of block[or all lines]                                                   |
|                                | `y`,`d`...                                                                     | Yank,delete selected content in visual mode                                                          |
|                                | `Y ,yy`                                                                        | Yank the current line                                                                                |
|                                | `J`                                                                            | Join all lines together                                                                              |
|                                | `<`, `>`                                                                       | Indent to the left, to the right                                                                     |
|                                | `=`                                                                            | Auto indent                                                                                          |
| **Op pending Mode**            | `c d y < >` ...                                                                |                                                                                                      |
|                                | `c[N]{motion} c2w,ce,c$`                                                       | Delete motion text and start insert                                                                  |
|                                | `y,d{motion} y$,d$,dt{?}`, `Np`                                                | Yank/Delete {motion} text, paste N times                                                             |
|                                | `y`,`d`,`D/d$`...                                                              | Yank,delete the selected content, delete until the end                                               |
|                                | `Y ,yy`                                                                        | Yank the current line                                                                                |
|                                | `yl`                                                                           | Yanks a letter                                                                                       |
|                                | `yaw`                                                                          | Yanks a word                                                                                         |
|                                | `yas`                                                                          | Yanks a sentence                                                                                     |
|                                | `yi(`                                                                          | Yanks everything within ( and so on…                                                                 |
|                                | `p`                                                                            | pastes something after the cursor                                                                    |
|                                | `P`                                                                            | pastes something before the cursor                                                                   |
|                                | `gp`                                                                           | same as p but puts the cursor after the pasted selection                                             |
|                                | `gP`                                                                           | same as P and puts the cursor after the pasted selection                                             |
|                                | `<, >`                                                                         | Undent and indent                                                                                    |
|                                | `d, c, v, y + <numb>i/a + w, s(sentence), p, t(tag,XML..), [], {} ...`         | `c2i{`                                                                                               |
|                                | `if (message == "sesame open")`                                                | 'a' under the cursor                                                                                 |
|                                | `dw`                                                                           | delete 'ame '                                                                                        |
|                                | `diw`                                                                          | delete 'sesame'  ; delete inside word                                                                |
|                                | `daw`                                                                          | delete 'sesame '; delete a word                                                                      |
|                                | `diW`                                                                          | delete '"sesame'                                                                                     |
|                                | `daW`                                                                          | delete '"sesame '                                                                                    |
|                                | `di"`                                                                          | delete 'sesame open'                                                                                 |
|                                | `da"`                                                                          | delete '"sesame open"'                                                                               |
|                                | `di(,di)`                                                                      | delete 'message == "sesame open"'                                                                    |
|                                | `da(,da)`                                                                      | delete '(message == "sesame open")'                                                                  |
|                                | `ysiw"`                                                                        | add "" to word, word -> "word"                                                                       |
|                                | `ysiW"`                                                                        | add "" to string                                                                                     |
|                                | `cs"'`                                                                         | "word" to 'word'                                                                                     |
|                                | `cs[<em>`                                                                      | [Mine] -> <em>Mine</em>                                                                              |
|                                | `S<em>`                                                                        | 'word -> <em>word</em>' in visual mode                                                               |
|                                | `ds"`, `dst`                                                                   | remove "" , HTML tab                                                                                 |
|                                | `:1,10y`, `y10G`                                                               | yank 10 lines                                                                                        |
|                                | `vim -c 'normal 5G36|'`                                                        | execute normal command to jump to  line 5 column 36                                                  |
|                                | `\v`, `ve"0p`                                                                  | replace the word under the cursor, efficient with '*', 'n'                                           |
| *move*                         | `f[ind]`, `t[ill]`                                                             |                                                                                                      |
|                                | `gj`, `gk`                                                                     | move screen line                                                                                     |
|                                | `(, )`                                                                         | previous / next senstence                                                                            |
|                                | `{, }`                                                                         | previous / next paragraph                                                                            |
|                                | `D, d$`, `C, c$`                                                               | delete , modify to the end of line                                                                   |
|                                | `S, cc`                                                                        | Modify line                                                                                          |
|                                | `s, cl`                                                                        | l -> right move. delete one char and insert                                                          |
|                                | `U`                                                                            | revoke all modifiation                                                                               |
|                                | `Ctrl-B, Ctrl-F`                                                               | scoll window backword/forward                                                                        |
|                                | `Ctrl-U, Ctrl-D`                                                               | scroll half a screen up/down                                                                         |
|                                | `<num>G, <num>\|`                                                              | go <num>th line, column                                                                              |
|                                | `H, M, L`                                                                      | Top, Middle, Bottom of the current screen                                                            |
|                                | `Ctrl-E, Ctrl-Y`                                                               | Scroll screen, not move cursor                                                                       |
|                                | `zt, zz, zb`                                                                   | scroll the current line to top, middle, bottom                                                       |
|                                | `;`                                                                            | repeat the recent searching by f, t ...                                                              |
|                                | `,`                                                                            | repeat the recent searching by f, t ...  reversely                                                   |
|                                | `n, N`                                                                         | repeat the recent searching by /, ?                                                                  |
|                                | `.`                                                                            | Repeat last change                                                                                   |
| **Windows and Tabs**           | `help :tab`                                                                    |                                                                                                      |
|                                | `Ctrl-w s,v`                                                                   | sp, vs                                                                                               |
|                                | `Ctrl-w w,W`                                                                   | next or last                                                                                         |
|                                | `Ctrl-W n`, `:new`                                                             | New window                                                                                           |
|                                | `Ctrl-W c`                                                                     | close current window excepte it is the last one.                                                     |
|                                | `Ctrl-W q`                                                                     | quit the current window                                                                              |
|                                | `Ctrl-W o`                                                                     | only reserve the current window                                                                      |
|                                | `Ctrl-W =`                                                                     | resize all windows as the same size                                                                  |
|                                | `<n>Ctrl-W _`, `:res[ize] <n>`                                                 | set the height of the window                                                                         |
|                                | `<n>Ctrl-W \|`,`:vertical res[ize] n`                                          | set the width of the window                                                                          |
|                                | `Ctrl-w -`, `Ctrl-w +`, `:res[ize] -n/+n`                                      | increase/decrease the height                                                                         |
|                                | `Ctrl-w >,<`                                                                   | increase/decrease the width                                                                          |
|                                | `Ctrl-W HJKL(capital)`                                                         | Maximize in a certain direction                                                                      |
|                                | `:tab <cmd>`                                                                   | new tab for <cmd>                                                                                    |
|                                | `:tabs`                                                                        | List all the tabs                                                                                    |
|                                | `:tabnew`, `:tabedit`                                                          | Open a new blank tab                                                                                 |
|                                | `:tabclose`, `Ctrl-w c`                                                        | Close the current tab                                                                                |
|                                | `:tabn`, `gt`                                                                  | go to next                                                                                           |
|                                | `:tabN`, `tabp`, `gT`                                                          | go to the previous tab                                                                               |
|                                | `:tabf`,  `:tabr[ewind]`,`tabl`                                                | go to the first ,last tab                                                                            |
|                                | `Ctrl-w T`                                                                     | Change the current window to a tab                                                                   |
|                                | `F9 + Tab`                                                                     | to show the recent used files in terminal                                                            |
|                                | `:set paste`, `:set nopaste`                                                   | Do not/ modify the format of the pasting content                                                     |
|                                | `:set autowrite`                                                               | autosave when swithching file                                                                        |
|                                | `n\|normal ggp`, `gg"+p`                                                       | switch to next and paste at the beginning, plaste system clipboard                                   |
| **Arguments and buffers**      | `vi *.c`                                                                       |                                                                                                      |
|                                | `:args`                                                                        | list the files                                                                                       |
|                                | `args file`                                                                    | replace args with file                                                                               |
|                                | `:args **/*.cpp **/*.h`                                                        | '**': open the relevant files, including the current directory and $(pwd)/${PWD}                     |
|                                | `:n[ext]`, `:N[ext]/:prev[ious]`                                               | go to the previous file                                                                              |
|                                | `:first`, `:rewind`                                                            | go to the fiirst file                                                                                |
|                                | `:last`                                                                        | go to the last file                                                                                  |
|                                | `:buffers`, `:ls`                                                              | Check the buffers,'%a': the current file, '#':the recent buffer, '+': Modified buffer                |
|                                | `b[uffer]<num>`                                                                | Jump to <num> buffer                                                                                 |
|                                | `bd[elete]`, `bw`                                                              | Delete one buffer                                                                                    |
|                                | `bn`, `bN/bp`, `bl/bf`                                                         | Jump to next, the previous, last/first                                                               |
|                                | `Ctrl-^`, `1Ctrl-^`                                                            | Jump between the two recent buffers ,or to the first                                                 |
| **Supper Mode**                |                                                                                |                                                                                                      |
|                                | `v`+`:`->`:'<,'>w flie`                                                        | Save selected content in a new file                                                                  |
|                                | `./N.`                                                                         | Repeat one/N times the last cmd                                                                      |
|                                | `N<command>`                                                                   | Repeat the command N times,likes `2dd,3p`                                                            |
|                                | `100icontent`                                                                  | Write 100 times `content`,`.`->100 times again, `3.`->3 times, not 300                               |
|                                | `<start position><command><end position>`                                      | Command from start positon to end position,`y,v (visual select), gU (uppercase), gu (lowercase) ...` |
|                                | `0y$`                                                                          | Yank from beginning to end of this line                                                              |
|                                | `ye`                                                                           | Yank from here to end of word                                                                        |
|                                | `y2/foo`                                                                       | Yank up to second foo                                                                                |
|                                | `<action>a/i<object>`                                                          | Only be used after an operator in visual mode,action:`y,d,v...`, object:`w,W,s,p,",',),},]`          |
|                                | `vis`                                                                          | Select the current sentence                                                                          |
|                                | `vip`                                                                          | Select the current paragraph                                                                         |
|                                | **Suppose the cursor is on the first `o` of `(map (+) ("foo"))`**              |                                                                                                      |
|                                | `vi"`                                                                          | Select `foo`                                                                                         |
|                                | `va"`                                                                          | Select `"foo"`                                                                                       |
|                                | `vi)`                                                                          | Select `"foo"`                                                                                       |
|                                | `va)`                                                                          | Select `("foo")`                                                                                     |
|                                | `v2i)`                                                                         | Select `map (+) ("foo")`                                                                             |
|                                | `v2a)`                                                                         | Select `(map (+) ("foo"))`                                                                           |
|                                | `:[n]cnext`                                                                    | To go to the [n] next one error                                                                      |
|                                | `:copen `                                                                      | All matches are available in the quickfix window which can be opened                                 |
|                                | **Register**                                                                   |                                                                                                      |
|                                | `qa,@a`                                                                        | Start recording your actions in a register, replay the action,                                       |
|                                | `@@`                                                                           | A shortcut to replay the last executed macro                                                         |
|                                | `"kyy`                                                                         | Copy the current line into k register                                                                |
|                                | `"Kyy`                                                                         | Append the current line into  k register                                                             |
|                                | `"kp`                                                                          | Paste k regiser                                                                                      |
|                                | `"+p`                                                                          | Paste from system clipboard on Linux                                                                 |
|                                | `"*p`                                                                          | To paste from system clipboard on Windows (or from "mouse highlight" clipboard on Linux)             |
|                                | `:reg`                                                                         | To access all currently defined registers type                                                       |
|                                | **Suppose on a line containing only the number 1**                             |                                                                                                      |
|                                | `qaYp<Ctrl-A>q`                                                                | `qa` Start recording `Yp` duplicate this line `Ctrl-A` increment the number `q` stop recording       |
|                                | `@a`                                                                           | Write 2 under the 1                                                                                  |
|                                | `@@`                                                                           | Write 3 under the 2                                                                                  |
|                                | `100@@`                                                                        | Create a list of increasing numbers until 103                                                        |
|                                | **Global:**                                                                    | `:g`:`%`                                                                                             |
|                                | `ggvG$`                                                                        | Select all content                                                                                   |
|                                | `:%d`                                                                          | delete every line                                                                                    |
|                                | `:%y`                                                                          | yank every line                                                                                      |
|                                | `:%normal! >>`                                                                 | indent every line                                                                                    |
|                                | `:g/^/d`                                                                       | delete every line                                                                                    |
|                                | `:g/^/y`                                                                       | yank every line                                                                                      |
|                                | `:g/^/normal! >>`                                                              | indent every line                                                                                    |
| **NERDTree**                   | `:NERDTree`, `:e .`                                                            | open NERDTree                                                                                        |
|                                | `:NERDTreeToggle`                                                              | open/close NERDTree -> remap shortcut, or short cmd                                                  |
|                                | `?`, `go`                                                                      | help, only preview, not jump into file                                                               |
|                                | `i`,  `s`, `t`                                                                 | Open to a new hirizontal ,vertical window, or a tab                                                  |
|                                | `I`, `m`                                                                       | display hidden files, open 'add, delete, rename, ...' menu                                           |
|                                | `:setlocal`, `:setglobal`                                                      | Check the local, global options                                                                      |
|                                | `:set tabstop?`, `:set tabstop=4`                                              | return the local value, set local and global                                                         |
| **Tags**                       | `$VIMRUNTIME/doc/tags`<br>`/usr/share/vim/vim80/doc/tags`                      |                                                                                                      |
|                                | `:helpt[ags]`                                                                  | Generate the help tags,':hep :helpt'                                                                 |
|                                | `set runtimepath?`                                                             | the patch including all plugins                                                                      |
|                                | `ctags -R .`                                                                   | Create tags index for the current directory                                                          |
|                                | `ctags -fields=+iaS --extra=+q -R .`                                           | create tags index for C++, `--c-kinds=+p` for system head file                                       |
|                                | `ctags --languages=c --langmap=c:.c.h --fields=+S -R .`                        | create tags file                                                                                     |
|                                | `Ctrl-]`, `g-click`, `:tag <str>`                                              | Jump to defined or declared location                                                                 |
|                                | `g]`, `:tj[ump]`                                                               | list, list and jump if only one                                                                      |
|                                | `:sts[elect]`, `:stj[ump]`                                                     | new window to list, list and jump if only one                                                        |
|                                | `:tn`, `:tN,:tp`,`:tf,:tr`,`:tl`                                               | next, previous, first, last                                                                          |
|                                | `:ts[elect]`, `:tag`                                                           | list all the tags                                                                                    |
|                                | `Ctrl-W + Ctrl-], g], g<Ctrl-]>`                                               | Open in new window                                                                                   |
|                                | `sudo python gen_systags.py`                                                   | generate tags for system head file                                                                   |
| **Tagbar**                     | `:TagbarToggle`                                                                | Open tagbar                                                                                          |
|                                | `:copen`                                                                       | Open quickfix                                                                                        |
|                                | `:cn`, `:cN, :cp`, `:cf, :cr`, `:cl`                                           | next, previous, first, last                                                                          |
| **Coding**                     | `:set makeprg=make\ -j4`, `make`                                               | building                                                                                             |
|                                | `gp, grepprg`                                                                  | 'help gp' for ':grep'                                                                                |
|                                | `:set tw=64 fo+=n + gq`                                                        | set linewidth = 64, number list to format content of code                                            |
|                                | `gq`, `:help gq`, `help fo-tale`                                               | Format the lines                                                                                     |
|                                | `gg=G`                                                                         | Format the file                                                                                      |
|                                | `:%s/\s\+$//g`                                                                 | Remove all trailing whitespace                                                                       |
|                                | `:grep -R --include='*.c' --include='*.h' '\<printf\>' . `                     | all files who used 'printf'                                                                          |
|                                | `:command! -bang -nargs=* -complete=file Make AsyncRun -program=make @ <args>` | run make asynchronously                                                                              |
|                                | `K`                                                                            | check the help document of word under the cursor, works for function                                 |
|                                | `:help keywordprg`                                                             | to check help of K                                                                                   |
|                                | `Ctrl-p`,`Ctrl-n`                                                              | Looking backforward, looking forward                                                                 |
|                                | `Ctrl-X Ctrl-F`                                                                | autocomplete filename or directory, 'Ctrl-p', 'Ctrl-n' to choose                                     |
|                                | `gf`, `gx`                                                                     | Jump to the file, link under the cursor                                                              |
|                                | `Ctrl-w f`                                                                     | Jump to the file and open a new window                                                               |
| **Writing**                    |                                                                                |                                                                                                      |
|                                | `iconv -l`                                                                     | check the formats what libiconv supports                                                             |
|                                | `:e ++ff=dos`                                                                  | Load file with DOS EOL(End Of Line)                                                                  |
|                                | `:%s/\r$//`                                                                    | Dlelete <CR> of EOL, from DOS to Unix                                                                |
|                                | `:help fo-table`                                                               | `t, c, q, r, o, l, n, w, a`, chinese: `m, M, B`                                                      |
|                                | `:set fo+=r ..., -=r ...`                                                      | set option flags                                                                                     |
|                                | `:set listchars`                                                               | highlight the end-of-line spaces and <LR>                                                            |
|                                | `:set linebreak`                                                               | Wrap long lines at 'space, ', ., ?...' rather than at the last char                                  |
|                                | `gq{motion}`                                                                   | Format the lines (like 72/80 chars each line)that {motion} moves over                                |
|                                | `J`                                                                            | Connect mutiple lines to one line, the reverse of 'gq'                                               |
| **Undotree**                   | `:UndotreeToggle`                                                              | Open undotree window                                                                                 |
|                                | `J, K`                                                                         | move in history list                                                                                 |
|                                | `:Rename`, `Move`                                                              | file handle                                                                                          |
| **fzf**                        | `:Files`                                                                       | Open fuzzy matching to find unknown-name file                                                        |
| **Binary**                     | `vim -b`, `:e ++binary`                                                        | Edit binary                                                                                          |
|                                | `gvim->tools->convert to Hex`                                                  |                                                                                                      |
|                                | `:%!xxd`, `%!xxd -r`                                                           | Covert to Hex                                                                                        |
|                                | `:setf xxd`                                                                    | highlight binary file contents                                                                       |
|                                | `:help using-xxd`                                                              |                                                                                                      |
| **YouCompleteMe**              | `Tab`, Double`Tab`                                                             | select, autoecomplete                                                                                |
|                                | `install vim-youcompleteme`                                                    |                                                                                                      |
|                                | `vam install youcompleteme`                                                    | enable, link youcompleteme.vim to ~/.vim/plugin                                                      |
|                                | `:YcmCompleter RefactorRename bar`                                             | rename the word under the cursor as bar                                                              |
|                                | `:YcmDiags`                                                                    | Display issue of all codes , not only the current line                                               |
| **vim-fugitive**               | `:help fugitive`                                                               |                                                                                                      |
|                                | `:G[it] pull, log ...`                                                         |                                                                                                      |
|                                | `:Gwrite`, `:Gread`                                                            | Save and git add, git checkout or ...                                                                |
|                                | `:Gmove`, `GRename`, `GDelete`                                                 |                                                                                                      |
|                                | `:0Gclog`                                                                      | Check the history with quickfix                                                                      |
|                                | `:Git blame`, `:Git`, `:Gvdiff`                                                | git blame, git status, git diff --stage                                                              |
| *`:G` to enter fugitive first* | `:help fugitive-staging-maps`                                                  |                                                                                                      |
|                                | `s`, `u`                                                                       | git add, revoke 's'                                                                                  |
|                                | `=`                                                                            | open/clos the diff-view of the current file                                                          |
|                                | `o`                                                                            | Open file in new split window                                                                        |
|                                | `dv`                                                                           | Compare to the stage area                                                                            |
|                                | `cc`                                                                           | :Git commit                                                                                          |
| **vim-gitgutter**              |                                                                                |                                                                                                      |
|                                | `[c`, `]c`                                                                     | Jump to previous/next modification                                                                   |
|                                | `<Leader>hp`                                                                   | Compare the modification block under the cursor to the stage area                                    |
|                                | `<Leader>hs`                                                                   | git add the modification block under the cursor                                                      |
|                                | `<leader>hu`                                                                   | revoke the stage area                                                                                |
| **vim-airline**                |                                                                                | a nice statusline at the bottom of each window                                                       |
|                                | `:AirlineExtensions`                                                           | all available airline extensions                                                                     |
|                                | `:help airline`                                                                |                                                                                                      |
|                                | `:AirlineToggle`                                                               | Open or close statusline                                                                             |
| **nerdcommenter**              |                                                                                |                                                                                                      |
|                                | `<Leader>cc`                                                                   | comment the codes under the cursor                                                                   |
|                                | `<Leader>cu`                                                                   | remove comment, revoke '\cc'                                                                         |
|                                | `<Leader>c<Space>`                                                             | comment/uncomment                                                                                    |
|                                | `<Leader>cb`                                                                   | add comment                                                                                          |
|                                | `<Leader>cs`                                                                   | add comment, a different comment                                                                     |
| **vim-visual-multi**           |                                                                                | put cursur on multiple locations and then c, d, i ...{motion}                                        |
|                                | `:help vm-quickref`                                                            |                                                                                                      |
|                                | `\\/`                                                                          | start search                                                                                         |
|                                | `n`, `q`                                                                       | select and jump to next one, skip                                                                    |
|                                | `\\A`                                                                          | Select all directly                                                                                  |
|                                | `Ctrl-N`                                                                       | search the word under the cursor, just likes '*'                                                     |
|                                | `\\\`                                                                          | add a cursor location manually                                                                       |
| **Terminal**                   | `:help t_CTRL-W`                                                               |                                                                                                      |
|                                | `:term[inal] [cmd] ++noclose/++close`                                          | open a ternminal, and to not close/close when exiting shell                                          |
|                                | `:vert term`, `:tab term`                                                      |                                                                                                      |
|                                | `Ctrl-w 'N'`, `Ctrl-\ Ctrl-N`                                                  | quit terminal, enter normal text terminal                                                            |
|                                | `a`, `i`                                                                       | reactive terminal                                                                                    |
|                                | `Ctrl-W "<register>`                                                           | paste the value of <register>                                                                        |
|                                | `Ctrl-W .`                                                                     | send 'Ctrl-W' to terminal                                                                            |
|                                | `Ctrl-W Ctrl-\`                                                                | send 'Ctrl-\' to ternminal                                                                           |
|                                | `exit`, `Ctrl-D`                                                               | quit terminal                                                                                        |
|                                | `Ctrl-w Ctrl-c`                                                                | Force quit terminal                                                                                  |
| **GDB**                        |                                                                                |                                                                                                      |
|                                | `:packadd termdebug`                                                           |                                                                                                      |
|                                | `:Termdebug`                                                                   | start to debug                                                                                       |
| **echofunc**                   | 'tags is required for this plugin'                                             |                                                                                                      |
|                                | `let g:EchoFuncAutoStartBalloonDeclaration = 0`                                | disable the function prompt                                                                          |
|                                | `Alt-=`, `Alt -`                                                               | to swith the function prototype declartion                                                           |
| **Cscope**                     |                                                                                |                                                                                                      |
|                                | `Ctrl-\ <cmd>`                                                                 | Execute cscope cmd in the current window                                                             |
|                                | `\|<cmd>`                                                                      | Execute cscope cmd in a new herizontal window                                                        |
|                                | `\|\|<CMD>`                                                                    | Execute cscope cmd in a new vertical window                                                          |
|                                | `apt install cscope`                                                           |                                                                                                      |
|                                | `cscope  -b`                                                                   |                                                                                                      |
|                                | `g`                                                                            | find the global definition                                                                           |
|                                | `s`                                                                            | find the reference of symbol                                                                         |
|                                | `d`                                                                            | find the called function                                                                             |
|                                | `c`                                                                            | find who call this funciton                                                                          |
|                                | `t`                                                                            | find all locations where this text appears                                                           |
|                                | `e`                                                                            | with 'egrep' to search                                                                               |
|                                | `f`                                                                            | According to filename to search, likes gf, <Ctrl-W>f of vim.                                         |
|                                | `i`                                                                            | find who includes this file                                                                          |
|                                | `a`                                                                            | find where it is assigned                                                                            |
|                                | `:cscope find g funcname`, `Ctrl-\ g`, `Ctrl-]`                                | find the definition of funcname                                                                      |
|                                | `:scscope find g funcname`, `\|g`, `Ctrl-w ]`                                  | split the window                                                                                     |
|                                | `:vert scscope find g funcname`, `\|\|g`                                       | vertically split the window                                                                          |
| **clang-format**               |                                                                                |                                                                                                      |
|                                | `apt install clang-format`                                                     |                                                                                                      |
|                                | `cp .vim/.clang-format .`                                                      | copy to the current project to make it work                                                          |
|                                | `Tab`                                                                          | format code                                                                                          |
| **python-mode**                |                                                                                | 'K' for searching works                                                                              |
|                                | `:Pymodeint`                                                                   | check code format                                                                                    |
|                                | `:PymodeLintAuto`                                                              | Fix automaticly                                                                                      |
| **vim-renamer**                |                                                                                |                                                                                                      |
|                                | `:Ren[amer]`                                                                   | rename                                                                                               |
|                                | `Ctrl-Del`                                                                     | delete fiel                                                                                          |
|                                | `gu`                                                                           | lowcase the selected word                                                                            |
|                                | `Ctrl-V`, `Ctrl-A`, `Ctrl-X`                                                   | increase, decrease the number                                                                        |
| **vim-rainbow**                |                                                                                |                                                                                                      |
|                                | `:RainbowToggle`                                                               |                                                                                                      |
|                                | `:RainbowLoad`                                                                 |                                                                                                      |

# More tips

## write with sudo
```bash
:w !sudo tee %

# :w – Write a file (actually buffer).
# !sudo – Call shell with sudo command.
# tee – The output of write (vim :w) command redirected using tee.
# % – The % is nothing but current file name.
```

## `c2i{` to  modify the content in {}.

```bash
while(true){
if(count<100) {
		...
			
}
	count++;
	
}

# -> ```c2i{`

while(ture){
}
```

## Complex repeats
```markdown
q           -> record, * to search, qa to record content to a register
eabar<Esc>  -> Modify foo under the cursor to foobar , ea -> append at end of foo
@           -> execute
q           -> stop to record
@a          -> repeat modification
`````

## Register

```bash
unnamed register "" : default,no " before opertation or "" . ""p = p
0..9: 0 - the latest yank(d,x,c...), 1..9 and so on. "0p -> paste 0 register content.
- -> delete less than one line, and not use '%,(,),`,/,?,n,N' to delete, the contents will save in '-' register
- a..z -> need user to point, quit vim will not clear. "ayy, "ap could always paste it until a is rewriten
- .,:,#,% -> uncommonly used, :help ". 
- _ -> black hole register, for delete , likes /dev/null
- / -> last search pattern register, used for 'n' , 'hlsearch'...
- = -> expression register
- + -> system clipboard, help "+
- *,~ -> help "  

"+yy -> yank to system clipboard , "+y12G  -> yank to 12G
"+nyy

"+p -> paste from system clipboard
"+P
```

Access register:
```
normal mode -> d,y,p, "ayy...
Insert mode -> Ctrl-R<register>
```

## swith two contents 
- `d` -> delete first content, unnamed register saved it
- - `p` -> select next content, p , unnamed register will saved new content
- - `P` -> Paste next content to first location 

## Skills
```
:v/<pattern>/d -> find not <pattern> content and delete to filter.
:g -> help :g  ,find <pattern> content

:364,757y equals 364GV757Gy

:%s/pattern//ng  -> Print matching message, and no changes will be made to buffer

`:global/pattern/print`, `:g/pattern`   -> Display all <pattern> lines in a new window
```

# Vim cheat sheet for programmers
![vim_cheat_sheet_for_programmers_print](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/linux/vim/vim_cheat_sheet_for_programmers_print.png)

# Vim common cheat sheet
![vi-vim-cheat-sheet](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/linux/vim/vi-vim-cheat-sheet.gif)
