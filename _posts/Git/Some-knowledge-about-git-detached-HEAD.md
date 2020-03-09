title: "Oh, the Git! - detached HEAD"
date: 2020-03-08 18:49:40
categories: Git
tags: [Tools]
---

The current commit history is as follows:

```bash
$ git log --oneline --all --graph
* 5ea3cec (HEAD -> master) Modify README.md of src
* 2b6e826 Same file, same blob
* 1ff08f2 Modify README.md.
* 8c19a38 Add Copyright notice.
* 318c11a Copy css to lib.
| * 1134f9e (dev) Make graph more readability
| * 71c40d3 Modify README.md in dev branch.
|/
* ce4297f Add image.
| * 2cb23ac (dev-1.0) README for dev-1.0 branch.
|/
* 6fc4b44 (tag: kikoff_tag) Copy doc README.md
* 726c6c0 Add source README.md
* c8ff9c5 Add README
```

<!--more-->

分离头指针  -> 易被 git 清理掉，未指向任何分支

git checkout sha1

git checkout -b new_branch  base_branch_or_commit

git diff HEAD  HEAD~1 ^ ~2 ^^


```bash
$ git checkout 8c19a38
Note: checking out '8c19a38'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b <new-branch-name>

HEAD is now at 8c19a38 Add Copyright notice.
```

```bash
$ cat .git/HEAD
8c19a3856e27ff8e29171e49ccccdc042f1de32e
```


```bash
Lee@Lee-PC MINGW64 /e/code/Git/Demonstration ((8c19a38...))
$ git log --oneline --all --graph
* 5ea3cec (master) Modify README.md of src
* 2b6e826 Same file, same blob
* 1ff08f2 Modify README.md.
* 8c19a38 (HEAD) Add Copyright notice.
* 318c11a Copy css to lib.
| * 1134f9e (dev) Make graph more readability
| * 71c40d3 Modify README.md in dev branch.
|/
* ce4297f Add image.
| * 2cb23ac (dev-1.0) README for dev-1.0 branch.
|/
* 6fc4b44 (tag: kikoff_tag) Copy doc README.md
* 726c6c0 Add source README.md
* c8ff9c5 Add README

Lee@Lee-PC MINGW64 /e/code/Git/Demonstration ((8c19a38...))
$ vi README.md

Lee@Lee-PC MINGW64 /e/code/Git/Demonstration ((8c19a38...))
$ git add .;git commit -m "detached HEAD"
[detached HEAD 2457088] detached HEAD
 1 file changed, 3 insertions(+)

Lee@Lee-PC MINGW64 /e/code/Git/Demonstration ((2457088...))
$ git log --oneline --all --graph
* 2457088 (HEAD) detached HEAD
| * 5ea3cec (master) Modify README.md of src
| * 2b6e826 Same file, same blob
| * 1ff08f2 Modify README.md.
|/
* 8c19a38 Add Copyright notice.
* 318c11a Copy css to lib.
| * 1134f9e (dev) Make graph more readability
| * 71c40d3 Modify README.md in dev branch.
|/
* ce4297f Add image.
| * 2cb23ac (dev-1.0) README for dev-1.0 branch.
|/
* 6fc4b44 (tag: kikoff_tag) Copy doc README.md
* 726c6c0 Add source README.md
* c8ff9c5 Add README
```

```bash
Lee@Lee-PC MINGW64 /e/code/Git/Demonstration ((2457088...))
$ git checkout master
Warning: you are leaving 1 commit behind, not connected to
any of your branches:

  2457088 detached HEAD

If you want to keep it by creating a new branch, this may be a good time
to do so with:

 git branch <new-branch-name> 2457088

Switched to branch 'master'
```

it's gone.
```bash
$ git log --oneline --all --graph
* 5ea3cec (HEAD -> master) Modify README.md of src
* 2b6e826 Same file, same blob
* 1ff08f2 Modify README.md.
* 8c19a38 Add Copyright notice.
* 318c11a Copy css to lib.
| * 1134f9e (dev) Make graph more readability
| * 71c40d3 Modify README.md in dev branch.
|/
* ce4297f Add image.
| * 2cb23ac (dev-1.0) README for dev-1.0 branch.
|/
* 6fc4b44 (tag: kikoff_tag) Copy doc README.md
* 726c6c0 Add source README.md
* c8ff9c5 Add README

```

