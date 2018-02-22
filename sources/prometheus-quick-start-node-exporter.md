# 使用NodeExporter监控主机

上一小节，我们已经部署了一个Prometheus Server的实例，并且通过修改Prometheus的配置文件，使Prometheus Server可以采集自身的监控指标。并且我们可以通过Prometheus内置的UI，直接对数据进行查询，过滤，聚合。还可以直接以图表的形式对数据进行展示。

除此之外也了解到，为了满足特定监控目的的需求，需要运行单独Exporter程序，从而使Prometheus Server可以从该Exporter暴露的监控端点获取监控数据。

接下来，我们将尝试通过部署Node Exporter实现对主机监控指标（CPU，内存，磁盘）的采集。

## 安装Node Exporter

#### 创建用户

```
sudo useradd --no-create-home node_exporter
```

#### 获取并安装软件包

```
cd ~
curl -LO https://github.com/prometheus/node_exporter/releases/download/v0.15.1/node_exporter-0.15.1.linux-amd64.tar.gz

tar xvf node_exporter-0.15.1.linux-amd64.tar.gz

sudo cp node_exporter-0.15.1.linux-amd64/node_exporter /usr/local/bin
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-0.15.1.linux-amd64.tar.gz node_exporter-0.15.1.linux-amd64
```

#### 创建Node Exporter的Service Unit文件

```
sudo vim /etc/systemd/system/node_exporter.service
```

```
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

#### 启动Node Exporter

```
service node_exporter start
```

NodeExporter启动后，访问[http://192.168.33.10:9100/metrics](http://192.168.33.10:9100/metrics)，我们可以获取到当前NodeExporter所在主机的当前资源使用情况的监控数据。

![http://p2n2em8ut.bkt.clouddn.com/node_exporter_metrics.png](http://p2n2em8ut.bkt.clouddn.com/node_exporter_metrics.png)

## 配置主机监控采集任务

#### 配置Prometheus采集主机信息

编辑配置文件/etc/prometheus/prometheus.yml，并添加以下内容：

```
    - job_name: 'node_exporter'
        scrape_interval: 5s
        static_configs:
        - targets: ['localhost:9100']
```

这里我们添加了一个新的Job名字为node_exporter。并且定义了一个实例为localhost:9100。

完整的Prometheus配置文件/etc/prometheus/prometheus.yml如下：

```
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
```

重新启动Prometheus Server

```
sudo service prometheus restart
```

#### 验证结果

访问[http://192.168.33.10:9090/targets](http://192.168.33.10:9090/targets)查看所有的采集目标实例，这时我们可以看到新的采集任务：node_exporter以及相应的实例。

![http://p2n2em8ut.bkt.clouddn.com/node_exporter_targets.png](http://p2n2em8ut.bkt.clouddn.com/node_exporter_targets.png)

这是我们可以通过PromQL语言在，Prometheus UI上直接查询主机相关资源的使用情况。

例如:

按CPU模式查询主机的CPU使用率：

```
avg without (cpu)(irate(node_cpu{mode!="idle"}[5m]))
```

![](http://p2n2em8ut.bkt.clouddn.com/host_stats_cpu.png)

按主机查询主机内存使用量：

```
sum(node_memory_MemTotal - node_memory_MemFree - node_memory_Buffers - node_memory_Cached) by (instance)
```

![](http://p2n2em8ut.bkt.clouddn.com/host_stats_mem_used.png)

按主机查询各个磁盘的IO状态:

```
sum(irate(node_disk_io_time_ms{device!~'^(md\\\\d+$|dm-)'}[5m]) / 1000) by (instance, device)
```

![](http://p2n2em8ut.bkt.clouddn.com/host_status_disk_io.png)