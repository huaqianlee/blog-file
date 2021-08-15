title: Jump into Tmux + Terminal
date: 2020-11-09 23:06:19
categories:
- Linux Tree
- Misc
tags:
---
之前为了让终端炫酷好用，配置了 `Terminator + Oh My ZSH + autosuggestions + highlighting + Agnoster theme + powerline fonts + solarized colors`，可是终端的反应速度受到了影响，移植性也不高，最主要的是对于我来说，`Terminator` 不够 `Terminal + Tmux` 酷，所以最近决定切回 `Terminal + Tmux `。

`Terminal` 是 `Ubuntu` 自带的终端，就不做介绍了。今天主要聊聊`Tmux` 的基本用法，做一个备忘录。 `Tmux` 除了分屏功能外，还有一个功能我很喜欢，即 `persistent`，也就是运行在 `Tmux` 中的程序在其断开前会一直保持运行状态。譬如：远程登录服务器，通过 `Tmux` 运行程序，即使本地登录客户端断开，程序也会保持运行，除非我们在服务器端退出 `Tmux` 或者重启服务器。

<!--more-->

`Tmux` 中的所有命令在执行前都需要一个前缀， 默认为 `C-b`。
> `C-b` 表示 `Ctrl + b`，如下雷同，`C` 即代表 `Ctrl` 建。

# Start

```bash
tmux
# or
tmux new -s session_name
```

# Stop

```bash
# Kill server and all sessions
tmux kill-server
pkill -f tmux

tmux kill-session -a # Close all other sessions

tmux kill-session -t <name> # Kill the specific session
```

# Manual

Actually, the following command is all we need to know at the first time:
```bash
man tmux
```

# Commands Cheat Sheet

| #       | Commands                                     | Comments                                                                           |
| ------- | -------------------------------------------- | ---------------------------------------------------------------------------------- |
| Session | `C-b s`                                      | List the sessions                                                                  |
|         | `C-b $`                                      | Rename the current session                                                         |
|         | `C-b ?`                                      | Display help page, to get a list of all commands                                   |
|         | `C-b d`                                      | Detach from the Tmux session, the program running in the Tmux will continue to run |
|         | `C-b D`                                      | Choose one session to detach                                                       |
|         | `C-b L`                                      | Swicth the attached clinet back to the last session                                |
|         | `tmux ls`                                    | To get a list of the currently runnning sessions                                   |
|         | `tmux attach[-session] -t name`              | Re-attach to <name> tmux session                                                   |
|         | `tmux rename[-session] -t old_name new_name` | Rename old_name session to new_name                                                |
| Window  | `C-b c`                                      | Create a new window (with shell)                                                   |
|         | `C-b w`                                      | List the windows                                                                   |
|         | `C-b ,`                                      | Rename the current window                                                          |
|         | `C-b p`                                      | Switch to the previous window                                                      |
|         | `C-b n`                                      | Switch to the next window                                                          |
|         | `C-b <number>`                               | Switch to window <number>                                                          |
|         | `C-b !`                                      | Break the current pane out to a new window                                         |
|         | `C-b f`                                      | Promt to search for text in open windows                                           |
| Pane    | `C-b %`                                      | Split current pane horizontally into two panes                                     |
|         | `C-b "`                                      | Split current pane vertically into two panes                                       |
|         | `C-b o`                                      | Go to the next pane                                                                |
|         | `C-b ;`                                      | Toggle between the current and previous pane                                       |
|         | `C-b arrows,HIJK`                            | Move among panes                                                                   |
|         | `C-b z`                                      | Make a pane go full screen. Hit C-b z again to shrink it back to its previous size |
|         | `C-b }`                                      | Swap the position of the current pane with the next                                |
|         | `C-b {`                                      | Swap the position of the current pane with the previous                            |
|         | `C-b-arrows`                                 | Resize the window                                                                  |
|         | `C-b C-arrows`                               | Resize pane in direction of <arrow key>4                                           |
|         | `C-b q`                                      | Make tmux briefly flash the number of each pane.                                   |
|         | `C-b x`                                      | Close the current pane                                                             |
|         | `C-b [`, `C-b PgUp`                          | Enter vim editting mode, copy mode                                                 |
|         | `C-b ]`                                      | Paste the most recently copied buffer                                              |
|         | `C-b t`                                      | Show time in the current pane                                                      |

# Configuration

```bash
# tmux configuration
# Ref: https://github.com/hamvocke/dotfiles/tree/master/tmux

# open new windows in the current path
#bind c new-window -c "#{pane_current_path}"

# reload config file
bind r source-file ~/.tmux.conf

#unbind p
#bind p previous-window

# shorten command delay
set -sg escape-time 1

# don't rename windows automatically
set -g allow-rename off 

# mouse control (clickable windows, panes, resizable panes)
set -g mouse on

# Use Alt-arrow keys without prefix key to switch panes
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# enable vi mode keys
set-window-option -g mode-keys vi

# set default terminal mode to 256 colors
set -g default-terminal "screen-256color"

# present a menu of URLs to open from the visible pane. sweet.
bind u capture-pane \;\ 
    save-buffer /tmp/tmux-buffer \;\ 
    split-window -l 10 "urlview /tmp/tmux-buffer"


######################
### DESIGN CHANGES ###
######################

# loud or quiet?
set -g visual-activity off
set -g visual-bell off
set -g visual-silence off
setw -g monitor-activity off
set -g bell-action none

#  modes
setw -g clock-mode-colour colour5
setw -g mode-style 'fg=colour1 bg=colour18 bold'

# panes
#set -g pane-border-style 'fg=colour19 bg=colour0'
#set -g pane-active-border-style 'bg=colour0 fg=colour5'

# statusbar
set -g status-position bottom
set -g status-justify left
set -g status-style 'bg=colour18 fg=colour4'
set -g status-left ''
set -g status-right '#[fg=colour18,bg=colour4] %d/%m #[fg=colour4,bg=colour18] %H:%M:%S '
set -g status-right-length 50
set -g status-left-length 20

setw -g window-status-current-style 'fg=colour1 bg=colour19 bold'
setw -g window-status-current-format ' #I #[fg=colour7]#W#[fg=colour8]#F '

setw -g window-status-style 'fg=colour1 bg=colour18 dim'
setw -g window-status-format ' #I #[fg=colour250]#W#[fg=colour244]#F '

setw -g window-status-bell-style 'fg=colour255 bg=colour1 bold'

# messages
set -g message-style 'fg=colour18 bg=colour4 bold'
```
