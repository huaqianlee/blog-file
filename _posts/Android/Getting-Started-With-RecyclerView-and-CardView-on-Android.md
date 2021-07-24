title: "Getting Started With RecyclerView and CardView on Android"
date: 2017-11-08 22:23:59
categories:
- Android Tree
- Application
tags: App
---
>偶然看到这篇文章，觉得写得很好，简单明了，所以尝试将其翻译一下。

如果你想创作一个用列表显示数据的Android应用，Android L提供了两个让你更容易实现的新特性：RecyclerView和CardView。通过用这些控件，可以很容易让你的app符合Google的Material Design规范。

创作APP时一个模板参考的好地方：[Envato market](https://go.redirectingat.com/?id=1342X589339&site=code.tutsplus.com&xs=1&isjs=1&url=https%3A%2F%2Fcodecanyon.net%2Fcategory%2Fmobile%2Fandroid%3F_ga%3D2.255032513.873197305.1503543294-826134730.1503543294&xguid=6c32060c165aa0d81cc926f785d03c1a&xuuid=40b87ed972cd06dc4bfc1a62b8c59465&xsessid=e18f51adda215e4913eb634122cf8895&xcreo=0&xed=0&sref=https%3A%2F%2Fcode.tutsplus.com%2Ftutorials%2Fgetting-started-with-recyclerview-and-cardview-on-android--cms-23465&xtz=-480)。你可以找到成千上万的APP模板，从[Youtube](https://go.redirectingat.com/?id=1342X589339&site=code.tutsplus.com&xs=1&isjs=1&url=https%3A%2F%2Fcodecanyon.net%2Fitem%2Flayar-tancep-youtube-app-for-android%2F5190062%3F_ga%3D2.248270926.873197305.1503543294-826134730.1503543294&xguid=6c32060c165aa0d81cc926f785d03c1a&xuuid=40b87ed972cd06dc4bfc1a62b8c59465&xsessid=e18f51adda215e4913eb634122cf8895&xcreo=0&xed=0&sref=https%3A%2F%2Fcode.tutsplus.com%2Ftutorials%2Fgetting-started-with-recyclerview-and-cardview-on-android--cms-23465&xtz=-480)到[obstacleavoidance game](https://go.redirectingat.com/?id=1342X589339&site=code.tutsplus.com&xs=1&isjs=1&url=https%3A%2F%2Fcodecanyon.net%2Fitem%2Fflappybot-an-obstacle-avoidance-game%2F6827330%3F_ga%3D2.248270926.873197305.1503543294-826134730.1503543294&xguid=6c32060c165aa0d81cc926f785d03c1a&xuuid=40b87ed972cd06dc4bfc1a62b8c59465&xsessid=e18f51adda215e4913eb634122cf8895&xcreo=0&xed=0&sref=https%3A%2F%2Fcode.tutsplus.com%2Ftutorials%2Fgetting-started-with-recyclerview-and-cardview-on-android--cms-23465&xtz=-480)。

或者你可以尝试一下[通用的Android app模板](https://codecanyon.net/item/universal-full-multipurpose-android-app/6512720?_ga=2.217207135.873197305.1503543294-826134730.1503543294),它能为你创作任何种类app提供一个坚实的基础。
![Universal-Android-app](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/blog/recyclerview_cardview/Universal-Android-app.png)
<!--more-->

# 前提
为了继续，你应该使用最新版本Android Studio。你可以从[Android 开发者官网](http://developer.android.com/sdk/index.html)获得它。

## 支持老版本
在写这篇文章时，只有少于2%的Android设备运行在Android L上。无论怎样，多亏v7 Support Library，你能使用RecyclerView和CardView控件运行在老版本的安卓设备上面，通过在你工程中build.grade文件添加如下依赖片段实现：
```gradle
compile 'com.android.support:cardview-v7:21.0.+'
compile 'com.android.support:recyclerview-v7:21.0.+'
```
## 创建CardView
*CardView*是一个*ViewGroup*，像其他*ViewGroup*一样，它能通过Layout xml文件添加到你的 *Activity* 或者 *Fragment*。

为了创建一个空*CardView*，你应该添加如下代码片段到你的layout XML文件中：
```xml
<android.support.v7.widget.CardView
        xmlns:card_view="http://schemas.android.com/apk/res-auto"
        android:layout_width="match_parent"
        android:layout_height="wrap_content">
 
</android.support.v7.widget.CardView>
```
最为一个更实际的例子，咱们创建一个*LinearLayout*并将*CardView*作为子控件放在里面。*CardView*可以代表一个人，包含如下信息：
* *TextView* - 显示人名
* *TextView* - 显示年纪
* *ImageView* - 显示照片
 
xml内容如下：
```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:padding="16dp"
    >
 
    <android.support.v7.widget.CardView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:id="@+id/cv"
        >
 
        <RelativeLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:padding="16dp"
            >
 
            <ImageView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:id="@+id/person_photo"
                android:layout_alignParentLeft="true"
                android:layout_alignParentTop="true"
                android:layout_marginRight="16dp"
                />
 
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:id="@+id/person_name"
                android:layout_toRightOf="@+id/person_photo"
                android:layout_alignParentTop="true"
                android:textSize="30sp"
                />
 
            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:id="@+id/person_age"
                android:layout_toRightOf="@+id/person_photo"
                android:layout_below="@+id/person_name"
                />
 
        </RelativeLayout>
 
    </android.support.v7.widget.CardView>
 
</LinearLayout>
```
如果这个xml文件被用作*Activity*的layout，并且给*TextView*和ImageView*设置有意义的值，那么在Android设备上面它看起来应该像这个样子：
![device](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/blog/recyclerview_cardview/device_2015.png)

## 创建RecyclerView
### 在Layout中定义它
使用一个*RecyclerView*实例有一些复杂，但是在layout xml中定义它十分简单。可以定义如下：
```xml
<android.support.v7.widget.RecyclerView
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:id="@+id/rv"
    />
```
通过如下代码片段在你的*Activity*中去获得句柄：
```java
RecyclerView rv = (RecyclerView)findViewById(R.id.rv);
```
如果你确定*RecyclerView*的大小不会改变，你可以添加如下语句：
```java
rv.setHasFixedSize(true);
```
### 使用LayoutManager
和*ListView*不一样，*RecyclerView*需要一个*LayoutManger*去管理其子项的位置。你可以通过继承*RecyclerView.LayoutManager*类定义自己的*LayoutManager*。不过，大多数案子里面，你直接使用如下预定义的*LayoutManager*子类就可以了：
* LinearLayoutManager
* GridLayoutManager
* StaggeredGridLayoutManager
在这篇教程里，我将使用*LinearLayoutManager*，它默认将让你的*RecyclerView*看起来像一个*ListView*。
```java
LinearLayoutManager llm = new LinearLayoutManager(context);
rv.setLayoutManager(llm);
```
### 定义内容
和*ListView*一样，*RecyclerView*也需要一个适配器去接入数据。但是在创建适配器前，我们先创建我们需要的数据。创建一个简单的类来代表一个人然后写一个方法来初始化一个*Person*对象集：
```java
class Person {
    String name;
    String age;
    int photoId;
 
    Person(String name, String age, int photoId) {
        this.name = name;
        this.age = age;
        this.photoId = photoId;
    }
}
 
private List<Person> persons;
 
// This method creates an ArrayList that has three Person objects
// Checkout the project associated with this tutorial on Github if
// you want to use the same images.
private void initializeData(){
    persons = new ArrayList<>();
    persons.add(new Person("Emma Wilson", "23 years old", R.drawable.emma));
    persons.add(new Person("Lavery Maiss", "25 years old", R.drawable.lavery));
    persons.add(new Person("Lillie Watts", "35 years old", R.drawable.lillie));
}
```
### 创建适配器
要创建一个*RecyclerView*可以使用的适配器，你必须继承*RecyclerView.Adapter*。这个适配器遵循**View holder**设计模式，也就意味着你需要定义一个类继承与*RecyclerView.ViewHolder*。这种模式最大限度减少调用*findViewByIdea*方法。

前面我们已经在 XML Layout中定义了一个*CardView*代表一个人。我们将重复利用此布局文件。在我们自定义*ViewHolder*的构造方法中，初始化此视图属于*RecyclerView*的子项。
```java
public class RVAdapter extends RecyclerView.Adapter<RVAdapter.PersonViewHolder>{
 
    public static class PersonViewHolder extends RecyclerView.ViewHolder {      
        CardView cv;
        TextView personName;
        TextView personAge;
        ImageView personPhoto;
 
        PersonViewHolder(View itemView) {
            super(itemView);
            cv = (CardView)itemView.findViewById(R.id.cv);
            personName = (TextView)itemView.findViewById(R.id.person_name);
            personAge = (TextView)itemView.findViewById(R.id.person_age);
            personPhoto = (ImageView)itemView.findViewById(R.id.person_photo);
        }
    }
 
}
```
接下来，为自定义适配器增加一个构造方法来处理*RecyclerView*显示的数据。我们的数据有*Person*对象集组成，添加如下代码：
```java
List<Person> persons;
 
RVAdapter(List<Person> persons){
    this.persons = persons;
}
```
*RecyclerView.Adapter*有三个抽象方法必须被重写。咱们从*getItemCount*方法开始。这个方法返回子项存在数据的数量。对于我们由*List*形成的数据，我们只需要调用*List*对象的*size()*方法即可：
```java
@Override
public int getItemCount() {
    return persons.size();
}
```
接下来，重写*onCreateViewHolder*方法。正如方法名所展示，当自定义*ViewHolder*需要被初始化时调用。我们指明*RecyclerView*每个子项使用的布局。通过使用*LayoutInflater*完成，传递着结果到自定义的*ViewHolder*的构造方法。
```java
@Override
public PersonViewHolder onCreateViewHolder(ViewGroup viewGroup, int i) {
    View v = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item, viewGroup, false);
    PersonViewHolder pvh = new PersonViewHolder(v);
    return pvh;
}
```
重写*onBindViewHolder*方法去指明每一个*RecyclerView*子项的内容。这个反复与*ListView*的适配器的*getView*方法十分相似。在我们的例子中，你必须设置*CardView*中的名字、年纪以及照片。
```java
@Override
public void onBindViewHolder(PersonViewHolder personViewHolder, int i) {
    personViewHolder.personName.setText(persons.get(i).name);
    personViewHolder.personAge.setText(persons.get(i).age);
    personViewHolder.personPhoto.setImageResource(persons.get(i).photoId);
}
```
最好，你需要重写*onAttachedToRecyclerView*方法。我们就简单实用地直接调用父类的实现。
>注：新版本已经不需要重写此方法。
```java
@Override
public void onAttachedToRecyclerView(RecyclerView recyclerView) {
    super.onAttachedToRecyclerView(recyclerView);
}
```
### 实用适配器
现在适配器准备好了，接下来就是让*Activity*通过适配器构造函数和*RecyclerView*的*setAdapter*去初始化和使用这个适配器了。添加如下代码：
```java
RVAdapter adapter = new RVAdapter(persons);
rv.setAdapter(adapter);
```
### 编译及运行
当你在你的Android设备上运行这个例程时，你将会看类似如下图片的结果：
![device](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/blog/recyclerview_cardview/device-2015-02.png)

# 结论
在这篇教程，你已经学会了怎么去使用在Android L中引入的*CardView*和*RecyclerView*控件。你也明白了在Material Design应用中怎么去使用这些控件。注意：通过*RecyclerView*可以做几乎所有*ListView*所做的事，不过为了更少的代码，使用*ListView*仍然是一个比较好的选择。

你可以参考Android Developers reference去获得更多关于*CardView*和*RecyclerView*类的信息。

最好，如果你想更快速地开发你的app，不要忘记在Envato Market查看Android app templates。

>[原文章地址。](https://code.tutsplus.com/tutorials/getting-started-with-recyclerview-and-cardview-on-android--cms-23465)
