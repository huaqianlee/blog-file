title: "Android Kotlin之曲折HelloWord"
date: 2017-05-23 08:09:56
categories:
- Android Tree
- Application
tags: [App,Android Studio]
---
最近工作业余时间一直在自学Android，Google I/O 2017 惊闻Kotlin成为Google支持的官方语言，当然得紧跟“中央”的脚步，开始程序入门必备之HelloWord，殊不知这个HelloWord充满了曲折。

## 了解Kotlin
知道了Kotlin之后就开始在网上搜集相关资料，发现了如下个人觉得比较好的资料：
[Getting started with Android and Kotlin](https://kotlinlang.org/docs/tutorials/kotlin-android.html)  
[kotlin项目](https://github.com/JetBrains/kotlin)   
[kotlin配置及与java的互操作](https://github.com/JetBrains/kotlin-examples)  
[kotlin语法练习](https://github.com/Kotlin/kotlin-koans)  
[Kotlin1.1手册](doc/kotlin-docs.pdf)  
[kotlin中文网](http://tanfujun.com/kotlin-web-site-cn/docs/reference/)  
[kotlin官网](https://kotlinlang.org/)  
[中文kotlin项目](https://github.com/huanglizhuo/kotlin-in-chinese)
<!--more-->
## 曲折之路
### 安装插件+HelloWorld
自己一直是使用的Android Studio的稳定版，通过**File->setting->Install JetBrains Plugins**安装了Kotlin插件。安装完成后会发现**Tools->Kotlin**工具，可以进行相关Kotlin操作。

插件装好后，新建HelloWord项目，新建完成后打开MainActivity.java，然后通过**Code->Convert Java File to Kotlin File**或者**Ctrl+Alt+Shift+K**将其转换为kt文件，Android Studio将自动在build.gradle文件添加依赖，如下：
```gradle
ext.kotlin_version = '1.1.2-4'
...
classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
```
本以为马上就是见证奇迹的时刻了，可惜各种错误纷至沓来，主要就集中在Android Studio不能成功自动下载kotlin的相关依赖，翻墙下载也不能成功，所以就通过错误log和Task手动下载相关包，这样解决了大部分问题，但是仍然不能成功编译。

### Android Studio 3.0
折腾良久不能成功， 就决定下载Google新发布的自带Kotlin的3.0。下载安装完成后，导入HellowWorld项目，又出现了一大堆翻墙不能解决的gradle和kotlin依赖下载问题，所以又通过手动下载的方式解决了问题。3.0自动对项目的一些依赖进行了更新，kotlin更新为如下：
```gradle
ext.kotlin_version = '1.1.3-eap-34'
...
classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
```
> 自带Kotlin的IDE，新建项目的时候就能选择kotin或者java

本以为终于可以开心的见证奇迹了，3.0 和我的Ubuntu16.1又出现了兼容性问题，由于之前不小心把系统升级后已经多次遇到和软件不够兼容的问题，所以这次就放弃继续折腾，就准备再切换回Android Studio2.3.2再试试，实在不行就只有备份重装系统了。

> 血的教训：Linux开发机千万要用之前的稳定版本，不要升级到最新系统。

### 终见证奇迹
Android3.0+ubuntu16.01 不成功，最终用回2.3.2+kotlin插件，老天总算没让继续折腾，通过3.0更新了Kotlin版本后，在2.3.2中一下就编译过了，赶紧如下添加一点代码：
```java
class KotlinActivity : AppCompatActivity() {

    private lateinit var hello_view:android.widget.TextView
    //private lateinit var hello_anko:android.widget.TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_kotlin)

        hello_view = findViewById(R.id.hello_view) as android.widget.TextView
        hello_view.text = "Hello, Kotlin! "
    }
}
```
编译下载，终于在手机里面看到了：Hello，Kotlin！。

不过仍然有一个小瑕疵，由于兼容性有些问题，总会有IDE Error和Plugin Error提示，不过就这样子将就用了，不准备耗掉大量时间来折腾系统了，相信随着Google的更新和系统补丁，这些问题终将解决。

## Anko项目
尝试了一下比较火的开源项目[Anko](https://github.com/Kotlin/anko)，通过Anko实现HelloWord。
引入依赖，我这里选择了自己能用到的部分依赖，如下：
```gradle
ext.anko_version = "0.10"
...
compile "org.jetbrains.anko:anko-sdk25:$anko_version" // sdk15, sdk19, sdk21, sdk23 are also available
compile "org.jetbrains.anko:anko-appcompat-v7:$anko_version"
```
实现代码：
```kt
# 常规用法
private lateinit var hello_anko:android.widget.TextView
hello_anko = find<TextView>(R.id.hello_anko) //可以省略泛型

# 直接将TextView的id当作示例
hello_anko.text = "Hello, Anko!"

# 动态加载布局
verticalLayout {
    val name = editText()
    button("Say Hello") {
        onClick { toast("Hello, ${name.text}!") }
    }
}
```

## Kotlin学习项目
[Github地址](https://github.com/huaqianlee/KotlinDemo)

## 附上一点经验
1. 依赖包总是下载失败时，通过log和Task确定链接，手动下载然后放到相应路径。
```bash
# 依赖包路徑，可以通过ExternalLibraries-><PackegName>->Library Properties查看
/home/lee/.gradle/caches/modules-2/files-2.1

# gradle路徑
/home/lee/.gradle/wrapper/dists

# gradle下载路径
http://services.gradle.org/distributions/
```

2. 图形界面查看和添加依赖

```bash
# 查看
Project Structure->app->Dependencies

# 添加, 这样添加后会自动在build.gradle中添加语句
Project Structure->app->Dependencies->+->Library/Jar/Module Dependency
```
看log耐心一些，做一些分析尝试，再加上Google会找到原因的。





