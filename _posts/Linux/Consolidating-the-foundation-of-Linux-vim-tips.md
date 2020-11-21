title: 'Consolidating the foundation of Linux, vim tips'
date: 2020-11-19 21:55:12
categories: Linux
tags: [Tools,Vim]
---
# Vim Tips

Record my commonly used commands in the form of a memo, and will continue to increase according to usage in the future.

| #                         | Commands                                                          | Comment                                                                                              |
| ------------------------- | ----------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| **Help:**                 |                                                                   |                                                                                                      |
| 0                         | `vimtutor`                                                        | vim tutor with shell                                                                                 |
| 1                         | `:help user-manual`                                               | User manual overview                                                                                 |
| 2                         | `:help usr_02.txt`                                                | User manual                                                                                          |
| 3                         | `:help index`                                                     | All commands for each mode                                                                           |
| 4                         | `:help insert-index/visual-index/...`                             | All commands for insert/visual/... mode                                                              |
| 5                         | `:help -t`                                                        | `vim -t {tag}`                                                                                       |
| 6                         | `:help E37`                                                       | 'error inf E37...' explanation                                                                       |
| 7                         | `:help <command>`                                                 | Command's manual                                                                                     |
| 8                         | `:help w`                                                         | Common commands                                                                                      |
| 9                         | `:help c_Ctrl-D`                                                  | Command-line Editing commands                                                                        |
| 10                        | `:help vimrCtrl-intro`                                            | vimrc introduction                                                                                   |
| 11                        | `:r $VIMRUNTIME/vimrc_example.vim`                                | Read vimrc example                                                                                   |
| 12                        | `Ctrl-A` or `Tab`                                                 | Automaticly transfer $VIMRUNTIME as `:r /usr/share/vim/vim80/`                                       |
| 13                        | `:help helphelp`                                                  | Help on help files                                                                                   |
| 14                        | `help help`                                                       | help on help commands                                                                                |
| **Command Line Editing:** | `: / ? !` ...                                                     |                                                                                                      |
| 0                         | `:help ex-edit-index`                                             | All commands for command-line                                                                        |
| 1                         | `/` `?`                                                           | Forward or reverse search,  `n, N` - next/previous                                                   |
| 2                         | `:e <path/to/file>`                                               | Open  <path/to/file> ,`:e` for reloading                                                             |
| 3                         | `:saveas <path/to/file>`                                          | Save to <path/to/file>                                                                               |
| 4                         | `:x, ZZ , :wq`                                                    | Save and quit (:x only save if necessary)                                                            |
| 5                         | `:q!`                                                             | Quit without saving, also: :qa! to quit even if there are modified hidden buffers                    |
| 6                         | `:bn/bp`                                                          | Next/previous file buffer                                                                            |
| 7                         | `:[%]s/old/new/[gcI]`                                             | Replace,`%` - whole file, `gc` globally and confirm, `I` - ?                                         |
| 8                         | `:3,5s/old/new/g`                                                 | Replace from 3 to 5 line                                                                             |
| 9                         | `:set hls[earch]/nonhls`                                          | highlight all matching phrases or not                                                                |
| 10                        | `:set [no]ic, 'ignorecase'`                                       | ignore upper/lower case when searching or not                                                        |
| 11                        | `\c`                                                              | Ignore capital, likes `/ignor\c`,`:s/old\c/new/g`                                                    |
| 12                        | `:set [no]is, 'incsearch'`                                        | show partial matches for a search phrase or not                                                      |
| 13                        | `sp[lit] vsp`                                                     | `:help split`,Split screen horizontal or vertical                                                    |
| 14                        | `：vertical res/res + num`                                        | Set the width or height                                                                              |
| 15                        | `Ctrl-W + Ctrl-W/HJKL`                                            | Move between/among splitted screens                                                                  |
| 16                        | `Ctrl-W _`(resp. `Ctrl-W \|`)                                     | Maximise the size of the split (resp. vertical split)                                                |
| 17                        | `Ctrl-W +`(resp. `Ctrl-W -`)                                      | Grow (resp. shrink) split                                                                            |
| 18                        | `Ctrl-W =`                                                        | Evenly allocate size                                                                                 |
| 19                        | `:set [no]scb, 'scrollbind'`                                      | Sync the screens which this option is set                                                            |
| 20                        | `:Ctrl-D`                                                         | Show a list of commands                                                                              |
| 21                        | `<TAB>`                                                           | Complete , likes `:edi[t]`,`:!fin[d]` and others. like name                                          |
| 22                        | `:set showmode`                                                   | Tell you which mode you are on the last line                                                         |
| 23                        | `:r !ls`                                                          | Put ls's output below the cursor                                                                     |
| 24                        | `:r <file>`                                                       | Put the contents of file below the cursor                                                            |
| 25                        | `:map Y y$`                                                       | Map `Y` command yank to the end of line, map shortcut                                                |
| 26                        | `:set [no]nu[mber]`                                               | Hider/display line number                                                                            |
| 27                        | `:set mouse=[all]`                                                | Enable mouse usage (all modes)                                                                       |
| 28                        | `:se[t]`                                                          | Show all options that differ from their default value                                                |
| 29                        | `:se[t] all`                                                      | Show all but terminal options.                                                                       |
| **Normal Mode:**          | `ESC Ctrl-[  Ctrl-C`...                                           | Back to Normal Mode                                                                                  |
| 0                         | `:help normal-index`                                              | All commands for normal mode                                                                         |
| 1                         | `[n]command`                                                      | Excute n times command, likes `10itest`, insert 10 test                                              |
| 2                         | `Ctrl-D/Ctrl-U`,`hjkl`                                            | Move down or up,...                                                                                  |
| 3                         | `0,^,$,g_`                                                        | Go to the first/last column or non-blank character                                                   |
| 4                         | `[N]G, :N`                                                        | Go to line N                                                                                         |
| 5                         | `gg`,`G`                                                          | Go to the start of the file, to last line                                                            |
| 6                         | `w, e , b` `2w,3e`                                                | Go to the start/end of next word, start of previous word                                             |
| 7                         | `W,E,B`                                                           | Go to the start/end of next/previous Group                                                           |
| 8                         | `fa/F`,`,` `;`                                                    | Go to next/previous 'a' on the line,`3fa` go to 3rd 'a', `,` `;` next/previous                       |
| 9                         | `t,/T` `,` `;`                                                     | Go to before/after `,`, `,` `;` next/previous                                                        |
| 10                        | `%`                                                               | Go to next corresponding item, likes `([{}],#ifdef/#endif`)                                          |
| 11                        | `*,#`                                                             | Go to next/previous occurence of the word, `:set hls` will highlight them                            |
| 12                        | `x`,`J`                                                           | Delete char, rm line break                                                                           |
| 13                        | `Ctrl-A`                                                          | Increment the number                                                                                 |
| 14                        | `U/u`,`Ctrl-R`                                                    | Undo all latest changes on one line or undo one changes, redo changes                                |
| 15                        | `Ctrl-O`,`Ctrl-I`                                                 | Go to older/newer cursor possitons,support switching files                                           |
| 16                        | `Ctrl-]`                                                          | jumps to the location of the tag given by the word under the cursor                                  |
| 17                        | `Ctrl-T`                                                          | (pop tag) takes you back to the preceding position                                                   |
| 18                        | `Ctrl-G`                                                          | Prints the current file name, the cursor position, etc.                                              |
| 19                        | `Te(gt gT),Ve[!],He[!]`                                           | Create a Tab/Vertical/Horizontal page, gt/gT - next/previous, `!` -> switch split place              |
| **EX commands:**          |                                                                   |                                                                                                      |
| 0                         | `:help ex-cmd-index`                                              | All commands for ex-cmd                                                                              |
| 1                         | `man vim`                                                         |                                                                                                      |
| 2                         | `:!<command>` `:！which shutdown`                                 | Excute shell command                                                                                 |
| 3                         | `Ctrl-Z` `fg`                                                     | Pause vim, back to vim                                                                               |
| 4                         | `vim -pO/o[N] files...`                                           | Open N/one(when N is omitted) tab page for each file,`o` Horizontal, `O`-Vertical                    |
| 5                         | `vim -n`                                                          | No swap file will be used                                                                            |
| 6                         | `Ctrl-Shift-C`,`Ctrl-Shift-V`                                     | Copy and Paste, supports outside of vim                                                              |
| **Insert Mode:**          | `a i r s` ...                                                     | Enter Insert Mode                                                                                    |
| 0                         | `:help insert-index`                                              | All commands for insert mode                                                                         |
| 1                         | `r,R gR`                                                          | Replace mode,`gR`:visual mode replace                                                                |
| 2                         | `Ctrl-N, Ctrl-P`                                                  | Completion,complete the word from start of word                                                      |
| **Visual Mode:**          | `v V Ctrl-V Ctrl-Q` ...                                           | Enter visual Mode, CTRL-Q insteads Ctrl-V(used to paste) in Insert and Command-line mode.            |
| 0                         | `:help visual-index`                                              | All commands for visual mode                                                                         |
| 1                         | `v/V/Ctrl-V`                                                      | Select char/line/block                                                                               |
| 2                         | `Ctrl-V` + `Shift-I` + `ESC`                                      | Add same content at beginning of all lines                                                           |
| 3                         | `Ctrl-V` + `$` + `Shift-A` + `ESC`                                | Add same content at the end of all lines                                                             |
| 4                         | `y`,`d`...                                                        | Yank,delete selected content in visual mode                                                          |
| 5                         | `Y ,yy`                                                           | Yank the current line                                                                                |
| 6                         | `J`                                                               | Join all lines together                                                                              |
| 7                         | `<`, `>`                                                          | Indent to the left, to the right                                                                     |
| 8                         | `=`                                                               | Auto indent                                                                                          |
| **Op pending Mode**       | `c d y < >` ...                                                   |                                                                                                      |
| 1                         | `c[N]{motion} c2w,ce,c$`                                          | Delete motion text and start insert                                                                  |
| 2                         | `y,d{motion} y$,d$,dt{?}`, `Np`                                   | Yank/Delete {motion} text, paste N times                                                             |
| 3                         | `y`,`d`...                                                        | Yank,delete the selected content                                                                     |
| 4                         | `Y ,yy`                                                           | Yank the current line                                                                                |
| 5                         | `yl`                                                              | Yanks a letter                                                                                       |
| 6                         | `yaw`                                                             | Yanks a word                                                                                         |
| 7                         | `yas`                                                             | Yanks a sentence                                                                                     |
| 8                         | `yi(`                                                             | Yanks everything within ( and so on…                                                                 |
| 9                         | `p`                                                               | pastes something after the cursor                                                                    |
| 10                        | `P`                                                               | pastes something before the cursor                                                                   |
| 11                        | `gp`                                                              | same as p but puts the cursor after the pasted selection                                             |
| 12                        | `gP`                                                              | same as P and puts the cursor after the pasted selection                                             |
| 13                        | `<, >`                                                            | Undent and indent                                                                                    |
| **Supper Mode**           |                                                                   |                                                                                                      |
| 0                         | `v`+`:`->`:'<,'>w flie`                                           | Save selected content in a new file                                                                  |
| 1                         | `./N.`                                                            | Repeat one/N times the last cmd                                                                      |
| 2                         | `N<command>`                                                      | Repeat the command N times,likes `2dd,3p`                                                            |
| 3                         | `100icontent`                                                     | Write 100 times `content`,`.`->100 times again, `3.`->3 times, not 300                               |
| 4                         | `<start position><command><end position>`                         | Command from start positon to end position,`y,v (visual select), gU (uppercase), gu (lowercase) ...` |
| 5                         | `0y$`                                                             | Yank from beginning to end of this line                                                              |
| 6                         | `ye`                                                              | Yank from here to end of word                                                                        |
| 7                         | `y2/foo`                                                          | Yank up to second foo                                                                                |
| 8                         | `<action>a/i<object>`                                             | Only be used after an operator in visual mode,action:`y,d,v...`, object:`w,W,s,p,",',),},]`          |
| 9                         | `vis`                                                             | Select the current sentence                                                                          |
| 10                        | `vip`                                                             | Select the current paragraph                                                                         |
|                           | **Suppose the cursor is on the first `o` of `(map (+) ("foo"))`** |                                                                                                      |
| 11                        | `vi"`                                                             | Select `foo`                                                                                         |
| 12                        | `va"`                                                             | Select `"foo"`                                                                                       |
| 13                        | `vi)`                                                             | Select `"foo"`                                                                                       |
| 14                        | `va)`                                                             | Select `("foo")`                                                                                     |
| 15                        | `v2i)`                                                            | Select `map (+) ("foo")`                                                                             |
| 16                        | `v2a)`                                                            | Select `(map (+) ("foo"))`                                                                           |
| 17                        | `:[n]cnext`                                                       | To go to the [n] next one error                                                                      |
| 18                        | `:copen `                                                         | All matches are available in the quickfix window which can be opened                                 |
|                           | **Register**                                                      |                                                                                                      |
| 19                        | `qa,@a`                                                           | Start recording your actions in a register, replay the action,                                       |
| 20                        | `@@`                                                              | A shortcut to replay the last executed macro                                                         |
| 21                        | `"kyy`                                                            | Copy the current line into k register                                                                |
| 22                        | `"Kyy`                                                            | Append the current line into  k register                                                             |
| 23                        | `"kp`                                                             | Paste k regiser                                                                                      |
| 24                        | `"+p`                                                             | Paste from system clipboard on Linux                                                                 |
| 25                        | `"*p`                                                             | To paste from system clipboard on Windows (or from "mouse highlight" clipboard on Linux)             |
| 26                        | `:reg`                                                            | To access all currently defined registers type                                                       |
|                           | **Suppose on a line containing only the number 1**                |                                                                                                      |
| 27                        | `qaYp<Ctrl-A>q`                                                   | `qa` Start recording `Yp` duplicate this line `Ctrl-A` increment the number `q` stop recording       |
| 28                        | `@a`                                                              | Write 2 under the 1                                                                                  |
| 29                        | `@@`                                                              | Write 3 under the 2                                                                                  |
| 30                        | `100@@`                                                           | Create a list of increasing numbers until 103                                                        |
| 31                        | **Global:**                                                       | `:g`:`%`                                                                                             |
| 32                        | `ggvG$`                                                           | Select all content                                                                                   |
| 33                        | `:%d`                                                             | delete every line                                                                                    |
| 34                        | `:%y`                                                             | yank every line                                                                                      |
| 35                        | `:%normal! >>`                                                    | indent every line                                                                                    |
| 36                        | `:g/^/d`                                                          | delete every line                                                                                    |
| 37                        | `:g/^/y`                                                          | yank every line                                                                                      |
| 38                        | `:g/^/normal! >>`                                                 | indent every line                                                                                    |

<!--more-->

# Vim cheat sheet for programmers
![vim_cheat_sheet_for_programmers_print](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/linux/vim/vim_cheat_sheet_for_programmers_print.png)

# Vim common cheat sheet
![vi-vim-cheat-sheet](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/linux/vim/vi-vim-cheat-sheet.gif)
