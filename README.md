## Prometheus实践之路

Prometheus实践之路

### 全书组织

我们假定你已经对Linux系统以及Docker技术有一定的基本认识，也可能使用过像Java，Golang这样的编程语言，所以我们不会像对任何一个没有任何基础的初学者那样事无巨细的讲述所有事。

第1章，是Prometheus基础的综述，通过一个简单的（使用Prometheus采集主机的监控数据）例子来了解Prometheus是什么？能做什么？以及Prometheus的基础架构。希望读者能从这一章中能对Promentheus有一个基本的理解和认识。

第2章中我们先讲述Prometheus的数据模型以及，以及时间序列存储方式。并且利用Prometheus的数据查询语言(Prometheus Query Language)对监控数据进行查询，聚合以及计算等。

第3章，我们重点放在监控告警部分，作为监控系统的重要能力之一，我们需要及时了解系统环境的变化，因此这一章，我们会介绍如何在Prometheus中定义告警规则，并且结合Prometheus中的另外一个重要组件AlertManager来对告警进行处理。

第4章，"You can't fix what you can't see"我们讨论可视化，如何基于Grafana这一可视化工具自定义我们的可视化仪表盘，介绍Grafana作为一个通用的可视化工具是如何与Prometheus进行配合。

可以看出，从第1章到第4章的部分是基础性的，读者通过前5章对于大部分的研发或者运维人员能够很快的掌握，并且能够使用Prometheus来完成一些基本的日常任务。余下的章节我们会关注到Prometheus的高级用法部分。

第5章，我们会介绍一些常用的Prometheus Exporter的使用场景以及用法。最本章的最后部分我们会带领读者通过Java和Golang实现我们的Exporter,以及如何在现有应用系统上添加Prometheus支持，从而实现应用层面的监控对接。

第6章，我们会了解如何通过Prometheus的服务发现能力，实现动态监控。特别是在云平台或者容器平台中，资源的创建和销毁成本变得如此的低的情况下，通过服务发现如何自动化的去动态发现监控目标,能够充分简化Prometheus的运维和管理难度。

第7章，Prometheus在单个节点的情况下能够轻松完成对N级别资源的监控，但是监控的目标资源以及数据量变得更大的时候，我们如何实现对Prometheus的扩展。这一章节我们重点在Prometheus的数据管理和高可用方面。

第8章，这一章节中我们的另外一位重要成员Kubernetes将会登场，这里我们会带领读者对Kubernetes有一个基本的认识，并且通过Prometheus构建我们的容器云监控系统。并且介绍如何通过Prometheus与Kubernetes结合实现应用程序的弹性伸缩。

### 目录结构

```
book
 |- CHANGELOGS.md 版本更新历史
 |- SUMMARY.md 目录
 |- chapter[n] 章节
    |- static/ 静态文件资源
    |- README.md 章节头
    |- SUMMARY.md 章节尾
```

### 本地预览

```
npm install
```

Start Local Preview

```
npm run start
```