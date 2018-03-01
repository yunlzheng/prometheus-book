# Prometheus简介

> TODO: 替换草图

Prometheus受启发于Google的Brogmon监控系统（相似的Kubernetes是从Google的Brog系统演变而来），从2012年开始由前Google工程师在Soundcloud以开源软件的形式进行研发，并且于2015年早期对外发布早期版本。2016年5月正式成为继Kubernetes之后的第二个正式加入CNCF基金会的项目，同年6月正式发布1.0版本。2017年底发布了基于全新存储层的2.0版本，能更好地与容器平台，云平台配合。

![Prometheus简史](http://p2n2em8ut.bkt.clouddn.com/prometheus-release-roadmaps.png)

目前已经有超过650+位贡献者参与到Prometheus的研发工作上，并且超过120+项的第三方集成。

## 监控的目标

一般来说对于一个组织而言，引入监控系统一般都是为了解决以下几个主要问题：

##### 及时了解问题的发生

对于大部分人而言，采用监控系统的首要元婴就是能够在系统发生问题时及时的获取到通知。从而能够对问题进行快速的处理，或者提前预防问题的发生，避免出现对业务的影响。

##### 故障定位与分析

当用户接收到告警通知后，通常对需要对问题进行调查和处理。通过不同监控项以及历史数据的分析，找到并解决导致异常的根本原因。

##### 历史数据追踪

通过建立监控系统，持续对特定样本数据进行收集。通过对这些历史数据的观察用户可以从中发现我们的业务和应用是如何被用户使用的。例如用户访问量在一天时间当中的变化趋势，以及系统在不同用户量下的响应状态。以帮助业务和开发人员更好的做出决策。

##### 与其他的系统或者流程做集成

有些用户可能还需要将监控系统与其他的系统做集成，将监控获取到的数据作为其他业务流程的支撑数据。比如基于监控系统的样本数据从而判断是否需要对应用或者基础设施进行容量调整。

## 问题和挑战

而对于大部分采纳上一代监控系统(例如：Nagios、Zabbix)的用户而言往往并不能很好的解决这些问题。首先对于大部分上一代监控系统而言，大部分的监控能力都是围绕系统的一些边缘性的问题，比如系统服务和资源的状态(check_cpu,check_disk,check_load)以及应用程序的可用性，

以监控系统Nagios为例。如下图所示，Nagios的主要功能是监控服务和主机。Nagios软件需要安装在一台独立的服务器上运行，该服务器称为监控中心。每一台被监控的硬件主机或者服务都需要运行一个与监控中心服务器进行通信的Nagios软件后台程序，可以理解为Agent或者插件。

![Nagios监控原理](https://www.ibm.com/developerworks/cn/linux/1309_luojun_nagios/image003.jpg)

Nagios启动后周期性的调用插件去检查服务器状态。Nagios提供了插件机制，比如check_disk可以用于检查磁盘空间，check_load用于检查CPU负载等。插件可以返回4种Nagios可识别的状态，0(OK)表示正常，1(WARNING)表示警告，2(CRITTCAL)表示错误，3(UNKNOWN)表示未知错误。并通过Web UI显示出来。

![Nagios主机监控页面](https://www.ibm.com/developerworks/cn/linux/1309_luojun_nagios/image049.jpg)

而当问题产生之后（比如主机负载异常增加）对于用户而言，他们看到的依然是一个黑盒，他们无法了解主机上服务真正的运行情况，因此当故障发生后，这些告警信息并不能有效的支持用户对于故障根源问题的分析和定位。

除此以外，监控系统获取到的监控指标与业务本身也是一种分离的关系。好比客户可能关注的是服务的可用性，以及服务的SLA等级，而监控系统却只能根据系统负载去产生告警，业务和监控系统之间无法有效协作。

同时诸如Nagios这一类监控系统本身运维管理难度就比较大，需要有专业的人员进行安装，配置和管理，而且过程并不简单。并且也很难对监控系统自身做扩展，以适应监控规模的变化。

##### 监控服务的内部运行状态

Pometheus鼓励用户监控服务的内部状态，基于Prometheus丰富的client库，用户可以轻松的在应用程序中添加对Prometheus监控的支持，从而让用户可以看到服务和应用内部真正的运行状态。

![监控服务内部运行状态](http://p2n2em8ut.bkt.clouddn.com/monitor-internal.png)

## Prometheus提供了什么？

##### 强大的数据模型

Prometheus是一个完全开源的监控系统，所有采集的监控数据均以指标(metric)的形式保存在内置的时间序列数据库当中(TSDB)。所有的样本除了基本的指标名称以外，还包含一系列用于描述该样本特征的标签(键值对)。

如下所示：

```
http_request_status{code='200',content_path='/api/path', environment='produment'} => [value1@timestamp1,value2@timestamp2...]

http_request_status{code='200',content_path='/api/path2', environment='produment'} => [value1@timestamp1,value2@timestamp2...]
```

当采集HTTP请求状态样本数据时，每一条时间序列表示由指标名称以及一组标签唯一标示。每条时间序列按照时间序列记录了一系列的样本值。

这些表示维度的标签可能来源于你的监控对象，比如code=404或者content_path=/api/path。也可能来源于的你的环境定义，比如environment=produment。基于这些维度我们可以方便的对监控数据进行聚合，过滤，裁剪。

##### 强大的查询语言PromQl

同时Prometheus内置了一个强大的自定义查询语言PromQL,通过PromQL可以对采集到的进行查询，聚合。同时PromQL还被应用于数据可视化(结合其他工具如Grafana)以及告警当中。

例如，通过PromQL可以轻松回答类似于以下问题：

* 在过去一段时间95%的应用延迟的分布范围？
* 在4小时候后，磁盘空间占用大致会是什么情况？
* CPU占用率前5位的服务有哪些？

##### 易于管理

Prometheus核心部分只有一个单独的二进制文件，不存在任何的第三方依赖(数据库，缓存等等)。唯一需要的就是本地磁盘，因此不会潜在级联故障的风险。

Prometheus基于Pull模型的架构方式，可以在任何地方（本地电脑，开发环境，测试环境）搭建我们的监控系统。对于一些复杂的情况，我们可以基于服务发现(Service Discovery)用于动态发现监控目标。

##### 高效

对于Prometheus而言大量的监控任务，意味着有大量样本数据的产生。而Prometheus可以高效地处理这些数据，对于单实例的Prometheus Server，可以处理：

* 数以百万的监控指标
* 每秒处理数十万的数据点。

##### 可扩展

Prometheus是如此简单，因此你可以在每个数据中心，每个团队运行独立的Prometheus Sevrer。Prometheus对于联邦集群地支持，可以让Prometheus从其他Prometheus Server拉取监控指标样本。因此当对于单实例Prometheus Server来说监控的任务量过大时，我们可以使用功能分区(sharding)+联邦集群(federation)来进行扩展。

##### 易于集成

使用Prometheus可以快速搭建监控服务，并且可以非常方便的在应用程序中进行集成。目前支持： Java， JMX， Python， Go，Ruby， .Net， Node.js等等语言的客户端SDK，基于这些SDK可以快速让应用程序纳入到Prometheus的监控当中，或者开发自己的监控数据收集程序。同时这些客户端收集的监控数据，不仅仅支持Prometheus，还能支持Graphite这些其他的监控工具。

同时Prometheus还支持与其他的监控系统进行集成：Graphite， Statsd， Collected， Scollector， muini， Nagios等。

Prometheus社区还提供了大量第三方实现的监控数据采集支持：JMX， CloudWatch， EC2， MySQL， PostgresSQL， Haskell， Bash， SNMP， Consul， Haproxy， Mesos， Bind， CouchDB， Diango， Memcached， RabbitMQ， Redis， RethinkDB， Rsyslog等等。

##### 可视化

Prometheus Server中自带了一个Prometheus UI，通过这个UI可以方便的直接对数据进行查询，并且支持直接以图形化的形式展示数据。同时Prometheus还提供了一个独立的基于Ruby On Rails的Dashboard解决方案Promdash。最新的Grafana可视化工具也已经提供了完整的Prometheus支持，基于Grafana可以创建更加精美的监控图标。基于Prometheus提供的API还可以实现自己的监控可视化UI。

##### 开放性

通常来说当我们需要监控一个应用程序时，一般需要该应用程序提供对相应监控系统协议的支持。因此应用程序会与所选择的监控系统进行绑定。为了减少这种绑定所带来的限制。对于决策者而言要么你就直接在应用中集成该监控系统的支持，要么就在外部创建单独的服务来适配不同的监控系统。

而对于Prometheus来说，使用Prometheus的client library的输出格式不止支持Prometheus的格式化数据，也可以输出支持其它监控系统的格式化数据，比如Graphite。

因此你甚至可以在不使用Prometheus的情况下，采用Prometheus的client library来让你的应用程序支持监控数据采集。

## 接下来

在本书当中，将带领读者感受Prometheus是如何对监控系统的重新定义。