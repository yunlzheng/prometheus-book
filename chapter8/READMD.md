# 第8章 Kubernetes监控实战

Kubenetes是一款由Google开发的开源的容器编排工具，在Google已经使用超过15年。作为容器领域事实的标准，我们将利用Prometheus以及在前面学习的知识简历一套完整的Kubernetes容器集群监控系统。 

本章的主要内容：

* 理解Kubernetes的工作机制
* Promtheus在Kubernetes下的服务发现机制
* 使用Prometheus监控基础设施
* 使用Prometheus监控Kubernetes集群状态
* 使用Prometheus监控应用容器
* 如果通过Operator高效管理部署在Kubernetes集群中的Prometheus