title: "第一行代码之项目结构与活动"
date: 2017-03-24 20:07:01
categories: 学习笔记
tags: [App,FirstCode]
---
 [《第一行代码》第2版思维导图及所有学习笔记目录](http://huaqianlee.github.io/2017/03/24/FirstCode/The-departure-of-FirstCode-learning-notes/)

# 第一个应用
## 项目结构
很早以前第一次接触Android代码的项目结构的时候确实够头疼滴.
<!--more-->

![项目结构](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/firstcode/prj_struct.png)

* .gradle & .idea  
Android Studio自动生成, 无需关心, 版本管理时,一般将其忽略(即.gitignore文件).
* app
项目代码、资源基本位于此路径。
* build
编译自动生成
* gradle
gradle wrapper配置文件.
* .gitignore
git版本管理忽略文件及路径的脚本
* build.gradle
项目全局的gradle构建脚本, 通常不需修改
* gradle.properties
全局gradle的配置文件,所配置属性影响项目中所有gradle编译脚本
* gradlew & gradlew.bat
用以命令行界面执行gradle命令, gradlew用于Linux或Mac Os, gradlew.bat 用于windows.
* 项目名.iml
iml文件是InteliJ IDEA项目(Android Studio基于其开发)自动生成的文件
* local.properties
指定本机Android SDK路径
* settings.gradle
指定项目中所有引入的模块

### app目录
* build
编译自动生成
* libs
构建项目所需的库第三方.jar包
* androidTest
对项目进行一些自动化测试的Android Test测试用例
* java
所有Java代码的路径
* res
项目所使用的所有图片、布局、字符等资源路径
* AndroidManifest.xml
整个项目的配置文件，权限声明、四大组件注册
* test
Unit Test测试用例，项目自动化测试的另一种方式
* .gitignore
git版本管理忽略文件及路径的脚本
* app.iml
InteliJ IDEA文件
* build.gradle
app模块的gradle构建脚本
* proguard-rules.pro
指定项目代码的混淆规则

### build.gradle
最外层build.gradle
```bash
// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        jcenter()   # 声明jcenter代码托管库
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:2.3.0'  # 声明Android版本gradle

        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}

allprojects {
    repositories {
        jcenter()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}

```

app目录下的build.gradle
```bash
apply plugin: 'com.android.application'  # 声明application or library 

android {
    compileSdkVersion 24
    buildToolsVersion "25.0.0"
    defaultConfig {
        applicationId "me.huaqianlee.broadcastbestpractice"  
        minSdkVersion 15
        targetSdkVersion 24
        versionCode 1   # 项目版本号
        versionName "1.0" # 项目版本名
        testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
    }
    buildTypes {
        release {
            minifyEnabled false   # 指定是否混淆代码
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
            # xxx.txt Android SDK目录下项目通用混淆规则
            # xxx.pro 当前项目根目录下,编写特有混淆规则
        }
    }
}

dependencies { # 指定当前项目的所有依赖关系(本地依赖\库依赖\远程依赖)
    compile fileTree(dir: 'libs', include: ['*.jar'])  # 本地依赖,libs下的所有.jar
    androidTestCompile('com.android.support.test.espresso:espresso-core:2.2.2', {
        exclude group: 'com.android.support', module: 'support-annotations'
    })
    # 远程依赖
    compile 'com.android.support:appcompat-v7:24.2.1' 
    compile 'com.android.support.constraint:constraint-layout:1.0.2'
    testCompile 'junit:junit:4.12'

    # 库依赖: compile project(':xxx')
}

```

# 活动
## 基本用法
### 活动中使用Menu
在res/menu路径下新建xxx.xml,添加代码:
```bash
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item 
        android:id="@id/add_item"
        android:title="Add"/>
    <item
        android:id="@id/remove_item"
        androi:title="Remove"/>    
</menu> 
```
在Activity中重写onCreateOptionsMenu()方法:
```bash
public boolean onCreateOptionsMenu(Menu menu) {
    getMenuInflater().inflate(R.menu.main, menu);
    return true; // 允许菜单显示
}
# getMenuInflater() 获得MenuInflater对象,然后通过inflate方法创建菜单
```

响应菜单事件, 重写onOptionsItemSelected(MenuItem item)方法,item.getItemId() 判断item ID.

### 销毁活动
finish()方法即可.

## Intent的应用
### 显式Intent
通过Intent显示启动另一活动.
```bash
Intent intent = new Intent(FirstActivity.this, SecondActivity.class);
startActivity(intent);
```
### 隐式Intent
在AndroidManifest.xml中针对SecondActivity添加:
```bash
<intent-filter>
    <action android:name="me.huaqianlee.activity.ACTION_START"/>
    <category android:name="android.intent.category.DEFAULT"/> # 默认category
</intent-filter>
```
在FistActivity中Intent指定相同<action\>与<category\>即可启动另一活动.
```bash
Intent intent = new Intent("me.huaqianlee.activity.ACTION_START");
//intent.addCategory("android.intent.category.DEFAULT");
# 因为声明的默认category, 这里不用添加, startActivity会自动添加.
startActivity(intent);
```

### 更多隐式Intent用法
#### 启动浏览器
在自己应用程序中展示网页。
```bash
Intent intent = new Intent(Intent.ACTION_VIEW); # 内置动作,常量值:android.intent.action.VIEW.
intent.setData(Uri.parse("http://www.google.com"));
startActivity(intent);
```
AndroidManifest.xml中更精确指定当前活动响应的类型：
```bash
<intent-filter>
    <data>
        android:scheme  # 指定数据协议,如 http
        android:host    # 主机名, 如域名
        android:port    # 端口
        android:path    # 如网址中域名后面的内容
        android:mimeType # 可以处理的数据类型, 可以通过通配符指定
    </data>
</intent-filter>
```
譬如在某一活动xml中加入如下内容则可响应http网页：
```bash
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <data android:scheme="http"/>
</intent-filter>
```
#### 启动系统拨号
```bash
Intent intent = new Intent(Intent.ACTION_DIAL);
intent.setData(Uri.parse("tel:10010"));
startActivity(intent);
```
### 活动中传递数据
#### 传递数据到下一个活动
FirstActivity中添加：
```bash
String data = "Hello, SecondActivity!";
Intent  intent = new Intent(FirstActivity.this, SecondActivity.class);
intent.putExtra("extra_data", data); // 参数：键值对
startActivity(intent);
```
SecondActivity中接收：
```bash
Intent intent = getIntent();
String data = intent.getStringExtra("extra_data");
```
#### 返回数据给上一活动
FirstActivity中添加代码：
```bash
Intent  intent = new Intent(FirstActivity.this, SecondActivity.class);
startActivityForResult(intent,1);
```
FirstActivity中重写回调函数：
```java
@Override
protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    switch(requestCode) {
        case 1: 
            if(resultCode = RESULT_OK)
                String returnData = data.getStringExtra("data_return");
    }
}
```

SecondActivity中实现返回逻辑：
```bash
Intent intent = new Intent();
intent.putExtra("data_return", "Hello, FirstActivity!");
setResult(RESULT_OK, intent);
finish();
# 为了在按返回键时也返回数据,需要重写onBackPressed()方法,并加入如上内容.
```
## 活动的生命周期
![lifecycle](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/firstcode/lifecycle.gif)

根据生命周期，活动存在被回收的可能性，所以为了有好的体验，需要保存数据。
```bash
@Overide
protected void onSaveInstanceState(Bundle outState) {
    super.onSaveInstanceState(outState);
    String tempData = "**********";
    outState.putString("data_key", tempData);
}
```
恢复数据:
```bash
protected void onCreate(Bundle savedInstanceState) {
    ....
    if(savedInstanceState != null){
        String tmpData = savedInstaceState.getString("data_key");
    }
}
```
>Bundle对象亦可放在Intent对象中传递.

## 活动的启动模式
活动启动模式一共4种：standard、singleTop、singleTask和singleInstance。AndroidManifest.xml中<activity/>指定android:launchMode属性来选择。
### standard
系统默认，每启动一个活动就在栈顶创建，即使已经存在。
![standard](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/firstcode/standard.jpg)

### singleTop
活动启动时，栈顶如果不存在此活动，则创建此活动。
![singleTop](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/firstcode/singleTop.jpg)

### singleTask
活动启动时，如果栈里存在此活动，则将之前的全部出栈，将此活动置于栈顶。
![singleTask](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/firstcode/singleTask.jpg)

### singleInstance
启动活动时，单独创建一个返回栈来管理，这样所有应用可以共用返回栈，访问此活动。
![singleInstance](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/firstcode/singleInstance.jpg)

## 最佳实践及有用的技巧
### 随时随地退出程序
随时随地退出程序，建一个ActivityCollector类和所有新建类的基类BaseActivity类。
```bash
public class ActivityCollector {
    public static List<Activity> activities = new ArrayList<>();

    public static void addActivity(Activity activity) {
        activities.add(activity);
    }
    public static void removeActivity(Activity activity) {
        activities.remove(activity);
    }

    public static void finishAll() {
        for(Acitivity activity : activities) {
            if(!activity.isFinishing()) {
                activity.finish();
            }
        }
    }
}

public class BaseActivity extends AppCompatActivity {
    protected void onCreate(Bundle saveInstanceState) {
        ...
        ActivityCollector.addActivity(this);
    }

    protected void onDestory () {
        ...
        ActivityCollector.removeActivity(this);
    }
}
```
当需要销毁所有活动时
```bash
ActivityCollector.finishAll();
android.os.Process.killProcess(android.os.Process.myPid());
# kill掉当前进程， 确保万一的语句
```

### 项目合作时启动活动的最佳写法
在需要被启动的活动中实现actionStart()方法。
```bash
public static void actionStart(Context context, String data1, String data2) {
    Intent intent = new Intent(context, xxx.class);
    intent.putExtra("param1",data1);
    intent.putExtra("param2",data2);
    context.startActivity(intent);
}
```




