title: "按返回键只关闭DrawerLayout侧边栏不退出Activity的实现方案"
date: 2017-08-18 22:44:17
categories:
- Android Tree
- Application
tags: App
---
今天写自己的练习APP时，发现侧边导航栏可见时，我按返回键，Activity直接退出了， 可是我想要的是只是关闭侧边栏，研究了一下，其实解决办法挺简单。

只需要在Activity中重写onBackPressed()即可：
```bash
private DrawerLayout mlayout; 

@Override
public void onBackPressed() {
    if (mlayout.isDrawerOpen(findViewById(R.id.nav_left_layout)))
        mlayout.closeDrawers();
    else
        super.onBackPressed();
}

# R.id.nav_left_layout为侧边栏显示部分顶层Layout
```

