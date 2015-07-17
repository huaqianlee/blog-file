title: "如何在内核里操作文件(create/open/read/write)"
date: 2015-03-17 22:15:42
categories: Linux
tags: [kernel,文件IO]
---
　　因之前工作需要在kernel里存取数据到文件中，特意研究了一下怎么做，我们应尽可能避免直接操作文件I/O，选择通过调用VFS（虚拟文件系统）的函数来实现，我的实现demo如下：

##Includes
```c
#include <linux/fs.h>
#include <asm/segment.h>
#include <asm/uaccess.h>
#include <linux/buffer_head.h>
```
##Opening a file 
<!--more-->
```c
struct file* file_open(const char* path, int flags, int rights) {
    struct file* filp = NULL;
    mm_segment_t oldfs;
    int err = 0;

   /* 内核中进行系统调用（如文件操作）时，必须调用下面两句，对其进行保护，其作用是让内核能访问用户空间 */
    oldfs = get_fs();  // 备份当前进程地址空间
    set_fs(get_ds()); // 设置进程地址空间为虚拟地址空间上限，#define get_ds() (KERNEL_DS) ,
    filp = filp_open(path, flags, rights); // 调用文件打开函数
    set_fs(oldfs); //恢复进程地址空间
    if(IS_ERR(filp)) {
        err = PTR_ERR(filp);
        return NULL;
    }
    return filp;
}
```

##Close a file 
```c
void file_close(struct file* file) {
    filp_close(file, NULL);
}
```
##Reading from a file
```c
int file_read(struct file* file, unsigned long long offset, unsigned char* data, unsigned int size) {
    mm_segment_t oldfs;
    int ret;

    oldfs = get_fs();
    set_fs(get_ds());

    ret = vfs_read(file, data, size, &offset);  // 读取文件，文件存在用户空间

    set_fs(oldfs);
    return ret;
}   
```
##Writing to a file 
```c
int file_write(struct file* file, unsigned long long offset, unsigned char* data, unsigned int size) {
    mm_segment_t oldfs;
    int ret;

    oldfs = get_fs();
    set_fs(get_ds());

    ret = vfs_write(file, data, size, &offset); // 写文件

    set_fs(oldfs);
    return ret;
}
```
##Syncing changes a file
```c
int file_sync(struct file* file) {
    vfs_fsync(file, 0); // 同步文件，确定文件写到硬盘
    return 0;
}
```
