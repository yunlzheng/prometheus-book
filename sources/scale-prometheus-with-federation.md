# 联邦集群

单个Prometheus Server可以轻松的处理数以百万的时间序列。当然根据规模的不同的变化，Prometheus同样可以轻松的进行扩展。本小节将会介绍利用Prometheus的联邦集群特性，对Prometheus进行扩展。

## 使用联邦集群

Prometheus支持使用联邦集群的方式，对Prometheus进行扩展。对于大部分监控规模而言，我们只需要在每一个数据中心(例如：EC2可用区，Kubernetes集群)安装一个Prometheus Server实例，就可以在各个数据中心处理上千规模的集群。同时将Prometheus Server部署到不同的数据中心可以避免网络配置的复杂性。

![联邦集群](http://p2n2em8ut.bkt.clouddn.com/prometheus-federation.png)

如上图所示，在每个数据中心部署单独的Prometheus Server用于采集当前数据中心监控数据。并由一个中心的Prometheus Server负责聚合多个数据中心的监控数据。

每一个Prometheus Server实例包含一个/federate接口，用于获取一组指定的时间序列的监控数据。因此在中心Prometheus Server中只需要配置一个采集任务用于从其他Prometheus Server中获取监控数据。

```
scrape_configs:
  - job_name: 'federate'
    scrape_interval: 15s
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
        - '{job="prometheus"}'
        - '{__name__=~"job:.*"}'
        - '{__name__=~"node.*"}'
    static_configs:
      - targets:
        - '192.168.77.11:9090'
        - '192.168.77.12:9090'
```

通过params可以用于控制Prometheus Server向Target实例请求监控数据的URL当中添加请求参数。例如：

```
"http://192.168.77.11:9090/federate?match[]={job%3D"prometheus"}&match[]={__name__%3D~"job%3A.*"}&match[]={__name__%3D~"node.*"}"
```

通过URL中的match[]参数指定我们可以指定需要获取的时间序列。match[]参数必须是一个瞬时向量选择器，例如up或者{job="api-server"}。配置多个match[]参数，用于获取多组时间序列的监控数据。

horbor_labels配置true可以确保当采集到的监控指标冲突时，能够自动忽略冲突的监控数据。如果为false时，prometheus会自动将冲突的标签替换为”exported_<original-label>“的形式。

## 功能分区

而当你的监控大道单个Prometheus Server无法处理的情况下，我们可以在各个数据中心中部署多个Prometheus Server实例。每一个Prometheus Server实例只负责采集当前数据中心中的一部分任务(Job)，例如可以将应用监控和主机监控分离到不同的Prometheus实例当中。

![功能分区](http://p2n2em8ut.bkt.clouddn.com/prometheus-sharding.png)

假如监控采集任务的规模继续增大，通过功能分区的方式可以进一步细化采集任务。对于中心Prometheus Server只需要从这些实例中聚合数据即可。

功能分区，即通过联邦集群的特性在任务级别对Prometheus采集任务进行划分，以支持规模的扩展。