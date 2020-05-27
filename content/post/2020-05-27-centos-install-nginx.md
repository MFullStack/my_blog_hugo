---
title:       "CentOS Install Nginx"
subtitle:    "centos7"
description: ""
date:        2020-05-26
author:      "莫伟伟"
image:       "http://img.moweiwei.com/Bangkok15.jpg"
tags:
    - nginx
categories:  [ TECH ]
---

## CentOS Install Nginx

1、EPEL 仓库中有 Nginx 的安装包。如果你还没有安装过 EPEL，可以通过运行下面的命令来完成安装:

```sh
sudo yum install epel-release
```

2、安装 Nginx

```
sudo yum install nginx
```

3、设置 Nginx 开机启动

```
sudo systemctl enable nginx
```

4、启动 Nginx：

```
sudo systemctl start nginx
```

5、检查 Nginx 的运行状态

```
sudo systemctl status nginx
```

6、验证 Nginx 是否成功启动，可以在浏览器中打开 <code>http://YOUR_IP</code>，您将看到默认的 Nginx 欢迎页面

## 通过 systemctl 管理 Nginx

启动 Nginx

```
sudo systemctl start nginx
```

停止 Nginx

```
sudo systemctl stop nginx
```

重启 Nginx

```
sudo systemctl restart nginx
```

修改 Nginx 配置后，重新加载

```
sudo systemctl reload nginx
```

设置开机启动 Nginx

```
sudo systemctl enable nginx
```

关闭开机启动 Nginx

```
sudo systemctl disable nginx
```
