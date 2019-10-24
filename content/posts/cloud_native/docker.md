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

## 一 、什么是容器

<div align="center">
  <img src="/img/cloud_native/docker/container.png" width="200" height="100">
</div>

容器，是一个视图隔离、资源可限制、独立的文件系统的进程的集合。

- 资源视图隔离-namespace   --如能看见部分进程：独立的主机名等
- 控制资源使用率-cgroup --2G 内存；CPU 个数
- 独立的文件系统-chroot

## 二、什么是镜像

运行容器所需要的所有文件集合-容器镜像。Build once, Run anywhere

- Dockfile-描述镜像构建步骤
- 构建步骤所产出文件系统的变化-changeset
- changeset 带来分层和复用
- 提高分发效率，减少磁盘压力。

## 三、如何构建镜像

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

## 四、如何运行容器

1. 从 docker registry 下载镜像-docker pull busybox:1.25
1. docker images
1. 选择相应的镜像并运行-docker run [-d] -name demo busybox:1.25

<div align="center">
  <img src="/img/cloud_native/docker/docker_register.png" width="300">
</div>

## 五、容器运行时的生命周期

单进程模型

- Init 进程生命周期 == 容器生命周期
- 运行区间可运行 -- exec 执行运维操作

数据持久化

- 数据独立于容器的生命周期
- 数据卷--docker colume vs bind

<div align="center">
  <img src="/img/cloud_native/docker/container_volume.png" width="450">
</div>

## 六、容器项目架构介绍

### moby 容器引擎架构

<div align="center">
  <img src="/img/cloud_native/docker/moby.png">
</div>

moby 是目前最流行的容器管理引擎，moby daemon 会对上提供有关于容器、镜像、网络以及 Volume的管理。moby daemon 所依赖的最重要的组件就是 containerd，containerd 是一个容器运行时管理引擎，其独立于 moby daemon ，可以对上提供容器、镜像的相关管理。

containerd 底层有 containerd shim 模块，其类似于一个守护进程，这样设计的原因有几点：

- 首先，containerd 需要管理容器生命周期，而容器可能是由不同的容器运行时所创建出来的，因此需要提供一个灵活的插件化管理。而 shim 就是针对于不同的容器运行时所开发的，这样就能够从 containerd 中脱离出来，通过插件的形式进行管理。
- 其次，因为 shim 插件化的实现，使其能够被 containerd 动态接管。如果不具备这样的能力，当 moby daemon 或者 containerd daemon 意外退出的时候，容器就没人管理了，那么它也会随之消失、退出，这样就会影响到应用的运行。
- 最后，因为随时可能会对 moby 或者 containerd 进行升级，如果不提供 shim 机制，那么就无法做到原地升级，也无法做到不影响业务的升级，因此 containerd shim 非常重要，它实现了动态接管的能力。

### 容器 VS VM

VM 利用 Hypervisor 虚拟化技术来模拟 CPU、内存等硬件资源，这样就可以在宿主机上建立一个 Guest OS，这是常说的安装一个虚拟机。

每一个 Guest OS 都有一个独立的内核，比如 Ubuntu、CentOS 甚至是 Windows 等，在这样的 Guest OS 之下，每个应用都是相互独立的，VM 可以提供一个更好的隔离效果。但这样的隔离效果需要付出一定的代价，因为需要把一部分的计算资源交给虚拟化，这样就很难充分利用现有的计算资源，并且每个 Guest OS 都需要占用大量的磁盘空间，比如 Windows 操作系统的安装需要 10~30G 的磁盘空间，Ubuntu 也需要 5~6G，同时这样的方式启动很慢。正是因为虚拟机技术的缺点，催生出了容器技术。

容器是针对于进程而言的，因此无需 Guest OS，只需要一个独立的文件系统提供其所需要文件集合即可。所有的文件隔离都是进程级别的，因此启动时间快于 VM，并且所需的磁盘空间也小于 VM。当然了，进程级别的隔离并没有想象中的那么好，隔离效果相比 VM 要差很多。

总体而言，容器和 VM 相比，各有优劣，因此容器技术也在向着强隔离方向发展。

<div align="center">
  <img src="/img/cloud_native/docker/container_vm.png">
</div>

<div align="center">
  <img src="/img/cloud_native/docker/logo.png">
</div>