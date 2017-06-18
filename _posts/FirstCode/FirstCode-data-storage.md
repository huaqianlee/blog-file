title: "第一行代码之数据存储"
date: 2017-04-29 18:35:49
categories: 学习笔记
tags: [App,FirstCode]
---
[《第一行代码》第2版思维导图及所有学习笔记目录](http://huaqianlee.github.io/2017/03/24/FirstCode/The-departure-of-FirstCode-learning-notes/)

## 文件存储
### 数据存到文件
Context类提供了一个openFileOutput()方法，可以用于文件存储，此方法有两个参数：
* arg1 - 文件名，不包括路径，全默认存储于/data/data/<packagename>/files/
* arg2 - 文件操作模式， MODE_PRIVATE（覆盖式）和 MODE_APPEND（追加式）
<!--more--> 

如下是一个简短示例：
```java
public void save () {
    FileOutputStream out = null;
    BufferedWriter writer = null;
    try {
        out = openFileOutput("data", Context.MODE_PRIVATE);
        writer = new BufferedWriter(new OutputStreamWriter(out));
        writer.write("the content");
    } ... finally {
        if(wirter != null)
            writer.close();
        ...
    }
}
```
### 从文件中读取数据
Context类提供了一个openFileInput()方法，用于从文件读取数据，简例如下：
```bash
public String load() {
    FileInputStream in = null;
    BufferedReader reader = null;
    StringBuilder content = new StringBuilder();
    try {
        in = openFileInput("data");
        reader = new BufferedReader(new InputStreamReader(in));
        String line = "";
        while((line = reader.readLine()) != null) {
            content.append(line);
        }...finally {
            if(reader != null) {
                reader.close();
            }
            ...
        }
    }
    return content.toString();
}

# 判断字符是否为空的一个方式
TextUtils.isEmpty(string)
```

## SharedPreferences存储
### 将数据存储到SharedPreferences中
SharedPreferences是通过键值对的方式存储，Android中获取SharedPreferences对象的三种方法：

1. Context类中的getSharedPreferences()方法。
	- arg1: SharedPreferences文件名，**存于：/data/data/<package_name>/shared_prefs/**
	- arg2: 操作模式，只有MODE_PRIVATE一种方式，传入0也一样的效果，其余皆被废弃

2. Activity中的getPreferences()方法。
    - 一个参数：操作模式，自动以类名命名文件

3. PreferenceManager类中的getDefaultSharedPreferences()静态方法，
    - 接收Context参数，自动用包名为前缀命名文件 

获取了SharedPreferences对象后， 就可以存储数据了，主要分三步实现：

* **step1**：通过SharedPreferences对象的edit()方法获取SharedPreferences.Editor对象

* **step2**：通过putXxx()方法向SharedPreferences.Editor对象添加数据

* **step3**：调用apply()方法提交数据，完成数据存储。
   
一个存储的简单书写方式：    
```java
SharedPreferences.Editor editor = getSharedPreferences("data",MODE_PRIVATE).edit();
editor.putString("name","andy");
editor.putInt("age",)
editor.putBoolean("married",true);
editor.apply();
```
### 从SharedPreferences中读取数据
读取数据的方式十分简单，得到SharedPreferences对象后通过getX()方法即可获取到数据。getX()方法有两个参数：
* arg1：key值
* arg2：当通过key值找不到内容时的默认值
 
## SQLite数据库存储

SQL的数据类型：
```sql
integer：整型
real：浮点型
text：文本类型
blob：二进制
# 一些其他关键字
primary key：设为主键
autoincrement：自增长
```
一个关键的抽象类SQLiteOpenHelper及其两个实例方法：
**getReadableDatabase()** 和 **getWritableDatabase()**。两个方法都能创建或打开数据库，不过当数据不可写入是，getWritableDatabase()将报异常。

### 创建数据库及CRUD操作
要使用SQLite，首先需要实现SQLiteOpenHelper抽象类：
```java
public class MyDatabaseHelper extends SQLiteOpenHelper {
    private static final String CREATE_BOOK = "create table Book (" +
            "id integer primary key autoincrement," +
            "author text," +
            "price real," +
            "pages integer," +
            "name text)";

    private static final String CREATE_CATEGORY = "create table Category (" +
            "id integer primary key autoincrement," +
            "category_name text," +
            "category_code integer)";



    private Context mcontext;

    public MyDataBaseHelper(Context context, String name, SQLiteDatabase.CursorFactory factory, int version) {
        super(context, name, factory, version);
        mcontext = context;
    }

    @Override
    /*创建数据库*/
    public void onCreate(SQLiteDatabase db) {
        db.execSQL(CREATE_BOOK);
        db.execSQL(CREATE_CATEGORY);
        Toast.makeText(mcontext, " Created succeeded!", Toast.LENGTH_SHORT).show();

    }

    /*升级数据库*/
    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("drop table if exists Book");
        db.execSQL("drop table if exists Category");
        onCreate(db);

    }
}
```
有了这类之后，就可以进行CRUD操作了
```java
#c-create r-retrieve(查询) u-update d-delete
final MyDataBaseHelper helper = new MyDataBaseHelper(this, "BookStore.db", null, 1); // 1 为数据库版本号， 当升级数据库的时候需更新
// 创建数据库
SQLiteDatabase db = helper.getWritableDatabase();

// 添加数据
ContentValues values = new ContentValues();
values.put("name", "Just for fun");
...
db.insert("Book", null, values);
// 更新数据
values.put("price",1000);
db.update("Book", values,"name=?",new String[]{"Just for fun"});
// 删除数据
db.delete("Book","price < ?", new String[]{"100"});
// 查询数据
Cursor cursor = db.query("Book",null,null,null,null,null,null);
if (cursor.moveToFirst()) {
    do{
        String name = cursor.getString(cursor.getColumnIndex("name"));
        ...

    } while (cursor.moveToNext());

```
### 直接使用SQL操作数据库
直接使用SQL来完成CRUD操作：
```bash
# 添加数据
db.execSQL("insert into Book(name,author,pages,price) values(?,?,?,?)", new String{"Just for fun","Linus","355","99"});
# 更新数据
de.execSQL("update Book set price =? where name = ?",new String[]{"88","Just for fun");
# 删除数据
db.execSQL("delete from Book where pages > ?", new String[]{"300"});
# 查询数据
db.rawQuery("select * from Book",null);
```
### 命令查看数据库
连接上手机，adb shell进入终端：
```shell
# 查看数据库中的表
.table   
# 查看建表语句
.schema
# 查询语句
select * from Book
```


## 使用开源LitePal操作数据库
Litepal采用了对象关系映射(ORM)的模式，其地址：[https://github.com/LitePalFramework/LitePal](https://github.com/LitePalFramework/LitePal)。

### 配置LitePal
要使用LitePal首先需要再app/build.gradle文件里添加依赖：
```bash
dependencies {
    compile 'org.litepal.android:core:1.3.2' # 目前最新已经俩到1.5.1
}
```
接下来需要配置litepal.xml文件。需在app/src/main下新建assets/litepal.xml。
```
<?xml version="1.0" encoding="utf-8"?>
<litepal>
    <dbname value="BookStore"></dbname> # 指定数据库名
    <version value="1"></version> # 指定数据库版本号
    <list></list>  # 指定映射模型
</litepal>
```
最后需要再AndroidMannifest.xml中做如下配置：
```xml
<manifest>
    <application
        android:name="org.litepal.LitePalApplication"
        ...
    >
        ...
    </application>
</manifest>
```
如果已经有了自己的application，如下：
```xml
<manifest>
    <application
        android:name="com.example.MyOwnApplication"
        ...
    >
        ...
    </application>
</manifest>
```
可以通过如下方式实现让LitePal成功运行：
```java
public class MyOwnApplication extends AnotherApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        LitePal.initialize(this);
    }
    ...
}
```
### 创建和升级数据库
为了创建一个Book表，先定义一个Book类：
```java
public class Book extends DataSupport {
    private int id;
    private String author;
    ...
    // generated getters and setters.
}
```
接下来将Book类添加到litepal.xml的映射模型列表中：
```xml
<list>
    <mapping class="com.example.litepaltest.Book" />
</list>
```
现在进行任意一次数据库操作，BookStore.db就会自动被创建出来：
```java
Connector.getDataBase(); // LitePal 的一个最简单数据库操作方法
```
现在如若要向表中添加列等数据，只需要在Book类中添加一个字段即可。

### 增删改查

```java
// 添加数据
Book book = new Book();
book.setXx();
book.save();

// 以存储对象更新数据
book.setXx();
book.save();

// 通用方式更新数据
book.setPrice(14.95);
book.setPress("Anchor");
book.updateAll("name=? and author = ?","Just for fun","Linus");

// 指定数据更新为默认值
book.setToDefault("pages");
book.updateAll();

// 删除数据
DataSupport.deleteAll(Book.class, "price < ?","15");

// 查询数据
List<Book> books = DataSupport.findAll(Book.class);
```

### 更多方法
[https://github.com/LitePalFramework/LitePal](https://github.com/LitePalFramework/LitePal)。




  