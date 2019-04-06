title: "RecyclerView Item选中效果及点击事件的实现"
date: 2017-08-17 19:46:41
categories: Android
tags: App
---
最近需要对RecyclerView的Item实现选中效果和Item点击事件，尝试了两种方式。


# 受限的简易实现方案
## 布局文件
首先在Item的布局文件中加入如下代码：
```bash
android:clickable="true"
android:focusableInTouchMode="true"
android:focusable="true"
android:background="@drawable/selector_item_selected"
```
完成selector_item_selected.xml：
```bash
<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:state_focused="true" android:drawable="@drawable/select"/>
    <item android:state_focused="false" android:drawable="@drawable/un_select"/>
</selector>
```
<!--more-->
实现select和unselect资源（也可以直接找两张图片）：
```bash
# unselect.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" >
    <gradient
            android:startColor="#FFF"
            android:endColor="#FFF"
            android:centerColor="#FFF"
    />

</shape>
# select.xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" >
    <gradient
            android:startColor="@color/colorPrimary"
            android:endColor="@color/colorPrimary"
            android:centerColor="@color/colorPrimary"
    />

</shape>
```
## 代码
只需要onBindViewHolder方法中添加如下代码即可：
```java
@Override
public void onBindViewHolder(final ViewHolder holder, int position) {
    ...
    holder.itemView.setSelected(position == SelectedNavItem.getSlectedNavItem()); 
    /*item点击事件的一种实现方式*/
    holder.itemView.setOnClickListener(new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            
        }
    });
    holder.cardView.setOnClickListener(new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            
        }
    });
}
```

# 更实用的实现方案
上面的方案有挺多局限性， 这个方案主要通过注册按键事件来实现。
## 布局
删掉上一种方案加入属性：
```bash
android:clickable="true"
android:focusableInTouchMode="true"
android:focusable="true"
android:background="@drawable/selector_item_selected"
```
## 代码
在adpter中定义可在其他地方使用的OnItemClickListener接口，如下：
```java
private OnItemClickListener onItemClickListener = null;

/*暴露给外部的方法*/
public void setOnItemClickListener(OnItemClickListener listener) {
    onItemClickListener = listener;
}


public interface OnItemClickListener{
    void onItemClick(View view, int position);
}
```

实现选中效果，然后为每个itemview添加并注册点击事件，并将点击事件传给外面的调用者，如下：
```java
@Override
public void onBindViewHolder(final ViewHolder holder, final int position) {
    ...

    /*设置选中状态*/
    if (position == SelectedNavItem.getSlectedNavItem()) {
        holder.itemView.setBackground(mContext.getResources().getDrawable(R.drawable.selected));
    } else {
        holder.itemView.setBackground(mContext.getResources().getDrawable(R.drawable.un_select));
    }

    holder.itemView.setOnClickListener(new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            onItemClickListener.onItemClick(holder.itemView, position);
        }
    });
}
```
Activity中的代码：
```java
adapter.setOnItemClickListener(new NavFuncAdapter.OnItemClickListener() {
    @Override
    public void onItemClick(View view, int position) {
        SelectedNavItem.setSlectedNavItem(position);//自定义的方法，告诉adpter被点击item
        adapter.notifyDataSetChanged();
    }
});
```

# 源码地址
[ForMe](https://github.com/huaqianlee/ForMe)


# 效果
![nav_item_selected](https://github.com/huaqianlee/blog-file/https://github.com/huaqianlee/blog-file/https://github.com/huaqianlee/blog-file/image/blog/forme/select_item_effct.gif)
