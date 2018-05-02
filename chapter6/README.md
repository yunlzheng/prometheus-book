# 第7章 Prometheus服务发现

在前6个章节中，我们主要介绍了Prometheus自身的一些特性，包括高效的数据能力、灵活的查询语言PromQL、Prometheus的告警模式、Exporter的使用、以及自身的高可用等。但是似乎这里总感觉缺少了什么。云原生，Prometheus是如何成为云原生应用以及容器生态中监控场景加几乎事实标准的？这一章节，将介绍Promtheus是在云原生、容器等场景是如何展现出它的与众不同的。

本章的主要内容：
* 云原生、容器场景下监控的挑战
* Prometheus服务发现的实现机制
* Prometheus中服务发现的几种实现方式
* Prometheus中强大的Relabel机制