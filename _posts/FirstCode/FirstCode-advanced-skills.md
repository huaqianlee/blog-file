title: "第一行代码之高级技巧"
date: 2017-05-13 19:09:08
categories: 学习笔记
tags: [App,FirstCode]
---
## 全局获取Context
新建一个自己Application，如下：
```java
public class MyApplication extends Application {
    private static Context context;
    
    @Override
    public void onCreate() {
        context = getApplicationContext();
    }
    
    public static Context getContext() {
        return context;
    }
}
```
<!--more-->
指定程序启动时初始化的Application，如下：
```xml
<application
    android:name="com.example.networknest.MyApplication" //完整的包名
    ...>
    ...
</application>    
```
需要Context时而没有，即可调用如下：
```java
Toast.makeText(MyApplication.getContext(),...).show();
```
不过LItePal要正常工作也需要配置起自己的Application，如下：
```xml
android:name="org.litepal.LitePalApplication"
```
其也是为了能在内部自动获取Context，遇到这种冲突，类似如下方式解决：
```java
public class MyApplication extends Application {
    private static Context context;
    
    @Override
    public void onCreate() {
        context = getApplicationContext();
        LitePalApplication.initialize(context);
    }
    ...
}
```
## 使用Intent传递对象
### Serializable方式
将对象实现Serializable接口，让对象成为序列化可存储传输状态，如下：
```java
# 对象实现接口
public class Person implements Serializable {}

# 传输
intent.putExtra("person_data",person);

# 接收
Person person = (Person)getIntent().getSerializableExtra("person_data");
```
### Parcelable方式
>**推荐此方式，效率更高**

Parcelable方式是将对象分解为Intent支持的数据类型，如下：
```java
# 对象实现接口
public class Person implements Parcelable {
    private String name;
    ...
    
    @Override 
    public int describeContents() {
        return 0;
    }
    
    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(name); // 写出name
        dest.writeInt(age);
    }
    
    public static final Parcelable.Creator<Person> CREATOR = new Parecelable.Creator<Person>() {
        @Override
        public Person createFromParcel(Parcel source) {
            Person person = new Person();
            /*必须与上面写出的顺序一致*/
            person.name = source.readString();// 读取name
            person.age = source.readInt();
            return person;
        }
        
        @Override
        public Person[] newArray(int size) {
            return new Person[size];
        }
    };
}

# 传输
intent.putExtra("person_data",person);

# 接收
Person person = (Person)getIntent().getParcelableExtra("person_data");
```
## 定制日志工具
为了方便控制开关日志，一般会定义一个日志工具类，如下：
```java
public class LogUtil {
    public static final int VERBOSE = 1;
    public static final int DEBUG = 2;
    public static final int INFO = 3;
    public static final int WARN = 4;
    public static final int ERROR = 5;
    public static final int NOTHING = 6;
    public static int level = VERBOSE;
    
    public static void v(String tag, String msg) {
        if (level <= VERBOSE) {
            Log.v(tag, msg);
        }
    }
    
    public static void d(String tag, String msg) {
        if (level <= DEBUG) {
            Log.d(tag, msg);
        }
    }   
    
    public static void i(String tag, String msg) {
        if (level <= INFO) {
            Log.i(tag, msg);
        }
    }    
    
    public static void w(String tag, String msg) {
        if (level <= WARN) {
            Log.w(tag, msg);
        }
    }
    
    public static void e(String tag, String msg) {
        if (level <= ERROR) {
            Log.e(tag, msg);
        }
    }    
}

# 调用
LogUtil.v() ...

# 关闭所有日志
LogUtil.level = NOTHING;
```
## 创建定时任务
### Alarm机制
简单用法如下：
```java
AlarmManager manager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
long triggerAtTime = SystemClock.elapsedRealtime() + 10*1000;
/*开机至今时间（ms）+定时时间*/
manager.set(AlarmManager.ELAPSED_REALTIME_WAKE_UP, triggerAtTime, pendingIntent);
/*
** arg1: 指定AlarmManager工作类型，即时间计算方式与是否唤醒CPU。
*/

or

long triggerAtTime = System.currentTimeMillis() + 10*1000;
/*1970.1.1 0点至今时间（ms）+定时时间*/
manager.set(AlarmManager.RTC_WAKEUP, triggerAtTime, pendingIntent);
...
```
一个后台定时服务示例：
```java
public class LongRunningService extends Service {
    @Override
    onBind(){}

    @Override
    public int onStartCommand(Intent intent , int flags , int startId) {
        new Thread(new Runnable() {
                public void run(){
                    // 执行具体逻辑操作， 新开线程，为了定时准确性
                }
            }).start();
        AlarmManager manager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
        long triggerAtTime = SystemClock.elapsedRealtime() + 60*60*1000;// 定时一小时
        Intent i = new Intent(this, LongRunningService.class);
        PenddingIntent pi = PendingIntent.getService(this, 0, i, 0);
        manager.set(AlarmManager.ELAPSED_REALTIME_WAKE_UP, triggerAtTime, pendingIntent);   
        return super.onStartCommand(intent, flags, startId); 
    }
}
```
需要定时服务时启动服务：
```java
Intent intent = new Intent(this, LongRunningService.class);
context.startService(intent);
```
>不过为了功耗，Android限制减少了cpu唤醒次数，set()可能不十分准确，若准确性要求高，可使用setExact()方法。

### Doze模式
Android6.0及以上为了省电新加入了Doze模式，满足未插电、屏幕关闭等一段时间将进入doze模式，对cpu、网络、Alarm等进行限制，如下为Android7.0进入Doze模式的两个阶段：
阶段一：
![First Level](http://7xjdax.com1.z0.glb.clouddn.com/image/firstcode/doze_first_level.png)
阶段二：
![Second Level](http://7xjdax.com1.z0.glb.clouddn.com/image/firstcode/doze_second_level.png)

如若想Alarm在Doze模式也能正常执行，则需要使用AlarmManager的如下两个方法：
```java 
setAndAllowWhileIdle()        
setExactAndAllowWhileIdle()  
```
>区别同上set()与setExact()

## 多窗口模式编程
进入多窗口模式活动会重建，可以通过如下方式改变：
```xml
<activity
    ...
    android:configChanges="orientation|keyboardHidden|screenSize|screenLayout">
    // 多窗口、横竖屏切换，活动皆不会被重建
    ...
</activity>    
```
屏幕的变化将通知到Acitvity的onConfigurationChanged()方法，可以重写此方法进行逻辑处理。

禁用多窗口模式：
```xml
# <application>或<activity>标签加入
android:resizeableActivity="false"  // 默认为true，支持
```
不过targetSDKVersion低于24的，上述属性将不会生效，这就得通过另一种方案：制定不支持横竖屏切换，因为android规定24以下不允许横竖屏切换的亦不知多窗口，如下：
```xml
android:screenOrientation=["portrait"|"landscape"]
```
## Lambda表达式
使用Java8新特性，需先在app/build.gradle添加如下配置：
```gradle
defaultConfig {
    ...
    jackOptions.enabled = true
}

compileOptions {
    sourceCompatibility JavaVersion.VERSION_1_8
    targetCompatibility JavaVersion.VERSION_1_8
}
```
只有一个待实现方法的接口，都可使用Lambda表达式，如下：
```java
new Thread(new Runnable() {
    public void run(){}
}).start();

# Lambda 方式
new Thread(() -> {
    // 实现run()逻辑
}).start();
```
带参数的书写方式：
```java
(String a, int b) -> {// 还可以省略掉参数类型，Java根据上下文推断    
}
```






