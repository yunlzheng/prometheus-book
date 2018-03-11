# Alertmanager高可用

在前面的部分我们主要讨论了Promethues Server自身的高可用问题。而接下来，重点将放在告警处理也就是Alertmanager部分。如下所示。

![Alertmanager成为单点](http://p2n2em8ut.bkt.clouddn.com/prom-ha-with-single-am.png)

为了提升Promthues的服务可用性，通常用户会部署两个或者两个以上的Promthus Server，它们具有完全相同的配置包括Job配置，以及告警配置等。当某一个Promethues Server发生故障后可以去报Promthues持续可用。

同时基于Alertmanager的告警分组机制即使不同的Promtheus Sever分别发送相同的告警给Alertmanager，Alertmanager也可以自动将这些告警合并为一个通知向receiver发送。

![Alertmanager特性](http://p2n2em8ut.bkt.clouddn.com/alertmanager-features.png)

但不幸的是，虽然Alertmanager能够同时处理多个相同的Promthues Server所产生的告警。但是由于单个Alertmanager的存在，当前的部署结构存在明显的单点故障风险，当Alertmanager单点失效后，告警的后续所有业务全部失效。

如下所示，最直接的方式，就是尝试部署多套Alertmanager。但是由于ALertmanager之间不存在并不了解彼此的存在，因此则会出现告警通知被不同的Alertmanager重复发送多次的问题。

![](http://p2n2em8ut.bkt.clouddn.com/prom-ha-with-double-am.png)

为了解决这一问题，如下所示。Alertmanager引入了Gossip机制。Gossip机制为多个Alertmanager之间提供了信息传递的机制。确保及时在多个Alertmanager分别接收到相同告警信息的情况下，也只有一个告警通知被发送给Receiver。

![Alertmanager Gossip](http://p2n2em8ut.bkt.clouddn.com/prom-ha-with-am-gossip.png)

## Gossip机制

要理解Gossip机制，首先需要了解Alertmanager中的一次告警通知是如何产生的，如下所示，Alertmanager通过流水线的形式处理告警通知：

![通知流水线](http://p2n2em8ut.bkt.clouddn.com/am-notifi-pipeline.png)

1. 在流水线的第一个阶段Silence中，Alertmanager会判断当前通知是否匹配到任何的静默规则，如果没有则进入下一个阶段，否则则中断流水线不发送通知。
2. 在第二个阶段Wait中，Alertmanager会根据当前Alertmanager在集群中所在的顺序(index)等待index * 5s的时间。
3. 当前Alertmanager等待阶段结束后，Dedup阶段则会判断当前Alertmanager数据库中该改进是否已经发送，如果已经发送则中断流水线，不发送告警，否则则进入下一阶段Send对外发送告警通知。
4. 告警发送完成后该Alertmanager进入最后一个阶段Gossip，Gossip会通知其他Alertmanager实例当前告警已经发送。其他实例接收到Gossip消息后，则会在自己的数据库中保存该通知已发送的记录。

因此如下所示，Gossip机制的关键在于两点：

![Gossip机制](http://p2n2em8ut.bkt.clouddn.com/am-gossip.png)

* Alertmanager实例之间需要保证Silence设置完全相同。这样可以确保被设置为静默的告警都不会对外通知。
* Alertmanager通过Gossip机制同步告警通知状态，同时流水线中定义Wait阶段确保告警依次被集群中的Alertmanager处理。

Alertmanager基于Gossip实现的集群机制虽然不能保证所有实例上的数据时刻保持一致，但是实现了CAP理论中的AP系统，即可用性和分区容错性。同时对于Promethues Server而言保持了配置了简单性，Promthues Server之间不需要任何的状态同步。

## 配置Alertmanager集群

为了能够让Alertmanager节点之间进行通讯，需要在Alertmanager启动时设置相应的参数。其中主要的参数包括：

* --cluster.listen-address string: 当前实例集群服务监听地址
* --cluster.peer value: 初始化时关联的其它实例的集群服务地址

例如：

定义Alertmanager实例a1，其中Alertmanager的服务运行在9093端口，集群服务地址运行在8001端口。

```
alertmanager  --web.listen-address=":9093" --cluster.listen-address="127.0.0.1:8001" --config.file=/etc/prometheus/alertmanager.yml  --storage.path=/data/alertmanager/ 
```

定义Alertmanager实例a2，其中主服务运行在9094端口，集群服务运行在8002端口。为了将a1，a2组成集群。 a2启动时需要定义--cluster.peer参数并且指向a1实例的集群服务地址:8001。

```
alertmanager  --web.listen-address=":9094" --cluster.listen-address="127.0.0.1:8002" --cluster.peer=127.0.0.1:8001 --config.file=/etc/prometheus/alertmanager.yml  --storage.path=/data/alertmanager2/
```

为了能够在本地模拟集群环境，这里使用了一个轻量级的多线程管理工具goreman。使用以下命令可以在本地安装goreman命令行工具。

```
go get github.com/mattn/goreman
```

创建Procfile文件，并且定义了三个Alertmanager节点（a1，a2，a3）

```
a1: alertmanager  --web.listen-address=":9093" --cluster.listen-address="127.0.0.1:8001" --config.file=/etc/prometheus/alertmanager.yml  --storage.path=/data/alertmanager/ --log.level=debug
a2: alertmanager  --web.listen-address=":9094" --cluster.listen-address="127.0.0.1:8002" --cluster.peer=127.0.0.1:8001 --config.file=/etc/prometheus/alertmanager.yml  --storage.path=/data/alertmanager2/ --log.level=debug
a3: alertmanager  --web.listen-address=":9095" --cluster.listen-address="127.0.0.1:8003" --cluster.peer=127.0.0.1:8001 --config.file=/etc/prometheus/alertmanager.yml  --storage.path=/data/alertmanager2/ --log.level=debug

p1: prometheus --config.file=/etc/prometheus/prometheus-ha.yml --storage.tsdb.path=/data/prometheus/ --web.listen-address="127.0.0.1:9090"
p2: prometheus --config.file=/etc/prometheus/prometheus-ha.yml --storage.tsdb.path=/data/prometheus2/ --web.listen-address="127.0.0.1:9091"

node_exporter: node_exporter -web.listen-address="0.0.0.0:9100"
```

在Procfile文件所在目录，执行goreman start命令，启动所有进程:

```
goreman start
```

启动完成后访问任意Alertmanager节点[http://localhost:9093/#/status](http://localhost:9093/#/status),可以查看当前Alertmanager集群的状态。

![Alertmanager集群状态](http://p2n2em8ut.bkt.clouddn.com/am-ha-status.png)

> 注意：当集群中的Alertmanager节点不在一台主机时，通常需要使用--cluster.advertise-address参数指定当前节点所在网络地址。

对于Promethues实例而言，需要配置集群中所有Alertmanager实例，prometheus-ha.yml配置文件内容如下:

```
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - 127.0.0.1:9093
      - 127.0.0.1:9094
      - 127.0.0.1:9095
```