title: "The second week of ARTS: Hurry"
date: 2019-09-07 20:49:00
categories: ARTS
tags: [Algorithm, 成长]
---
# Algorithm
Title：[Reverse Integer](https://leetcode.com/problems/reverse-integer/)  
Solution：[C solution](https://github.com/huaqianlee/LeetcodeSolutions/blob/master/algorithms/c/reverseInteger.c)

# Review
Because I am learnning python, I was attracted by the [Learning Python: From Zero to Hero](https://medium.com/free-code-camp/learning-python-from-zero-to-hero-120ea540b567) article of [Medium](http://Medium.com).  

This article is very good ,  it almost show all the python-related knowledge in a limited page. Such as , variables, conditional statements, looping, collection/array, key-value collection, iterate , classes and objects, encapsulation, inheritance, etc.

<!-- more -->
# Tips
## Get the patch of the specified commission.
```bash
git diff origin/master HEAD # Get patch for all commits which are not merged
git diff start_commit_id end_commit_id # Get patch between start_commit_id and end_commit_id
```

## A way to avoid that security issue between vendor and system.
I am not sure when, if I am correct , there is security issues with file operations between vendor and system from Android O. I found a way to avoid it this week, that is, escape selinux verification in the following file.
```c
external/selinux/libselinux/src/avc.c
```

# Share
[A little basic knowledge of the shell](http://huaqianlee.github.io/2019/09/08/Shell/A-little-basic-knowledge-of-the-shell/)
