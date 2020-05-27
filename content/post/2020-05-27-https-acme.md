---
title:       "给博客添加 https 证书并自动更新"
subtitle:    "let's encrypt 和 acme.sh"
description: "acme.sh 实现了 acme 协议, 可以从 letsencrypt 生成免费的证书."
date:        2020-05-27
author:      "莫伟伟"
image:       "http://img.moweiwei.com/Bangkok9.jpg"
tags:
    - https
categories:  [ TECH ]
---

# 给博客添加 https 证书并自动更新

[acme.sh](https://github.com/acmesh-official/acme.sh/wiki/%E8%AF%B4%E6%98%8E) 实现了 acme 协议, 可以从 letsencrypt 生成免费的证书. 我的博客使用的是 nginx 服务器。其他参考 acme.sh.

## 1. 安装 acme.sh

````sh
curl  https://get.acme.sh | sh
````

出现 <code>Install success!</code> 即安装成功。

创建 bash 的 alias：

```sh
alias acme.sh=~/.acme.sh/acme.sh
```

## 2. 生成证书

只需要指定域名, 并指定域名所在的网站根目录. 我的域名是<code>moweiwei.com</code>. <code>/usr/share/nginx/html</code> 是我放博客的 nginx 目录。

````sh
acme.sh  --issue  -d moweiwei.com -d www.moweiwei.com  --webroot /usr/share/nginx/html
````

出现如下信息即生成证书成功：

```sh
[2020年 05月 27日 星期三 09:13:16 CST] Your cert is in  /root/.acme.sh/moweiwei.com/moweiwei.com.cer
[2020年 05月 27日 星期三 09:13:16 CST] Your cert key is in  /root/.acme.sh/moweiwei.com/moweiwei.com.key
[2020年 05月 27日 星期三 09:13:16 CST] The intermediate CA cert is in  /root/.acme.sh/moweiwei.com/ca.cer
[2020年 05月 27日 星期三 09:13:16 CST] And the full chain certs is there:  /root/.acme.sh/moweiwei.com/fullchain.cer
```

## 3. Copy 证书

默认生成的证书都放在安装目录下: ~/.acme.sh/. 不直接使用该处的证书。详情参考 acme.sh. Copy到其他目录使用，新建目录: <code>/data/nginx/ssl</code>。

```sh
acme.sh --installcert -d moweiwei.com \
    --keypath       /data/nginx/ssl/moweiwei.com.key  \
    --fullchainpath /data/nginx/ssl/moweiwei.com.key.pem \
    --reloadcmd     "service nginx force-reload"
```

出现 <code>Reload success</code> 等信息即拷贝成功。后续无需操作，证书自动更新。

## 4. 开启 acme.sh 自动升级

```sh
acme.sh  --upgrade  --auto-upgrade
```

## 5. 配置 nginx

修改 <code>/etc/nginx/nginx.conf</code> nginx配置如下，添加443端口监听和 ssl信息，之前生成的证书，80端口添加重定向到 https。

```sh
server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  moweiwei.com;
        root         /usr/share/nginx/html;
        return 301 https://$server_name$request_uri;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
server {
        listen       443 ssl http2 default_server;
        listen       [::]:443 ssl http2 default_server;
        server_name  moweiwei.com;
        root         /usr/share/nginx/html;

        ssl_certificate /data/nginx/ssl/moweiwei.com.key.pem;
        ssl_certificate_key /data/nginx/ssl/moweiwei.com.key;
        ssl_session_cache shared:SSL:1m;
        ssl_session_timeout  10m;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
                location = /50x.html {
        }
    }
```

## 重启 nginx

重启后，博客即可以 https 访问。

```sh
service nginx force-reload
```
