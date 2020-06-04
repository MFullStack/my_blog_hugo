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
URL:         "/2020/05/30/training-k8s"
---

# Training Kubernetes

## 基本技能

- vim基础操作--编辑、修改、保存文件
- 网络基础知识--网段cidr、vlan、vxlan、配置linux网卡等等
- 基础的linux知识--权限、文件系统、服务
- systemd的基础操作--重启、关闭、启动、重载、查看system的服务

***

### 1. 网段 cidr

A级段 192.168.1.1/8 表示192.0.0.0-192.255.255.255

对应子网掩码格式 192.168.1.1/255.0.0.0

B级段 192.168.1.1/16 表示192.168.0.0-192.168.255.255

对应子网掩码格式 192.168.1.1/255.255.0.0

C级段 192.168.1.1/24 表示192.168.1.0-192.168.1.255

对应子网掩码格式 192.168.1.1/255.255.255.0

### 2. vlan

- Virtual local area network， 虚拟局域网
- VLAN的作用，主要是将一个大的广播域隔离开来，形成对个小的广播域，各个广播域内可以互通，广播域之间默认不能直接通讯。

### 3. vxlan

- Virtual eXtensible Local Area Network，虚拟可扩展的局域网
- 它是一种 overlay 技术，通过三层的网络来搭建虚拟的二层网络。
- vxlan 解决的问题：
  - 虚拟化（虚拟机和容器）的兴起使得一个数据中心会有成千上万的机器需要通信，而传统的 VLAN 技术只能支持 4096 个网络上限，已经满足不了不断扩展的数据中心规模
  - 越来越多的数据中心（尤其是公有云服务）需要提供多租户的功能，不同用户之间需要独立地分配 ip 和 MAC 地址，如何保证这个功能的扩展性和正确性也是一个待解决的问题
  - 云计算业务对业务灵活性要求很高，虚拟机可能会大规模迁移，并保证网络一直可用，也就是大二层的概念。解决这个问题同时保证二层的广播域不会过分扩大，也是云计算网络的要求

### 4. 配置linux网卡

- 打开网卡配置文件(centos7.4)

```sh
vim /etc/sysconfig/network-scripts/ifcfg-ens34
```

- 配置文件

```sh
TYPE=Ethernet    # 网卡类型：为以太网
PROXY_METHOD=none    # 代理方式：关闭状态
BROWSER_ONLY=no      # 只是浏览器：否
BOOTPROTO=dhcp  #设置网卡获得ip地址的方式，可能的选项为static(静态)，dhcp(dhcp协议)或bootp(bootp协议).
DEFROUTE=yes        # 默认路由：是, 不明白的可以百度关键词 `默认路由`
IPV4_FAILURE_FATAL=no     # 是不开启IPV4致命错误检测：否
IPV6INIT=yes         # IPV6是否自动初始化: 是[不会有任何影响, 现在还没用到IPV6]
IPV6_AUTOCONF=yes    # IPV6是否自动配置：是[不会有任何影响, 现在还没用到IPV6]
IPV6_DEFROUTE=yes     # IPV6是否可以为默认路由：是[不会有任何影响, 现在还没用到IPV6]
IPV6_FAILURE_FATAL=no     # 是不开启IPV6致命错误检测：否
IPV6_ADDR_GEN_MODE=stable-privacy   # IPV6地址生成模型：stable-privacy [这只一种生成IPV6的策略]
NAME=ens34     # 网卡物理设备名称
UUID=8c75c2ba-d363-46d7-9a17-6719934267b7   # 通用唯一识别码，没事不要动它，否则你会后悔的。。
DEVICE=ens34   # 网卡设备名称, 必须和 `NAME` 值一样
ONBOOT=no #系统启动时是否设置此网络接口，设置为yes时，系统启动时激活此设备
IPADDR=192.168.103.203   #网卡对应的ip地址
PREFIX=24             # 子网 24就是255.255.255.0
GATEWAY=192.168.103.1    #网关
DNS1=114.114.114.114        # dns
HWADDR=78:2B:CB:57:28:E5  # mac地址
```

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
- https://cizixs.com/2017/09/25/vxlan-protocol-introduction/
- https://www.jianshu.com/p/c937278418f9