title: "第一行代码之Material Design"
date: 2017-05-10 21:31:27
categories: 学习笔记
tags: [App,FirstCode]
---
[《第一行代码》第2版思维导图及所有学习笔记目录](http://huaqianlee.github.io/2017/03/24/FirstCode/The-departure-of-FirstCode-learning-notes/)


## Toolbar控件
### 主题定义
对应于ActionBar，由于ActionBar被限定于活动顶部，不能实现一些Material Design效果，因此已不推荐使用了。

ActionBar来自项目指定的主题定义的显示，如下：
```xml
# AndroidManifest.xml
android:theme="@style/AppTheme"
```
<!--more-->
主题的定义：
```xml
# res/values/styles.xml
<resources>
    <!-- Base application theme. -->
    <style name="AppTheme" parent = "Theme.AppCompat.Light.DarkActionBar"> # 定义指定父主题
    <!-- Customize your theme here. -->
    <item name="colorPrimary">@color/colorPrimary</item>
    <item name="colorPrimaryDark">@color/colorPrimaryDark</item>
    <item name="colorAccent">@color/colorAccent</item>
</resources>
```
父主题Theme.AppCompat.Light.DarkActionBar自带了ActionBar，使用Toolbar则需要将父主题替换，主要有如下两种可选主题：
```bash
Theme.AppCompat.Light.NoActionBar : 淡色主题，主题颜色设为淡色，陪衬颜色设为深色
Theme.AppCompat.NoActionBar: 深色主题，界面主题颜色设为深色，陪衬颜色设为淡色
```

为了使用Toolbar修改主题定义：
```xml
<resources>
    <!-- Base application theme. -->
    <style name="AppTheme" parent = "Theme.AppCompat.Light.NoActionBar"> # 定义指定父主题
    <!-- Customize your theme here. -->
    ...
</resources>
```

主题中的颜色控制属性，主要如下几种：
```bash
colorPrimary       指定标题栏背影色
colorPrimaryDrak   指定状态栏颜色
textColorPrimary   指定标题文字颜色
windowBackground   背景色
navigationBarColor 指定状态导航条颜色
colorAccent        指定浮动按钮颜色以及一些控件选择状态
```
每个属性指定颜色的位置如下：

![各属性指定颜色位置](http://7xjdax.com1.z0.glb.clouddn.com/android/firstcode/toolbar_anay.jpg)

### 引入Toolbar
Toolbar控件是由appcompat-v7库提供，引入布局：
```xml
<FrameLayout ...
 xmlns:app="http://schemas.android.com/apk/res-auto"
 //引入app命名空间，因为android:attribute之类属性只支持5.0及以上系统，5.0以下需要使用app:xx来兼容
 
 <android.support.v7.widget.Toolbar
    android:id="@+id/toolbar"
    android:layout_width="match_parent"
    android:layout_height="?attr/actionBarSize" // 高度设置为actionBar的高度
    android:background="?attr/colorPrimary"
    android:theme="@style/ThemeOverlay.AppCompat.Dark.ActionBar"
    // 为了Toolbar单独使用深色主题让效果更好，通过此属性设置，如不设置这使用默认的浅色主题效果
    app:popupTheme="@style/ThemeOverlay.AppCompat.Light"
    // 将Toolbar中菜单按钮弹出的菜单项设为浅色主题
    app:layout_scrollFlags="enterAlways|snap|scroll"
    />
</FrameLayout>    
```
加入代码：
```java
Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
setSupportActionBar(toolbar);
```

### 美化Toolbar
修改标题栏显示内容：
```xml
# AndroidManifest.xml
<activity
  ...
  android:label="Fruits">
  // 未指定的话，则显示application中android:label指定的内容
 </activity> 
```
添加action按钮：
```java
# 引入布局
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto">
    <item
        android:id="@+id/backup"
        android:icon="@drawable/ic_backup"
        android:title="Backup"
        app:showAsAction="always"/> 
        //指定显示位置,永远显示在Toolbar中，屏幕不够则隐藏
    <item
        android:id="@+id/del"
        android:icon="@drawable/ic_delete"
        android:title="Delete"
        app:showAsAction="ifRoom"/>
        //如果屏幕空间足够则显示，不够则显示在菜单中
    <item
        android:id="@+id/setting"
        android:icon="@drawable/ic_settings"
        android:title="Setting"
        app:showAsAction="never"/>
        //永远隐藏，显示在菜单中
</menu>

# 加入代码
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.toolbar,menu);
        // 加载toolbal.xml
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.backup:
                //Toolbar上按钮响应逻辑
                break;
            case R.id.del:
                break;
            case R.id.setting:
                break;
            default:
                break;
        }
        return true;
    }
```
效果如下：

![带action按钮的Toolbar](http://7xjdax.com1.z0.glb.clouddn.com/android/firstcode/toolbar_xiaoguo.jpg)

## 滑动菜单
### DrawerLayout
DrawerLayout是一个布局，允许放入两个子控件，第一个控件是主屏幕中显示的内容，第二个子控件是滑动菜单中显示的内容。
引入布局：
```xml
<?xml version="1.0" encoding="utf-8"?>
<android.support.v4.widget.DrawerLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/drawer_layout"
    android:layout_width="match_parent"
    android:layout_height="match_parent">
    
   <FrameLayout
        android:layout_width="match_parent"
        android:layout_height="match_parent">    
    
        <android.support.v7.widget.Toolbar
                ...
                />
                
    </FrameLayout>
    
    <TextView 
        android:layout_gravity="start" 
        //表示根据系统语言判断第二界面隐藏在左边还是右边，比如英语和中文从左边开始，就为左边，也可指定“right" "left" "end"
        .../> //滑动界面先加载一个TextView
</android.support.v4.widget.DrawerLayout>    
```
加入导航按钮：
```java
private DrawerLayout mlayout;

mlayout = (DrawerLayout) findViewById(R.id.drawer_layout);
ActionBar actionBar = getSupportActionBar();//获得ActionBar(其实是Toolbar)
if (actionBar != null) {
    actionBar.setDisplayHomeAsUpEnabled(true); // 显示导航按钮(HomeAsUp按钮)，默认是一个返回箭头
    actionBar.setHomeAsUpIndicator(R.drawable.ic_menu);//设置图标
}

@Override
public boolean onOptionsItemSelected(MenuItem item) {
    switch (item.getItemId()) {
    ...
    case android.R.id.home:
        mlayout.openDrawer(GravityCompat.START);
        break;
    ...
```
### NavigationView
NavigationView是Design Support提供的一个空间，可以让滑动菜单设计好看又简单，首先需要加入依赖：
```gradle
compile 'com.android.support:design:24.2.1' //Design Support库
compile 'de.hdodenhof:circleimageview:2.1.0' // Circleimageview，实现图片圆形化功能，用于头像
```
>[Circleimageview项目主页地址](https://github.com/hdodenhof/Circleimageview)

准备滑动菜单页面布局：
```xml
# menu  
<?xml version="1.0" encoding="utf-8"?>
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <group android:checkableBehavior="single"> //指定这一组菜单项单选
        <item
            android:id="@+id/nav_call"
            android:icon="@drawable/nav_call"
            android:title="Call"/>
        <item
            android:id="@+id/nav_friends"
            android:icon="@drawable/nav_friends"
            android:title="Friends"/>
        <item
            android:id="@+id/nav_location"
            android:icon="@drawable/nav_location"
            android:title="Location"/>
        <item
            android:id="@+id/nav_mail"
            android:icon="@drawable/nav_mail"
            android:title="Mail"/>
        <item
            android:id="@+id/nav_task"
            android:icon="@drawable/nav_task"
            android:title="Tasks"/>
    </group>
</menu>

# headerLayout
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="180dp"
    android:padding="10dp"
    android:background="?attr/colorPrimary">

    <de.hdodenhof.circleimageview.CircleImageView
        android:id="@+id/icon_image"
        android:layout_width="70dp"
        android:layout_height="70dp"
        android:src="@drawable/nav_icon"
        android:layout_centerInParent="true"/>

    <TextView
        android:id="@+id/mail"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentBottom="true"
        android:text="huaqinalee@gmail.com"
        android:textColor="#FFF"
        android:textSize="14sp"/>

    <TextView
        android:id="@+id/usr_name"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_above="@+id/mail"
        android:text="Andy Lee"
        android:textColor="#fff"
        android:textSize="14sp"/>
</RelativeLayout>
```
引入滑动菜单页面布局：
```xml
# 将前面的TextView换为NavigationView
<android.support.design.widget.NavigationView
    android:id="@+id/nav_view"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:layout_gravity="start"
    app:menu="@menu/nav_menu"  // 引入menu
    app:headerLayout="@layout/nav_header" // 引入headerLayout
    />
```
加入响应代码：
```java
NavigationView navView = (NavigationView) findViewById(R.id.nav_view);
//navView.setCheckedItem(R.id.nav_call); //设置菜单默认选中项
navView.setNavigationItemSelectedListener(new NavigationView.OnNavigationItemSelectedListener() {
    @Override
    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
        //添加菜单项响应逻辑
        //mlayout.closeDrawers(); 关闭滑动菜单
        return false;
    }
```
效果如下：
![NavigationView滑动菜单界面](http://7xjdax.com1.z0.glb.clouddn.com/android/firtcode/navigationview_ex.jpg)

## 悬浮按钮和可交互提示
### FloatingActionButton
引入悬浮按钮布局：
```xml
<FrameLayout
    android:layout_width="match_parent"
    android:layout_height="match_parent">    

    <android.support.v7.widget.Toolbar
            ...
            />
            
    <android.support.design.widget.FloatingActionButton
            android:id="@+id/fab"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_gravity="bottom|end" //对于中英文，右下角
            android:layout_margin="16dp"
            android:src="@drawable/ic_done"
            app:elevation="8dp" //悬浮高度
            />    
</FrameLayout>
```
加入响应代码：
```java
FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
fab.setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View v) {
        // 实现响应逻辑
    }
```

### Snackbar
提供交互的提示，与Toast类似，加入代码：
```java
/*
**arg1：一个View，当前界面的任意view，会自动找到最外层布局
**arg2：显示的内容
**arg3：时长
*/
Snackbar.make(v, "Data deleted", Snackbar.LENGTH_SHORT).setAction("Undo", new View.OnClickListener() {
    @Override
    public void onClick(View v) {
        Toast.makeText(MainActivity.this, "Del undo!", Toast.LENGTH_SHORT).show();
    }
}).show();
```
### CoordinatorLayout
直接如上加入Snackbar，提示的内容直接弹出会覆盖悬浮按钮，体验不好，所以就需要引入加强版FrameLayout：CoordinatorLayout。此布局可以监听子控件，并且做出响应调整。
引入布局：
```xml
# 替换掉FrameLayout
<android.support.design.widget.CoordinatorLayout
    android:layout_width="match_parent"
    android:layout_height="match_parent">
    ...
    <android.support.design.widget.FloatingActionButton
    .../>
</android.support.design.widget.CoordinatorLayout>    
```
这样替换布局后，悬浮按钮会自动上移以避免覆盖，效果如下：

![效果图](http://7xjdax.com1.z0.glb.clouddn.com/android/firstcode/coorlayout.jpg)
>Snackbar.make时传入的view是Snackbar本身，包含在CoordinatorLayout中，所以能响应，如若传入的是外面的View，则不能响应。

## 卡片式布局
### CardView
CardView也是appcompat-v7库提供的一个FrameLayout，不过增加了圆角阴影等立体效果。
#### 基本用法：
```xml
<android.support.v7.widget.CardView
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:cardCornerRadius="4dp" // 圆角弧度
    app:elevation="5dp"/>// 投影高度
    
    <TextView .../>
    
</android.support.v7.widget.CardView>
```
#### RecyclerView和CardView等控件实现水果列表效果
添加依赖：
```gradle
compile 'com.android.support:recyclerview-v7:24.2.1'
compile 'com.android.support:cardview-v7:24.2.1'
compile 'com.github.bumptech.glide:glide:3.7.0' 
//一个强大的图片加载库，可加载（网络）图片、GIF、本地视频。
```
>[Glide项目主页地址](https://github.com/bumptech/glide)

引入RecyclerView布局：
```java
<android.support.design.widget.CoordinatorLayout
    <android.support.v7.widget.Toolbar
        ..../>
        
    <android.support.v7.widget.RecyclerView
        android:id="@+id/recycler_view"
        android:layout_width="match_parent"
        android:layout_height="match_parent"/>
    ...
</android.support.design.widget.CoordinatorLayout>
```
>这样子RecyclerView会将Toolbar给遮住，因为CoordinatorLayout(类似FrameLayout)布局默认置于左上角，后面通过APPBarLayout解决此问题

定义一个Fruit实体类（只有name和imageId两个字段）。接下来需要为RecyclerView的子项指定自定义布局fruit_item.xml。

引入CardView布局：
```xml
<?xml version="1.0" encoding="utf-8"?>
<android.support.v7.widget.CardView     xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_margin="5dp"
    app:cardCornerRadius="4dp">

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical">
        <ImageView
            android:id="@+id/fruit_image"
            android:scaleType="centerCrop" //指定图片缩放方式
            .../>
        <TextView
            android:id="@+id/fruit_name"
            .../>

    </LinearLayout>

</android.support.v7.widget.CardView>
```
添加RecyclerView适配器FruitAdapter，如下：
```java
public class FruitAdapter extends RecyclerView.Adapter<FruitAdapter.ViewHolder> {
    private Context mContext;
    private List<Fruit> mLists;

    public FruitAdapter(List<Fruit> lists) {
        mLists = lists;
    }

    @Override
    public FruitAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        if (mContext == null) {
            mContext = parent.getContext();
        }
        View view = LayoutInflater.from(mContext).inflate(R.layout.fruit_item, parent, false);
        return view;
    }

    @Override
    public void onBindViewHolder(FruitAdapter.ViewHolder holder, int position) {
        Fruit fruit = mLists.get(position);
        holder.fruitName.setText(fruit.getName());
        Glide.with(mContext).load(fruit.getImageId()).into(holder.fruitImage);
        // 使用Glide加载图片
    }

    @Override
    public int getItemCount() {
        return mLists.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        CardView cardView;
        ImageView fruitImage;
        TextView fruitName;
        public ViewHolder(View itemView) {
            super(itemView);
            cardView = (CardView) itemView;
            fruitImage = (ImageView) itemView.findViewById(R.id.fruit_image);
            fruitName = (TextView) itemView.findViewById(R.id.fruit_name);
        }
    }
}
```
添加加载RecyclerView代码：
```java
...
RecyclerView recyclerView = (RecyclerView) findViewById(...);
GridLayoutManager layoutManager = new GridLayoutManager(this, 2);
recyclerView.setLayoutManager(layoutManager);
adapter = new FruitAdapter(fruitList);
recyclerView.setAdapter(adapter);
```
### AppBarLayout
APPBarLayout也是Design Support提供，解决RecyclerView遮挡Toolbar问题只需两步：
1. 将Toolbar嵌套到APPBarLayout中。
2. 给RecyclerView指定一个布局行为。

修改布局如下：
```xml
<android.support.design.widget.AppBarLayout
    android:layout_width="match_parent"
    android:layout_height="wrap_content">

    <android.support.v7.widget.Toolbar
    app:layout_scrollFlags="enterAlways|snap|scroll"
    /*  
    ** enterAlways - Toolbar跟随向下滚动并重新显示
    ** snap - Toolbar还未完全隐藏或显示时，根据滚动距离自动选择
    ** scroll - Toolbar跟着向上滚动并隐藏
    */
        .../>
</android.support.design.widget.AppBarLayout>
<android.support.v7.widget.RecyclerView
    ... 
    app:layout_behavior="@string/appbar_scrolling_view_behavior"/>
```
## 下拉刷新
support-v4提供的SwipeRefreshLayout可以很简单的实现刷新功能。
引入布局：
```xml
<android.support.v4.widget.SwipeRefreshLayout
    android:id="@+id/swipe_refresg"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    app:layout_behavior="@string/appbar_scrolling_view_behavior">
    // 需要将上述的布局行为移到其父控件了

    <android.support.v7.widget.RecyclerView
        .../>

</android.support.v4.widget.SwipeRefreshLayout>
```
代码实现：
```java
private SwipeRefreshLayout swipeRefresh;
swipeRefresh = (SwipeRefreshLayout)findViewById(R.id.swipe_refresg);
swipeRefresh.setColorSchemeResources(R.color.colorPrimary); // 设置下拉进度条颜色
swipeRefresh.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
    @Override
    public void onRefresh() {
        refreshFruits();
    }
}); 

private void refreshFruits() {
  new Thread(new Runnable() {
    @Override
    public void run() {
        try {
            Thread.sleep(2000); //获取数据，这里模拟时间
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        runOnUiThread(new Runnable() {//切回主线程更新UI
            @Override
            public void run() {
                initFruits();
                adapter.notifyDataSetChanged();
                swipeRefresh.setRefreshing(false);//刷新结束，隐藏进度条
            }
        });
    }
}).start();
```
## 可折叠式标题栏
### CollapsingToolbarLayout
如下所示，左边必须作为右边的子控件才能存在：

**CollapsingToolbarLayout -> AppBarLayout -> CoordinatorLayout.**

新建一个水果详情展示页面布局（activity_fruit.xml）来应用可折叠式标题栏。


引入布局：
```xml
<android.support.design.widget.CoordinatorLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:fitsSystemWindows="true">
    
    # 标题部分
    <android.support.design.widget.AppBarLayout
        ...>    
        <android.support.design.widget.CollapsingToolbarLayout
            ...
            android:theme="@style/ThemeOverlay.AppCompat.Dark.ActionBar" // Toolbar主题，移到此父控件
            app:contentScrim="?attr/colorPrimary" //折叠背景色,折叠后就变成一个普通Toolbar了
            app:layout_scrollFlags="scroll|exitUntilCollapsed"
            /*
            ** Toolbar属性，移到父控件了
            ** exitUntilCollapsed - 表示折叠后保留不隐藏
            */
            android:fitsSystemWindows="true">
            
            /*标题栏内容：图片+普通标题栏*/
            <ImageView
                ...
                android:scaleType="centerCrop"
                app:layout_collapseMode="parallax" // 指定折叠模式，parallax-折叠时错位偏移
                android:fitsSystemWindows="true"/>

            <android.support.v7.widget.Toolbar
                android:id="@+id/toolbar"
                android:layout_width="match_parent"
                android:layout_height="?attr/actionBarSize"
                app:layout_collapseMode="pin" // 表示折叠过程中Toolbar位置不变
                />

        </android.support.design.widget.CollapsingToolbarLayout>
    </android.support.design.widget.AppBarLayout>    
    
    # 详情页部分
    <android.support.v4.widget.NestedScrollView
        ...
        app:layout_behavior="@string/appbar_scrolling_view_behavior">
        /*
        ** 同ScrollView，允许滚动查看，不过多了响应滚动事件
        ** 因为外使用CoordinatorLayout，需要用此控件或RecyclerView，用法同上RecyclerView一样
        ** 只允许存在一个直接子布局
        */

        <LinearLayout
            ...>

            <android.support.v7.widget.CardView
                ...>

                <TextView
                    .../>

            </android.support.v7.widget.CardView>

        </LinearLayout>

    </android.support.v4.widget.NestedScrollView>
    
    # 增加一个悬浮按钮
    <android.support.design.widget.FloatingActionButton
        ...
        app:layout_anchor="@id/appBar" //指定描点，这里写APPBarLayout的id，这样按钮就出现在标题栏区域
        app:layout_anchorGravity="bottom|end"/>
</android.support.design.widget.CoordinatorLayout>    
```
加入代码：
```java
# Adapter中添加RecyclerView子项响应代码
public FruitAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
    if (mContext == null) {
        mContext = parent.getContext();
    }
    View view = LayoutInflater.from(mContext).inflate(R.layout.fruit_item, parent, false);
    final ViewHolder holder = new ViewHolder(view);
    holder.cardView.setOnClickListener(new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            int position = holder.getAdapterPosition();
            Fruit fruit = mLists.get(position);
            Intent intent = new Intent(mContext,FruitActivity.class);
            intent.putExtra(FruitActivity.FRUIT_NAME,fruit.getName());
            intent.putExtra(FruitActivity.FRUIT_IMAGE_ID,fruit.getImageId());
            mContext.startActivity(intent);
        }
    });

    return holder;
}


# 详情页面代码
public class FruitActivity extends AppCompatActivity {
    public static final String FRUIT_NAME = "fruit_name";
    public static final String FRUIT_IMAGE_ID = "fruit_image_id";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_fruit);

        Intent intent = getIntent();
        String  fruitName = intent.getStringExtra(FRUIT_NAME);
        int fruitImageId = intent.getIntExtra(FRUIT_IMAGE_ID,0);
        ...
        //显示默认HomeAsUp按钮，一个返回箭头
        setSupportActionBar(toolbar); 
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
        }

        collapsingToolbar.setTitle(fruitName);
        Glide.with(this).load(fruitImageId).into(fruitImageView);
        fruitText.setText(fruitContent); //设置详情页内容

    }

    ...
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:  // HomeAsUp按钮返回上一活动
                finish();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }
}

```
### 背景图片和系统状态栏融合
对ImageView及其所有父布局属性设定，如下：
```xml
<?xml version="1.0" encoding="utf-8"?>
<android.support.design.widget.CoordinatorLayout
 ...
 android:fitsSystemWindows="true">
 <android.support.design.widget.AppBarLayout
        ...
        android:fitsSystemWindows="true">
        <android.support.design.widget.CollapsingToolbarLayout
            ...
            android:fitsSystemWindows="true">
            <ImageView
                ...
                android:fitsSystemWindows="true"/>
...                
```
接下来需要将状态栏指定撑透明，但是android:statusBarColor属性是API21开始支持的（即Android5.0）。先为5.0以上新建一个values-21/styles.xml，如下：
```xml
<resources>
    <style name="FruitActivityTheme" parent="AppTheme">
        <item name="android:statusBarColor">@android:color/transparent</item>
    </style>
<resources>    
```
为了支持5.0以前，对values/styles.xml进行修改，如下：
```xml
...
<style name="FruitActivityTheme" parent="AppTheme">
</style>
# 因为5.0以前不能指定状态栏颜色，所以留空即可了。
```
最后让activity调用此主题，如下：
```xml
# AndroidManifest.xml
<activity
    ...
    android:theme="@style/FruitActivityTheme"
</activiy>
```
效果图如下：

![待补充]()

## 示例源码
整个Material Design示例源码的地址如下：

[Material Design示例源码](https://github.com/huaqianlee/AndroidDemo/tree/master/FirstCode/chapter12)。

