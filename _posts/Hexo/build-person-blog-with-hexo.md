title: Build person blog with hexo and  github
date: 2014-10-24 01:12:15
categories: Hexo
tags: Tools
---
　　基于Hexo和Github的个人博客构建，我参照[hexo你的博客](http://ibruce.info/2013/11/22/hexo-your-blog/)、[hexo官方文档](http://hexo.io/docs/)及[github官方文档](https://help.github.com/articles/set-up-git/)完成了自己的个人blog。通过前段时间学习Android和这些天build自己的github、个人blog，关于学习新东西有一个新的体会，就是官方文档和帮助是最好的资料，虽然是英文的，但是看官方的源文档能提升自己的效率。

现在写博客只需要几个简单的命令就能完成发布了．

``` bash
$ hexo new "My New Post"
$ hexo generat
$ hexo deploy
也可以直接简写为：
$ hexo n "My New Post"
$ hexo d -g
```
<!--more-->
博客内容编辑语法教程：

- [Markdown_en](http://daringfireball.net/projects/markdown/syntax.php)
- [Markdown_cn](http://wowubuntu.com/markdown/#overview)
---

##Github　　

要成功构建blog首先得有Github账号和Github　Pages. 　　

- 首先注册一个 [github](https://github.com)账号　　
- 建立一个与用户名对应的repository来构建Github　pages,仓库名必须为your_user_name.github.com或者your_user_name.github.io．也可以[creating pages with the automatic generator](https://help.github.com/articles/creating-pages-with-the-automatic-generator/).
- [添加ssh公钥到Github](https://help.github.com/articles/generating-ssh-keys/),如果安装[Github for windows](https://windows.github.com/)可以省掉这一步,因为软件已经自动生成了.

##环境安装　　

安装hexo十分容易，不过在安装之前需要先做一些准备工作：　　

- [Node.js](http://nodejs.org/)
- [Git](http://git-scm.com/)　　

###安装git　　

关于Git版本我个人安装[msysgit](http://msysgit.github.io/)；如果装[Github for windows](https://windows.github.com/)，其会自动为电脑安装git，而且还有另外一个好处，它会自动为github创建一个ssh密匙，为我们省去很多工作。　　

###安装Node.js　　

最好的方法是通过[nvm](https://github.com/creationix/nvm)安装.　　

cURL:

```bash
$ curl https://raw.github.com/creationix/nvm/master/install.sh | sh
```

Wget:
 
```bash
$ wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | sh
```

安装成功后,重启terminal终端,然后运行接下来命令安装Node.js　　

```bash
$ nvm install 0.10  #版本号
```

当然也可以通过上面Node.js下载安装.　　

###安装hexo　　

当上面的所有准备工作做好后,可以安装hexo通过npm.

```bash
$npm install -g hexo
```

###初始化

当Hexo安装完成后,运行接下来的命令,hexo将编译所有需要的文件到目标路径.

```bash
$ hexo init <folder>
$ cd <folder>
$ npm install
```

编译完成后,工程目录如下:

.
├── _config.yml
├── package.json
├── scaffolds
├── scripts
├── source
|├── _drafts
|└── _posts
└── themes

详细配置信息及文件内容格式参照 [hexo configuration](http://hexo.io/docs/setup.html)

###生成静态页面

进入hexo目标目录,执行如下命令,生成静态文件至hexo\pulbic.

```bash
hexo generate / hexo g
* 必须在init目录下(hexo目录)执行.
*当修改文章Tag或内容，不能正确重新生成内容，可以删除hexo\db.json后重试，还不行就到public目录删除对应的文件，重新生成。
```
执行如下命令,将启动本地服务,进行文章预览调试.
```bash
hexo server
```
在浏览器输入<http://localhost:4000>即可看到效果.


###写文章

执行如下命令,生成制定名称的文章至hexo\source\_post\pstName.md.
```bash
hexo new [layout] "postName" 
*postName为文件名,如果包含空格,则必须加"",其将出现在文章的URL中.
```
*layout为可选参数,默认为post,详细见scaffolds目录,若添加自己的layout,只需新建一个文件在scaffolds目录即可,也可以编辑现有的layout,比如修改默认的post.md,想添加一个categories分类,让每次生成文章时能自动添加分类栏目,就只需在---上面添加categories.
```bash
title: { { title } }
date: { { date } }
categories: # 添加
tags:
---
*注意大括号之间多加了空格,否则会被转义,而不能正常显示
* 所有文件后面必须有个一个空格,否则会报错
```
###fancybox (此段摘录自[hexo你的博客](http://ibruce.info/2013/11/22/hexo-your-blog/))
可能有人对这个Reading页面中图片的fancybox效果感兴趣，这个是怎么做的呢。
很简单，只需要在你的文章*.md文件的头上添加photos项即可，然后一行行添加你要展示的照片：
```bash
layout: photo
title: 我的阅历
date: 2085-01-16 07:33:44
tags: [hexo]
photos:
- http://bruce.u.qiniudn.com/2013/11/27/reading/photos-0.jpg
- http://bruce.u.qiniudn.com/2013/11/27/reading/photos-1.jpg
*经过测试，文件头上的layout: photo可以省略。
```
不想每次都手动添加怎么办？同样的，打开您的hexo\scaffolds\photo.md
```bash
layout: { { layout } }
title: { { title } }
date: { { date } }
tags: 
photos: 
- 
---
```
然后每次可以执行带layout的new命令生成照片文章：
```bash
hexo new photo "photoPostName" #新建照片文章
```
####description
markdown文件头中也可以添加description，以覆盖全局配置文件中的description内容，请参考下文_config.yml的介绍。
```bash
title: hexo你的博客
date: 2013-11-22 17:11:54
categories: default
tags: [hexo]
description: 你对本页的描述
---
*hexo默认会处理全部markdown和html文件，如果不想让hexo处理你的文件，可以在文件头中加入layout: false。
```
###文章摘要
在需要显示摘要的地方添加如下代码即可：
```bash
以上是摘要
<!--more-->
以下是余下全文
```
more以上内容即是文章摘要，在主页显示，more以下内容点击『> Read More』链接打开全文才显示。
```bash
hexo中所有文件的编码格式均是UTF-8。
```

##主题安装

到hexo的主题列表[Hexo Themes](https://github.com/hexojs/hexo/wiki/Themes)安装自己中意的主题.我比较喜欢简洁版的,所以clone安装的[winterland](https://github.com/winterland1989/hexo-theme-winterland).主题的安装方法基本每个主题的READEM.md都有描述.

*自己最初clone了[metro-light](https://github.com/halfer53/metro-light),结果主题未完善,发表博文是格式总是不对,浪费了自己大半天的时间,后面换个主题就行了.在警示一下自己.


未完待续...
```bash
*到这为至,自己的个人blog基本完成,能满足基本需求.
*我会在使用blog的过程中不断加入自己喜欢的元素,到时再继续.
```

##附 补充一下出错解决方法
搞软件总是会出现很多错误,很多时候各种方法试尽仍不能解决,从头再来很多时候问题就解决了.如果遇到怎么都不能解决的问题可以试试如下方式.
1. 备份自己的配置文件(_config.yml source文件夹 themes文件夹).然后删除Hexo目录下的所有文件.

2.rebuild Hexo文件夹,进入Hexo文件夹执行如下命令.
```bash
hexo init
npm install
```
3.执行如下命令,在浏览器输入 localhost:4000,预览测试博客.
```bash
hexo g
hexo s
```
4.如果3成功则将备份文件copy回来,再通过3测试.

Hexo 升级时总是很容导致很多问题， 有时会比较麻烦，如果想降级回去，可以通过如下方式装回老版本：
```bash
npm install -g hexo@3.x.x
```
