# 理解Prometheus数据模型

在1.2节当中，通过node exporter暴露的HTTP服务，Prometheus可以采集到主机相关监控指标的样本数据。例如：

```
# HELP node_cpu Seconds the cpus spent in each mode.
# TYPE node_cpu counter
node_cpu{cpu="cpu0",mode="idle"} 362812.7890625
# HELP node_load1 1m load average.
# TYPE node_load1 gauge
node_load1 3.0703125
```

其中，node_cpu{cpu="cpu0", mode="idle"} 362812.7890625表示一个采集到的监控样本。node_cpu、node_load1为指标名称，如果该样本的一些特征和维度，则可以通过大括号中的键值对进行标识，最后一个浮点型的数据则是该样本的具体值。

## 样本(Sample)

Prometheus按照时间发展先后顺序将这些样本数据保存在本地的时间数据库当中。唯一的指标名称和键值对的组合（例如:node_cpu{cpu="cpu0",mode="idle"}）定义了一条以时间为X轴的一条时间序列。如果将Prometheus存储的数据理解为一个二维的平面，如下所示：

```
  ^   
  │   . . . . . . . . . . . . . . . . .   . .   node_cpu{cpu="cpu0",mode="idle"}
  │     . . . . . . . . . . . . . . . . . . .   node_cpu{cpu="cpu0",mode="system"}
  │     . . . . . . . . . .   . . . . . . . .   node_load1{}
  │     . . . . . . . . . . . . . . . .   . .  
  v
    <------------------ 时间 ---------------->
```

时间序列中的每一个点称为一个Sample(样本)，每一个样本由以下三个部分组成：

* 指标(metric)：由指标名称和一组描述当前样本特征的键值对唯一定义。
* 时间戳(timestamp)：一个精确到毫秒的时间戳。
* 样本值(value)： 一个folat64的浮点型数据表示当前样本的值。

```
<--------------- metric ---------------------><-timestamp -><-value->
http_request_total{status="200", method="GET"}@1434417560938 => 94355
http_request_total{status="200", method="GET"}@1434417561287 => 94334

http_request_total{status="404", method="GET"}@1434417560938 => 38473
http_request_total{status="404", method="GET"}@1434417561287 => 38544

http_request_total{status="200", method="POST"}@1434417560938 => 4748
http_request_total{status="200", method="POST"}@1434417561287 => 4785
```

在Prometheus源码中通过以下结构体表示一个样本：

```golang
type Sample struct {
	Metric    Metric      `json:"metric"`
	Value     SampleValue `json:"value"`
	Timestamp Time        `json:"timestamp"`
}

type SampleValue float64
```

## 指标(Metric)

在形式上，所有的指标(Metric)都通过如下格式标示：

```
<metric name>{<label name>=<label value>, ...}
```

指标的名称(metric name)可以反映被监控系统的特征（比如，http_request_total - 标示当前系统接收到的Http请求总量）。指标名称只能由ASCII字符，数字，下划线以及冒号组成。每一个指标名称都必须符合正则表达式```[a-zA-Z_:][a-zA-Z0-9_:]*```。

而标签(label)则反映出当前样本数据的多个特征维度，通过这些维度Promtheus可以对样本数据进行过滤，聚合等复杂操作。Prometheus提供了强大的自定义查询语言PromQL对这些数据进行查询。标签的名称只能由ASCII字符，数字，以及下划线组成。每一个标签名必须满足正则表达式```[a-zA-Z_][a-zA-Z0-9_]*```。其中以__作为前缀的标签，是系统保留的关键字，只能在系统内部使用。标签的值则可以包含任何Unicode编码的字符。

例如，如果一条时间序列的指标名称为api_http_request_total并且标签为 method="POST"，handler="/message"可以表示为如下形式：

```
api_http_requests_total{method="POST", handler="/messages"}
```

在Prometheus源码中通过以下结构体定义了指标(Metric)的数据结构：

```
type Metric LabelSet

type LabelSet map[LabelName]LabelValue

type LabelName string

type LabelValue string
```

从代码中可以看出在底层实现中所有的Metric均是一组键值对，一组唯一的键值对定义了一条时间序列。而指标的名称<metric name>实际上是存储在标签```__name__```当中，因此通过以下两种PromQL的形式，都可以查询到响应的时间序列：

```
api_http_requests_total{method="POST", handler="/messages"}
# 等价于
{__name__="api_http_requests_total", method="POST", handler="/messages"}
```