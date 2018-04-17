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

在默认情况下，Prometheus在保存监控样本之前会根据当前Target实例的Metadata标签信息动态重新样本的标签值。例如，从Node Exporter中获取的原始样本为：

```
node_cpu{cpu="cpu0",mode="idle"} 93970.8203125
```

而实际保存到Promtheus中的样本为：

```
node_cpu{cpu="cpu0",instance="localhost:9100",job="node",mode="idle"}
```

其中job标签的值对应采集任务的job_name，而instance则是从Metadata的```__address```标签中获取。这种在保存样本数据之前动态重写样本标签的工作机制在Prometheus下称为Relabeling。

## 使用Relabeling重写标签

用户可以在每一个采集任务的配置中添加多个relabel_config配置，一个最简单的relabel配置如下：

```
scrape_configs:
  - job_name: node_exporter
    consul_sd_configs:
      - server: localhost:8500
        services:
          - node_exporter
    relabel_configs:
    - source_labels:  ["__meta_consul_dc"]
      target_label: "dc"
```

该采集任务通过Consul动态发现Node Exporter实例信息作为监控采集目标。在上一下节中，我们知道通过Consul动态发现的监控Target都会包含一些额外的Metadata标签，比如标签__meta_consul_dc表明了当前实例所在的Consul数据中心，因此我们希望从这些实例中采集到的监控样本中也可以包含这样一个标签，例如：

```
node_cpu{cpu="cpu0",dc="dc1",instance="172.21.0.6:9100",job="consul_sd",mode="guest"}
```

这样我们可以方便的根据dc标签的值，根据不同的数据中心聚合分析各自的数据。

在这个例子中，我们直接从Target实例中获取__meta_consul_dc的值，并且重写所有从该实例获取的样本中。

一个完整的relabel_config配置如下：

```
# The source labels select values from existing labels. Their content is concatenated
# using the configured separator and matched against the configured regular expression
# for the replace, keep, and drop actions.
[ source_labels: '[' <labelname> [, ...] ']' ]

# Separator placed between concatenated source label values.
[ separator: <string> | default = ; ]

# Label to which the resulting value is written in a replace action.
# It is mandatory for replace actions. Regex capture groups are available.
[ target_label: <labelname> ]

# Regular expression against which the extracted value is matched.
[ regex: <regex> | default = (.*) ]

# Modulus to take of the hash of the source label values.
[ modulus: <uint64> ]

# Replacement value against which a regex replace is performed if the
# regular expression matches. Regex capture groups are available.
[ replacement: <string> | default = $1 ]

# Action to perform based on regex matching.
[ action: <relabel_action> | default = replace ]
```

其中action定义了当前relabel_config对Metadata标签的处理方式，默认的action行为为replace。 replace行为会根据regex的配置匹配source_labels标签的值（多个source_label的值会按照separator进行拼接），并且将匹配到的值写入到target_label当中，如果有多个匹配组，则可以使用${1}, ${2}确定写入的内容。如果没匹配到任何内容则不对target_label进行重新。

repalce操作允许用户根据Target的Metadata标签重写或者写入新的标签键值对，在多环境的场景下，可以帮助用户添加与环境相关的特征维度，从而可以更好的对数据进行聚合。

除了使用replace的方式覆写标签以外，还可以使用labelmap的方式。当action为labelmap时，Prometheus会使用正则表达式regex去匹配Target中所有的标签名称，并且匹配到的标签的值写入到replacement中。例如，在监控Kubernetes下所有的主机节点时，为将这些节点上定义的标签写入到样本中时，可以使用如下relabel_config配置：

```
- job_name: 'kubernetes-nodes'
  kubernetes_sd_configs:
  - role: node
  relabel_configs:
  - action: labelmap
    regex: __meta_kubernetes_node_label_(.+)
```

这里省略了默认的replacement: $1，通过该配置可以将Kubernetes节点中定义的标签写入到样本的标签键值对中。

> TODO labeldrop/labelkeep

## 使用Relabeling过滤Target实例

在上一部分中，我们在relabel_config中使用了replace的行为，其可以帮助用户为时间序列添加一个自定义的特征维度。而本节开头还提到过第二个问题，使用中心化的服务发现注册中心时，所有环境的Exporter实例都会注册到该服务发现注册中心中。而不同职能（开发、测试、运维）的人员可能只关心其中一部分的监控数据，他们可能各自部署的自己的Prometheus Server用于监控自己关心的指标数据，如果让这些Prometheus Server采集所有环境中的所有Exporter数据显然会存在大量的资源浪费。如何让这些不同的Prometheus Server采集各自关心的内容？答案还是Relabeling，relabel_config的action除了默认的replace以外，还支持keep/drop行为。例如，如果我们只希望采集数据中心dc1中的Node Exporter实例的样本数据，那么可以使用如下配置：

```
scrape_configs:
  - job_name: node_exporter
    consul_sd_configs:
      - server: localhost:8500
        services:
          - node_exporter
    relabel_configs:
    - source_labels:  ["__meta_consul_dc"]
      regex: "dc1"
      action: keep
```

当action设置为keep时，Prometheus会丢弃source_labels的值中没有匹配到regex正则表达式内容的Target实例，而当action设置为drop时，则会丢弃那些source_labels的值匹配到regex正则表达式内容的Target实例。可以简单理解为keep用于选择，而drop用于排除。
