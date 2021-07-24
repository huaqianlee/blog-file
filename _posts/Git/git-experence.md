title: "Git 常见问题集"
date: 2015-10-22 12:49:10
categories:
- Tools
- Git
tags: Tools
---
## 问题一 .gitignore无效，不能过滤某些文件或路径。
**现象:**
在.gitignore中添加了files和directories过滤，但git status仍会显示files和directories。

**原因：**
在git仓库中已经存在此files和directories，其已经被git跟踪。.gitignore只对未加入版本管理的文件生效。

**解决：** 
从版本库删除文件和目录，更新。
```bash
git rm (--cached) files directories -r -f
git commit
```  
<!--more-->


## 问题二  已经添加文件或路径, 提示untracked
**现象：**
已经将某文件夹添加到暂存区, git status 仍提示: modified: next (modified content, untracked content)

**原因：**
此文件夹中有.git , git将其识别为submodule.

**解决：**
删除文件夹中.git.