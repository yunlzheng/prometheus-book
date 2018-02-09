# 初识PromQL

Prometheus通过指标名称Metrics Name以及对应的一组键值对Labels唯一定义一条时间序列。指标名称反应了监控样本的基本标识，而Label则在这个基本特征上为采集到的数据提供了多种特征维度。用户可以基于这些特征维度过滤，聚合，统计从而产生新的计算后的一条时间序列。

## 查询基础

当Prometheus通过Exporter采集到响应的监控指标样本数据后，我们就可以通过PromQL对监控样本数据进行查询。

### 基本查询

最基本的，当我们直接使用监控指标的名称为查询时，可以查询该指标下的所有时间序列。如：

```
http_requests_total
```

等同于

```
http_requests_total{}
```

该表达式会返回，所有指标名称为http_requests_total的时间序列。

```
http_requests_total{code="200",handler="alerts",instance="localhost:9090",job="prometheus",method="get"} -> 1
http_requests_total{code="200",handler="graph",instance="localhost:9090",job="prometheus",method="get"} -> 3
http_requests_total{code="200",handler="graph",instance="other:9090",job="prometheus",method="get"} -> 3
```

SQL:

```
SELECT * FROM http_requests_total;
```

### 精确查询

在查询数据时，我们还可以通过标签选择器对时间序列进行精确匹配查询。

* 使用“=”表示选择标签完全匹配的时间序列，
* "!="表示排除这些匹配的时间序列。

如下所示，我们只查询所有http_requests_total时间序列中，标签instance为localhost:9090的时间序列。这里在标签选择器中我们使用“=”表示精确匹配

```
http_requests_total{instance="localhost:9090"}
```

相反的我们可以使用“!=”表示排除:

```
http_requests_total{instance!="localhost:9090"}
```

返回结果：

```
http_requests_total{code="200",handler="graph",instance="other:9090",job="prometheus",method="get"} -> 3
```

SQL:

```
SELECT * FROM http_requests_total WHERE instance="localhost:9090"
```

### 模糊查询

除了精确查询以外，PromQL还可以通过正则表达式的方式，实现模糊查询。

* 当需要使用正则表达式进行模糊查询时，需要使用“=~”。
* 相反的，“!~”表示排除所有的匹配的时间序列。

例如

```
http_requests_total{environment=~"staging|testing|development",method!="GET"}
```

SQL:

```
SELECT * FROM http_requests_total WHERE environment LIKE '%testing%'
```

### 使用内置函数

一般来说，如果描述样本特征的标签(label)在不是唯一的情况下，通过PromQL查询数据，会返回多条满足这些特征维度的时间序列。而PromQL提供的聚合操作可以用来对这些多条时间序列进行处理，形成一条新的时间序列。

```
# 查询系统所有http请求的总量
sum(http_request_total)

# 按照mode计算主机cpu的平均使用时间
avg(node_cpu) by (mode)

# 按照主机查询各个主机的cpu使用率
sum(sum(irate(node_cpu{mode!='idle'}[5m]))  / sum(irate(node_cpu[5m]))) by (instance)
```

## PromQL的返回值

通过上面的几个简单例子我们可以看出，通过指标名称(metric name)以及指标的维度labels，通过Prometheus提供的PromQL查询语言，我们可以根据样本特征对时序数据进行过滤。同时多条时间序列之间的数据还可以进行聚合以及数学操作，从而形成一条新的时间序列。

在PromQL中如果表达式返回的是一组时序数据，并且每条时间序列只包含给定时间戳（瞬时）的单个样本数据 这些返回数据的类型在Prometheus中我们称为瞬时数据(Instant vector)。

### 瞬时数据(Instant vector)

例如，使用如下表达式，会可以过滤并查询到一组时间序列以及给定时间戳（瞬时，一般为最后一次采集数据的时戳）的单个样本数据。

```
http_request_total{code="200"}
```

会返回一组时间序列

```
http_requests_total{code="200",handler="alerts",instance="localhost:9090",job="prometheus",method="get"}=(20889@1518096812.326)
http_requests_total{code="200",handler="graph",instance="localhost:9090",job="prometheus",method="get"}=(21287@1518096812.326)
```
并且这组时间序列的样本数据共享相同的时间蹉。

这一类表达式，我们称为**瞬时数据选择器**，瞬时数据选择器返回的数据类型为**瞬时数据**。

瞬时数据选择器，至少包含一个指标名称(例如http_request_total)，或者一个不会匹配到空字符串的标签过滤器(例如{code="200"})。

因此以下两种方式，均为合法的表达式：

```
http_request_total # 合法
http_request_total{} # 合法
{method="get"} # 合法
```

而如下表达式，则不合法：

```
{job=~".*"} # 不合法
```

同时，除了使用metrics{label=value}的形式，使用metrics指定监控指标以外，我们还可以使用内置的```__name__```指定监控指标名称：

```
{__name__=~"http_request_total"} # 合法
{__name__=~"node_disk_bytes_read|node_disk_bytes_written"} # 合法
```

### 区间数据(Range vector)

除了瞬时数据以外，PromQL表达式还可以查询区间数据，区间数据和瞬时数据非常相似，区别在于区间数据返回是从当前时刻开始选择的一个范围的样本数据。返回区间数据类型的表达式，我们称为**区间数据选择器**。

例如：

```
http_request_total{code="200"}[5m]
```

该表达式，表示查询时间序列名称为http_request_total并且满足code="200"的时序数据中，最近5分钟内的样本数据。如下：

```
http_requests_total{code="200",handler="alerts",instance="localhost:9090",job="prometheus",method="get"}=[
    1@1518096812.326
    1@1518096817.326
    1@1518096822.326
    1@1518096827.326
    1@1518096832.326
    1@1518096837.325
]
http_requests_total{code="200",handler="graph",instance="localhost:9090",job="prometheus",method="get"}=[
    4 @1518096812.326
    4@1518096817.326
    4@1518096822.326
    4@1518096827.326
    4@1518096832.326
    4@1518096837.325
]
```

除了使用m表示分钟以外，PromQL还可以使用其他的时间单位：

* s - 秒
* m - 分钟
* h - 小时
* d - 天
* w - 周
* y - 年

### 标量(Scalar): 一个浮点型的数字值

标量只有一个数字，没有时序

例如：

```
10
```

> 需要注意的是，当使用表达式count(http_requests_total)，返回的数据类型，依然是瞬时数据。

### 字符串(String): 一个简单的字符串值

直接使用字符串，作为PromQL表达式，则会直接返回字符串。

```
"this is a string"
'these are unescaped: \n \\ \t'
`these are not unescaped: \n ' " \t`
```

### 时间位移

在瞬时选择器，或者区间选择器中，都是以当前时间为基准

```
http_request_total{code="200"} # 瞬时选择器，选择当前最新的数据
http_request_total{code="200"}[5m] # 区间选择器，选择以当前时间为基准，5分钟内的数据
```

那如果我们想查询，5分钟前的瞬时样本数据，或昨天一天的区间内的样本数据呢? 这个时候我们就可以使用位移操作，位移操作的关键字为**offset**。

因此我们可以使用时间位移操作：

```
http_request_total{code="200"} offset 5m
http_request_total{code="200"}[1d] offset 1d
```

## 接下来

接下来我们会详细探索Prometheus提供的这一强大工具PromQL。以及它给我们带来的强大的数据统计功能。