title: "第一行代码之UI"
date: 2017-03-25 08:34:40
categories:
- Android Tree
- Notation
tags: [App,FirstCode]
---
[《第一行代码》第2版思维导图及所有学习笔记目录](http://huaqianlee.github.io/2017/03/24/FirstCode/The-departure-of-FirstCode-learning-notes/)

本部分思维导图如下：
![UI](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/firstcode/UI.png)
<!--more-->

## 常用控件
如下总结一些常用的参数配置或者方法，某些参数可能对于其它控件也适用。
### TextView
```bash
android:gravity - 指定文字对齐方式，用指定控件内容的位置。
android:layout_gravity -  指定控件相对于父布局的位置。
```

### Button
```bash
android:textAllCaps="false" - 禁用Button字母自动大写转换
```
### EditText
```bash
android:hint=""    # 提示内容
android:maxLines="" # 输入框拉伸最大行数
```
### ImageView
```bash
android:src=""  # 参数配置图片资源
imageView.setImageResource()  # 动态设置图片资源
```
### ProgressBar
```bash
# 参数
android:visibility=""  # 控件可见设置，不设的都默认可见
android:max=""  #进度条最大值
style="?android:attr/progressBarStyleHorizontal" # 设置为水平进度条，默认是圆形进度条

# 方法
progressBar.getvisibility()  # 获取可见状态
progressBar.setVisibility(View.VISIBLE/View.GONE) # 动态设置可见状态
progressBar.getProgress(); # 获取进度
progressBar.setProgress(int); # 设置进度
```
### AlertDialog
在当前界面弹出一个对话框，置于所有界面之上，能屏蔽其他控件的交互能力。
```java
# 弹出一个确认框
AlertDialog.Builder dialog = new AlertDialog.Builder(MainActivity.this);
dialog.setTile("");
dialog.setMessage("");
dialog.setCancelable(false); # 不可通过Back键取消
dialog.setPositiveButton("OK",new DialogInterface.onClickListener(){
    public void onClick(DialogInterface dialog, int which) {};
});
dialog.setNegativeButton("Cancel",new DialogInterface.onClickListener(){
    public void onClick(DialogInterface dialog, int which) {};
});
dialog.show();
```

### ProgressDialog
与AlertDialog类似，不过多一个进度条。
```java
ProgressDialog dialog = new ProgressDialog(MainActivity.this);
dialog.setTitle("");
dialog.setMessage("");
dialog.setCancelable(true);  # 可通过Back键取消
# 如若传入false，则需要再加载完成后调用ProgressDialog的dismiss()方法关闭对话框，否则对话框会一直存在
dialog.show();
```

## 4种基本布局
布局与控件嵌套结构如下：

![布局与控件](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/firstcode/layout_tool.jpg)

### 线性布局
只有LinearLayout支持 android:layout_weight属性，指定了此属性后控件大小即由其来决定，举个简单例子：
```bash
# widget1   
android:layout_width = "0dp"
android:layout_weight = 1   # 此控件占用1/3空间

#widget2
android:layout_width = "0dp"
android:layout_weight = 2  # 此控件占用2/3空间
```

### 百分比布局
>前不久好像看到文章讲此布局被弃用了

此布局要使用需先引入依赖库，然后直接指定百分比。
```bash
# app/build.gradle
compile  'com.android.support:percent:24.2.1'

#  xxx.xml
<android.support.percent.PercentFrameLayout
xmlns:app="http://schemas.android.com/apk/res-auto"

app:layout_widthPercent="50%"  # 指定宽度为布局的50%
app:layout_heightPercent="50%" # 指定高度为布局的50%
```
还存在PercentRelativeLayout，除了可以如上使用百分比布局外，继承了RelativeLayout的属性。

## 自定义控件
所有控件和布局都是直接或间接继承自View，如下：
![](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/firstcode/view_extends_struc.png)

### 引入布局
自定义标题栏控件，针对自定义控件新建一布局文件title.xml。然后在主布局文件中引入title.xml。
```bash
<include layout="@layout/title"/>
```
### 创建自定义控件
针对布局实现控件响应类。
```bash
public class TitleLayout extends LinearLayout {
    public TitleLayout(Context context, AttributeSet attrs){
        super(context,attrs);
        LayoutInflater.from(context).inflate(R.layout.title,this);
        // 通过LayoutInflater.from(context)构建LayoutInflater对象，然后inflate()动态加载布局文件    
        // 参数：布局ID， 父布局
        ... //实现控件响应功能
    }
}
```
除了通过include引入布局外，亦可以在布局文件中直接添加控件：
```bash
<com.lee.TitleLayout
    android:layout_width="match_parent"
    android:layout_height="wrap_content"/>
```

## ListView
### 简单用法
适配ListView，将数据通过适配器传递给ListView。
```bash
# 显示字符串
ArrayAdapter <String> adapter = new ArraAdapter<String>(MainActivity.this, android.R.layout.simple_list_item_1, String[]);
listView.setAdapter(adapter);
```
### 定制ListView
定制一个水果名+图片的ListView。
首先定义一个实体类，作为ListView适配器的适配类型。
```java
public class Fruit {
    private String name;
    private int imageId;  // 图片ID，R.drawable.xx
    
    public Fruit(String name, int imageId) {
        this.name = name;
        this.imageId = imageId;
    }
    
    public String getName(){
        return name;
    }
    public String getImageId(){
        return imageId;
    }
}
```
然后需要为ListView的子项指定一个布局fruit_item.xml。
```bash
<LinearLayout ....>
    <ImageView ..../>
    <TextView ..../>
</LinearLayout>
```
接下来需要继承ArrayAdapter创建一个自定义适配器FruitAdapter。
```java
public class FruitAdapter extends ArrayAdapter<Fruit> {
    private int resourceId; // 子项布局的ID
    public FruitAdapter(Context context, int Id, List<Fruit> objects) {
        super(...);
        resourceId = Id;
    }
    
    /*getView()在每个子项滚入屏幕时被调用*/
    @override
    public View getView(int position, View convertView, ViewGroup parent) {
        Fruit fruit = getItem(position); // 获取当前子项Fruit实例
        View view = LayoutInflater.from(getContext).inflate(resourceId, parent, false);
        ImageView fruitImage = view.findViewById(...);
        TextView fruitName = View.findViewById(...);
        fruitImage.setImgageResource(fruit.getImageId()；
        fruitName.setText(Fruit.getName();
        return view;
    }
}
```
关于inflate()方法，第三个参数false表示只让在父布局中声明的layout属性生效，但不为这个View添加父布局，因View有了父布局后，就不能添加到ListView中了。
适配ListView，如下：
```java
public class MainActivity extends AppCompatActivity {
	private List<Fruit> fruitList = new ArrayList<>();

	onCreate() {
		...
		initFruits();
		FruitAdapter adapter = new FruitAdapter(MainActivity.this,R.layout.fruit_item.xml,fruitList);
		listView.setAdapter(adapter);
	}

	initFruits() {
		Fruit apple = new Fruit("Apple", R.drawble.apple_pic);
		fruitList.add(apple);
		...
	}
}
```

### 提升ListView的效率
目前getView()时，每次加载子项都会重新加载布局，这样给了一个提升效率的方式。
```java
public View getView(int position, View convertView, ViewGroup parent) {
	...
	if(convertView == null) {
		view = LayoutInflater.from(getContext()).inflate(resourceId,parent,false);
	} else {
		view = convertView;
	}
	...
}

```
不过目前getView每次都要同findViewById()获取硬件实例，所以可以通过ViewHolder优化。
```java
public View getView(int position, View convertView, ViewGroup parent) {
	...
	if(convertView == null) {
		view = LayoutInflater.from(getContext()).inflate(resourceId,parent,false);
		viewHolder = new ViewHolder();
		viewHolder.fruitImage = view.findViewById(...);
		viewHolder.fruitName = view.findViewById(...);
		view.setTag(viewHolder); // viewHolder存储于view中
	} else {
		view = convertView;
		viewHolder = (ViewHolder)view.getTag();
	}
	...
}

Class ViewHolder {
	ImageView fruitImage;
    TextView fruitName;
}
```

### ListView的点击事件
```java
listView.setOnItemClickListener(new AdapterView.onItemClickListener) {
	onItemClick(AdapterView<?> parent, View view , int position, long id) {
		Fruit fruit = fruitList.get(position);
		...
	}
}
```
## RecyclerView
### 基本用法
首先需要再build.gradle中添加依赖库。
```bash
dependencies{
    compile 'com.android.support:recyclerview-v7:24.2.1'
}
```
然后在activity_main.xml中添加布局：
```
<LinearLayout
    <android.support.v7.widget.RecyclerView
        android:id=""
        android:layout_width="match_parent"
        android:layout_height="match_parent"/>
</LinearLayout>        
```
接下来需准备一个适配器类FruitAdapter：
```java
public class FruitAdapter extends RecyclerView.Adapter<FruitAdapter.ViewHolder> {
    private List<Fruit> mFruitList;
    
    static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView fruitImage;
        TextView fruitName;
        
        public viewHolder (View view) {
            suiper(view);
            fruitImage = (ImageView) view.findViewById();
            fruitName = (TextView) view.findViewById();
        }
    }
    
    public FruitAdapter(List<Fruit> fruitList) {
        mFruitList = fruitList;
    }
    
    @override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getcontext()).inflate(R.layout.fruit_item, parent, false);
        ViewHolder holder = new ViewHolder(view);
        return holder;
    }
    
    @override
    public void onBindViewHolder (ViewHolder holder, int position) {
        Fruit fruit = mFruitList.get(position);
        holder.fruitImage.setImageResource (fruit.getImageId());
        holder.fruitName.setText(fruit.getName());
    }
    
    @override
    public int getItemCount() {
        return mFruitLIst.size();
    }
}
```
适配器准备好后，就可以使用RecyclerView，修改MainActivity：
```
public class MainActivity extends AppCompatActivity {
    private List<Fruit> fruitList = new ArrayList<>();
    
    onCreate () {
        initFruits();
        RecyclerView recyclerView = (RecyclerView)findViewById();
        LinearLayoutManager layoutManager = new LinearLayoutManager(this);
        // 用于指定RecyclerView的布局方式，此指定为线性布局
        recyclerView.setLayoutManager(layoutManager);
        FruitAdapter adapter = new FruitAdapter(fruitList);
        recyclerView.setAdapter(adapter);
        
    }
    private void initFruits(){
        Fruit apple = new Fruit("Apple", R.drawable.apple_pic);
        fruitLIst.add(apple);
        ...
    }
}
```
### 横向滚动和瀑布流布局
实现横向滚动的话，为了好看，需要将fruit_item.xml中图片和文字控件改为竖向布局。
```bash
<LinearLaout
    android:orientation = "vertical">
```
然后再MainActivity中设置为横向滚动：
```java
onCreate {
    layoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
}
```
RecyclerView除了提供LinearLayoutManager布局排列外，还提供了如下两种布局排列：
```bash
GridLayoutManager：用于实现网格布局 
StaggeredGridLayoutManager：用于实现瀑布流布局（类似于表格，不过根据内容多少适配显示） 
```
实现瀑布流，可以对fruit_item.xml做一些针对性的调整，然后修改MainActivity，如下：
```java
onCreate() {
    StaggeredGridLayoutManger layoutManager = new StaggeredGridLayoutManager(3, StaggeredGridLayoutManger.VERTICAL);
}
```
### RecyclerView点击事件
RecyclerView需要针对具体view去注册，这样也能响应子项的点击事件。修改FruitAdapter，如下：
```java
FruitAdapter {
    ViewHolder {
        View fruitView;
        
        ViewHolder(View view){
            fruitView = view;
        }
    }
    
    onCreateViewHolder() {
        ...
        final ViewHolder holder = new ViewHolder(view);
        // 子项点击事件
        holder.fruitView.setOnclickListener(new View.OnCickListener () {
            onClick(View v) {
                int position = holder.getAdapterPosition();
                Fruit fruit = mFruitList.get(position);
            }
        }
        );
        //图片点击事件
        holder.fruitImage.setOnclickListener(...);
    }
}
```
## 界面最佳实践
这个实践是一个做一个简单的聊天界面。

### Nine-Patch图片
为了防止图片被拉伸变形， 需要对信息背景的图片进行处理,windows下sdk/tools下有一个draw9patch.bat工具脚本，可以用来制作Nine-Patch图片，Ubuntu下没找到。
### 编写界面
因为会用RecyclerView，所以第一件事就是添加依赖：
```bash
compile 'com.android.support:recyclerview-v7:24.2.1'
```
编写主界面activity_main.xml：
```
<LinearLayout>
    <android.support.v7.widget.RecyclerView/> // 信息界面
    <LinearLayout> 
        <EditText>  // 编辑框
        <Button>    // 发送按钮
    </LinearLayout> 
</LinearLayout>
```
定义一个消息实体类：
```java
public class Msg {

    public static final int TYPE_RECEIVED = 0; // 收到的消息
    public static final int TYPE_SENT = 1;     // 发送的消息
    private String content;
    private int  type;


    public Msg(String content, int type) {
        this.content = content;
        this.type = type;
    }


    public String getContent() {
        return content;
    }

    public int getType() {
        return type;
    }
}
```
消息类写好了，还需要写RecyclerView的子项布局文件msg_item.xml，如下：
```bash
<LinearLayout>
    <LinearLayout > //background设为制作的Nine-Patch消息背景图片
        <TextView>  // 收到消息
    </LinearLayout>
    
    <LinearLayout > //background设为制作的Nine-Patch消息背景图片
        <TextView>  // 发出的消息
    </LinearLayout>      
</LinearLayout>
```
此处子项布局文件是将发送和接收写在一起的，可以动可见属性来决定显示和隐藏。

接下来就该写适配器类MsgAdapter:
```java 
public class MsgAdapter extends RecyclerView.Adapter<MsgAdapter.ViewHolder> {

    private List<Msg> mMsgList;

    public MsgAdapter(List<Msg> msgList) {
        mMsgList = msgList;
    }

    static class ViewHolder extends RecyclerView.ViewHolder {

        LinearLayout leftLayout;
        LinearLayout rightLayout;

        TextView leftMsg;
        TextView rightMsg;

        public ViewHolder(View itemView) {
            super(itemView);
            leftLayout = (LinearLayout) itemView.findViewById(R.id.left_layout);
            rightLayout = (LinearLayout) itemView.findViewById(R.id.right_layout);
            leftMsg = (TextView) itemView.findViewById(R.id.left_msg);
            rightMsg = (TextView) itemView.findViewById(R.id.right_msg);
        }
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.msg_item, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        Msg msg = mMsgList.get(position);
        if (msg.getType() == Msg.TYPE_RECEIVED){
            holder.leftLayout.setVisibility(View.VISIBLE);
            holder.rightLayout.setVisibility(View.GONE);
            holder.leftMsg.setText(msg.getContent());
        } else if (msg.getType() == Msg.TYPE_SENT) {
            holder.rightLayout.setVisibility(View.VISIBLE);
            holder.leftLayout.setVisibility(View.GONE);
            holder.rightMsg.setText(msg.getContent());
        }
    }

    @Override
    public int getItemCount() {
        return mMsgList.size();
    }
}
```
最后在MainActivity中做一些处理即可实现一个聊天界面了。如下：
```java
onCreate(Bundle savedInstanceState) {
    ...
    initMsgs();
    msgRecyclerView = findViewById();
    LinearLayoutManager layoutManager = new LinearLayoutManager(this);
    msgRecyclerView.setLayoutManager(layoutManager);
    adapter = new MsgAdapter(mMsgLists);
    msgRecyclerView.setAdapter(adapter);

    send = (Button) findViewById(R.id.send);
    inputText = (EditText) findViewById(R.id.input_text);
    send.setOnClickListener(new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            String content = inputText.getText().toString();
            if (!"".equals(content)) {
                Msg msg = new Msg(content,Msg.TYPE_SENT);
                mMsgLists.add(msg);
                adapter.notifyItemInserted(mMsgLists.size()-1);  // 刷新消息
                msgRecyclerView.scrollToPosition(mMsgLists.size()-1); //listview 定位到最后一行
                inputText.setText(""); // 清空输入框

            } else {
                Toast.makeText(MainActivity.this, "The input text can not be emputy!", Toast.LENGTH_SHORT).show();
            }
        }
    });
private void initMsgs() { // 默认在消息几面显示一些聊天信息
    Msg msg1 = new Msg("Hello , this is msg1!", Msg.TYPE_RECEIVED);
    mMsgLists.add(msg1);        
    ...
}
```







