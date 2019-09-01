title: "First week of ATRS: Start"
date: 2019-08-31 16:39:35
categories: ATRS
tags: [Algorithm, Program Kill]
---

ARTS 简单介绍

Algorithm：
主要是为了编程训练和学习。每周至少做一个 leetcode 的算法题（先从Easy开始，然后再Medium，最后才Hard）。进行编程训练，如果不训练你看再多的算法书，你依然不会做算法题，看完书后，你需要训练。

Review：
主要是为了学习英文，如果你的英文不行，你基本上无缘技术高手。所以，需要你阅读并点评至少一篇英文技术文章，我个人最喜欢去的地方是 [Medium](http://Medium.com)（需要梯子）以及各个公司的技术 blog，如 Netflix 的。

Tip：
主要是为了总结和归纳你在是常工作中所遇到的知识点。学习至少一个技术技巧。你在工作中遇到的问题，踩过的坑，学习的点滴知识。

Share：
主要是为了建立你的影响力，能够输出价值观。分享一篇有观点和思考的技术文章。

<!--more-->
# Algorithm
本周用 c 语言完成了两道算法题。
算法题目：[Two Sum](https://leetcode.com/problems/two-sum/)  
我的代码：[Solutions](https://github.com/huaqianlee/LeetcodeSolutions/blob/master/algorithms/c/twoSum.c)  

算法题目：[Add Two Numbers](https://leetcode.com/problems/add-two-numbers/)  
我的代码：[Solutions](https://github.com/huaqianlee/LeetcodeSolutions/blob/master/algorithms/c/addTwoNumbers.c)  

# Review
因为自己想学习一下正则表达式，所以就找了一篇英文教程：[Regex tutorial — A quick cheatsheet by examples](https://medium.com/factory-mind/regex-tutorial-a-simple-cheatsheet-by-examples-649dc1c3f285) 。 

这篇文章简单介绍了 topics 及相关实例，十分适合入门学习，而且通过这个网站我发现了一个[在线 regex 调试器](https://regex101.com/r/cO8lqs/2) ，通过这个在线调试器我们就能很方便的进行正则表达式学习。


# Tips
这周学到了两个版本管理的技巧。
1. 快速撤销本地的所有修改和提交件。
```bash
repo forall -vc "git reset --hard; git clean -fdx"
forall - Execute for all repos.
v - Print the output of the command
c - Command to execute,the actual command
```  

2. 将版本回退到指定时间。
```bash
repo forall -c 'git checkout 'git rev-list --all -n1 --before="2019-08-15 15:00"''
```

# Share
[进程与线程](http://huaqianlee.github.io/2019/08/31/Linux/Process-and-thread-in-linux/)
