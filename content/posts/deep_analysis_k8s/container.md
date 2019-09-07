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

