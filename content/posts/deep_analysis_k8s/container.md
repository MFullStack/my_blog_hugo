---
title: "Container"
date: 2019-09-07T21:19:27+08:00
hidden: false
draft: false
tags: []
keywords: []
categories: [深入剖析Kubernetes笔记]
description: ""
---

# 容器技术

## 一、进程

容器技术的核心功能，就是通过约束和修改进程的动态表现，从而其创造出一个“边界”。

**Cgroups 技术**是制造约束的主要手段

**Namespace 技术**是用来修改进程视图的主要方法

Namespace 进程机制：这种机制，就是对被隔离应用的进程克难攻坚做手脚，使这些进程只能看到被重新计算过的进程编号，如 PID=1。实际上在宿主机里还是原来的进程号。

除了 PID Namespace，Linux 系统还有 Mount、UTS、IPC、Network 和 User 等 Namespace，用来对不同进程上下文进行“障眼法”操作。

- Mount Namespace，让被隔离进程只能看到当前 Namespace 里的挂载点信息
- Network Namespace，用于让被隔离进程看到当前 Namespace 里的网络设备和配置

**这，就是 Linux 容器基本实现原理。**

Docker 容器：就是创建容器进程时，指定这个进程需要启用的 Namespace 参数。

**所以，容器，其实是一种特殊的进程。**

## 二、隔离和限制

优点与不足：

- “敏捷”和“高性能”是容器相比较于虚拟机的最大优势。
- Namespace 隔离机制不足之处就是：隔离得不彻底。

多个容器之间使用的还是同一个宿主机的操作系统内核。有的资源和对象不能被Namespace 化，如：时间。

虽然 Namespace 隔离后，只能看到容器里的情况，但是宿主机上，该进程与其他进程是平等竞争关系，资源可能被其他进程抢占。

**Linux Ggroups（Linux Control Group）是 Linux 内核中用来为进程设置资源限制的一个重要功能。**

Cgroups 作用：限制一个进程组能够使用的资源上线，包括 CPU、内存、磁盘、网络带宽等。

总结：一个运行的 Docker 容器，就是一个启用了多个 Linux Namespace 的应用进程，这个进程能够使用的资源量，受 Cgroups 配置的限制。

- 容器是一个“单进程”模型
- 一个容器本质就是一个进程
- 用户的应用进程实际上就是容器里 PID=1 的进程

## 三、容器镜像

Mount Namespace 修改的，是容器进程对文件系统“挂载点”的认知。只有挂载（mount）操作发生后，进程的视图才会改变，在此之前，容器会直接继承宿主机的各个挂载点。

容器镜像：挂载在容器根目录上，用来为容器提供隔离后执行环境的文件系统，叫 rootfs（根文件系统）。包括/bin, /etc, /proc等

创建容器实际上是：

1. 启用 Linux Namespace 配置
1. 设置指定的 Cgroups参数
1. 切换进程的根目录（Change Root）

Docker 镜像设计中，引入层的概念，用户制作镜像时每一步操作，生成一个层，**也就是是一个增量 rootfs**

**联合文件系统（Union File System）：** 将不同位置的目录联合挂载（union mount）到同一个目录下。

Example：

    docker run -d ubuntu:latest sleep 3600

拉下来的 Ubuntu 镜像，就是一个 ubuntu 操作系统的 rootfs，它的内容是 Ubuntu 操作系统的所有文件和目录。

Docker 使用的 rootfs 往往由多个“层”组成。

    docker image inspect ubuntu:latest
    ...
     "RootFS": {
      "Type": "layers",
      "Layers": [
        "sha256:f49017d4d5ce9c0f544c...",
        "sha256:8f2b771487e9d6354080...",
        "sha256:ccd4d61916aaa2159429...",
        "sha256:c01d74f99de40e097c73...",
        "sha256:268a067217b5fe78e000..."
      ]
    }

该镜像五层，就是五个增量 rootfs，每层都是ubuntu 操作系统文件与目录的一部分，使用镜像时，Docker 会把这些增量联合挂载在一个统一的挂载点。

<div align="center">
  <img src="/img/deep_analysis/image_layer.png" width="500">
</div>

1. 只读层：容器 rootfs 最下五层，挂载方式是只读（readOnly+whiteout）
1. 读写层：容器 rootfs 最上一层，挂载方式rw（read write）
1. init 层：在只读层和读写层之间，init 层是 Docker 项目单独生成的一个内部层，专门用来存放 /etc/hosts 等信息。


