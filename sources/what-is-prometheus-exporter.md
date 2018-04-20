# Exporter是什么

简单来说Exporter是指可以向Prometheus提供用于获取监控样本数据的应用程序实例。如下所示：

![Exporter](http://p2n2em8ut.bkt.clouddn.com/prometheus-exporter.png)

下面表格列举一些社区中常用的Exporter：

| 范围       |  常用Exporter |
|------     |-------------|
|   数据库   | MySQL Exporter, Redis Exporter, MongoDB Exporter, MSSQL Exporter等|
|   硬件    | Apcupsd Exporter，IoT Edison Exporter， IPMI Exporter, Node Exporter等   |
|   消息队列| Beanstalkd Exporter, Kafka Exporter, NSQ Exporter, RabbitMQ Exporter等 |
|   存储| Ceph Exporter, Gluster Exporter, HDFS Exporter, ScaleIO Exporter等|
|   HTTP服务 | Apache Exporter, HAProxy Exporter, Nginx Exporter等|
|   API服务| AWS ECS Exporter， Docker Cloud Exporter, Docker Hub Exporter, GitHub Exporter等 |
|   日志   | Fluentd Exporter, Grok Exporter等 |
|   监控系统 | Collectd Exporter, Graphite Exporter, InfluxDB Exporter, Nagios Exporter, SNMP Exporter等   |
|   其它| Blockbox Exporter, JIRA Exporter, Jenkins Exporter， Confluence Exporter等|

## 扩展Prometheus

除了这些社区直接提供的Exporter程序，Prometheus还提供了丰富的SDK。使用这些SDK用户可以快速实现自己的Exporter程序。目前Promthues社区官方提供了对以下编程语言的支持：Go、Java/Scala、Python、Ruby。同时还有第三方实现的如：Bash、C++、Common Lisp、Erlang,、Haskeel、Lua、Node.js、PHP、Rust等。

对于用户而言，一般可以在3种场景下使用Prometheus提供的这些SDK：

* 直接创建Exporter程序。当用户需要采集特定的监控指标时，可以使用SDK创建一个单独运行的Exporter程序。

* 直接在应用程序当中集成。 直接将对Prometheus的支持内置到应用程序当中，这种方式可以更好的监控应用(或者服务)的内部运行状态。目前开源社区中已经有很多软件件直接集成了对Prometheus的支持，例如：Ceph, Collectd, ETCD, Kubernetes, Linkerd，Telegraf等。

* 封装到公共库中。 用户可以把Promtheus SDK集成到公共库中，从而可以使得使用了这些公共库的应用程序透明地集成对Prometheus的支持。 目前开源社区中也有这样的例子，例如Clojure中的prometheus-clj，Java下的Hystrix metrics publisher都是这样的模式。

![Prometheus Client Library应用场景](http://p2n2em8ut.bkt.clouddn.com/client-library-usage.png)

## Exporter规范

无论是社区已有的Exporter程序还是基于Client Library实现的自定义Exporter，他们都需要按照Prometheus的格式规范返回监控样本数据。因此即使目前已有的Client Library还不支持你所使用的编程语言，你可以直接将监控样本转换为Promthues要求的格式即可。

以node exporter为例，当访问/metrics地址时会返回以下内容：

``` text
# HELP node_cpu Seconds the cpus spent in each mode.
# TYPE node_cpu counter
node_cpu{cpu="cpu0",mode="idle"} 362812.7890625
# HELP node_load1 1m load average.
# TYPE node_load1 gauge
node_load1 3.0703125
```

这是一种基于纯文本的格式规范。其中HELP用于解释当前指标的含义，TYPE则说明当前指标的数据类型。

除了通过纯文本的形式返回样本数据以外，Prometheus 2.0之前的版本还支持Protocol buffer的输出格式。虽然Protocol buffer有更好的性能，但是文本具有更好的可读性，以及跨平台性。Prometheus 2.0的版本也已经不再支持Protocol buffer，这里就不对Protocol buffer规范做详细的阐述。

纯文本格式要求Exporter通过HTTP协议以及UTF-8编码格式返回当前所有的监控样本。

其中HTTP响应的Header中需要定义Content-Type类型为**text/plain; version=0.0.4** 其中version用于指定Text-based的格式版本，当没有指定版本的时候，默认使用最新格式规范的版本。同时HTTP响应头还需要指定压缩格式Content-Encoding为gzip。以下是HTTP响应头信息的示例：

```
HTTP/1.1 200 OK
Content-Encoding: gzip
Content-Length: 2906
Content-Type: text/plain; version=0.0.4
Date: Sat, 17 Mar 2018 08:47:06 GMT
```

Prometheus会对内容逐行解析，在解析时Prometheus会按照空格或者是制表符对行内容进行分割。如果当前行是以#开头，那么Prometheus会认为当前行内容为注释内容。一般来说注释内容分为HELP或者TYPE。

如果当前行以# HELP开始，Promtheus将会按照以下规则对内容进行解析，得到当前的指标名称以及相应的说明信息：

``` text
# HELP <metrics_name> <doc_string>
```

如果当前行以# TYPE开始，Prometheus会按照以下规则对内容进行解析，得到当前的指标名称以及指标类型:

``` text
# TYPE <metrics_name> <metrics_type>
```

TYPE注释行必须出现在指标的第一个样本之前。如果没有当前指标类型会被定为为untyped。 除了# 开头的所有行都会被视为是监控样本数据。 每一行样本需要满足以下格式规范:

```
metric_name [
  "{" label_name "=" `"` label_value `"` { "," label_name "=" `"` label_value `"` } [ "," ] "}"
] value [ timestamp ]
```

其中metric_name和label_name必须遵循PromQL的格式规范要求。value是一个float格式的数据，timestamp的类型为int64（从1970-01-01 00:00:00以来的毫秒数），timestamp为可选默认为当前时间。具有相同metric_name的样本必须按照一个组的形式排列，并且每一行必须是唯一的指标名称和标签键值对组合。

需要特别注意的是对于histogram和summary类型的样本。需要按照以下约定返回样本数据：

* 类型为summary或者histogram的指标x，该指标所有样本的值的总和需要使用一个单独的x_sum指标表示。
* 类型为summary或者histogram的指标x，该指标所有样本的总数需要使用一个单独的x_count指标表示。

* 对于类型为summary的指标x，其不同分位数quantile所代表的样本，需要使用单独的x{quantile="y"}表示。
* 对于类型histogram的指标x为了表示其样本的分布情况，每一个分布需要使用x_bucket{le="y"}表示，其中y为当前分布的上位数。同时必须包含一个样本x_bucket{le="+Inf"}，并且其样本值必须和x_count相同。
* 对于histogram和summary的样本，必须按照分位数quantile和分布le的值的递增顺序排序。

以下是类型为histogram和summary的样本输出示例：

``` text
# A histogram, which has a pretty complex representation in the text format:
# HELP http_request_duration_seconds A histogram of the request duration.
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{le="0.05"} 24054
http_request_duration_seconds_bucket{le="0.1"} 33444
http_request_duration_seconds_bucket{le="0.2"} 100392
http_request_duration_seconds_bucket{le="+Inf"} 144320
http_request_duration_seconds_sum 53423
http_request_duration_seconds_count 144320

# Finally a summary, which has a complex representation, too:
# HELP rpc_duration_seconds A summary of the RPC duration in seconds.
# TYPE rpc_duration_seconds summary
rpc_duration_seconds{quantile="0.01"} 3102
rpc_duration_seconds{quantile="0.05"} 3272
rpc_duration_seconds{quantile="0.5"} 4773
rpc_duration_seconds_sum 1.7560473e+07
rpc_duration_seconds_count 2693
```

接下来，我们将带来读者了解常见Exporter的用法，以及如何使用Client Library实现自定义Exporter。