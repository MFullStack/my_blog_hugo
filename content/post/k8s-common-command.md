---
title:       "Kubernetes 常用命令"
subtitle:    "常用命令汇总"
description: "apt-get update -y"
date:        2020-06-05
author:      "莫伟伟"
image:       "https://img.moweiwei.com/k8s-bg-gray.png"
tags:
    - kubernetes
    - command
categories:  [ TECH ]
URL:         "/2020/06/05/k8s-command"
---

# Kubernetes 常用命令

## 2020.5.30

```sh
apt-get update -y

# Install docker
apt-get install docker.io -y
systemctl enable docker
systemctl start docker

# iptables 看到 bridge 流量
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

# Install kubeadm
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get install -y kubelet kubeadm kubectl

# 重启 kubelet
systemctl daemon-reload
systemctl restart kubelet

# 拉起 k8s 群集
kubeadm init --pod-network-cidr 192.168.1.90/16

# 配置 kubectl 客户端
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 添加网络插件
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# 查看 pods 和 nodes 状态
kubectl get pods --all-namespaces
kubectl get nodes


# 起 nginx pod
kubectl apply -f nginx.yaml

# 诊断
kubectl describe pod nginx

# 去污点、允许调度到 master
kubectl taint nodes cka003 node-role.kubernetes.io/master:NoSchedule-

# 查看 pods
kubectl get pods

# 查看容器
docker ps | grep nginx
```
