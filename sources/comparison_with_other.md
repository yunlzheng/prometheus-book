# 百里挑一

## Prometheus Vs Graphite

### 范围

Graphite专注于时序数据库本身，对外提供查询和图形可视化的功能。 而其他监控相关的问题都需要由外部组件来解决。

Prometheus则是一个完整的监控系统，包括内置的数据采集，存储，查询，图形可视化以及基于时间序列数据的告警能力。

### 数据模型

Graphite和Prometheus一样，对基于时间序列的数据进行存储。

Graphite中的监控指标通过一组基于“.”的关键字维度组成：

```
stats.api-server.tracks.post.500 -> 93
```

而Prometheus中，每一个监控指标拥有对个基于key-value形式的标签组成。 通过这些标签，我们可以更容易的对数据进行过滤，分组，以及查询。

```
api_server_http_requests_total{method="POST",handler="/tracks",status="500",instance="<sample1>"} -> 34
api_server_http_requests_total{method="POST",handler="/tracks",status="500",instance="<sample2>"} -> 28
api_server_http_requests_total{method="POST",handler="/tracks",status="500",instance="<sample3>"} -> 31
```

### 存储

Graphite使用Whisper的格式将时间序列数据存储在本地磁盘中，这是一种RRD风格的数据库，期望采集到的样本数据能定期到达。每一条时间序列存储在单独的文件当中，并且新的样本数据会在一段时间后覆盖旧的样本数据。

Prometheus同样将时间序列数据分别存储在独立的本地磁盘中，但是运行样本已不同的周期进行采集。因为新的样本数据只是简单的追加到时间序列上，因此老的数据可能会保留较长的时间。Prometheus也适用于那些生命周期较短，变化频繁的时间序列。

### 总结

Prometehus提供了更灵活的数据模型以及查询语言，同时更容易运行以及集成到现有的环境中。但是如果你想要一个可以长期保存历史数据的集群解决方案，那么Graphite可能是一个更好的选择。

## Prometheus Vs InfluxDB

InfluxDB是一个开源的时间序列数据库，同时具有支持扩展以及集群的商业版本。Prometheus和InfluxDB之间存在着一些显著的差异，并且由各自适用的使用场景。

但是当将Kapacitor和InfluxDB一起考虑时，它们的组合与Prometheus与AlertManager解决了相同的问题。

### 范围

### 数据模型/存储

### 架构设计

### 总结

## Prometheus Vs OpenTSDB

### 范围

### 数据模型

### 存储

### 总结

## Prometheus Vs Nagios

### 范围

### 架构

### 总结

## Prometheus vs. Sensu

## 范围

### 数据模型

### 架构

### 总结