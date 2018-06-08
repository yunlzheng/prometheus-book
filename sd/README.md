# 第7章 Prometheus服务发现

在前6个章节中，我们主要介绍了Prometheus自身的一些特性，包括高效的数据能力、灵活的查询语言PromQL、Prometheus的告警模式、Exporter的使用、以及自身的高可用等。而作为下一代监控系统的首选解决方案，Prometheus对云以及容器环境下的监控场景提供了完善的支持。本章中将介绍Prometheus是如何通过服务发现机制完美解决云原生场景下的监控挑战的。

本章的主要内容：

* 云原生、容器场景下监控的挑战；
* Prometheus服务发现的实现机制；
* Prometheus中服务发现的几种实现方式；
* Prometheus中强大的Relabel机制。