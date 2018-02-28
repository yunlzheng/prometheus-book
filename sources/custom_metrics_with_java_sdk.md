## 使用Spring Boot创建自定义Exporter

一般来说在Prometheus社区我们能够找到大量已经实现的Exporter，例如监控主机时我们会使用Node Exporter，监控Mysql数据库时我们会用到Mysql Exporter。监控容器的运行指标时，则使用cAdvisor。

而在一些情况下我们可能需要实现自己的Exporter。例如我们要获取一些业务相关的监控指标，又或者是现成的Exporter无法直接提供我们需要的监控指标时，我们需要创建自定义的Exporter或者对现有Exporter进行补充。

这一部分我们将介绍如何在Spring Boot基础上使用Prometheus Java Client实现自定义Exporter用于采集Docker Runtime Metrics数据。

### 指标类型

Prometheus中定义了四种指标类型： Counter、Gauge、Histogram以及Summary。先回顾一下这四种基本类型的定义以及使用场景

* Counter计数器，只增不减
* Gauge用于反映当前状态，可增可减
* Summary用于统计监控数据的大小或者事件发生的次数
* Histogram主要用于统计监控数据的大小或者事件发生的次数的分布情况

### Docker Runtime Metrics API

在使用Docker的过程中如果我们需要查看某些容器的运行时指标数据时，我们会使用docker stats命令来查看该容器的实时状态。

```
$ docker stats redis1 redis2
CONTAINER           CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O
redis1              0.07%               796 KB / 64 MB        1.21%               788 B / 648 B       3.568 MB / 512 KB
redis2              0.07%               2.746 MB / 64 MB      4.29%               1.266 KB / 648 B    12.4 MB / 0 B
```

该命令会返回当前容器的CPU使用率，内存用量，内存使用率，以及网络IO等数据。基于这些指标我们可以获取并判断容器的一些基本状态