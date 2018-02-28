# Prometheus的崛起

> TODO: 感觉Prometheus是什么与核心优势内容显得有点重复，考虑重新组织一下。

## 为什么需要监控

一般来说对于一个组织而言，引入监控系统一般都是为了解决以下几个主要问题：

* 组织需要了解系统在什么时候发生了异常，当发生异常的时候可以及时进行处理，避免产生业务层面的影响，或者提前处理预防问题的发生；
* 用于对问题进行定位，以及历史数据跟踪；
* 通过历史监控数据，为技术或者业务决策提供数据支撑；
* 用于支持其它的系统或者流程，比如自动化、安全、测试等；

## 面临的挑战

以监控系统Nagios为例。如下图所示，Nagios的主要功能是监控服务和主机。Nagios软件需要安装在一台独立的服务器上运行，该服务器称为监控中心。每一台被监控的硬件主机或者服务都需要运行一个与监控中心服务器进行通信的Nagios软件后台程序，可以理解为Agent或者插件。

![Nagios监控原理](https://www.ibm.com/developerworks/cn/linux/1309_luojun_nagios/image003.jpg)

Nagios启动后周期性的调用插件去检查服务器状态。Nagios提供了插件机制，比如check_disk可以用于检查磁盘空间，check_load用于检查CPU负载等。插件可以返回4种Nagios可识别的状态，0(OK)表示正常，1(WARNING)表示警告，2(CRITTCAL)表示错误，3(UNKNOWN)表示未知错误。并通过Web UI显示出来。

![Nagios主机监控页面](https://www.ibm.com/developerworks/cn/linux/1309_luojun_nagios/image049.jpg)

对于大部分采用Nagios或者其它上一代监控系统的组织而言，当使用这些系统时，通常往往会面临各种挑战：

* 过高的运维成本，比如Zabbix或者Nagios这类工具网络需要有专业的人员进行安装，配置和管理，而且过程并不简单；
* 同时很难对监控系统自身做扩展，以适应监控规模的变化；
* 同时监控系统本身也会限制技术和业务本身；
* 监控指标与业务分离，无法有效的支撑业务需求；

好比客户可能关注的是服务的可用性，以及服务的SLA等级，而监控系统却只能根据CPU使用率去产生告警。 业务和监控指标之间无法有效协作。

除了这些基本的挑战以外，应用架构以及基础设施架构的变化同样也带来了巨大的挑战。

从单体架构到微服务架构，通过各个小的独立的进程支撑整个业务，每一个部分都可以独立根据需求进行独立开发，独立部署，独立伸缩。应用程序无论从结构，还是实例都是不断演进变化的。

![单体架构和微服务架构](http://p2n2em8ut.bkt.clouddn.com/microservice.png)

物理主机、虚拟机、容器运行应用的基础设施正在不断的发生变化。这些变化让底层资源的创建、销毁变得更加频繁。同时基础设施还可能根据当前业务的需求不断发生变化，因此基础设施也变成了一个动态的基础服务。

![基础设施服务](http://p2n2em8ut.bkt.clouddn.com/caas.jpeg)

这一系列的变化，都在预示着一件事情，就是上一代监控系统已经无法有效的应对当前软件设计所带来的变化，我们需要的是一个全新的监控系统，来适应当前万物皆云的现状。

## Prometheus来了

Prometheus受启发于Google的Brogmon监控系统（相似的Kubernetes是从Google的Brog系统演变而来），从2012年开始由前Google工程师在Soundcloud以开源软件的形式进行研发，并且于2015年早期对外发布早期版本。2016年5月正式成为继Kubernetes之后的第二个正式加入CNCF基金会的项目，同年6月正式发布1.0版本。2017年底发布了基于全新存储层的2.0版本，能更好地与容器平台，云平台配合。

![Prometheus简史](http://p2n2em8ut.bkt.clouddn.com/prometheus-release-roadmaps.png)

目前已经有超过650+位贡献者参与到Prometheus的研发工作上，并且超过120+项的第三方集成。

## Prometheus是什么？

### 一个时序数据库

首先Prometheus是一个基于时间序列（time-searies）的数据库系统。Prometheus与其他主流的监控系统一样均采用了基于时间序列的方式对数据进行存储。相比其它时序数据库（例如：OpenTsdb）Prometheus中采集到的监控样本数据，通过指标名称(metric)和一组描述当前样本特征维度的键值对（Labels）进行唯一标示（例如：api_http_requests_total{method=”POST”, handler=”/messages”}）。通过这种多维的数据模型，Prometheus可以提供高效的存储和查询能力。

Promtheus将数据存储在内存和本地磁盘上。当需要Prometheus进行扩展时，可以通过功能分片或者联邦集群实现。关于如果实现Prometheus扩展的部分我们会在第4章进行讨论。

### 一个数据查询引擎

Prometheus提供了灵活高效的数据查询系统，通过Promethues自定义的数据查询语言PromQL，可以对数据进行查询和聚合，实现各种报表和数据分析。

关于使用Prometheus进行数据聚合分析的部分我们会在第2章节进行讨论。

### 一个监控告警预警平台

Prometheus支持用户创建基于Prometheus的自定义查询语言，定义告警。并且结合AlertManager组件实现件监控告警，可以与第三方工具和平台进行集成。

### 一个开放的监控框架

社区同时提供了大量的第三方Exporter。可以快速实现对诸如服务器、容器、中间件的监控指标采集。
Prometheus同时提供超过10种以上的客户端SDK，基于这些客户端SDK，可以轻松实现自己的Exporter或者直接在应用程序上集成Prometheus。

## 核心优势

### 完整的监控支持

Prometheus作为系统监控方案(不同于应用监控APM)，提供了完整的监控支持，包括但不限于：基础设施监控，中间件监控，应用监控;

提供了完整的可视化，以及告警支持，并且易于集成。

## 强大的数据模型

所有的监控指标数据都是基于标签的多维度数据。基于这些维度我们可以方便的对监控数据进行聚合，过滤，裁剪。并且这些数据均以时间序列的形式存储在本地磁盘中。

### 强大的查询语言

通过Prometheus提供的自定义查询语言PromQL，我们可以直接对基于时间序列的数据进行数学运算(加，减，乘，除)，聚合并立即得到结果。基于这些运算结果我们可以方便地绘制出需要的可视化图标。

例如，通过PromQL我们可以回答类似于以下问题：

* 在过去一段时间95%的应用延迟的分布范围？
* 在4小时候后，磁盘空间占用大致会是什么情况？
* CPU占用率前5位的服务有哪些？

### 易于管理

Prometheus核心部分只有一个单独的二进制文件，不存在任何的第三方依赖(数据库，缓存等等)。唯一需要的就是本地磁盘，因此不会潜在级联故障的风险。

Prometheus基于Pull模型的架构方式，可以在任何地方（本地电脑，开发环境，测试环境）搭建我们的监控系统。

对于一些复杂的情况，我们可以基于服务发现(Service Discovery)用于动态发现监控目标。

### 高效

对于Prometheus而言大量的监控任务，意味着有大量样本数据的产生。而Prometheus可以高效地处理这些数据，对于单实例的Prometheus Server，可以处理：

* 数以百万的监控指标
* 每秒处理数十万的数据点。

### 可扩展

Prometheus是如此简单，因此你可以在每个数据中心，每个团队运行度量的Prometheus Sevrer。Prometheus对于联邦集群地支持，可以让Prometheus从其他Prometheus Server拉取监控指标样本。因此当对于单实例Prometheus Server来说监控的任务量过大时，我们可以使用功能分区(sharding)+联邦集群(federation)来进行扩展。

### 易于集成

使用Prometheus可以快速搭建监控服务，并且可以非常方便的在应用程序中进行集成。目前支持： Java， JMX， Python， Go，Ruby， .Net， Node.js等等语言的客户端SDK，基于这些SDK可以快速让应用程序纳入到Prometheus的监控当中，或者开发自己的监控数据收集程序。同时这些客户端收集的监控数据，不仅仅支持Prometheus，还能支持Graphite这些其他的监控工具。

同时Prometheus还支持与其他的监控系统进行集成：Graphite， Statsd， Collected， Scollector， muini， Nagios等。

同时Prometheus还存在官方的第三方实现的监控数据采集支持：JMX， CloudWatch， EC2， MySQL， PostgresSQL， Haskell， Bash， SNMP， Consul， Haproxy， Mesos， Bind， CouchDB， Diango， Memcached， RabbitMQ， Redis， RethinkDB， Rsyslog等等。

### 可视化

Prometheus Server中自带了一个Prometheus UI，通过这个UI我们可以方便的直接对数据进行查询，并且可以直接以图的形式展示数据。同时Prometheus还提供了一个独立的基于Ruby On Rails的Dashboard解决方案Promdash。最新的Grafana可视化工具也已经提供了完整的Prometheus支持，基于Grafana可以创建更加精美的监控图标。基于Prometheus提供的API还可以实现自己的监控可视化UI。

### 开放性

通常来说当我们需要监控一个应用程序时，一般需要该应用程序提供对相应监控系统协议的支持。因此应用程序会与所选择的监控系统进行绑定。为了减少这种绑定所带来的限制。对于决策者而言要么你就直接在应用中集成该监控系统的支持，要么就在外部创建单独的服务来适配不同的监控系统。

而对于Prometheus来说，使用Prometheus的client library的输出格式不止支持Prometheus的格式化数据，也可以输出支持其它监控系统的格式化数据，比如Graphite等。

因此你甚至可以在不使用Prometheus的情况下，采用Prometheus的client library来让你的应用程序支持监控数据采集。