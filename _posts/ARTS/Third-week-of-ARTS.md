title: "The third week of ARTS: Repo"
date: 2019-09-13 16:34:02
categories: ARTS
tags: [Algorithm, 成长]
---
# Algorithm
Title：[Palindrome Number](https://leetcode.com/problems/palindrome-number/)  
Solution：[C solution](https://github.com/huaqianlee/LeetcodeSolutions/blob/master/algorithms/c/isPalindrome.c)

# Review
I always don't kwnow enough about repo, so I read some articles about repo this week. These articles describe the repo Manifest format, usage of repo, repo && git , etc in detail. It helps me a lot. But I have not absorbed them yet, I need more time.

The links are as follows:
[repo](https://android.googlesource.com/tools/repo)
- [Source Control Tools](https://source.android.com/setup/develop)
- [Source Control Workflow](https://source.android.com/setup/create/coding-tasks)
- [Repo Command Reference](https://source.android.com/setup/develop/repo)
- [Repo Manifest Format](https://gerrit.googlesource.com/git-repo/+/master/docs/manifest-format.md)
- [Repo hooks](https://android.googlesource.com/tools/repo/+/HEAD/docs/repo-hooks.md)
- [How to separate topic branches](https://mirrors.edge.kernel.org/pub/software/scm/git/docs/howto/separating-topic-branches.txt)  

<!-- more -->

# Tips
* Delete Files Using Extended Pattern Matching Operators.
```bash
# enable extglob
shopt -s extglob

rm -v !("filename")
rm -v !("filename1"|"filename2") 
# such as,
rm -i !(*.zip)
rm -v !(*.zip|*.odt)

# disable extglob
shopt -u extglob
```

* Delete Files Using Linux find Command
```bash
find /directory/ -type f -not -name 'PATTERN' -delete
find /directory/ -type f -not -name 'PATTERN' -print0 | xargs -0 -I {} rm {}
find /directory/ -type f -not -name 'PATTERN' -print0 | xargs -0 -I {} rm [options] {}
# such as,
find . -type f -not -name '*.gz'-delete
find . -type f -not -name '*gz' -print0 | xargs -0  -I {} rm -v {}
find . -type f -not \(-name '*gz' -or -name '*odt' -or -name '*.jpg' \) -delete
```


# Share
[How does the repo of android source code work ?](http://huaqianlee.github.io/2019/09/15/Git/How-does-android-repo-work/)
