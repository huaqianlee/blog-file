title: "xml基础"
date: 2015-01-18 00:13:28
categories: Web
tags: xml
---
XML 是有w3c组织发布的一种可扩展标记语言(Extensible Markup Language)。

##XML 的常见应用

XML常见的应用场景：
　
1. XML技术除用于保存有关系的数据之外，它还经常用作软件配置文件，以描述程序模块之间的关系。
2.在一个软件系统中，为提高系统的灵活性，它所启动的模块通常由其配置文件决定
　
例如一个软件在启动时，它需要启动Ａ、Ｂ两个模块，而A、Ｂ这两个模块在启动时，又分别需要A1、A2和B1、B2模块的支持，为了准确描述这种关系，此时使用ＸＭＬ文件最为合适不过。


##XML的语法

###文档的声明
```bash
<?xml version="1.0" encoding="GB2312"  standalone="yes" ?>
    encoding - 文档的字符编码。（代码里面写什么格式，一般就将文档存为什么格式，一般通用“UTF-8”）
    standalone - 文档是否为独立的，有依赖
```    
###元素

元素指XML中的标签,可以嵌套,只有一个主标签,两种书写方式如下:
•包含标签体：<a>www.itcast.cn</a>
•不含标签体的：<a></a>, 简写为：<a/>

###属性
属性值必须用"" 或'' 引起来,如:
```bash
<input name=“text”>
也可以:(XML将空格也当做内容,不过现在浏览器都会执行处理,调用trim())
<input>
   <name>text</name>
</input>
```
###注释
<\!--注释-->  // 注释语句必须写在XML声明语句后面

###CDATA区

CDATA(character data)区用于让解析引擎不对其进行处理,按照原始内容显示. 
```bash
格式:<![CDATA[ 内容 ]]>
eg:
  <![CDATA[
      <itcast>
          <br/>
      </itcast>
  ]]>
``` 
###转义字符
![escape](https://github.com/huaqianlee/blog-file/image/blogxml.png)        
###处理指令

处理指令，简称PI （processing instruction）。处理指令用来指挥解析引擎如何解析XML文档内容。例如，在XML文档中可以使用xml-stylesheet指令，通知XML解析引擎，应用css文件显示xml文档内容。  
<?xml-stylesheet type="text/css" href="1.css"?>
处理指令必须以“<?”作为开头，以“?>”作为结尾，XML声明语句就是最常见的一种处理指令。 


