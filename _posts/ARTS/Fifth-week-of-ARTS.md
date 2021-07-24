title: "The fifth week of ARTS"
date: 2019-09-29 22:44:56
categories:
- Laboratory
- ARTS
tags: [Algorithm, 成长]
---
# Algorithm
Title: [Longest Common Prefix](https://leetcode.com/problems/longest-common-prefix/)
Solution: [Java](https://github.com/huaqianlee/LeetcodeSolutions/blob/master/algorithms/java/LongestCommonPrefix.java)

# Review
I always want to change the mind of my loves, but I didn't use the good way to do it. So I read [How to Change a Mind](https://forge.medium.com/how-to-change-a-mind-1774681b9369) this week.

To be honesty, I can't get this article well, it is a little hard to me. But I got the following opinions from this topic.
1. Firstly we should think or do like the people who we want to change.
2. For scams, we should let the people lose the faith in the person not in the scams, it will be a better way. Quote the sentence:  
> "Dylan did not need to lose his faith in what his elders were saying; he needed to lose his faith in them." 
<!-- more -->
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

## To add it to your `/etc/fstab`
sshfs#$USER@<IP>:/dir /home/$USER/remote_dir fuse defaults,idmap=user 0 0
> sshfs $USER@<IP>:/dir /home/$USER/remote_dir // mount via terminal

# Share
[Consolidating the foundation of Linux, basic cmds](http://huaqianlee.github.io/2020/02/06/Linux/Consolidating-the-foundation-of-Linux-basic-cmds/)