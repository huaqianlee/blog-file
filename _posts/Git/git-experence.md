title: "git 常见问题集"
date: 2015-10-22 12:49:10
categories: Git
tags: Tools
---
## 问题一: .gitignore无效，不能过滤某些文件或路径。
**现象:**
在.gitignore中添加了files和directories过滤，但git status仍会显示files和directories。

**原因：**
在git仓库中已经存在此files和directories，其已经被git跟踪。.gitignore只对未加入版本管理的文件生效。
<!--more-->

**解决：** 
从版本库删除文件和目录，更新。
```bash
git rm (--cached) files directories -r -f
git commit
```  
