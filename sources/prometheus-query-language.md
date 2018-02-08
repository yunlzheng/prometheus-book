# PromQL初识

Prometheus通过指标名称Metrics Name以及对应的一组键值对Labels唯一定义一条时间序列。指标名称反应了监控样本的基本标识，而Label则在这个基本特征上为采集到的数据提供了多种特征维度。用户可以基于这些特征维度过滤，聚合，统计从而产生新的计算后的一条时间序列。

## 查询基础

当Prometheus通过Exporter采集到响应的监控指标样本数据后，我们就可以通过PromQL对监控样本数据进行查询。

* 基本查询

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

* 精确查询

在查询数据时，我们还可以通过标签选择器对时间序列进行精确匹配查询。使用“=”表示选择标签完全匹配的时间序列，"!="表示排除这些匹配的时间序列。

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

* 模糊查询

除了精确查询以外，PromQL还可以通过正则表达式的方式，实现模糊查询。当需要使用正则表达式进行模糊查询时，需要使用“=~”,相反的，“!~”表示排除所有的匹配的时间序列。

例如

```
http_requests_total{environment=~"staging|testing|development",method!="GET"}
```

SQL:

```
SELECT * FROM http_requests_total WHERE environment LIKE '%testing%'
```

## 使用标签过滤数据

通过PromQL我们可以通过标签描述采集到数据的特征，并且根据该特征得到一条新的时间序列。

例如：

```
# 查询Http返回状态码为500的所有时间序列
http_request_total{code="500"}

# 查询Http返回状态码非200的所有时间序列
http_request_total{code!="200"}

# dc标签的值匹配正则表达式的所有时间序列
http_request_total{dc~="us-west-.*"}
```

## 使用标签对数据进行聚合

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

通过上面的几个简单例子我们可以看出，通过指标名称(metric name)以及指标的维度labels，通过Prometheus提供的PromQL查询语言，我们可以根据样本特征对数据进行过滤。同时多条时间序列之间的数据还可以进行聚合以及数学操作，从而形成一条新的时间序列。

对于PromQL表达式，除了返回一条或者多条时间序列以外。还可能返回一下几种不同的结果。

* 瞬时向量(Instant vector)

包含一组时间序列，每个序列只包含一个样本数据

例如，使用表达式: 

```
http_request_total
```

会返回一组时间序列。如果记这些时间序列分别为A和B：

```
A=(a@timestamp1)
B=(b@timestamp1)
```

并且这组时间序列的样本数据共享相同的时间蹉。

如使用sum()函数则实际进行的是向量之间的加法。sum(http_request_total{}) = (a+b) 从而形成一条新的时间序列。

* 区间向量(Range vector)

包含一组时间序列，每个时间序列，包含多个样本数据,例如当使用表达式:

```
http_request_total[5m]
```

```
A={[a1@timestamp1, a2@timestamp2, a3@timestamp3, a4@timestamp4]}
B={[b1@timestamp1, b2@timestamp2, b3@timestamp3, b4@timestamp4]}
```

多条时间序列中的样本数据同样共享相同的时间戳。

另外Prometheus表达式中还支持纯量以及字符串，这两种返回类型实际使用场景并不多。

* 纯量(Scalar): 一个浮点型的数字值

纯量只有一个数字，没有时序

例如：

```
10
```

> 需要注意的是，当使用表达式count(http_requests_total)，返回的数据类型，依然是瞬时向量。

* 字符串(String): 一个简单的字符串值

直接使用字符串，作为PromQL表达式，则会直接返回字符串。

```
"this is a string"
'these are unescaped: \n \\ \t'
`these are not unescaped: \n ' " \t`
```

## 接下来

接下来我们会详细探索Prometheus提供的这一强大工具PromQL。