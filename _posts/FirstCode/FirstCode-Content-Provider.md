title: "第一行代码之跨程序共享数据-内容提供器"
date: 2017-05-03 21:51:23
categories:
- Android Tree
- Notation
tags: [App,FirstCode]
---
[《第一行代码》第2版思维导图及所有学习笔记目录](http://huaqianlee.github.io/2017/03/24/FirstCode/The-departure-of-FirstCode-learning-notes/)

内容提供器(Content Provider)是Android实现跨程序共享数据的标准方式。

## 运行时权限

### Android权限机制
为了安全，Android6.0后引入了新特性，让APP申请的权限用户可控，Android的权限分为了两类：1. 普通权限，2.危险权限。危险权限一共有9组24个权限。
<!--more-->

![Android danger permission](https://andylee-1258982386.cos.ap-chengdu.myqcloud.com/android/firstcode/android_permission.jpg)

权限详情参考：[官网权限介绍](http://developer.android.com/reference/android/Manifest.permission.html)。

### 程序运行时申请权限
以CALL_PHONE为例来说明。定义触发打电话的逻辑：
```java
Intent intent = new Intent(Intent.ACTION_CALL);
intent.setData(Uri.parse("tel:10086"));
startActivity(intent);
```
在AndroidMainifest.xml中声明权限：
```xml
<uses-permission android:name="android.permission.CALL_PHONE"/>
```
这样声明的APP运行在6.0及以上的版本则会报错，要求在使用危险权限是都必须进行运行时权限处理。所以就得对触发打电话的逻辑进行修改：
```java
# 申请权限，处理打电话逻辑 {
	if(ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED) {
	    ActivityCompat.requestPermissions(MainActivity.this, new String[]{Manifest.permission.CALL_PHONE},1); // 申请授权
	} else {
	    call(); // 已授权，CALL
	}	
}

public void call () {
    try {
        Intent intent = new Intent(Intent.ACTION_CALL);
        intent.setData(Uri.parse("tel:911"));
        startActivity(intent);
    } catch (SecurityException e){
        e.printStackTrace();
    }
}

@Override
public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    //super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    switch (requestCode) {
        case 1:
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                call();
            } else {
                Toast.makeText(this, "You denied the permission!",Toast.LENGTH_SHORT).show();
            }
            break;
        default:
    }
}
```

## 访问其他程序中数据
### ContentResolver基本用法
ContentResolver类的实例可以通过Context的getContentResolver()获取。其提供了一系列方法用CRUD操作。ContentResolver中的增删改查方法接收一个Uri参数，其唯一标识符有两部分组成：authority和path。为了避免冲突一般用authority用包名，path对应用程序中的表进行区分。如下：
```bash
# content://authority/path
content://com.example.app.provider/table1
content://com.example.app.provider/table2
```
解析：
```java
Uri uri = Uri.parse("content://authority/path")
```
查询：
```java
#查询
Cursor cursor = getContentResolver().query(uri,projection,selecton,selectionArgs,sortOrder);
```
ContentResolver的查询方法参数解释如下：

|参数|对应SQL部分|描述|
|:--:|:---------:|:--:|
|uri|from table_name|指定查询某应用程序下一张表|
|projection|select column1,column2|指定查询的列名|
|selection|where column=value|指定where条件|
|selectionArgs|-|为where重占位符提供值|
|orderBy|order by column1,column2|指定查询结果排序方式|

获取到Cursor对象后，就能方便取出数据了：
```java
if(cursor=!null) {
    while(cursor.moveToNext()) {
        String column1 = cursor.getString(cursor.getColumnIndex("column1"));
        int column2 = cursor.geteInt(...);
    }
}
```
增改删：
```java
# 增加
ContentValues value = newContentValues();
values.put("column1","text");
values.put("column2",1);
getContentResolver().insert(uri, values);

#更新
values.put("column1","");
getContentResolver().update(uri, values,"column1 = ? and column2 = ?",new String [] {"text", "1"});

#删除

getContentResolver().delete(uri, "column2 = ?",new String [] {"1"});
```
### 读取系统联系人
```java
# 判断权限
if(ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS）!= PackageManager.PERMISSION_GRANTED) {
    ActivityCompat.requestPermisssions(this,new String []{Mainest.permission.READ_CONTACTS},1);
} else {
    readContacts();
}

onRequestPermissionsResult{
    switch(requestCode) {
        case 1:
         if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
             readContacts();
         } else {}
         default:
    }
}
# 读取共享数据
Cursor cursor = getContentResolver().qurey(ContactsContract.CommonDataKinds.Phone.CONTENT_URI,null,null,null,null);
if (cursor != null){
    while (cursor.moveToNext()) {
        String name = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME));
        String number = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
        contactLists.add(name+"\n"+number);
    }
}
```
然后需要加上读取联系人权限，如下：
```xml
<uses-permission android:name="android.permission.READ_CONTACTS"/>
```

## 创建内容提供器
### 创建步骤
首先需要实现一个类继承ContentProvider，重写6个抽象方法，一个重要参数就是Uri，URI还可以在前面所描述的组成后面加上一个id，如下：
```bash
content://authority/path/id // 访问指定表中指定id的数据，不指定id时就访问所以数据

# 可以用通配符来匹配id
* - 匹配任意长度字符
# - 匹配任意长度数字 
```
另外，其中比较特殊的getType()用于获取uri对象对应的MIME类型，其格式要求如下：
* 内容以路径结尾：vnd.android.cursor.dir/vnd.<authority>.<path>
* 内容以id结尾：vnd.android.cursor.item/vnd.<authority>.<path>
 
一个完整的内容提供器实例如下：
```java
public class DatabaseProvider extends ContentProvider {

    public static final int BOOK_DIR = 0;
    public static final int BOOT_ITEM = 1;
    public static final int CATEGORY_DIR = 2;
    public static final int CATEGORY_ITEM = 3;
    public static final String AUTHORITY = "com.lee.databasetest.provider";
    private static UriMatcher uriMatcher;
    private MyDataBaseHelper helper;

    static {
        uriMatcher = new UriMatcher(UriMatcher.NO_MATCH);
        uriMatcher.addURI(AUTHORITY,"book",BOOK_DIR);
        uriMatcher.addURI(AUTHORITY,"book/#",BOOT_ITEM);
        uriMatcher.addURI(AUTHORITY,"category",CATEGORY_DIR);
        uriMatcher.addURI(AUTHORITY,"category/#",CATEGORY_ITEM);
    }

    public DatabaseProvider() {
    }

    @Override
    public int delete(Uri uri, String selection, String[] selectionArgs) {
        // Implement this to handle requests to delete one or more rows.
        throw new UnsupportedOperationException("Not yet implemented");
    }

    @Override
    public String getType(Uri uri) {
        // TODO: Implement this to handle requests for the MIME type of the data
        // at the given URI.
        throw new UnsupportedOperationException("Not yet implemented");
    }

    @Override
    public Uri insert(Uri uri, ContentValues values) {
        SQLiteDatabase db = helper.getWritableDatabase();
        Uri uriReturn = null;
        switch (uriMatcher.match(uri)) {
            case BOOK_DIR:
            case BOOT_ITEM:
                long newBookId = db.insert("Book", null, values);
                uri = Uri.parse("content://"+AUTHORITY+"/book/"+newBookId);
                break;
            case CATEGORY_DIR:
            case CATEGORY_ITEM:
                long newCategoryId = db.insert("Category", null, values);
                uri = Uri.parse("content://"+AUTHORITY+"/category"+newCategoryId);
                break;
        }
        return uri;
    }

    @Override
    public boolean onCreate() {
        // TODO: Implement this to initialize your content provider on startup.
        helper = new MyDataBaseHelper(getContext(),"book.db",null,2);
        return true;
    }

    @Override
    public Cursor query(Uri uri, String[] projection, String selection,
                        String[] selectionArgs, String sortOrder) {
        SQLiteDatabase db = helper.getReadableDatabase();
        Cursor cursor = null;
        switch (uriMatcher.match(uri)) {
            case  BOOK_DIR:
                cursor = db.query("Book", projection,selection,selectionArgs,null,null,sortOrder);
                break;
            case BOOT_ITEM:
                String bookId = uri.getPathSegments().get(1);
                cursor = db.query("Book", projection,"id = ?",new String[]{bookId},null,null,sortOrder);
                break;
            case CATEGORY_DIR:
                cursor = db.query("Category", projection,selection,selectionArgs,null,null,sortOrder);
                break;
            case CATEGORY_ITEM:
                String categoryId = uri.getPathSegments().get(1);
                cursor = db.query("Category",projection,"id = ?", new String[]{categoryId},null,null,sortOrder);
                break;
            default:
                break;
        }
        return cursor;
    }

    @Override
    public int update(Uri uri, ContentValues values, String selection,
                      String[] selectionArgs) {
        // TODO: Implement this to handle requests to update one or more rows.
        throw new UnsupportedOperationException("Not yet implemented");
    }
}
```
更多代码见：[跨程序数据共享实例](https://github.com/huaqianlee/AndroidDemo/tree/master/FirstCode/chapter7/DataBaseTest/app/src/main/java/com/example/lee/databasetest)。



