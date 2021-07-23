title: "第一行代码之服务"
date: 2017-05-06 23:58:30
categories:
- Android Tree
- Notation
tags: [App,FirstCode]
---
[《第一行代码》第2版思维导图及所有学习笔记目录](http://huaqianlee.github.io/2017/03/24/FirstCode/The-departure-of-FirstCode-learning-notes/)


## 多线程编程
### 线程基本用法
方式一：
```java
class MyThread extends Thread {
    public void run(){}
}

new MyThread().start();
```
<!--more-->
方式二：
```java
class MyThread implements Runnable{
    public void run(){}
}

new Thread(new MyThread()).start();
```
方式三：
```java
new Thread(new Runnable() {
    public void run(){}
}).start();
```
### 在子线程中更新UI
直接在子线程中更新UI将导致APP崩溃，所以正确做法是通过异步消息处理机制来实现。譬如按键实现更新UI：
```java
public static final int UPDATE_TEXT = 1;

onClick() {
    new Thread(new Runnable() {
        public void run () { // 这里不能更新UI
            Message message = new Message();
            message.what = UPDATE_TEXT;
            handler.sendMessage(message);
        }
    }).start();
}

private Handler handler = new Handler() {
    public void handleMessage(Message msg) {
        switch(msg.what) {
            case UPDATE_TEXT:
            // 进行更新UI操作
            break;
            ...
        }
    }
}
```

另一种在子线程更新UI的快捷方式：
```java
runOnUiThread(new RUnnable() {
    @Override
    public void run {
        // UI操作逻辑
    }
});
```
### 异步消息处理机制
Android的异步消息处理主要由四个部分组成：
1. Message
    可以携带少量信息，用于在线程之间传递。
2. Handler
    处理者，用于发送与处理消息。
3. MessageQueue
    消息队列，存放所有Handler发送的消息，等待处理，每个线程只有一个。
4. Looper
    MessageQueue的管家，其loop()方法循环取出消息传递到handleMessage()方法中处理。每个线程只有一个。

流程示意图如下：

![异步消息机制处理流程图](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/firstcode/yibu_flow.png)

### AsyncTask
AsyncTask的一个简单示例：
```java
/*
** Void - 不需传入参数给后台任务
** Integer - 用整型数据作为后台任务进度显示单位
** Boolean - 布尔型数据返回执行结果
*/
class DownloadTask extends AsyncTask<Void, Integer, Boolean> {
    /*后台任务开始前调用*/
    @Override
    protected void onPreExecute() {
        progressDialog.show();//显示进度对话框
    }
    
    /*执行在子线程，耗时任务应在此方法执行*/
    @Override
    protected Boolean doInBackground(Void... params) {
        try {
            while(true) {
                int downloadPercent = doDownload();
                publishProgress(downloadPercent); // 反馈当前执行进度
                if (donwloadPercent >= 100) {
                    break;
                }
            }
        }
        ...
        return true;
    }
    
    /*publishProgress触发*/
    @Override
    protected void onProgressUpdate(Integer... values) {
        progressDialog.setMessage("Downloaded" + values[0]+"%");
        // 更新下载进度
    }
    
    /*doInBackground返回触发*/
    @Override
    protected void onPostExecute ( Boolean result) {
        progressDialog.dismiss();//关闭进度对话框
        if(result) {} else{}  // 提示下载结果
    }
}

// 启动此任务
new DownloadTask().execute();
```
## 服务基本用法
### 定义服务
创建服务时两个属性：Exported - 是否允许其他程序访问，Enabled - 启用服务。示例：
```java
public class MyService extends Service {
    public MyService() {
    }

    /*第一次创建时调用，创建一个实例后不再调用*/
    @Override
    public void onCreate() {
        super.onCreate();
    }

    /*每次启动服务时调用*/
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    /*必须实现的抽象方法*/
    @Override
    public IBinder onBind(Intent intent) {
        // TODO: Return the communication channel to the service.
        ...
    }
}
```
### 启动和停止服务
```java
# 启动服务
Intent startIntent = new Intent(this, MyService.class);
startService(startIntent);

# 停止服务
Intent stopIntent = new Intent(this, MyService.class);
stopService(stopIntent);
```

### 活动与服务通信
让MyService提供下载功能，并活动可以决定下载时间和查看进度，添加通信代码：
```java
# 服务部分
public class MyService extends Service {
    @Override
    public IBinder onBind(Intent intent) {
        // TODO: Return the communication channel to the service.
        return mBinder;
    }

    private DownloadBinder mBinder = new DownloadBinder();

    class DownloadBinder extends Binder {
        public void startDownload () {}
        public int getProgress() {}
    }
    ...
}

# 活动部分
实现匿名类：
    private MyService.DownloadBinder downloadBinder;

    private ServiceConnection connection= new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            /*service向下转型得到DownloadBinder，进行交互*/
            downloadBinder= (MyService.DownloadBinder) service;
            downloadBinder.startDownload();
            downloadBinder.getProgress();
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {

        }
    };

绑定服务：
    Intent bindIntent = new Intent(this,MyService.class);
    bindService(bindIntent,connection,BIND_AUTO_CREATE); //arg3:绑定后自动创建服务，onCreate()执行，onStartCommand()不执行
    
解绑服务：
    unbindService(connection);
```

### 前台服务
前台服务可以一直处于运行状态，而不会被垃圾回收，并且会在系统状态栏显示。一个简单的示例：
```java
    @Override
    public void onCreate() {
        super.onCreate();
        Intent intent = new Intent(this,MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this,0,intent,0);
        Notification notification = new NotificationCompat.Builder(this)
                .setContentTitle("This is a content title!")
                .setContentText("this is a content text!")
                .setWhen(System.currentTimeMillis())
                .setSmallIcon(R.mipmap.ic_launcher)
                .setLargeIcon(BitmapFactory.decodeResource(getResources(),R.mipmap.ic_launcher))
                .setContentIntent(pendingIntent)
                .build();
        startForeground(1,notification);// 将服务变为前台服务
    }
```
### 使用IntentService
**服务默认运行于主线程**，所以耗时逻辑得通过多线程技术处理。IntentService的好处就是新开线程来处理耗时操作。
标准写法：
```java
onStartCommand(){
    new Thread(new Runnable() {
        @Override
        public void run() {
            // 处理具体逻辑
            stopSelf();//执行完毕后自动停止服务
        }
    }).start();
}
```
IntentService方式：
>AS自动创建IntentService会生成一大堆用不到的代码，因此手动创建

```java
public class MyIntentService extends IntentService {
    public MyIntentService() {
        super("MyIntentService");// 调用父类有参构造函数
    }
    
    @Override
    protected void onHandleIntent(Intent intent) {
        // 处理具体逻辑，已经运行于子线程
    }
    
    @Override
    public void onDestroy() {
        super.onDestroy();
    }
}

# 启动IntentService
Intent intent = new Intent(MainActivity.this, MyIntentService.class);
startService(intent);

# 注册
<service android:name=".MyIntentService"/>
```
