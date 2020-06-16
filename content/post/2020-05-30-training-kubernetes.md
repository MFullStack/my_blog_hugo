---
title:       "Training Kubernetes"
subtitle:    "Training"
description: "k8s 学习笔记"
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

A级段 192.168.1.1/ 8 表示192.0.0.0-192.255.255.255

对应子网掩码格式 192.168.1.1/ 255.0.0.0

B级段 192.168.1.1/ 16 表示192.168.0.0-192.168.255.255

对应子网掩码格式 192.168.1.1/ 255.255.0.0

C级段 192.168.1.1/ 24 表示192.168.1.0-192.168.1.255

对应子网掩码格式 192.168.1.1/ 255.255.255.0

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

- 原理
- 应用场景

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

自动化编排：自愈，快速缩放，一键部署和升降级，备份恢复

### K8S 不解决什么问题？

- 用户管理
- 限流熔断：istio
- 监控审计：prometheus / grafana / alertmanager / elasticsearch / fluent / kibana
- 用户界面
- 中间件
- 底层云平台支持

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

## 2020.06.06

### 什么是 YAML？

- 写配置文件的语言
- 大小写敏感、缩进表示层级、缩进用空格，不允许tab

[https://www.ruanyifeng.com/blog/2016/07/yaml.html](https://www.ruanyifeng.com/blog/2016/07/yaml.html)

### 什么是 Namespace & Quota？

- 租户隔离
- Quota：为 namespace中运行的 container 的总内存和 cpu 设置配额

```sh
# 创建一个 namespace
kubectl create ns quota-mem-cpu-example

# 为这个 namespace 限定配额
kubectl apply -f https://k8s.io/examples/admin/resource/quota-mem-cpu.yaml -n quota-mem-cpu-example

# 查看配额的详细信息
kubectl get resourcequota mem-cpu-demo -n quota-mem-cpu-example -o yaml

# 创建一个 pod，并限制它的资源使用
kubectl apply -f https://k8s.io/examples/admin/resource/quota-mem-cpu-pod.yaml -n quota-mem-cpu-example

# 确认 pod 已经启动
kubectl get pod quota-mem-cpu-demo -n quota-mem-cpu-example

# 再次查看配额信息，检查已用部分
kubectl get resourcequota mem-cpu-demo -n quota-mem-cpu-example -o yaml

# 尝试启动第二个 pod，因为配额原因，失败
kubectl apply -f https://k8s.io/examples/admin/resource/quota-mem-cpu-pod-2.yaml -n quota-mem-cpu-example

# Error from server (Forbidden): error when creating "examples/admin/resource/quota-mem-cpu-pod-2.yaml":pods "quota-mem-cpu-demo-2" is forbidden: exceeded quota: mem-cpu-demo, requested: requests.memory=700Mi,used: requests.memory=600Mi, limited: requests.memory=1Gi

# 删除命名空间
kubectl delete namespace quota-mem-cpu-example
```

### 什么是 Deployment & ReplicaSet？

#### 1. Deployment

- Deployment: 为 Pod 和 ReplicaSet 提供了声明式更新。
- 一般用来部署 pod

https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

#### ReplicaSet

- 用来维护 Pod 数量，保证指定数量的 Pod 可用

https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/

### 什么是 Services？

- 对外暴露一组 Pod 的抽象方法
- service 为 一组 Pods提供自己的IP地址和一组Pod的单个DNS名称
- 能够在 Pod 之间进行负载均衡
- 服务发现，service 解析是通过 kube-dns 完成

https://kubernetes.io/docs/concepts/services-networking/service/

### DeamonSet & StatefulSet

#### 1. DeamonSet

- DeamonSet 是在每个（或一些） node 上都运行 pod 的副本。
- 典型应用场景：
  - 每个节点上运行集群存储守护程序，例如：glusterd，ceph。
  - 每个节点上都一个日志收集程序，如：fluentd or filebeat。
  - 每个节点上运行一个监控守护进程，如 Prometheus Node Exporter 等

https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/

#### 2. StatefulSet

- StatefulSet 是工作负载 API 对象
- 管理一组Pod的部署和扩展，并保证 pod 顺序和唯一性。

https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/

### 什么是静态 Pod？

- 静态 pod 由节点上的 kubelet daemon 直接管理。
- 静态 pod 始终绑定到特定节点上的kubelet
- API server 可见静态 pod，但是不能控制。

https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/

### 什么是 K8S 的 3A？

API Server是集群网关，是访问及管理资源对象的唯一入口
客户端认证由API Server配置的一到多个认证插件完成(依次调用认证插件，直到其中一个插件可以识别请求者身份为止)

认证过程：客户端 -> API Server -> 认证插件（Authentication） -> 授权插件（Authorization） -> 准入控制插件（AdmissionControl ） -> 写入成功， 即3A认证

### 怎么配置 kubectl？

### K8S 怎么保证网络安全？

### 什么是用户和角色？

- RBAC（Role-Based Access Control， 基于角色的访问可控制）
- 一个角色包含了一套表示一组权限的规则
- 角色可以由命名空间（namespace）内的Role对象定义
- Kubernetes集群范围内有效的角色则通过ClusterRole对象实现

RoleBinding与ClusterRoleBinding：

- 角色绑定将一个角色中定义的各种权限授予一个或者一组用户。
- 角色绑定包含了一组相关主体（即subject, 包括用户——User、用户组——Group、或者服务账户——Service Account）以及对被授予角色的引用。
- 在命名空间中可以通过RoleBinding对象授予权限，而集群范围的权限授予则通过ClusterRoleBinding对象完成。

https://jimmysong.io/kubernetes-handbook/concepts/serviceaccount.html

https://jimmysong.io/kubernetes-handbook/concepts/rbac.html

## 2020.06.13



***

参考：

- [99cloud/training-kubernets](https://github.com/99cloud/training-kubernetes/blob/master/doc/class-01-Kubernetes-Administration.md)
- https://zhuanlan.zhihu.com/p/38533234
- https://cizixs.com/2017/09/25/vxlan-protocol-introduction/
- https://www.jianshu.com/p/c937278418f9
- https://pdf.us/2019/03/21/3061.html