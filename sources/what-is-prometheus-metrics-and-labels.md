## 什么是Metrics和Labels

### 理解时序数据模型

在之前的部分我们讲Prometheus除了是监控系统以外，本身也是一个时序（time series）数据库。从本质上将Prometheus将所有的数据，按照时间序列进行存储。每一条时间序列都通过唯一定义的指标名称即Metric名称以及一组key-value的键值对组成，这组键值对被称为Labels。

对于所有采集到的样本数据都有一下几部分组成：

* 指标名称Mrtics,
* 用于描述样本的维度的键值对Labels
* 样本的采集时间
* 当前样本的值。

```
<--Metrics Name--><--------Labels-----------><--Timestamp--><-Value->
http_request_total{status="200", method="GET"}@1434417560938 => 94355
http_request_total{status="200", method="GET"}@1434417561287 => 94334
http_request_total{status="200", method="GET"}@1434417562344 => 94383

http_request_total{status="404", method="GET"}@1434417560938 => 38473
http_request_total{status="404", method="GET"}@1434417561287 => 38544
http_request_total{status="404", method="GET"}@1434417562344 => 38663

http_request_total{status="200", method="POST"}@1434417560938 => 4748
http_request_total{status="200", method="POST"}@1434417561287 => 4785
http_request_total{status="200", method="POST"}@1434417562344 => 4833
```

如果将Prometheus存储的数据理解为一个二维的平面，如下所示，我们则可以看到每一个唯一的指标名称+键值对采集到的样本数据，组成了以时间为X轴的一条间序数据。

```
series
  ^   
  │   . . . . . . . . . . . . . . . . .   . . . . .   request_total{path="/status",method="GET"}
  │     . . . . . . . . . . . . . . . . . . . . . .   request_total{path="/",method="POST"}
  │         . . . . . . .
  │       . . .     . . . . . . . . . . . . . . . .                  ... 
  │     . . . . . . . . . . . . . . . . .   . . . .   
  │     . . . . . . . . . .   . . . . . . . . . . .   errors_total{path="/status",method="POST"}
  │           . . .   . . . . . . . . .   . . . . .   errors_total{path="/health",method="GET"}
  │         . . . . . . . . .       . . . . .
  │       . . .     . . . . . . . . . . . . . . . .                  ... 
  │     . . . . . . . . . . . . . . . .   . . . . 
  v
    <-------------------- time --------------------->
```

### 指标名称和标签

指标的名称可以反映被监控系统的特征（比如，http_request_total - 标示当前系统接收到的Http请求总量）。指标名称只能由ASCII字符，数字，下划线以及冒号组成。每一个指标名称都必须符合正则表达式```[a-zA-Z_:][a-zA-Z0-9_:]*```。

而标签则反映出当前样本数据的多个特征维度，通过这些维度Promtheus可以对样本数据进行过滤，聚合等复杂操作。Prometheus提供了强大的自定义查询预言PromQL对这些数据进行查询。标签的名称只能由ASCII字符，数字，以及下划线组成。每一个标签名必须满足正则表达式```[a-zA-Z_][a-zA-Z0-9_]*```。其中以__作为前缀的标签，是系统保留的关键字，只能在系统内部使用。标签的值则可以包含任何Unicode编码的字符。

### 样本

在时序数据库中存储的每一个样本都有两个部分组成：

* 一个folat64的浮点型数据表示当前样本的值
* 一个精确到毫秒的时间戳

### 表示方法

通过给定的指标名称以及一组标签，可以唯一定义一条时间序列：

```
<metric name>{<label name>=<label value>, ...}
```

例如，如果一条时间序列的指标名称为api_http_request_total并且标签为 method="POST"，handler="/message"可以表示为如下形式：

```
api_http_requests_total{method="POST", handler="/messages"}
```
