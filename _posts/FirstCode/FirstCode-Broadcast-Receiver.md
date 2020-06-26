title: "第一行代码之广播机制"
date: 2017-03-25 21:06:00
categories: 学习笔记
tags: [App,FirstCode]
---
[《第一行代码》第2版思维导图及所有学习笔记目录](http://huaqianlee.github.io/2017/03/24/FirstCode/The-departure-of-FirstCode-learning-notes/)

## 广播机制
### 标准广播
![normal_broadcast](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/firstcode/normal_broadcasts.png)
<!--more-->
### 有序广播
![ordered_broadcast](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/firstcode/ordered_broadcast.png)

## 接收系统广播
### 动态注册监听网络变化
通过内部类创建广播接收器，实现动态监听网络广播的代码。
```java
class MainActivity {
    private IntentFilter intentFilter;
    private NetworkChangeReceiver networkChangeReceiver;
    
    oncreate() {
        ...
        intentFilter = new IntentFilter();
        intetFilter.addAction("android.net.conn.CONNECTIVITY_CHANGE");
        networkChangeReceiver = new NetworkChangeReceiver();
        registerReceiver(newworkChangeReceiver, intentFilter);
    }
    
    onDestory() {
        ...
        unregisterReceiver(networkChangeReceiver);
    }
    
    clss NetworkChangeReceiver extends BroadcastReceiver {
        public void onReceive(Context context, Intent intent){
            ConnectivityManager manager =(ConnectivityManager)getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo networkInfo = manager.getActiveNetworkInfo();
            if(networkInfo != null && networkInfo.isAvailable()){}
            else{}
        }
    }
}
```
AndroidManifest.xml中添加权限
```bash
<uses-permission android:name="android.permission.ACCES_NETWORK_STATE"/>
```
### 静态注册实现开机启动
新建BootCompletReceiver来作为广播接收器，通过AS自动创建时两个注意选项：Enable-启用，Exported-接收本程序外的广播。
```java
Public class BootCompletReceiver extends BroadcastReceiver {
    public void onReceive(Context context, Intent intent){}
}
```
>AndroidManiest.xml自动完成注册， 四大组件皆需要注册

AndroidManiest.xml中静态注册。
```bash
<receiver
    ...
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
    </intent-filter>
</receiver>
```

## 自定义广播
### 标准广播
新建广播接收器MyBroadcastReceiver。
```java
Public class MyBroadcastReceiver extends BroadcastReceiver {
    public void onReceive(Context context, Intent intent){}
}
```
注册修改接收器信息。
```bash
<receiver
    ...
    <intent-filter>
        <action android:name="com.lee.broadcasttest.MY_BROADCAST"/>
    </intent-filter>
</receiver>
```
发送广播：
```java
Intent intent = new Intent("com.lee.broadcasttest.MY_BROADCAST");
sendBroadcast(intent);
```
### 有序广播
发送有序广播：
```java
Intent intent = new Intent("com.lee.broadcasttest.MY_BROADCAST");
sendOrderedBroadcast(intent, null); // arg2:权限相关
```
广播接收器优先级设置：
```bash
<intent-filter android:priority="100">
...
```
优先级高的接收器截断广播：
```java
onReceive() {
    ...
    abortBroadcast();
}
```

## 使用本地广播
前面的广播方式属于全局广播，存在安全问题，使用本地广播就能避免安全问题。
```java
MainActivity {
    private LocalReceiver localReceiver;
    private LocalBroadcastReceiver localBroadcastReceiver;
    
    onCreate(){
        localBroadcastManager = LocalBroadcastManager.getInstance(this);//获取实例
        
        // 按键发送广播
        Intent intent = new Intent("com.lee.broadcasttest.LOCAL_BROADCAST");
        localBroadcastManager.sendBroadcast(intent);// 发送本地广播
        
        intentFilter.addAction("com.lee.broadcasttest.LOCAL_BROADCAST");
        localReceiver = new LocalReceiver();
        localBroadcastManager.registerReceiver(localReceiver, intentFilter); //注册本地广播监听器
    }
    
    onDestory() {
        localBroadcastManager.unregisterReceiver(localReceiver, intentFilter); 
    }
    
    class LocalReceiver extends BroadcastReceiver {
        onReceiver(){}
    }
}
```
>本地广播除了安全还有一个优势，效率更高。

## 实现强制下线功能
实现关闭所有活动的功能，创建管理所有活动的类ActivityCollector。
```java
public class ActivityCollector {
    public static List<Activity> activities = new ArrayList();
    
    public static addActivity(Activity activity){
        activities.add(activity);
    }
    
    public static removeActivity(Activity activity){
        activities.remove(activity);
    }
    
    public static finishAll(){
        for(Activity activity: activities) {
            if(!activity.isFinishing()) {
                activity.finish();
            }
        }
    }
}
```
创建所有活动的父类BaseActivity：
```java
public class BaseActivity extends AppCompatActivity {
    oncreate(){
        ActivityCollector.addActivity(this);
    }
    onDestory(){
        ActivityCollector.removeActivity(this);
    }
}
```
新建LoginActivity，设计布局文件：
```bash
<LinearLayout
    <LinearLayout <TextView/> <EditText/> </LinearLayout>    
    <LinearLayout <TextView/> <EditText/> </LinearLayout>  
    <Button "Login"/>
</LinearLayout>
```
LonginAcitivty中实现登录代码。
```java
if(account.equals("xxx") && password.equarls("xxx")) {
    Intent intent = new Intent(LoginActivity.this, MainActivity.class);
    startActivity(intent);
    finish();
}
```
实现强制下线活动，简单设计一个Button触发强制下线。
```java
Public class MainActivity extends BaseActivity {
    onClick(){
        Intent intent = new Intent("com.lee.demo.FORCE_OFFLINE");
        startBroadcast(intent);
    }
}
```
由于广播接收器需要弹出一个对话框阻止用户继续操作(不能静态注册方式)，然后接收器也得在所有活动中生效，所以在BaseActivity中动态注册广播接收器。
```java
BaseActivity {
    private ForceOfflineReceiver reicerver;
    
    onResume(){
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.lee.demo.FORCE_OFFLINE");
        receiver = new ForceOfflineReciever();
        registerReceiver(receiver, IntentFilter);
    }
    
    onPause(){
        if(receiver != null){
            unregisterReceiver(receiver);
            receiver = null;
        }
    }
    
    
    class ForceOfflineReceiver extends BroadcastReceiver {
        onReceive(final Context context, Intent intent){
            AlertDialog.Builder builder = new AlertDialog.Builder(context);
            builder.setTiltle("");
            builder.setMessage("");
            builder.setCancelable(false); // 对话框设置为不可取消，否则用户按一下返回键又可继续使用程序了
            builder.setPositiveButton("ok",new DialogInterface.OnclickListener(){
                onclick(){
                    ActivityCollector.finishAll();
                    Intent intent = new Intent(context, LoginActivity.class);
                    context.startActivity(intent);
                }
            });
            builder.show();
        }
    }
}
```
不过，还有一个遗漏需要处理，即将LoginActivity设为主活动。
```bash
<intent-filter>
    <action android:name="android.intent.action.MAIN"/>
    <category android:name="android.intent.category.LAUNCHER"/>
</intent-filter>    
```

