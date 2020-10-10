title: How to build intranet gitbook with docker
date: 2020-10-10 22:23:38
categories: Git
tags:
---
之前折腾局域网搭建 Gitbook，并写了一篇简易教程：[Gitbook + Jenkins + Gitlab 搭建内网自动构建的 Gitbook](http://huaqianlee.github.io/2019/05/05/Git/gitlab-jenkins-gitbook-to-create-LAN-gitbook/)。最近兴趣使然又用 docker 搭建一套方便部署的内网 Gitbook 镜像，也总结一篇简易教程如下。

# Install Docker
```bash
sudo apt install docker
```

# Gitbook

## Gitbook Image
下载 Gitbook Docker 镜像，我选择了如下 [billryan/gitbook 镜像](https://hub.docker.com/r/billryan/gitbook)：
```bash
docker pull billryan/gitbook
```

`mkdir gitbook` 创建一个 gitbook 路径，我们也可以将启动的镜像存储为另一个镜像：
```bash
# init
docker run --rm -v "$PWD/gitbook:/gitbook" -p 4000:4000 billryan/gitbook gitbook init
# serve
docker run --rm -v "$PWD/gitbook:/gitbook" -p 4000:4000 billryan/gitbook gitbook serve


docker ps # Get CONTAINER ID of gitbook
docker commit <CONTAINER ID> andylee/gitbook:1.0
```
<!--more-->
存储一个本地 docker 镜像，方便迁移到其他机器，存储和加载命令如下：
```bash
# Save docker image
docker save -o <path for generated tar file> <image name>

# Load docker image
docker load -i <path to image tar file> 
```

## Gitbook build

我做了一个脚本 `gitbook.sh` 给 `Jenkins` 提供执行脚本，内容如下：
```bash
#!/bin/bash

#GITBOOK_HOME=/home/lee/docker/gitbook/src
# Jenkins gitbook workspace
GITBOOK_HOME=/home/lee/docker/jenkins/jenkins_home/workspace/gitbook
# Nginx static html
STATIC_HTML=/home/lee/docker/nginx/static_html


#rm -rf $GITBOOK_HOME/_book
docker run --rm  -v $GITBOOK_HOME:/gitbook -p 4000:4000 andylee/gitbook:1.0 gitbook build
# docker run as root, so host can't rewrite _book, which means gitbook only can be built one times. 
# The following are two ways to fix this issue.
# 1. add '--user "$(id -u):$(id -g)"' , run docker as current user group, but fails to create /gitbook in docker.  ~Not work.
# 2. chown _book as current user group with root permission. ~Work.
sudo -S su - <<EOF
chown -R lee:lee $GITBOOK_HOME/_book
EOF

#docker run  --rm -v $GITBOOK_HOME:/gitbook -p 4000:4000 andylee/gitbook:1.0 gitbook serve
#echo "Execute docker with '$GITBOOK_HOME' successfully!"

rm -rf $STATIC_HTML/*
# Copy _book static html to Nginx server.
cp -rf $GITBOOK_HOME/_book/* $STATIC_HTML
```

如果我们不用脚本或者想以一种简单的方式执行 docker，可以在 `.bashrc` 里添加别名。
```bash
alias gitbook='docker run --rm  -v $GITBOOK_HOME:/gitbook -p 4000:4000 andylee/gitbook:1.0 gitbook'
# init
gitbook init
# serve
gitbook serve
# build
gitbook build
# pdf output
gitbook pdf .
```

# GitLab

## GitLab Image

### Dockerfile
`mkdir gitlab` 创建一个 gitlab 路径，为了保证 `Clone with HTTP` 能正常使用，利用官方镜像做一个指定容器端口的镜像（官方默认为 80 ，一般会被占用），编写 Dockerfile 如下：
```bash
# Use the official image
FROM gitlab/gitlab-ee
# Add listening port of container
EXPOSE 4002
```

### Build Docker

```bash
docker build --tag andylee/gitlab:1.0 . # Execute in the folder where Dockerfile is
```

## Run GitLab Docker

我做了一个`gitlab.sh`脚本来运行 GitLab Docker，如下：
```bash
#!/bin/bash

GITLAB_CONFIG=/home/lee/docker/gitlab/config
GITLAB_LOGS=/home/lee/docker/gitlab/logs
GITLAB_DATA=/home/lee/docker/gitlab/data

docker run -d -p 4043:443 -p 4002:4002 -p 4022:22 --name andylee-gitlab --restart always -v $GITLAB_CONFIG:/etc/gitlab -v $GITLAP_LOGS:/var/log/gitlab -v $GITLAB_DATA:/var/opt/gitlab andylee/gitlab:1.0
```

## Config GitLab
配置 `gitlab.rb`.
```bash
# config/gitlab.rb
# 端口为容器中的端口
external_url 'http://192.168.81.64:4002'  # 如果不配置此项，Clone with HTTP 中的链接将有由容器 ID 代替，如 http://e6012f4a2630/gitlab-instance-de9e956b/monitoring.git

# 不配置如下内容，Clone with SSH 中链接将由容器 ID 代替，如 ssh://git@5ba03b6cd640/root/document.git
gitlab_rails['gitlab_ssh_host'] = '192.168.81.64'
gitlab_rails['gitlab_shell_ssh_port'] = 4022
# gitlab_rails['gitlab_ssh_user'] = 'root' . 可不配置

# LDAP， Config LDAP authentication.

```

## Issues
**问题一：**
```bash 
gitlab Import url is blocked: "Requests to the local network are not allowed"
```
**Solution:**
```bash
Admin -> Settings -> Network -> Outbound Requests -> Allow requests to the local network from hooks and services
```

**问题二：**
```
Cloning into 'document'...
ssh: connect to host 192.168.81.64 port 2202: Connection refused
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
```
**Solution:**
配置的 ssh 访问端口需要与启动容器时的映射端口保持一致，当前问题是由于 `gitlab.rb` 中错把端口配置为了 2202.


# Jenkins

## Jenkins Image
```bash
docker pull jenkins/jenkins

docker ps # Get CONTAINER ID of jenkins
docker commit <CONTAINER ID> andylee/jenkins:1.0
```

## Run Jenkins Docker
我做了一个`jenkins.sh`脚本来运行 Jenkins Docker，如下：
```bash
#!/bin/bash
JENKINS_HOME=/home/lee/docker/jenkins/jenkins_home

docker run --name andylee-jenkins -d -v $JENKINS_HOME:/var/jenkins_home -p 4003:8080 -p 50000:50000 andylee/jenkins:1.0
```
## Config
这里只说一下注意事项和变化点，详细配置方式见[Gitbook + Jenkins + Gitlab 搭建内网自动构建的 Gitbook](http://huaqianlee.github.io/2019/05/05/Git/gitlab-jenkins-gitbook-to-create-LAN-gitbook/)。
1. Configure system -> gitlab, 需要注意`Gitlab host URL`只需要填 server 地址。

2. Configure of project.  
- Build Triggers
```bash
# 选中如下选项
Build when a change is pushed to GitLab. GitLab webhook URL: http://192.168.81.64:4003/project/gitbook
```
- Build->Execute shell
```bash
# 首先需要将容器中的 ~/.ssh/id_rsa.pub 的内容追加到主机的 ～/.ssh/authorized_keys 中，不然会要求输入 ssh 密码。
# 通过 ssh 在主机中执行 gitbook.sh 脚本
ssh -n -l lee 192.168.81.64 "gitbook.sh"
```
> jenkins_home/jobs/gitbook/config.xml: `<command>ssh -n -l lee 192.168.81.64 &quot;gitbook.sh&quot;</command>`

3. 因为新版本的 Jenkins(当前使用的是 2.249) 已经不支持 disable CSRF， 我们必须在 Gitlab project 中的 webhook 配置上用户名，详细见如下问题二。

## Issue
**问题一：**
```bash
An error occurred during installation: No such plugin: cloudbees-folder
```
**Solution:**
```bash
1. modify https as http in /var/lib/docker/volumes/jenkins-data/_data/hudson.model.UpdateCenter.xml 
2. http://localhost:4003/restart OR service jenkins restart
```


**问题二：**
```bash
HTTP ERROR 403 No valid crumb was included in the request
```
**Solution:**
1. 在`Jenkins` 中，通过`USER -> Configure -> API Token` 增加并保存 token 值（api key）。
2. 在 `GitLab project` 的 `Setting ->Webhooks`按照如下要求添加 webhook ，按照要求（此处要注意格式，需要第一步 Jenkins 额外创建一个api key ，让 GitLab 能够有权限触发 Jenkins）
```bash
URL:
http://username:apikey@jenkins.url/project/myPullrequest/

Secret Token: # 似乎不是必须的
apikey

Example:
http://root:1146cb664bbe589fd1a88fe42d24b64315@192.168.81.64:4003/project/gitbook
```

# Nginx

## Nginx Image
```bash
docker pull nginx

docker ps # Get CONTAINER ID of nginx
docker commit <CONTAINER ID> andylee/nginx:1.0
```

## Run Nginx Docker
我做了一个`nginx.sh`脚本来运行 nginx Docker，如下：
```bash
#!/bin/bash

STATIC_HTML=/home/lee/docker/nginx/static_html
# NGINX_CONFIG=/home/lee/docker/nginx/nginx.conf

docker run --name andylee-nginx -p 4001:80 -v $STATIC_HTML:/usr/share/nginx/html:ro -d andylee/nginx:1.0
# docker run --name nginx -p 4001:80 -v $STATIC_HTML:/usr/share/nginx/html:ro -v $NGINX_CONFIG:/etc/nginx/nginx.conf:ro -d nginx
```
