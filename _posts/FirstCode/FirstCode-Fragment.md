title: "第一行代码之碎片"
date: 2017-05-10 12:24:05
categories: 学习笔记
tags: [App,FirstCode]
---
[《第一行代码》第2版思维导图及所有学习笔记目录](http://huaqianlee.github.io/2017/03/24/FirstCode/The-departure-of-FirstCode-learning-notes/)

## 碎片的使用
### 碎片的简单用法
新建一个示例包含两个碎片，平分活动空间，新建左侧碎片布局，如下：
```xml
<LinearLayout...>
	<Button.../>
</LinearLayout>
```
<!--more-->
新建右侧碎片布局：
```xml
<LinearLayout...>
	<TextView.../>
</LinearLayout>
```
新建LeftFragment类，继承于Fragment（选择来自support-v4库的类，做到向下兼容）。如下：
```java
public class leftFragment extends Fragment {
	onCreateView() {
		View view = inflater.inflate(R.layout.left_fragment, container, false);
		return view;
	}
}
```
新建RightFragment类，如下：
```java
public class leftFragment extends Fragment {
	onCreateView() {
		View view = inflater.inflate(R.layout.right_fragment, container, false);
		return view;
	}
}
```
修改主活动布局：
```xml
<LinearLayout
	android:orientation="horizontal"	
	...>
	<fragment
	android:name="com.example.lee.fragmentdemo.LeftFragment"	
	.../>
	<fragment
	android:name="com.example.lee.fragmentdemo.RightFragment"	
	.../>
</LinearLayout>
```
### 动态添加碎片
新建another_right_fragment.xml：
```xml
<LinearLayout...>
	<TextView.../>
</LinearLayout>
```
新建AnotherRightFragment类，如下：
```java
public class AnotherRightFragment extends Fragment {
	onCreateView() {
		inflater.inflate(R.another_right_fragment, container, false);
		return view;
	}
}
```
主活动添加布局：
```xml
<FrameLaout ...>
</FrameLayout>
```
修改主活动代码：
```
replaceFragment(new AnotherRightFragment());
...
private void replaceFragment(Fragment fragment) {
	FragmentManager fragmentManager = getSupportFragmentManager();
	FragmentTransaction transaction = fragmentManager.beginTransaction();
	transaction.replace(R.id.right, fagment);
	transaction.commit();
}
```
### 碎片中模拟返回栈
修改代码：
```java
replaceFragment(){
	...
	transaction.addToBackStack(null);//按下返回键后，则回退碎片
	transaction.commmit();
}
```
### 碎片与活动通信
活动中获取碎片实例：
```java
RightFragment rightFragment = (RightFragment) getFragmentManager()
	.findFragmentById(R.id.right_fragment);
```
碎片中获取活动：
```java
MainActivity activity = (MainActivity)getActivity();//获取碎片相关联的活动实例
```
## 碎片的生命周期
碎片生命周期中的状态有：
1. 运行状态：碎片可见，关联活动处于运行状态，碎片也处于运行状态。
2. 暂停状态：活动进入暂停状态（另一非占全屏的活动加到栈顶），关联碎片也就进入暂停状态。
3. 停止状态：活动进入停止状态，或调用FragmentTransaction.remove()、replace()，事务提交前有调用addToBackStack()。进入停止状态不可见，可能会被系统回收。
4. 销毁状态：活动被销毁，或调用FragmentTransaction.remove()、replace()，事务提交前未调用addToBackStack()。

碎片生命周期如下：

![碎片的生命周期](https://github.com/huaqianlee/blog-file/blob/master/image/fragment_lifecycle.png)

几个关键回调：
* onAttach()：碎片和活动建立关联时调用。
* onCreateView()：为碎片创建视图（加载布局）时调用。
* onActivityCreated()：确保与碎片相关联的活动创建完毕时调用。
* onDestroyView()：与碎片关联的视图被移除时调用。
* onDetach()：碎片与活动解除关联时调用。

## 动态加载布局
### 使用限定符

修改主活动布局：
```xml
<LinearLayout
	android:orientation="horizontal"	
	...>
	<fragment
	android:name="com.example.lee.fragmentdemo.LeftFragment"
	//满屏显示	
	.../>
</LinearLayout>
```
新建新的主布局res/layout-large/activity_main.xml，如下：
```xml
<LinearLayout
	android:orientation="horizontal"	
	...>
	<fragment
	android:name="com.example.lee.fragmentdemo.LeftFragment"	
	.../>
	<fragment
	android:name="com.example.lee.fragmentdemo.RightFragment"	
	.../>
</LinearLayout>
```
这样布局后，手机就会默认加载第一个布局，平板则加载large布局。

Android中场景限定符（Qualifiers）如下：

|限定符|描述|
|:----:|:--:|
|small|小屏设备的资源|
|normal|中等屏设备的资源|
|large|大屏设备的资源|
|xlarge|超大屏设备的资源|
|ldpi|低分辨率设备的资源（120dpi以下）|
|mdpi|中分辨率设备的资源（120～160dpi）|
|hdpi|高分辨率设备的资源（160～240dpi）|
|xhdpi|超高分辨率设备的资源（240～320dpi）|
|xxhdpi|超超高分辨率设备的资源（320～480dpi）|
|land|横屏设备的资源|
|port|竖屏设备的资源|


### 使用最小宽度限定符
不用large，新建res/layout-sw600dp/activity_main.xml。这样在屏幕宽度大于600dp时，则会自动调此布局。

## 示例源码
示例源码地址： [一个简易新闻应用示例源码地址](https://github.com/huaqianlee/AndroidDemo/tree/master/FirstCode/chapter4/FragmentBestPractice)。



































