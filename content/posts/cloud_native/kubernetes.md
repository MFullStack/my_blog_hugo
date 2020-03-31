---
title: "课时 3 - Kubernetes 核心概念"
date: 2019-09-04T09:20:20+08:00
hidden: false
draft: false
tags: [kubernetes , docker]
keywords: []
categories: [云原生笔记]
description: ""
---

## 什么是 Kubernetes

自动化的容器编排平台

- 部署
- 弹性
- 管理

核心功能：

- 服务的发现与负载均衡
- 容器的自动装箱
- 存储的编排
- 自动容器恢复
- 自动发布与回滚
- 配置与密文的管理
- 批量执行
- 水平伸缩

## Kubernetes 的架构

- 典型的二层架构 Server-Client 架构

![k8s](/img/cloud_native/kubernetes/k8s_structure.png)

UI 和 CLI 命令只会与 Master 进行连接，Master 下发给 Node 节点。

- Master 包含 4 个主要的组件：
  - API Server :k8s 中所有的组件都与 API Server 进行连接，组件与组件之间一般不进行独立连接
  - Controller: 对集群状态进行管理，如自动修复、自动水平扩张
  - Scheduler: 完成调度操作
  - etcd: 分布式存储系统，API Server 需要的元信息放在 etcd 中。etcd 本身也是一个高可用系统，通过 etcd 保证整个 Master 组件的高可用性

![master](/img/cloud_native/kubernetes/master.png)

- Node:包含 kubelet、Container Runtime、Storage Plugin、 Network Plugin、kube-proxy 几个主要组件
  - Node 是真正运行业务负载的,每个业务负载以 pod 形式运行，一个 pod 中运行一个或多个容器
  - 真正运行 pod 的组件是 Kubelet，通过 API Server 接收到 pod 运行的状态，然后提交到 Container Runtime 组件中，在 OS 装创建 pod 运行环境，将 pod 运行起来
  - pod 也需要对存储和网络进行管理，通过 Storage Plugin 和 Network Plugin 进行操作
  - Kube-proxy 是完成 Service 组网的组件

![master](/img/cloud_native/kubernetes/node.png)

## pod 调度过程中组件如何进行交互例子

![master](/img/cloud_native/kubernetes/pod_progress.png)

![master](/img/test/logo.png)
![master](/img/test/logo2.png)

