---
title:       "Training Kubernetes"
subtitle:    "Training"
description: "k8s笔记"
date:        2020-05-30
author:      "莫伟伟"
image:       "https://img.moweiwei.com/k8s-bg-gray.png"
tags:
    - kubernetes
    - docker
categories:  [ TECH ]
URL:         "/2020/05/30/"
---

# Training Kubernetes

## 2020.5.30

### 什么是 Linux 容器?

Linux 容器是与系统其他部分隔离开的一系列进程。Linux Container主要由Namespace、Cgroup、UnionFS（联合文件系统）。

1. namespace（命名空间）：命名空间是 Linux 内核一个强大的特性。每个容器都有自己单独的名字空间，运行在其中的应用都像是在独立的操作系统中运行一样。名字空间保证了容器之间彼此互不影响。docker实际上一个进程容器，它通过namespace实现了进程和进程所使用的资源的隔离。使不同的进程之间彼此不可见。

1. cgroup（控制组）：是 Linux 内核的一个特性，主要用来对共享资源进行隔离、限制、审计等。只有能控制分配到容器的资源，才能避免当多个容器同时运行时的对系统资源的竞争。控制组可以提供对容器的内存、CPU、磁盘 IO 等资源的限制和审计管理。

1. UnionFS（联合文件系统）：Union文件系统（UnionFS）是一种分层、轻量级并且高性能的文件系统，它支持对文件系统的修改作为一次提交来一层层的叠加，同时可以将不同目录挂载到同一个虚拟文件系统下(unite several directories into a single virtual filesystem)。Union 文件系统是 Docker 镜像的基础。镜像可以通过分层来进行继承，基于基础镜像（没有父镜像），可以制作各种具体的应用镜像。另外，不同 Docker 容器就可以共享一些基础的文件系统层，同时再加上自己独有的改动层，大大提高了存储的效率。Docker 中使用的 AUFS（AnotherUnionFS）就是一种 Union FS。 AUFS 支持为每一个成员目录（类似 Git 的分支）设定只读（readonly）、读写（readwrite）和写出（whiteout-able）权限, 同时 AUFS 里有一个类似分层的概念, 对只读权限的分支可以逻辑上进行增量地修改(不影响只读部分的)。

![](https://img.moweiwei.com/docker.png)

Linux Container:

![](https://img.moweiwei.com/linux-container.png)

### 容器和虚拟机有何区别？

容器虚拟化的是操作系统而不是硬件，容器之间是共享同一套操作系统资源的。虚拟机技术是虚拟出一套硬件后，在其上运行一个完整操作系统。因此容器的隔离级别会稍低一些。

- 容器，它首先是一个相对独立的运行环境，在这一点类似于虚拟机，但是不像虚拟机那样彻底。
- 容器和虚拟机之间的主要区别在于虚拟化层的位置和操作系统资源的使用方式，虚拟机是硬件虚拟化，容器是操作系统虚拟化。
- vm 多了一层 guest OS，同时 Hypervisor 会对硬件资源进行虚拟化，docker直接使用硬件资源,所以资源利用率比 docker 低。

![](https://img.moweiwei.com/vm-vs-container.jpg)

### 虚拟化是为了解决什么问题？

资源隔离/资源限制

### Docker 和容器技术有什么关系？

当前，docker几乎是容器的代名词，很多人以为docker就是容器。其实，这是错误的认识，除了docker 还有coreos。

### Docker 的架构和概念空间是怎么样的？

![架构](https://img.moweiwei.com/docker-architecture.png)

Docker 三个核心概念：
- Docker 镜像（Images）
- Docker 容器（Container）
- Docker 仓库（Repository）

### 什么是所谓的容器安全技术？

Kata-Container

### Docker 的网络模型

https://docs.docker.com/network/

### Docker 的存储模型

https://docs.docker.com/storage/

### 什么是 K8S？

容器的调度框架

### K8S 解决什么问题？

快速缩放、自愈。

### K8S 不解决什么问题？

用户管理、限流熔断、监控审计

### K8S 的模块结构是什么样的？

![](https://img.moweiwei.com/k8s-architecture.png)

### K8S 有哪些竞品？

OpenShift/VMware/KubeSphere

### 产品会基于 K8S 做哪些改良？

界面/中间件/云支持

### 怎么部署出一个 K8S 集群？

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

### 什么是 Pod？

K8S中创建、部署的最小单元

https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/

***

参考：

- [99cloud/training-kubernets](https://github.com/99cloud/training-kubernetes/blob/master/doc/class-01-Kubernetes-Administration.md)
- https://zhuanlan.zhihu.com/p/38533234