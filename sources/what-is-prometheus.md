# Prometheus来了

Prometheus受启发于Google的Brogmon监控系统（相似的Kubernetes是从Brog演变而来）。从2012年开始由前Google工程师在Soundcloud以开源软件的形式进行研发，并且于2015年早期对外发布早期版本。2016年5月正式成为继Kubernetes之后的第二个正式加入CNCF基金会的项目，同年6月正式发布1.0版本。2017年底发布了基于全新存储层的2.0版本，能更好与容器平台，云平台配合。

![](http://p2n2em8ut.bkt.clouddn.com/prometheus-release-roadmaps.png)

目前已经有超过650+位贡献者参与到Prometheus的研发工作上，并且超过120+项的第三方集成。

## Prometheus是什么？

* 一个时序数据库

首先Prometheus是一个基于时间序列(time-searies)的数据库系统。Prometheus与其他主流的监控系统都采用了基于时间序列的方式对数据进行存储。其他典型的时序数据库诸如(OpenTsdb, Influxdb等等)。相比于其他的时序数据库，Prometheus中存储时间序列标示包含一个度量名称(Metric)以及多个的键值对(Label)进行标示（例如api_http_requests_total{method=”POST”, handler=”/messages”})。因此可以基于多种维度实现对监控数据的聚合。

Promtheus用一种高效的自定义格式存储时间序列，并且将数据存储在内存和本地磁盘上。
因此如果希望对Prometheus进行扩展，需要通过功能分片或者联邦集群实现。关于如果实现Prometheus扩展的部分我们会在第四章进行讨论。

* 一个数据查询引擎

Prometheus提供了灵活高效的数据查询系统，通过Promethues自定义的数据查询语言，可以对数据进行查询和聚合，实现各种报表和数据分析。

关于使用Prometheus进行数据聚合分析的部分我们会在第二章节进行讨论。

* 一个监控告警预警平台

Prometheus支持用户创建基于Prometheus的自定义查询语言，定义告警。并且结合AlertManager组件实现件监控告警，可以与第三方工具和平台进行集成。

* 一个开放的监控框架

社区同时提供了大量的第三方Exporter。 可以快速实现对诸如服务器，容器，中间件的监控指标采集。
Prometheus同时提供超过10中以上的客户端SDK，基于这些客户端SDK，我们可以轻松实现我们自己的Exporter或者直接在我们的应用程序上集成Prometheus。

## Prometheus的核心优势

### 完整的监控支持

Prometheus作为系统监控方案(不同于APM)，提供了完整的监控支持，包括但不限于：基础设施监控，中间件监控，应用监控;

提供了完整的可视化，以及告警支持，并且易于集成，任何企业，组织，个人实现个性化的需求。

## 强大的数据模型

所有的监控指标数据都是基于标签的多维度数据。基于这些维度我们可以方便的对监控数据进行聚合，过滤，裁剪。并且这些数据均以时间序列的形式存储在本地磁盘中。

### 强大的查询语言

通过Prometheus提供的自定义查询语言PromQL,我们可以直接对基于时间序列的数据进行数学运算(加，减，乘，除)，聚合并立即得到结果。基于这些运算结果我们可以方便的绘制出需要的可视化图标。

例如，通过PromQL我们可以回答类似于以下问题：

* 在过去一段时间95%的应用延迟的分布范围？
* 在4小时候，磁盘空间占用大致会是什么情况？
* CPU占用率前5的服务有哪些？

### 易于管理

Prometheus核心部分只有一个单独的二进制文件。不存在任何的第三方依赖(数据库，缓存等等)。唯一需要的就是本地磁盘，因此不会潜在级联故障的风险。

同时Prometheus基于Pull模型，因此可以在任何地方（本地电脑，开发环境，测试环境）搭建我们的监控系统。

对于一些复杂的情况下，我们可以基于服务发现(Service Discovery)用于动态发现监控目标。

### 高效

监控意味着大量的数据的产生。而Prometheus可以高效的处理这些数据，对于单独的一台服务器，可以处理：

* 数以百万的监控指标
* 每秒处理数十万的数据点。

### 可扩展

Prometheus是如此简单，因此你可以在每个数据中心，每个团队运行度量的Prometheus Sevrer.

而对于联邦集群的支持，可以让Prometheus从其他Prometheus Server拉取监控指标样本。

因此当对于单台Prometheus Server来说监控的任务量过大时，我们可以使用功能分区(sharding)+联邦集群(federation)来进行扩展。

### 易于集成

使用Prometheus我们可以快速搭建我们的监控服务，并且可以非常方便的在我们的应用程序中进行集成，目前支持： Java, JMX, Python, Go,Ruby, .Net， Node.js等等语言的客户端SDK，基于这些SDK我们可以快速让我们的应用程序纳入到Prometheus的监控当中，或者开发我们自己的监控数据收集程序。同时这些客户端收集的监控数据，不仅仅支持Prometheus本省，还能支持Graphite这些其他的监控工具。

同时Prometheus还支持与其他的监控系统进行集成：Graphite， Statsd, Collected, Scollector, muini, Nagios等。

同时Prometheus还存在官方的第三方实现的监控数据采集支持：JMX, CloudWatch, EC2, MySQL, PostgresSQL, Haskell, Bash, SNMP, Consul, Haproxy, Mesos, Bind, CouchDB, Diango, Memcached, RabbitMQ, Redis, RethinkDB, Rsyslog等等。

### 可视化

Prometheus Server中自带了一个Prometheus UI，通过这个UI我们可以方便的直接对数据进行查询，并且可以直接以图的形式展示数据。同时Prometheus还提供了一个独立的基于Ruby On Rails的Dashboard解决方案Promdash。最新的Grafana可视化工具也已经提供了完整的Prometheus支持，可以基于Grafana可以创建更加精美的监控图标。基于Prometheus提供的API我们还可以实现我们自己的监控可视化UI。

### 开放性

通常来说当一个应用程序需要被监控时，通常也会被受限与需要支持的监控系统。因此对于决策者而言，要不你就直接在应用中集成该监控系统的支持，要不就在外部创建单独的服务来适配不同的监控系统。

而对于Prometheus来说，使用Prometheus的client library的输出格式不止支持Prometheus的格式化数据，也可以输出支持其它监控系统的格式化数据，比如Graphite等。

因此你甚至可以在不适用Prometheus的情况下，采用Prometheus的client library来让你的应用程序支持监控数据采集。