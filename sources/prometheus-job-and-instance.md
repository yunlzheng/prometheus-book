# 任务和实例

在上一小节中，通过在prometheus.yml配置文件中，添加如下配置。我们让Prometheus可以从node exporter暴露的服务中获取监控指标数据。

```yaml
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
```

当我们需要采集不同的监控指标(例如：主机、MySQL、Nginx)时，我们只需要运行相应的监控采集程序，并且让Prometheus Server知道这些Exporter实例的访问地址。在Prometheus中，每一个暴露了用于被Prometheus采集数据的HTTP服务成为一个实例。例如在当前主机上运行的node exporter可以被成为一个实例(Instance)。

而一组用于相同采集目的的实例，或者同一个采集进程的多个副本则通过一个一个任务(Job)进行管理。

```
* job: node
    * instance 2: 1.2.3.4:9100
    * instance 4: 5.6.7.8:9100
```

当前在每一个Job中主要使用了静态配置(static_configs)的方式定义监控目标。除了静态配置每一个Job的采集Instance地址以外，Prometheus还支持与DNS、Consul、E2C、Kubernetes等进行集成实现自动发现Instance实例，并从这些Instance上获取监控数据。

除了通过使用“up”表达式查询当前所有Instance的状态以外，还可以通过Prometheus UI中的Targets页面查看当前所有的监控采集任务，以及各个任务下所有实例的状态:

![target列表以及状态](http://p2n2em8ut.bkt.clouddn.com/prometheus_ui_targets.png)

我们也可以访问[http://192.168.33.10:9090/targets](http://192.168.33.10:9090/targets)直接从Prometheus的UI中查看当前所有的任务以及每个任务对应的实例信息。

![Targets状态](http://p2n2em8ut.bkt.clouddn.com/prometheus_ui_targets_status.png)

