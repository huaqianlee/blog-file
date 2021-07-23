title: The document convetions for Java
date: 2014-10-27 22:28:28
categories:
- Programming Language
- Java
tags: Program Kill
---
　　注释一直是编程最重要的部分之一,学习Java很长一段时间了,由于之前一直没有很正式的写过项目，所以一直也就没怎么认真的写过注释．因为注释又是如此的重要，所以今天对Java的注释规范加以总结，也促使自己以后写代码注意注释．

## 注释的地方
1. 每个源文件开头应该有一段注释,介绍代码的作者\时间等信息.
2. 当代码比较长,嵌套较深时,应该在某些花括号末尾注明花括号对应的起点.
3. 重要的属性需要添加注释,每个方法需要添加注释.
4. 典型的算法等需要特别注意的地方需要添加注释.
5. 有bug的地方需要加以注释,修改过的代码需要加修改标志注释.

<!--more-->
## 注释的方法
1. 单行注释 // 
2. 多行注释 /**/
3. 文档注释
这是最重要的注释方式，并且用此方式注释后能生成Java doc，例如下面是一个servlet创建后生成的一个注释文档:
```bash
/**
 * The doGet method of the servlet. <br>
 *
 * This method is called when a form has its tag value method equals to get.
 * 
 * @param request the request send by the client to the server
 * @param response the response send by the server to the client
 * @throws ServletException if an error occurred
 * @throws IOException if an error occurred
 */
public void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
                    doPost();
     }
 ```
a.类注释

在myEclipse中，可以通过快捷键Alt+Shift+J生成，注释的内容可以通过Eclipse -> Window -> Preferences -> Java -> Code Style -> Code Templates -> Comments -> Types -> Edt 设置,格式如下：
```bash
/**
 * @author 
 *
 * @Time 
 */
```
b.类的英文注释模板
```bash
/***************************************************************************************** 
 *
 *
 * CopyRright (c)2014-xxxx:                          
 * Project:               <项目工程名 >                                          
 * Module ID:             <(模块)类编号，可以引用系统设计中的类编号>    
 * Comments:              <对此类的描述，可以引用系统设计中的描述>                                           
 * JDK version used:      <jdk1.7>                              
 * Namespace:             <命名空间>                              
 * Author：                       
 * Create Date：  
 * Modified By：                                           
 * Modified Date:                                     
 * Why & What is modified:     
 * Version:                                       
 ****************************************************************************************/ 
```
c.构造函数注释
```bash
/** 
 * 构造方法 的描述 
 * @param 
 *       
 */
```
d.方法注释
```bash
/** 
 * 方法描述 
 * @param 
 * @return  
 * @exception  (方法有异常的话加) 
 * @author  
 * @Time  
 */
```
e.成员变量注释
```bash
/** The count is the number of charactersin the String. */
private int count;
```
有必要时要说明变量功能，涉及到的方法等等。

## javadoc参数说明：
```bash
@see 生成文档中的“参见xx 的条目”的超链接，后边可以加上："类名"、"完整类名"、"完整类名#方法"。可用于：类、方法、变量注释。 
@param 参数的说明。可用于：方法注释。 
@return 返回值的说明。可用于：方法注释。 
@exception 可能抛出异常的说明。可用于：方法注释。 
@version 版本信息。可用于：类注释。 
@author 作者名。可用于：类注释。 
@deprecated 对类或方法的说明 该类或方法不建议使用,引起不推荐使用的警告 
@note 表示注解，暴露给源码阅读者的文档 
@remark 表示评论，暴露给客户程序员的文档 
@since 表示从那个版本起开始有了这个函数 
@see 表示交叉参考
```
