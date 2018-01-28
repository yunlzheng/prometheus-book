## 指标类型Metric Type

之前我们讲过Prometheus对于所有的数据样本，使用了metrics name和labels唯一标示一条时间序列。而这些监控的样本数据，在不同的场景下又具有不同的意义。比如http_request_total采集到的监控样本数据反应的是当前系统的所有Http总量，因此当我们观察数据变化时，会发现对于一条http_request_total所反应的时序数据是一条持续增长的样本。而又比如container_cpu_usage一条时序数据则反映出的则是一条变化的曲线。

因为为了更好的定义这些不同场景下监控样本数据所代表的含义，Prometheus提供了四种指标类型(Metrics Type)。用以帮助开发人员更好的定义和使用这些监控指标。

这四种监控指标类型分别为：Counter, Gauge, Histogram, Summary。

### Counter：只增不减的计数器

Counter类型好比计数器，用于统计类似于：CPU使用时间，API访问总次数，异常发生次数等等场景。这些指标的特点就是增加不减少。

![](http://7pn5d3.com1.z0.glb.clouddn.com/blog/prometheus_counter.jpeg)

Counter类型，Counter类型好比计数器，用于统计类似于：CPU时间，API访问总次数，异常发生次数等等场景。这些指标的特点就是增加不减少。

Example: 容器CPU使用率

在使用cAdvisor采集容器数据时，我们会得到监控指标**container_cpu_user_seconds_total**，该指标的的数据类型为Counter用户反映当前容器在各个CPU内核上已经使用的CPU总时间。

通过Prometheus直接查询该指标我们会得到以下数据

```
container_cpu_usage_seconds_total{beta_kubernetes_io_arch="amd64",beta_kubernetes_io_os="linux",container_name="mysql",cpu="cpu03",id="/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod74ab5e96_6209_11e7_9990_00163e122a49.slice/docker-fb332c4ede82562be6eaebe3eef6376d3f37b3402a7fd570c7c95f8963012c0b.scope",image="docker.io/mysql@sha256:d178dffba8d81afedc251498e227607934636e06228ac63d58b72f9e9ec271a6",instance="dev-4",job="kubernetes-nodes",kubernetes_io_hostname="dev-4",name="k8s_mysql_go-todo-mysql-3723120250-vf8wx_default_74ab5e96-6209-11e7-9990-00163e122a49_0",namespace="default",pod_name="go-todo-mysql-3723120250-vf8wx"}
container_cpu_usage_seconds_total{beta_kubernetes_io_arch="amd64",beta_kubernetes_io_os="linux",container_name="mysql",cpu="cpu01",id="/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod74ab5e96_6209_11e7_9990_00163e122a49.slice/docker-fb332c4ede82562be6eaebe3eef6376d3f37b3402a7fd570c7c95f8963012c0b.scope",image="docker.io/mysql@sha256:d178dffba8d81afedc251498e227607934636e06228ac63d58b72f9e9ec271a6",instance="dev-4",job="kubernetes-nodes",kubernetes_io_hostname="dev-4",name="k8s_mysql_go-todo-mysql-3723120250-vf8wx_default_74ab5e96-6209-11e7-9990-00163e122a49_0",namespace="default",pod_name="go-todo-mysql-3723120250-vf8wx"}
```

如果使用图形化查询我们可以看出

![](http://7pn5d3.com1.z0.glb.clouddn.com/blog/prometheus_cpu_counter.png)

因此当我们需要统计容器CPU的使用率时，我们需要使用rate()函数计算该Counter在过去一段时间内在每一个时间序列上的每秒的平均增长率

```
rate(container_cpu_user_seconds_total[5m]) * 100
```

![](http://7pn5d3.com1.z0.glb.clouddn.com/blog/prometheus_cpu_usgae.png)

![](http://7pn5d3.com1.z0.glb.clouddn.com/blog/prometheus_guage.jpg)

### Gauge: 可增可减的仪表盘

Gauge类型，英文直译的话叫“计量器”，但是和Counter的翻译太类似了，因此我个人更喜欢使用”仪表盘“这个称呼。仪表盘的特点就是数值是可以增加或者减少的。因此Gauge适合用于如：当前内存使用率，当前CPU使用率，当前温度，当前速度等等一系列的监控指标。

Example：主机负载信息

在使用NodeExporter时，指标node_load1可以反映当前主机的负载情况，而其类型则是Gauge，因此在查询主机负载变化时比较简单，直接使用node_load1即可查询出当前所有主机的负载情况

```
node_load1{app="node-exporter",instance="192.168.2.2:9100",job="kubernetes-service-endpoints",kubernetes_name="node-exporter",kubernetes_namespace="default",name="node-exporter",nodeIp="192.168.2.2:9100"}
node_load1{app="node-exporter",instance="192.168.2.3:9100",job="kubernetes-service-endpoints",kubernetes_name="node-exporter",kubernetes_namespace="default",name="node-exporter",nodeIp="192.168.2.3:9100"}
```

![](http://7pn5d3.com1.z0.glb.clouddn.com/prometheus_node_load.png)

### Histogram: 自带分区统计的分布统计图

![](http://7pn5d3.com1.z0.glb.clouddn.com/blog/prometheus_histogram.png)

Histogram这个比较直接柱状图图，更多的是用于统计一些数据分布的情况，用于计算在一定范围内的分布情况，同时还提供了度量指标值的总和。

Example：
以Kubernates的API Server度量指标apiserver_request_latencies为例，该指标反映了Kubernates的API请求响应延迟时间。该指标会在一次监控数据抓取过程中返回2中Metrics Key

```
apiserver_request_latencies_bucket
apiserver_request_latencies_count
apiserver_request_latencies_sum
```

apiserver_request_latencies_bucket反映在各个API响应延迟范围(le)内总数

```
apiserver_request_latencies_bucket{instance="192.168.2.2:6443",job="kubernetes-apiservers",le="+Inf",resource="podpresets",verb="WATCH"}	773
apiserver_request_latencies_bucket{instance="192.168.2.2:6443",job="kubernetes-apiservers",le="500000",resource="endpoints",verb="DELETE"}	85
apiserver_request_latencies_bucket{instance="192.168.2.2:6443",job="kubernetes-apiservers",le="1e+06",resource="configmaps",verb="PUT"}	1
apiserver_request_latencies_bucket{instance="192.168.2.2:6443",job="kubernetes-apiservers",le="1e+06",resource="daemonsets",verb="WATCHLIST"}	0
apiserver_request_latencies_bucket{instance="192.168.2.2:6443",job="kubernetes-apiservers",le="2e+06",resource="replicationcontrollers",verb="GET"}	6
apiserver_request_latencies_bucket{instance="192.168.2.2:6443",job="kubernetes-apiservers",le="125000",resource="deployments",verb="PATCH"}	12
apiserver_request_latencies_bucket{instance="192.168.2.2:6443",job="kubernetes-apiservers",le="+Inf",resource="configmaps",verb="DELETE"}	9
apiserver_request_latencies_bucket{instance="192.168.2.2:6443",job="kubernetes-apiservers",le="125000",resource="replicasets",verb="GET"}	1331
apiserver_request_latencies_bucket{instance="192.168.2.2:6443",job="kubernetes-apiservers",le="+Inf",resource="persistentvolumes",verb="LIST"}	3
```

apiserver_request_latencies_count反映对各个资源API的请求次数

```
apiserver_request_latencies_count{instance="192.168.2.2:6443",job="kubernetes-apiservers",resource="replicasets",verb="PUT"}	3030
apiserver_request_latencies_count{instance="192.168.2.2:6443",job="kubernetes-apiservers",resource="deployments",verb="PUT"}	2454
apiserver_request_latencies_count{instance="192.168.2.2:6443",job="kubernetes-apiservers",resource="clusterroles",verb="WATCH"}	1527
apiserver_request_latencies_count{instance="192.168.2.2:6443",job="kubernetes-apiservers",resource="replicationcontrollers",verb="WATCHLIST"}	7
apiserver_request_latencies_count{instance="192.168.2.2:6443",job="kubernetes-apiservers",resource="clusterroles",verb="POST"}	42
apiserver_request_latencies_count{instance="192.168.2.2:6443",job="kubernetes-apiservers",resource="resourcequotas",verb="LIST"}	304
apiserver_request_latencies_count{instance="192.168.2.2:6443",job="kubernetes-apiservers",resource="pods",verb="DELETE"}	913
```

而apiserver_request_latencies_sum则反映出对各个资源API操作延迟时间的总量

```
apiserver_request_latencies_sum{instance="192.168.2.2:6443",job="kubernetes-apiservers",resource="replicationcontrollers",verb="LIST"}	554991
apiserver_request_latencies_sum{instance="192.168.2.2:6443",job="kubernetes-apiservers",resource="clusterroles",verb="LIST"}	33586061
apiserver_request_latencies_sum{instance="192.168.2.2:6443",job="kubernetes-apiservers",resource="configmaps",verb="DELETE"}	16466
apiserver_request_latencies_sum{instance="192.168.2.2:6443",job="kubernetes-apiservers",resource="pods",verb="WATCH"}	3430725671235
apiserver_request_latencies_sum{instance="192.168.2.2:6443",job="kubernetes-apiservers",resource="secrets",verb="LIST"}	5843
apiserver_request_latencies_sum{instance="192.168.2.2:6443",job="kubernetes-apiservers",resource="nodes",verb="LIST"}	92849
apiserver_request_latencies_sum{instance="192.168.2.2:6443",job="kubernetes-apiservers",resource="persistentvolumes",verb="LIST"}	9302
apiserver_request_latencies_sum{instance="192.168.2.2:6443",job="kubernetes-apiservers",resource="serviceaccounts",verb="WATCH"}	1378625982766
```

在Exporter获取的度量指标当中通常会以一下形式表现：

```
<base_name>_bucket{ label1=value1, label2=value2 }
```

### Summary：客户端定义的分布统计图

![](http://7pn5d3.com1.z0.glb.clouddn.com/blog/prometheus_summary.png)

Summary摘要和Histogram柱状图比较类似，主要用于计算在一定时间窗口范围内度量指标对象的总数以及所有对量指标值的总和。

例如：

apiserver_request_latencies_summary
apiserver_request_latencies_summary_count
apiserver_request_latencies_summary_sum