title: "Oh, the Git! - local .git"
date: 2020-03-07 18:42:33
categories:
- Tools
- Git
tags: [Tools]
---

`.git` directory acts a major role in `git` VCS. We can do local verson management directly depended on `.git` directory. I will parse `.git` in current topic. 

# Directory tree

First, I created a project and managed it through `git`, its directory tree is as follows:

```bash
.
├── doc
│   └── README.md
├── .git
│   ├── COMMIT_EDITMSG
│   ├── config
│   ├── description
│   ├── HEAD
│   ├── hooks
│   │   ├── applypatch-msg.sample
│   │   ├── commit-msg.sample
│   │   ├── fsmonitor-watchman.sample
│   │   ├── post-update.sample
│   │   ├── pre-applypatch.sample
│   │   ├── pre-commit.sample
│   │   ├── prepare-commit-msg.sample
│   │   ├── pre-push.sample
│   │   ├── pre-rebase.sample
│   │   ├── pre-receive.sample
│   │   └── update.sample
│   ├── index
│   ├── info
│   │   └── exclude
│   ├── logs
│   │   ├── HEAD
│   │   └── refs
│   │       └── heads
│   │           ├── dev
│   │           ├── dev-1.0
│   │           └── master
│   ├── objects
│   │   ├── 02
│   │   │   ├── 40351d75b3f451e0ec4b399c38c3758f007152
│   │   │   └── d8eae705ebf203142fd2f381d3b216dde2b28f
|   |   |...
│   │   ├── c8
│   │   │   └── ff9c55ce2651d8380a14bee5b43b37e14fa7fc
│   │   ├── f0
│   │   │   └── 45488f3fa9a350ac01f48f2b000fe51a53f5aa
│   │   ├── info
│   │   └── pack
│   ├── ORIG_HEAD
│   └── refs
│       ├── heads
│       │   ├── dev
│       │   ├── dev-1.0
│       │   └── master
│       └── tags
│           └── kikoff_tag
├── img
│   └── check.png
├── lib
│   └── css_practice_1.html
├── README.md
└── src
    └── README.md
```
<!--more-->
# .git introduction

## .git/HEAD

It indicates which branch or commit the project works on. When the project works on a branch, the valuse of `.git/HEAD` is one reference. The details are as follows:

```bash
$ cat .git/HEAD
ref: refs/heads/dev-1.0

$ git checkout master
Switched to branch 'master'

$ cat .git/HEAD
ref: refs/heads/master

$ git checkout 8c19a3856 # detached HEAD, 分离头指针
Note: checking out '8c19a38'.
...
HEAD is now at 8c19a38 Add Copyright notice.

$ cat .git/HEAD  # Point to commit when the project works on detached HEAD
8c19a3856e27ff8e29171e49ccccdc042f1de32e
```

## .git/config

`.git/config` is local git configuration,it has the highest priority, it will cover global and system configuration. As follows:

```bash
$ cat .git/config
[core]
        repositoryformatversion = 0
        filemode = false
        bare = false
        logallrefupdates = true
        symlinks = false
        ignorecase = true
[user]
        name = lihq0416
        email = lihq0416@alsa.com

```

My global configuration is as follows:

```bash
E:\code\Git\Demonstration>git config --global --list
user.name=huaqianlee
user.email=huaqianlee@gmail.com
```

The working configuration(user) is as follows:

```bash
$ git log -n1
commit 8c19a3856e27ff8e29171e49ccccdc042f1de32e (HEAD -> master)
Author: lihq0416 <lihq0416@alsa.com>  # the local user.
Date:   Sun Mar 8 11:14:06 2020 +0800

    Add Copyright notice.

```

## .git/refs/ 

`.git/refs/` saves git reference, it replaces `SHA-1` with a simple string.

```bash
$ ls .git/refs/
heads/  tags/

heads - branch HEAD  
tags - milestone, tag reference
```

## index

Git puts the file size, creation time, and last modification information in the index. 

Git judges whether the blob has changed by comparing the current status with the content of index.

###  .git/refs/heads/

`.git/refs/heads` saves all branch name, as follows:

```bash
$ ls .git/refs/heads/
dev  dev-1.0  master
```

we can get the original SHA-1 value by `cat`.

```bash
$ cat .git/refs/heads/master
1ff08f245a3eaae8c5404cf3da2977a4637d3d68

$ git cat-file -t 1ff08f2 # cat type of object.
commit

$ cat .git/refs/heads/dev
1134f9ee07daf1589ec9cc424dec587d119f8477


$ cat .git/refs/heads/dev-1.0
2cb23acda7fc092152fd63c5c13bda287765d9da
```

Check the content `.git/refs/heads/master`.

```bash
$ git cat-file -p 1ff08f2 # cat content of object.
tree ccb86ecb23a86d363868ede3f8597dade731aeac
parent 8c19a3856e27ff8e29171e49ccccdc042f1de32e
author lihq0416 <lihq0416@alsa.com> 1583640484 +0800
committer lihq0416 <lihq0416@alsa.com> 1583640484 +0800

Modify README.md.

$ git show 1ff08f2 # show the details.
commit 1ff08f245a3eaae8c5404cf3da2977a4637d3d68 (HEAD -> master)
Author: lihq0416 <lihq0416@alsa.com>
Date:   Sun Mar 8 12:08:04 2020 +0800

    Modify README.md.

diff --git a/README.md b/README.md
index a687b4c..401b9a8 100644
--- a/README.md
+++ b/README.md
@@ -1,3 +1,3 @@
 Demonstration
 ===
-
+For master.

```

The SHA-1 in `.git/refs/heads` is the HEAD pointer of every branch.

```bash
$ git log --oneline --all --graph
* 1134f9e (dev) Make graph more readability # dev HEAD
* 71c40d3 Modify README.md in dev branch.
| * 1ff08f2 (HEAD -> master) Modify README.md. # master HEAD
| * 8c19a38 Add Copyright notice.
| * 318c11a Copy css to lib.
|/
* ce4297f Add image.
| * 2cb23ac (dev-1.0) README for dev-1.0 branch. # dev-1.0 HEAD
|/
* 6fc4b44 (tag: kikoff_tag) Copy doc README.md
* 726c6c0 Add source README.md
* c8ff9c5 Add README

$ git branch -av
  dev     1134f9e Make graph more readability
  dev-1.0 2cb23ac README for dev-1.0 branch.
* master  1ff08f2 Modify README.md.
```

### .git/refs/tags

`.git/refs/tags` save all tags, next, we analyze the `tag` reference. 

```bash
$ cat .git/refs/tags/kikoff_tag
6fc4b448eede8b86e0dff1156797a8b76b661c98
```

Again, let's look at the details of the `tag` object.

```bash
$ git cat-file -t 6fc4b44
commit

$ git cat-file -p 6fc4b44
tree e38a164f48baba5a6b6251d77926be66e77ae1c0
parent 726c6c01c5bdfee5c477962f69f5313d868398db
author lihq0416 <lihq0416@alsa.com> 1583636454 +0800
committer lihq0416 <lihq0416@alsa.com> 1583636454 +0800

Copy doc README.md
```

it is the SHA-1 of `kikoff_tag` tag.

## .git/objects

`.git/objects` saves all git objects.

```bash
$ ls -l .git/objects/
total 0
drwxr-xr-x 1 Lee 197121 0 三月    8 11:45 02/
drwxr-xr-x 1 Lee 197121 0 三月    8 12:10 11/
...
drwxr-xr-x 1 Lee 197121 0 三月    7 18:20 c8/
drwxr-xr-x 1 Lee 197121 0 三月    8 11:45 dd/
drwxr-xr-x 1 Lee 197121 0 三月    8 11:00 e3/
# if `02/,11/ ...` are too much, pack them into pack/, otherwise `info and pack are empty.
drwxr-xr-x 1 Lee 197121 0 三月    7 18:16 info/
drwxr-xr-x 1 Lee 197121 0 三月    7 18:16 pack/ 
```

List the contens of `c8/` and `dd/`, the content appends path name to the SHA-1.

```bash
$ ls -l .git/objects/c8/
total 1
-r--r--r-- 1 Lee 197121 132 三月    7 18:20 ff9c55ce2651d8380a14bee5b43b37e14fa7fc

$ ls .git/objects/dd/
5ab753d33087eb06bd69b3a9317674638e6685  9f4c82726240a5289b5e6e33028bbcee8ac540
```

Cat the contents of SHA-1.

```bash
1. c8/ directory
# SHA-1: c8 + ff9c55ce2651d8380a14bee5b43b37e14fa7fc
$ git cat-file -t c8ff9c55
commit

$ git cat-file -p c8ff9c55
tree 567fa4f607ea3685f7957cf42d1569ada65eb53b
author lihq0416 <lihq0416@alsa.com> 1583576427 +0800
committer lihq0416 <lihq0416@alsa.com> 1583576427 +0800

Add README

2. dd/ directory
# SHA-1: dd + 5ab753d33087eb06bd69b3a9317674638e6685
$ git cat-file -t dd5ab753
tree 

$ git cat-file -p dd5ab753
100644 blob 9bdec0343dd1dee61d37be2a4d678c1a43c20b69    README.md
$ git cat-file -t 9bdec0343
blob
$ git cat-file -p 9bdec0343
Hello, source code!    # Contents of README.md

# SHA-1: dd + 9f4c82726240a5289b5e6e33028bbcee8ac540
$ git cat-file -t dd9f4c82
blob
$ git cat-file -p dd9f4c82
Demonstration
===

For dev-1.0.
```

There are mainly three objects:

- tree : indicates a directory.
- commit : indicates a commit(SHA-1).
- blob: indicates a file, if the contents of two files are same, they saves as a same blob.

# More in .git

\# Todo

```bash
config       FETCH_HEAD   hooks/       info/        objects/     packed-refs
description  HEAD         index        logs/        ORIG_HEAD    refs/
```

# commit, tree and blob

`commit`, `tree` and `blob` are three main components of `.git`. I will introduce them by two examples.

The current commit history is as follows:

```bash
$ git log --oneline
5ea3cec (HEAD -> master) Modify README.md of src
2b6e826 Same file, same blob
1ff08f2 Modify README.md.
8c19a38 Add Copyright notice.
318c11a Copy css to lib.
ce4297f Add image.
6fc4b44 (tag: kikoff_tag) Copy doc README.md
726c6c0 Add source README.md
c8ff9c5 Add README
```

## Simple one

First, list relationship flowchart.

![commit_tree_blob_first](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/commit_tree_blob_first.png)

- Select the second commit `726c6c0` as benchmark.

- Get the type and content of second commit `726c6c0`.

```bash
$ git cat-file -t 726c6c0
commit

$ git cat-file -p 726c6c0
tree c72f3764e2179a8c61f0b948aca0b3720624b818
parent c8ff9c55ce2651d8380a14bee5b43b37e14fa7fc
author lihq0416 <lihq0416@alsa.com> 1583636339 +0800
committer lihq0416 <lihq0416@alsa.com> 1583636339 +0800

Add source README.md
```

- Get the content of `tree` object.

```bash
$ git cat-file -p  c72f3764
100644 blob a687b4c895de1b963fd4648cd12d7b1040b406c0    README.md
040000 tree dd5ab753d33087eb06bd69b3a9317674638e6685    src
```
> `100644` - blob; `040000` - tree

- Get the contents of `blob` and `tree`.

```bash
$ git cat-file -p a687b4c
Demonstration
===

$ git cat-file -p dd5ab75 # tree
100644 blob 9bdec0343dd1dee61d37be2a4d678c1a43c20b69    README.md

$ git cat-file -p 9bdec03 # Content of new blob.
Hello, source code!
```

## Complex one 

First, list the relationship flowchart too.
![commit_tree_blob_second](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/vcs/commit_tree_blob_second.png)

- Select a later commit `5ea3cec` to make the structure a bit more complicated.

- Get the content of `commit`.

```bash
$ git cat-file -p 5ea3cec
tree eda5671a377d2fcd258cfabbe13d0eaaff59a69a
parent 2b6e8269574c910b51492ce4c6731a1820b8b5da
author lihq0416 <lihq0416@alsa.com> 1583652333 +0800
committer lihq0416 <lihq0416@alsa.com> 1583652333 +0800

Modify README.md of src
```

- Get the content of `tree`.

```bash
$ git cat-file -p eda567
100644 blob 401b9a8be1ba5ce77df18d4038a58dbfa29e3122    README.md
040000 tree 04a87dd49ac3c928b872613bb07e8545ba08493a    doc
040000 tree bd5e80e9c3527d86ffdf7669521082ec282043d9    img
040000 tree b2713206c3d2f15dd71b25d124189edd2e8beab8    lib
040000 tree 8a55fe88f7a7129f5467d791e4f077c22c3b3bbd    src
```

- Get the contents of `trees` and `blob`.
  
```bash
1. README.md
$ git cat-file -p 401b9a8b
Demonstration
===
For master.

2. doc
$ git cat-file -p  04a87dd4
100644 blob 401b9a8be1ba5ce77df18d4038a58dbfa29e3122    README.md

# Because `doc/README.md` has the same content as root `README.md`
# Only one `blob` is saved to save space.
$ git cat-file -p 401b9a8b
Demonstration
===
For master.

3. img
$ git cat-file -p bd5e80e9
100644 blob 5d3c270574c1ee7b58851757c7b09b45b0cca460    check.png

# The image is a binary
$ git cat-file -p 5d3c270
▒PNG

IHDR{T▒▒▒IDATx▒▒yx▒U▒▒#k-▒f▒▒7▒8▒(t▒&▒▒Vh▒▒▒▒▒2"(茈▒▒▒▒A\▒.,▒

4. lib
$ git cat-file -p b271320
100644 blob d1cd12a7b5b0fa570662c360a0aa5cacf2c11c85    css_practice_1.html

$ git cat-file -p d1cd12a
<!DOCTYPE html>
<html>
        <head>
                <title>Boxes</title>
                        <p>
                                Copyright by Lee.
                        </p>
                </div>
        </body>
</html>

5. src
$ git cat-file -p 8a55fe8
100644 blob f045488f3fa9a350ac01f48f2b000fe51a53f5aa    README.md

$ git cat-file -p f045488
Hello, source code!

This is a demonstration of git.
```
