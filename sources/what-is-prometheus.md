## Prometheus是什么？

### Prometheus的前世今生

Prometheus是SoundCloud开源的监控与时序数据存储平台，专注于系统监控领域，并且从一开始就围绕云进行设计，特别适合与在云环境下动态的环境进行监控。最早由SoundCloud在2012年开始开发，由于大量组织的采用。在2015年正式以独立项目Prometheus的形式对外发布。2016年5月正式加入CNCF基金会，成为即Kubernetes后的第二个CNCF项目。 2016七月正式发布Prometheus1.0版本。在1.0版本正式发布之后，社区则将主要精力投入到2.0版本的开发中，并且在2017年底正式发布了2.0预览版，并且通过重新设计的存储层，能更好的与容器平台，云平台进行配合。

![](http://p2n2em8ut.bkt.clouddn.com/prometheus-release-roadmaps.png)

由于其从推出就提供了完整的基于容器的部署方式，开发者可以快速的基于容器搭建自己的监控平台。因此在Docker社区迅速聚集了大量的人气。

自2012起，有越来越多的组织加入到了Promethues的社区当中，并且有众多的开发者加入并为Prometheus贡献代码。2016年Prometheus正式加入CNCF基金会(Cloud Native Computing Foundation)，成为即Kubernetes之后的第二个顶级项目。

### Prometheus核心能力

Prometheus专注于系统监控领域，并且特别适用于在云以及容器平台下的监控需求。并且提供了下面的几个主要能力：

* 一个时序数据库

首先Prometheus是一个基于时间序列(time-searies)的数据库系统。Prometheus与其他主流的监控系统都采用了基于时间序列的方式对数据进行存储。其他典型的时序数据库诸如(OpenTsdb, Influxdb等等)。相比于其他的时序数据库，Prometheus中存储时间序列标示包含一个度量名称(Metric)以及多个的键值对(Label)进行标示（例如api_http_requests_total{method=”POST”, handler=”/messages”})。因此可以基于多种维度实现对监控数据的聚合。

Promtheus用一种高效的自定义格式存储时间序列，并且将数据存储在内存和本地磁盘上。
因此如果希望对Prometheus进行扩展，需要通过功能分片或者联邦集群实现。关于如果实现Prometheus扩展的部分我们会在第四章进行讨论。

* 一个数据查询引擎

Prometheus提供了灵活高效的数据查询系统，通过Promethues自定义的数据查询语言，可以对数据进行查询和聚合，实现各种报表和数据分析。

关于使用Prometheus进行数据聚合分析的部分我们会在第二章节进行讨论。

* 一个监控告警平台

Prometheus支持用户创建基于Prometheus的自定义查询语言，定义告警。并且结合AlertManager组件实现件监控告警，可以与第三方工具和平台进行集成。

* 一个监控框架

社区同时提供了大量的第三方Exporter。 可以快速实现对诸如服务器，容器，中间件的监控指标采集。
Prometheus同时提供超过10中以上的客户端SDK，基于这些客户端SDK，我们可以轻松实现我们自己的Exporter或者直接在我们的应用程序上集成Prometheus。