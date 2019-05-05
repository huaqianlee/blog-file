title: "Gitbook + Jenkins + Gitlab 搭建内网自动构建的 Gitbook"
date: 2019-05-05 20:04:59
categories: Git
tags:
---
最近在本地搭建了一个 Gitbook ，用于内网访问。总结一下简单流程形成此文，细节设置可以参考官网。

## Gitbook
### Install Git
```
sudo apt install git
```
<!--more-->
### Install Node.js
```
sudo apt install Node.js
```

### Install npm
```
sudo apt install npm
```

### Install gitbook
```
npm install gitbook-cli -g
gitbook -V
```

### Test gitbook server-web
```
mkdir server
cd server
gitbook init
gitbook build .
gitbook serve .
```

## Gitlab
### Install and configure the necessary dependencies
```
sudo apt-get update
sudo apt-get install -y curl openssh-server ca-certificates
```
### Install Postfix to send notification emails. 
```
sudo apt-get install -y postfix
```

### Add the GitLab package repository and install .
```
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash
sudo EXTERNAL_URL="https://gitlab.example.com" apt-get install gitlab-ee
```

### Config gitlab
```
sudo mkdir -p /etc/gitlab
sudo touch /etc/gitlab/gitlab.rb
sudo chmod 600 /etc/gitlab/gitlab.rb
sudo vim /etc/gitlab/gitlab.rb
# external_url 'http://164.69.136.23' , config as local ip or url.
# Modification is suggested. If '502 GitLab is not responding...' error exists, modify 'unicorn['port']' in gitlab.rb. 

sudo gitlab-ctl reconfigure # reconfigure and restart.
sudo gitlab-ctl status
```


## Jenkins

### Install Java
推荐安装 openjdk-7-jre 和 openjdk-7-jdk ，但是其在 Ubuntu 16.04 和更高版本不再有效，可以安装 Java 8 或者 9 代替。
```
sudo apt-get install openjdk-7-jre
sudo apt-get install openjdk-7-jdk
```

### Install Jenkins
```
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins
```

### Upgrade Jenkins
Jenkins 更新比较快，如若过期，可以按如下命令更新。
```
sudo apt-get update
sudo apt-get install jenkins
```
### Config Jenkins 
```
sudo vi /etc/init.d/jenkins
# Modify HTTP_PORT is suggested.
sudo vi /etc/sudoers
# jenkins ALL=(ALL) NOPASSWD:ALL ; 赋予 Jenkins sudo 权限和无密权限
```

### Install plugin
通过 web(eg:http://192.168.1.2:8080)  访问Jenkins 并安装插件 Git plugin　和　Gitlab Hook Plugin 。 
> 初次登陆时注意 check web 提示的密码地址。

## Nginx
### Install nginx
```
sudo apt-get install nginx
# upgrade
sudo apt-add-repository ppa:nginx/stable
sudo apt-get update
sudo apt-get upgrade nginx -y

sudo service nginx start
```
> nginx 默认使用 80 端口，打开浏览器输入：http://localhost/

### Config nginx
sudo vi /etc/nginx/nginx.conf ， 注释掉不需要的配置文件，并新配 server 。
```
# comment to solve "Welcome to nginx ..." issue.
# include /etc/nginx/conf.d/*.conf;
# include /etc/nginx/sites-enabled/*;
server {
        server_name localhost;
        listen 8082; # config port
        location / {
                root /home/lee/gitbook/www/mybook; # 自定义，用于存放 gitbook 内容
                #index  index.html index.html;

                #autoindex
                autoindex on;
                autoindex_exact_size on;
                autoindex_localtime on;
        }
}
nginx -t # 检查配置文件是否正常
nginx -s reload # 重启
若出现错误：
nginx:[error] open() "/run/nginx.pid" failed (2: No such file or directory)

nginx -c /etc/nginx/nginx.conf
nginx -s reload
nginx -s stop
```

## Automaticaly trigger
### Config gitlab
#### Add access token
```
user settings ---> Access Tokens
```
> *记录下 token ，一旦关闭网页，此 token 将不再可见。*

#### Create mybook
新建一个项目 <mybook>， 添加 webhooks.
```
a. Settings ---> Integrations 
b. add url: http://192.168.1.2:8082/gitlab/build_now (jenkins url) .
c. Select push event.
d. Add webhook.
```
在本地项目路径执行 ‘gitbook init’ 生成 README.md 和 SUMMARY.md 两个文件， push 到 gitlab.

### Config Jenkins
#### Add tokens
```
# 系统管理 ---> 系统设置
Gitlab:
Connection name: gitlab
Gitlab host url: gitlab url
credentials: Add token, 填入上面 Access Tokens.
Test connection.
```

#### Config trigger
新建任务 <mybook> ---> 构建一个自由风格的软件项目:
1. 源码管理: git
```
Repository URL:

http://192.168.1.2:8081/root/mybook.git
Credentials ---> Add , 填入 Gitlab 用户名和密码　
```

2. 构建 ---> 执行 shell
```
gitbook build
sudo rm -rf  /home/lee/gitbook/www/mybook
sudo cp -a    _book  /home/lee/gitbook/www/mybook
sudo chmod  777  /home/lee/gitbook/www/mybook
```
　
### Preview
更新本地文件，然后 push 到 Gitlab, 查看 Jenkins 是否会自动触发构建。

如果 OK ， 整个配置流程就完成了，也可以直接预览 Gitbook了。
```
http://192.168.1.2:8082 (nginx port)
```
