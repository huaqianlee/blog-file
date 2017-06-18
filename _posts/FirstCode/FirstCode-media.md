title: "第一行代码之手机多媒体"
date: 2017-05-06 23:57:26
categories: 学习笔记
tags: [App,FirstCode]
---
[《第一行代码》第2版思维导图及所有学习笔记目录](http://huaqianlee.github.io/2017/03/24/FirstCode/The-departure-of-FirstCode-learning-notes/)

## 使用通知
### 通知基本用法
获取通知:
```java
NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
```
<!--more-->
构建Notification对象：
```java
Notification notification = new NotificationCompat.Builder(context)
.setContentTitle(..)
.setContentText(..)
...
.build();
```
显示通知：
```java
manager.notify(1, notification);
```
一个实例写法：
```java
Intent intent = new Intent(MainActivity.this, NotificationActivity.class);
PendingIntent pi = PendingIntent.getActivity(MainActivity.this, 0, intent, 0);
NotificationManager manager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
Notification notification = new NotificationCompat.Builder(MainActivity.this)
        .setContentTitle("This is content title")
        .setContentText("this is content text")
        .setWhen(System.currentTimeMillis())
        .setSmallIcon(R.mipmap.ic_launcher)
        .setLargeIcon(BitmapFactory.decodeResource(getResources(),R.mipmap.ic_launcher))
        .setContentIntent(pi)  // 设置点击跳转
        .setAutoCancel(true)
        .setDefaults(Notification.DEFAULT_ALL)
        .setContentText("This is a notification test,  this Builder has many func, but do not test all of them ")
        .setPriority(NotificationCompat.PRIORITY_MAX)
        .build();
manager.notify(1,notification);
//manager.cancel(1);  // 同上面autocancel()，取消通知，这样通知点击后才能从通知栏消失

# Intent - 立即执行某个动作， PendingIntent - 合适的时机去执行某个动作
```
### 通知的进阶功能
```java
.setSound(Uri.fromFile(new File("/system/media/audio/ringtones/Luna.ogg"))
.setVibrate(new long[](0,1000,1000,1000)) // 下标偶数包括0静止时长，奇数-振动时长
.setLights(Color.GREE, 1000,1000)
.setDefaults(NotificationCompat.DEFAULT_ALL)//默认方式实现上述三种功能
.setStyle(new NotificationCompat.BigTextStyle().bigText("")) //完整显示一大段文字
.setStyle(new NotificationCompat.BigPictureStyle().bigPicture(BitmapFactory.decodeResource(getResources(),R.drawable.big_image))//显示大图片
.setPriority(NotificationCompat.PRIORITY_MAX) // 设置通知重要程度

<uses-permission android:name="android.permission.VIBRATE">
```
## 摄像头、相册和音视频
这部分不想搞笔记了，留下个实例地址吧：
[摄像头、相册和音视频简例](https://github.com/huaqianlee/AndroidDemo/tree/master/FirstCode/chapter8)。

