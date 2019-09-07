---
title: "课时 2 - Docker"
date: 2019-09-07T13:46:19+08:00
hidden: false
draft: false
tags: [docker , container]
keywords: []
categories: [云原生笔记]
description: ""
---

## 什么是容器

<div align="center">
  <img src="/img/cloud_native/docker/container.png" width="200" height="100">
</div>

容器，是一个视图隔离、资源可限制、独立的文件系统的进程的集合。

- 资源视图隔离-namespace   --如能看见部分进程：独立的主机名等
- 控制资源使用率-cgroup --2G 内存；CPU 个数
- 独立的文件系统-chroot

## 什么是镜像

运行容器所需要的所有文件集合-容器镜像。Build once, Run anywhere

- Dockfile-描述镜像构建步骤
- 构建步骤所产出文件系统的变化-changeset
- changeset 带来分层和复用
- 提高分发效率，减少磁盘压力。

## 如何构建镜像

    # base on golang:1.12-alpine image
    FROM golang:1.12-aalpine

    # setting current working dir (PWD -> /go/src/app)
    WORKDIR /go/src/app

    # copy local files into /go/src/app
    COPY . .

    # get all the depencencies
    RUN go get -d -v ./..

    # build the application and install it
    RUN go install -v ./..

    # by default, run the app
    CMD ["app]

    docker build . -t app:v1

docker registry - 镜像数据的存储和分发

    docker push app:v1

## 如何运行容器

1. 从 docker registry 下载镜像-docker pull busybox:1.25
1. docker images
1. 选择相应的镜像并运行-docker run [-d] -name demo busybox:1.25

<div align="center">
  <img src="/img/cloud_native/docker/docker_register.png" width="300">
</div>

## 容器运行时的生命周期

单进程模型

- Init 进程生命周期 == 容器生命周期
- 运行区间可运行 -- exec 执行运维操作

数据持久化

- 数据独立于容器的生命周期
- 数据卷--docker colume vs bind

<div align="center">
  <img src="/img/cloud_native/docker/container_volume.png" width="450">
</div>

## 容器项目架构介绍

<div align="center">
  <img src="/img/cloud_native/docker/moby.png">
</div>

<div align="center">
  <img src="/img/cloud_native/docker/container_vm.png">
</div>
