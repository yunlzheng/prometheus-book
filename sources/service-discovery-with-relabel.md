# 服务发现与Relabeling

在本章的前几个小节中笔者已经分别介绍了Prometheus的几种服务发现机制。通过服务发现的方式，管理员可以在不重启Prometheus服务的情况下动态的发现需要监控的Target实例信息。

![基于Consul的服务发现](http://p2n2em8ut.bkt.clouddn.com/bolg_sd_mutil_cluster.png)

如上图所示，对于线上环境我们可能会划分为:dev, stage, prod不同的集群。每一个集群运行多个主机节点，每个服务器节点上运行一个Node Exporter实例。Node Exporter实例会自动测试到服务注册中心Consul服务当中，Prometheus可以根据Consul返回的Node Exporter实例信息产生Target列表，并且向这些Target轮训监控数据。

然而，如果我们可能还需要：

* 按照不同的环境dev, stage, prod聚合监控数据？
* 对于研发团队而言，我可能只关心dev环境的监控数据，这是如何处理？
* 为每一个团队单独搭建一个Prometheus Server？ 那么如何让不同团队的Prometheus Server采集不同的环境监控数据？

面对以上这些场景下的需求时，我们实际上是希望Prometheus Server能够按照某些规则（比如标签）从服务发现注册中心返回的Target实例中有选择性的采集某些Exporter实例的监控数据。

接下来，我们将学习如何通过Prometheus强大的Relabel机制来实现以上这些具体的目标。

## 认识Target实例的Metadata

在Prometheus所有的Target实例中，都包含一些默认的Metadata标签信息。可以通过Prometheus UI的Targets页面中查看这些实例的Metadata标签的内容：

![实例的Metadata信息](http://p2n2em8ut.bkt.clouddn.com/prometheus_file_target_metadata.png)

默认情况下所有的Target都包含以下基本Metadata标签信息：

* ```__address__```：当前Target实例的访问地址```<host>:<port>```
* ```__scheme__```：采集目标服务访问地址的HTTP Scheme，HTTP或者HTTPS
* ```__metrics_path__```：采集目标服务访问地址的访问路径
* ```__param_<name>```：采集任务目标服务的中包含的请求参数

通过服务发现动态发现的Target实例还会包含一些额外的标签信息一般以__meta开头，例如通过Consul动态发现的服务实例还会包含以下Metadata标签信息：

* __meta_consul_address: consul地址
* __meta_consul_dc: consul中服务所在的数据中心
* __meta_consulmetadata: 服务的metadata
* __meta_consul_node: 服务所在consul节点的信息
* __meta_consul_service_address: 服务访问地址
* __meta_consul_service_id: 服务ID
* __meta_consul_service_port: 服务端口
* __meta_consul_service: 服务名称
* __meta_consul_tags: 服务包含的标签信息

## Relabeling机制

在默认情况下，Prometheus在保存监控样本之前会根据当前Target实例的Metadata标签信息动态重新样本的标签值。例如，从Node Exporter中获取的原始样本为：

```
node_cpu{cpu="cpu0",mode="idle"} 93970.8203125
```

而实际保存到Promtheus中的样本为：

```
node_cpu{cpu="cpu0",instance="localhost:9100",job="node",mode="idle"}
```

其中job标签的值对应采集任务的job_name，而instance则是从Metadata的```__address```标签中获取。这种在保存样本数据之前动态重写样本标签的工作机制在Prometheus下称为Relabeling。

