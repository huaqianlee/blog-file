title: "Fifth week of ARTS"
date: 2019-09-29 22:44:56
categories: ARTS
tags: [Algorithm, 成长]
---
# Algorithm
Title: [Longest Common Prefix](https://leetcode.com/problems/longest-common-prefix/)
Solution: [Java](https://github.com/huaqianlee/LeetcodeSolutions/blob/master/algorithms/java/LongestCommonPrefix.java)
<!-- more -->
# Review

# Tips
This week I leaned the way to unmount `sshfs`. `sshfs` is used to map(mount) a remote server dir to the local pc.
```bash
sudo fusermount -u remote_dir // unmount sshfs 
```

BTW, I summarize the sample use of `sshfs` cmd as follows.
## mount
mkdir ~/remote_dir
sshfs -o idmap=user $USER@far:/dir ~/remote_dir

## unmount 
fusermount -u ~/dir

## To add it to your ^/etc/fstab^ 
sshfs#$USER@<IP>:/dir /home/$USER/remote_dir fuse defaults,idmap=user 0 0
> sshfs $USER@<IP>:/dir /home/$USER/remote_dir // mount via terminal


# Share