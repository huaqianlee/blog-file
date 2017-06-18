title: "第一行代码之网络"
date: 2017-05-09 19:29:56
categories: 学习笔记
tags: [App,FirstCode]
---
[《第一行代码》第2版思维导图及所有学习笔记目录](http://huaqianlee.github.io/2017/03/24/FirstCode/The-departure-of-FirstCode-learning-notes/)

## WebView
WebView控件使用十分简单：
```java
# 布局
<WebView />

# 应用
webView.getSettings().setJavaScriptEnabled(true); // 设置浏览器属性，支持JavaScript脚本
webView.setWebViewClient(new WebViewClient());//目标网页在当前WebView中显示，而不打开系统浏览器
webView.loadUrl("http://huaqianlee.github.io");

# 权限
<uses-permission android:name="android.permission.INTERNET"/>
```
<!--more-->
## HTTP协议
### HttpURLConnection
获取实例：
```java
URL url = new URL("http://huaqianlee.github.io");
HttpURLConnection connection = (HttpURLConnection) url.openConnection();
```
设置HTTP请求所使用的方法：GET或POST。
```java
connection.setRequestMethod("GET");
```
其它定制：
```java
connection.setConnectTimeout(8000);
connection.setReadTimeout(8000);// ms
...
```
读取服务器返回的输入流：
```java
InputStream in = connection.getInputStream();
```
关闭HTTP连接：
```java
connection.disconnect();
```
提交数据：
```java
conneciton.setRequestMethod("POST");
DataOutputStream out = new DataOutputStream(connection.getOutputStream());
out.writeBytes("username=admin&password=123456");
//数据之间用“&”隔开
```


### OkHttp
OkHttp项目地址：[https://github.com/square/okhttp](https://github.com/square/okhttp)。

下载：
```xml
# Gradle: app/build.gradle
compile 'com.squareup.okhttp3:okhttp:3.7.0'
```
用法：
```java
# 创建实例
OKHttpClient client = new OkHttpClient();

# 创建Request对象,build()之前可以定制Request对象
Request request = new Request.Builder()
    .url("http://huaqianlee.github.io")
    .build();

# 创建Call对象,response为服务器返回的数据
Response response  = client.newCall(request).execute();

# 获取具体内容
String responseData = response.body().string();

# 如果发起POST请求，需先构建Body对象存储提交的参数
RequestBody requestBOdy = new FormBody.Builder()
    .add("username","admin")
    .add("password","123456")
    .build();
    
# 创建Request对象
Request request = new Request.Builder()
    .url("http://huaqianlee.github.io")
    .post(requestBody)
    .build();
# 其余就和上面GET请求一样了    
```

## 解析XML格式数据
假设服务器有如下一段xml：
```xml
<apps>
    <app>
        <id>1</id>
        <name>Google Maps</name>
        <version>1.0</version>
    </app>
    ...
</apps>    
```

### Pull解析方式
获取到网页字符数据后，解析方法如下：
```java
XmlPullParserFactory factory = XmlPullParserFactory.newInstance();
XmlPullParser xmlPullParser = factory.newPullParser();
/*设入需要解析的服务器数据*/
xmlPullParser.setInput(new StringReader(xmlData));
int eventType = xmlPullParser.getEventType();
while (eventType != XmlPullParser.END_DOCUMENT) {
    String nodeName = xmlPullParser.getName(); //获取当前节点名
    switch (eventType) {
        // 开始解析某个结点
        case XmlPullParser.START_TAG: {
            if ("id".equals(nodeName)) {
                id = xmlPullParser.nextText();
            } ...
            break;
        }
        // 完成解析某个结点
        case XmlPullParser.END_TAG: {
            if ("app".equals(nodeName)) {
                // 完成一个节点解析，要做什么代码写在这
            }
            break;
        }
        default:
            break;
    }
    eventType = xmlPullParser.next();
}
```
### SAX解析方式
新建一个继承于DefaultHandler的子类，并重写5个方法，如下：
```java
public class ContentHandler extends DefaultHandler {

    private String nodeName;

    private StringBuilder id;

    private StringBuilder name;

    private StringBuilder version;

    @Override
    public void startDocument() throws SAXException {
        id = new StringBuilder();
        name = new StringBuilder();
        version = new StringBuilder();
    }

    @Override
    public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException {
        // 记录当前结点名
        nodeName = localName;
    }

    @Override
    public void characters(char[] ch, int start, int length) throws SAXException {
        // 根据当前的结点名判断将内容添加到哪一个StringBuilder对象中
        if ("id".equals(nodeName)) {
            id.append(ch, start, length);
        } else if ("name".equals(nodeName)) {
            name.append(ch, start, length);
        } else if ("version".equals(nodeName)) {
            version.append(ch, start, length);
        }
    }

    @Override
    public void endElement(String uri, String localName, String qName) throws SAXException {
        if ("app".equals(localName)) {
            /*解析出来带换行符，所以调用trim()去掉*/
            Log.d("ContentHandler", "id is " + id.toString().trim());
            ...
            // 最后要将StringBuilder清空掉
            id.setLength(0);
            name.setLength(0);
            version.setLength(0);
        }
    }

    @Override
    public void endDocument() throws SAXException {
        super.endDocument();
    }

}
```
解析代码：
```java
try {
    SAXParserFactory factory = SAXParserFactory.newInstance();
    XMLReader xmlReader = factory.newSAXParser().getXMLReader();
    ContentHandler handler = new ContentHandler();
    // 将ContentHandler的实例设置到XMLReader中
    xmlReader.setContentHandler(handler);
    // 开始执行解析
    xmlReader.parse(new InputSource(new StringReader(xmlData)));
} catch (Exception e) {
    e.printStackTrace();
}
```

## 解析JSON格式数据
假设服务器有如下JSON数据：
```json
[{"id":"5","name":"Google Map","version":"1.0"},...]
```
### 使用JSONObject
获取到字符数据后，解析方式如下：
```java
/*将服务器的JSON数组传入JSONArray*/
JSONArray jsonArray = new JSONArray(jsonData);
for (int i = 0; i < jsonArray.length(); i++) {
    JSONObject jsonObject = jsonArray.getJSONObject(i);
    String id = jsonObject.getString("id");
    String name = jsonObject.getString("name");
    String version = jsonObject.getString("version");
    ...
}
```
### 使用GSON
加入依赖：
```xml
compile 'com.google.code.gson:gson:2.7'
```
基本用法：
```json
# json 数据
{"name":"Tom","age":"20"}

# 解析
Gson gson = new Gson();
Person person = gson.fromJson(jsonData, Person.class);

# 数组内容解析：
List<Person> people = gson.fromJson(jsonData, new TypeToken<List<Person>>(){}.getType());

```
示例：
```java
# 首先需要新建个App类

# 解析
Gson gson = new Gson();
List<App> appList = gson.fromJson(jsonData, new TypeToken<List<App>>() {}.getType());
for (App app : appList) {
    Log.d("MainActivity", "id is " + app.getId());
    ...
}
```
## 封装网络请求
```java
# HTTP方式首先得新建一个回调接口
interface HttpCallbackListener {
    void onFinish(String s);
    void onError(Exception e);
}

# 封装
public class HttpUtil {

    public static void sendHttpRequest(final String address, final HttpCallbackListener listener) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                HttpURLConnection connection = null;
                try {
                    URL url = new URL(address);
                    connection = (HttpURLConnection) url.openConnection();
                    connection.setRequestMethod("GET");
                    connection.setConnectTimeout(8000);
                    connection.setReadTimeout(8000);
                    connection.setDoInput(true);
                    connection.setDoOutput(true);
                    InputStream in = connection.getInputStream();
                    BufferedReader reader = new BufferedReader(new InputStreamReader(in));
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        response.append(line);
                    }
                    if (listener != null) {
                        // 回调onFinish()方法
                        listener.onFinish(response.toString());
                    }
                } catch (Exception e) {
                    if (listener != null) {
                        // 回调onError()方法
                        listener.onError(e);
                    }
                } finally {
                    if (connection != null) {
                        connection.disconnect();
                    }
                }
            }
        }).start();
    }

    public static void sendOkHttpRequest(final String address, final okhttp3.Callback callback) {
        OkHttpClient client = new OkHttpClient();
        Request request = new Request.Builder()
                .url(address)
                .build();
        client.newCall(request).enqueue(callback);
    }
}

# 调用
HttpUtil.sendHttpRequest("http://huaqianlee.github.io", new HttpCallbackListener() {
    @Override
    public void onFinish(String s) {

    }

    @Override
    public void onError(Exception e) {

    }
});

HttpUtil.sendOkHttprequest("http://huaqinalee.github.io", new Callback() {
    @Override
    public void onFailure(Call call, IOException e) {

    }

    @Override
    public void onResponse(Call call, Response response) throws IOException {
        String data = response.body().string();
    }
});
```

## 示例源码
整个示例源码的地址：
[示例源码地址](https://github.com/huaqianlee/AndroidDemo/tree/master/FirstCode/chapter9/NetworkTest)。


