# Exporter是什么

简单来说Promtheus中Exporter是指用于获取特定监控样本应用程序，这些应用程序使用HTTP服务的形式向Promthues暴露可以获取到当前监控样本数据的资源地址(一般约定使用/metrics)。如下所示：

![Exporter](http://p2n2em8ut.bkt.clouddn.com/prometheus-exporter.png)

## Client Libraries

为了让社区和用户可以快速实现对Prometheus的支持，Promethues官方以及第三方提供了大量可选的Client Library。基于这些Client Library用户可以实现自己的Exporter程序，或者直接在应用程序中进行集成，从而可以避免部署和管理多个应用程序。


目前Promthues社区官方提供了以下编程语言的Client Library支持：Go，Java/Scala，Python， Ruby。同时还有第三方实现的Client Library：Bash, C++, Common Lisp, Erlang, Haskeel, Lua, Node.js， PHP, Rust等等。

当Prometheus来获取监控样本时，这些Client Library会通过Promthues要求的格式规范将当前系统中记录的所有指标返回给Promtheus。

如果目前Client Library还不支持你所使用的应用程序，你可以直接将监控样本转换为Promthues要求的格式即可。

## Exporter格式规范

在前面章节中已经了解过范根node exporter的/metrics地址会返回以下格式响应内容：

```
# HELP node_cpu Seconds the cpus spent in each mode.
# TYPE node_cpu counter
node_cpu{cpu="cpu0",mode="idle"} 362812.7890625
# HELP node_load1 1m load average.
# TYPE node_load1 gauge
node_load1 3.0703125
```

其中HELP用于解释当前指标的含义，TYPE则说明当前指标的数据类型。

除了类似node exporter这样通过纯文本的形式返回样本数据以外，Prometheus 2.0之前的版本还支持Protocol buffer的输出格式。虽然Protocol buffer有更好的性能，但是文本具有更好的可读性，以及垮平台性。

> Prometheus 2.0的版本将不在支持Protocol buffer，因此这里也不对Protocol buffer规范做详细的阐述。

纯文本格式要求Exporter通过HTTP协议以UTF-8编码返回当前所有的监控样本。

其中HTTP响应的Header中需要定义Content-Type类型为**text/plain; version=0.0.4** 其中version用于指定Text-based的格式版本，当没有指定版本的时候，默认使用最新格式规范的版本。同时HTTP响应头还需要指定压缩格式Content-Encoding为gzip。以下，是HTTP响应头信息的示例：

```
HTTP/1.1 200 OK
Content-Encoding: gzip
Content-Length: 2906
Content-Type: text/plain; version=0.0.4
Date: Sat, 17 Mar 2018 08:47:06 GMT
```

Prometheus会按照行对响应的文本内容进行解析，并且响应的最后一行必须以换行符结束，在解析时Prometheus会按照空格或者是制表符对行内容进行分割。如果当前行是以#开头，那么Prometheus会认为当前行内容为注释内容。一般来说注释内容分为HELP或者TYPE。

如果当前行以 # HELP开始，Promtheus将会按照以下规则对内容进行解析：

```
# HELP <metrics_name> <doc_string>
```

例如：

```
# HELP http_requests_total The total number of HTTP requests.
```

HELP后的第一个部分为指标名称即http_requests_total，余下剩余的所有部分都被认为是对该指标的注释文档。

如果当前行以 # TYPE开始，Prometheus会按照以下规则对内容进行接信息:

```
# TYPE <metrics_name> <metrics_type>
```

例如：

```
# TYPE http_requests_total counter
```

表示当前指标名称为http_requests_total并且类型为counter。

TYPE注释行必须出现在指标的第一个样本之前。如果没有当前指标类型会被定为为untyped。 除了# 开头的所有行都会被视为是监控样本数据。 每一行样本需要满足以下格式规范:

```
metric_name [
  "{" label_name "=" `"` label_value `"` { "," label_name "=" `"` label_value `"` } [ "," ] "}"
] value [ timestamp ]
```

其中metric_name和label_name必需遵循PromQL的格式规范要求。value是一个float格式的数据，timestamp的类型为int64（从1970-01-01 00:00:00依赖的毫秒数）。具有相同metric_name的样本必需按照一个组的形式排列，并且每一行必需是唯一的指标名称和标签键值对。

需要特别注意的是对于histogram和summary类型的样本。需要按照以下约定返回样本数据：

* 类型为summary或者histogram的指标x，该指标所有样本的值的总和需要使用一个单独的x_sum指标表示。
* 类型为summary或者histogram的指标x，该指标所有样本的总数需要使用一个单独的x_count指标表示。

* 对于类型为summary的指标x，其不同分位数quantile所代表的样本，需要使用单独的x{quantile="y"}表示。
* 对于类型histogram的指标x为了表示其样本的分布情况，其中每一个分布需要使用x_bucket{le="y"}表示，其中y为当前分布的上位数。同时必须包含一个样本x_bucket{le="+Inf"}，并且其样本值必须和x_count相同。
* 对于histogram和summary的样本必须按照分位数quantile和分布le的值的递增顺序排序。

以下是类型为histogram和summary的样本输出示例：

```
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

## 使用Client Library的场景

对于用户而言，一般可以在以下三种场景中使用Prometheus的Client Library：

![Prometheus Client Library应用场景](http://p2n2em8ut.bkt.clouddn.com/client-library-usage.png)

第一种，创建Exporter程序。当用户需要采集特定的监控指标时，可以使用Client Library创建一个单独的Exporter程序。目前Prometheus官方以及第三方已经实现了大量的Exporter可以满足用户巨大多数的监控需求。

下面表格列举一些常用的Exporter：

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

> 读者可以从[https://prometheus.io/docs/instrumenting/exporters/](https://prometheus.io/docs/instrumenting/exporters/)获取最新的Exporter列表。

第二种，直接在应用程序当中集成。独立运行的Exporter程序以外， 用户还可以直接在软件当中集成Client Library，以支持向Promthues暴露监控指标，从而不需要运行独立的Exporter程序。目前在开源社区中已经有很多软件件直接集成了对Prometheus的支持，，例如：Ceph, Collectd, ETCD, Kubernetes, Linkerd，Telegraf等。

第三种，封装到公共库中。用于直接在用户自己的公共库中集成Prometheus Client Library。从而可以使得使用了这些公共库的应用程序透明的集成对Prometheus的支持。目前开源社区中也有这样的例子，例如Clojure中的prometheus-clj，Java下的Hystrix metrics publisher都是这样的模式。

接下来，将带来读者了解常见Exporter的用法。