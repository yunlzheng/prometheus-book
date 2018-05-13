# 目录

* [全书组织](Introduction.md)

## Part I - Prometheus基础

* [第1章 天降奇兵](./chapter0/README.md)
  * [Prometheus简介](./sources/why-monitor.md)
  * [初识Prometheus](./sources/prometheus-quick-start.md)
  * [任务和实例](./sources/prometheus-job-and-instance.md)
  * [Prometheus核心组件](./sources/prometheus-architecture-and-components.md)
  * [小结](./chapter0/SUMMARY.md)
* [第2章 探索PromQL](./chapter2/README.md)
  * [理解时间序列](./sources/what-is-prometheus-metrics-and-labels.md)
  * [Metrics类型](./sources/prometheus-metrics-types.md)
  * [初识PromQL](./sources/prometheus-query-language.md)
  * [PromQL操作符](./sources/prometheus-promql-operators-v2.md)
  * [PromQL聚合操作](./sources/prometheus-aggr-ops.md)
  * [PromQL内置函数](./sources/prometheus-promql-functions.md)
  * [在HTTP API中使用PromQL](./sources/prometheus-promql-with-http-api.md)
  * [最佳实践：4个黄金指标和USE方法](./sources/prometheus-promql-best-praticase.md)
  * [小结](./chapter2/SUMMARY.md)
* [第3章 Prometheus告警处理](./chapter3/README.md)
  * [Prometheus告警简介](./sources/prometheus-alert-manager-overview.md)
  * [自定义Prometheus告警规则](./sources/prometheus-alert-rule.md)
  * [部署AlertManager](./sources/install-alert-manager.md)
  * [基于Label的动态告警处理](./sources/alert-manager-routes.md)
  * [内置告警接收器Receiver](./sources/alert-manager-with-smtp.md)
  * [使用Webhook扩展Alertmanager](./sources/alert-manager-extension-with-webhook.md)
  * [屏蔽告警通知](./sources/alert-manager-inhibit.md)
  * [使用Recoding Rules优化性能](./sources/prometheus-recoding-rules.md)
  * [小结](./chapter3/SUMMARY.md)

## Part II - Prometheus进阶

* [第4章 Exporter详解](./chapter5/README.md)
  * [Exporter是什么](./sources/what-is-prometheus-exporter.md)
  * [常用Exporter](./sources/commonly-eporter-usage.md)
    * [容器监控：cAdvisor](./sources/use-prometheus-monitor-container.md)
    * [监控MySQL运行状态：MySQLD Exporter](./sources/use-promethues-monitor-mysql.md)
    * [网络探测：Blackbox Exporter](./sources/install_blackbox_exporter.md)
  * [使用Java自定义Exporter](./sources/custom_exporter_with_java.md)
    * [使用client_java](./sources/client_library_java.md)
    * [在Sring Boot中集成](./sources/custom_app_support_prometheus.md)
  * [小结](./chapter5/SUMMARY.md)
* [第5章 可视化一切](./grafana/README.md)
  * [Grafana简介](./grafana/grafana-intro.md)
  * [使用Panel可视化监控数据](./grafana/grafana-panels.md)
    * [变化趋势：Graph](./grafana/use_graph_panel.md)
    * [当前状态：SingleStat](./grafana/use_singlestat_panel.md)
    * [分布统计：使用Heatmap](./grafana/use_heatmap_panel.md)
    * 使用Tabel Panel
    * 使用注解
  * 自定义面板
    * 通用设置
    * 指标
    * 坐标轴
    * 图例
    * 显示
    * 告警
    * 时间范围
  * 动态面板
    * 动态参数
    * 动态Panel
    * 动态Row
  * 共享Dashboard
  * 告警
  * 团队与权限管理
  * [小结](./chapter5/SUMMARY.md)
* [第6章 集群与高可用](./chapter7/READMD.md)
  * [本地存储](./sources/prometheus-local-storage.md)
  * [远程存储](./sources/prometheus-remote-storage.md)
  * [联邦集群](./sources/scale-prometheus-with-federation.md)
  * [Prometheus高可用](./sources/prometheus-and-high-availability.md)
  * [Alertmanager高可用](./sources/alertmanager-high-availability.md)
  * [总结](./chapter4/SUMMARY.md)
* [第7章 Prometheus服务发现](./chapter6/README.md)
  * [Prometheus与服务发现](./sources/why-need-service-discovery.md)
  * [基于文件的服务发现](./sources/service-discovery-with-file.md)
  * [基于Consul的服务发现](./sources/service-discovery-with-consul.md)
  * [服务发现与Relabel](./sources/service-discovery-with-relabel.md)
  * [小结](./chapter6/SUMMARY.md)

## Part III - Prometheus实战

* [第8章 使用Prometheus监控Kubernetes集群](./chapter8/READMD.md)
  * [初识Kubernetes](./sources/kubernetes-with-minikube.md)
  * [Prometheus与Kubernetes](./sources/prometheus-with-kubernetes.md)
  * [部署Prometheus](./sources/deploy-prometheus-in-kubernetes.md)
  * [Kubernetes下的服务发现](./sources/service-discovery-with-kubernetes.md)
  * [应用容器监控](./sources/use-prometheus-monitor-containers-in-k8s.md)
  * [监控集群基础设施](./sources/use-promethues-monitor-node-in-k8s.md)
  * [监控集群状态](./sources/use-prometheus-monitor-k8s-cluster-state.md)
  * [使用Grafana创建可视化仪表盘](./sources/use-grafana-in-k8s.md)
  * Prometheus Vs Heapster
  * 基于Prometheus实现应用的弹性伸缩
  * 使用Opertor管理Prometheus
  * 总结
* [第9章 使用Prometheus监控Rancher集群](./chapter10/README.md)
* [参考资料](./REFERENCES.md)
