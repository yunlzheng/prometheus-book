# Metrics类型

之前我们讲过Prometheus对于所有的数据样本，使用了metrics name和labels唯一标示一条时间序列。而这些监控的样本数据，在不同的场景下又具有不同的意义。比如http_request_total采集到的监控样本数据反应的是当前系统的所有Http总量，因此当我们观察数据变化时，会发现对于一条http_request_total所反应的时序数据是一条持续增长的样本。而又比如container_cpu_usage一条时序数据则反映出的则是一条变化的曲线。

因为为了更好的定义这些不同场景下监控样本数据所代表的含义，Prometheus提供了四种指标类型(Metrics Type)。用以帮助开发人员更好的定义和使用这些监控指标。

这四种监控指标类型分别为：Counter, Gauge, Histogram, Summary。

### Counter：只增不减的计数器

计数器可以用于记录只会增加不会减少的指标类型,比如记录应用请求的总量(http_requests_total)，cpu使用时间(process_cpu_seconds_total)等。

对于Counter类型的指标，只包含一个inc()方法，用于计数器+1

一般而言，Counter类型的metrics指标在命名中我们使用_total结束。

通过指标io_namespace_http_requests_total我们可以：

* 查询应用的请求总量

```
# PromQL
sum(io_namespace_http_requests_total)
```

![](http://p2n2em8ut.bkt.clouddn.com/httP_request_total.png)

* 查询每秒Http请求量

```
# PromQL
sum(rate(io_wise2c_gateway_requests_total[5m]))
```

![](http://p2n2em8ut.bkt.clouddn.com/http_request_rate.png)

* 查询当前应用请求量Top N的URI

```
# PromQL
topk(10, sum(io_namespace_http_requests_total) by (path))
```

### Gauge: 可增可减的仪表盘

对于这类可增可减的指标，可以用于反应应用的__当前状态__,例如在监控主机时，主机当前空闲的内容大小(node_memory_MemFree)，可用内存大小(node_memory_MemAvailable)。或者容器当前的cpu使用率,内存使用率。

对于Gauge指标的对象则包含两个主要的方法inc()以及dec(),用户添加或者减少计数。在这里我们使用Gauge记录当前正在处理的Http请求数量。

通过指标io_namespace_http_inprogress_requests我们可以直接查询应用当前正在处理中的Http请求数量:

```
# PromQL
io_namespace_http_inprogress_requests{}
```

### Histogram: 自带分区统计的分布统计图

主要用于在指定分布范围内(Buckets)记录大小(如http request bytes)或者事件发生的次数。

以请求响应时间requests_latency_seconds为例，假如我们需要记录http请求响应时间符合在分布范围{.005, .01, .025, .05, .075, .1, .25, .5, .75, 1, 2.5, 5, 7.5, 10}中的次数时。

使用Histogram构造器可以创建Histogram监控指标。默认的buckets范围为{.005, .01, .025, .05, .075, .1, .25, .5, .75, 1, 2.5, 5, 7.5, 10}。如何需要覆盖默认的buckets，可以使用.buckets(double... buckets)覆盖。

Histogram会自动创建3个指标，分别为：

* 事件发生总次数： basename_count

```
# 实际含义： 当前一共发生了2次http请求
io_namespace_http_requests_latency_seconds_histogram_count{path="/",method="GET",code="200",} 2.0
```

* 所有事件产生值的大小的总和: basename_sum

```
# 实际含义： 发生的2次http请求总的响应时间为13.107670803000001 秒
io_namespace_http_requests_latency_seconds_histogram_sum{path="/",method="GET",code="200",} 13.107670803000001
```

* 事件产生的值分布在bucket中的次数： basename_bucket{le="上包含"}

```
# 在总共2次请求当中。http请求响应时间 <=0.005 秒 的请求次数为0
io_namespace_http_requests_latency_seconds_histogram_bucket{path="/",method="GET",code="200",le="0.005",} 0.0
# 在总共2次请求当中。http请求响应时间 <=0.01 秒 的请求次数为0
io_namespace_http_requests_latency_seconds_histogram_bucket{path="/",method="GET",code="200",le="0.01",} 0.0
# 在总共2次请求当中。http请求响应时间 <=0.025 秒 的请求次数为0
io_namespace_http_requests_latency_seconds_histogram_bucket{path="/",method="GET",code="200",le="0.025",} 0.0
io_namespace_http_requests_latency_seconds_histogram_bucket{path="/",method="GET",code="200",le="0.05",} 0.0
io_namespace_http_requests_latency_seconds_histogram_bucket{path="/",method="GET",code="200",le="0.075",} 0.0
io_namespace_http_requests_latency_seconds_histogram_bucket{path="/",method="GET",code="200",le="0.1",} 0.0
io_namespace_http_requests_latency_seconds_histogram_bucket{path="/",method="GET",code="200",le="0.25",} 0.0
io_namespace_http_requests_latency_seconds_histogram_bucket{path="/",method="GET",code="200",le="0.5",} 0.0
io_namespace_http_requests_latency_seconds_histogram_bucket{path="/",method="GET",code="200",le="0.75",} 0.0
io_namespace_http_requests_latency_seconds_histogram_bucket{path="/",method="GET",code="200",le="1.0",} 0.0
io_namespace_http_requests_latency_seconds_histogram_bucket{path="/",method="GET",code="200",le="2.5",} 0.0
io_namespace_http_requests_latency_seconds_histogram_bucket{path="/",method="GET",code="200",le="5.0",} 0.0
io_namespace_http_requests_latency_seconds_histogram_bucket{path="/",method="GET",code="200",le="7.5",} 2.0
# 在总共2次请求当中。http请求响应时间 <=10 秒 的请求次数为0
io_namespace_http_requests_latency_seconds_histogram_bucket{path="/",method="GET",code="200",le="10.0",} 2.0
# 在总共2次请求当中。http请求响应时间 10 秒 的请求次数为0
io_namespace_http_requests_latency_seconds_histogram_bucket{path="/",method="GET",code="200",le="+Inf",} 2.0
```

### Summary：客户端定义的分布统计图

Summary和Histogram非常类型相似，都可以统计事件发生的次数或者发小，以及其分布情况。

Summary和Histogram都提供了对于事件的计数_count以及值的汇总_sum。 因此使用_count,和_sum时间序列可以计算出相同的内容，例如http每秒的平均响应时间：rate(basename_sum[5m]) / rate(basename_count[5m])。

同时Summary和Histogram都可以计算和统计样本的分布情况，比如中位数，9分位数等等。其中 0.0<= 分位数Quantiles <= 1.0。

不同在于Histogram可以通过histogram_quantile函数在服务器端计算分位数。 而Sumamry的分位数则是直接在客户端进行定义。因此对于分位数的计算。 Summary在通过PromQL进行查询时有更好的性能表现，而Histogram则会消耗更多的资源。相对的对于客户端而言Histogram消耗的资源更少。

Summary指标，会对应多个时间序列：

* 事件发生总的次数

```
# 含义：当前http请求发生总次数为12次
io_namespace_http_requests_latency_seconds_summary_count{path="/",method="GET",code="200",} 12.0
```

* 事件产生的值的总和

```
# 含义：这12次http请求的总响应时间为 51.029495508s
io_namespace_http_requests_latency_seconds_summary_sum{path="/",method="GET",code="200",} 51.029495508
```

* 事件产生的值的分布情况

```
# 含义：这12次http请求响应时间的中位数是3.052404983s
io_namespace_http_requests_latency_seconds_summary{path="/",method="GET",code="200",quantile="0.5",} 3.052404983
# 含义：这12次http请求响应时间的9分位数是8.003261666s
io_namespace_http_requests_latency_seconds_summary{path="/",method="GET",code="200",quantile="0.9",} 8.003261666
```