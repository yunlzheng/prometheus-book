# Summary
This is the summary of my book.
* [Introduction](README.md)
* [版本变更历史](CHANGELOGS.md)
* [第一章 天降奇兵](./chapter0/README.md)
    * [Prometheus是什么](./sources/what-is-prometheus.md)
    * [在Linux环境下安装Prometheus](./sources/install_prometheus_in_with_binary.md)
    * [在Docker环境下安装Prometheus](./sources/install_prometheus_in_docker.md)
        * Docker简介
        * 运行Prometheus容器
    * 初识Prometheus配置
        * 使用NodeExporter采集主机信息
            * 运行NodeExporter
            * 配置Prometheus采集目标
            * 重新加载配置
    * Pull Vs Push
    * Promethues生态系统
        * AlertManager
        * Exporters
        * Prometheus PushGateway
        * Prometheus Operator
        * Grafana
    * 百里挑一
        * Prometheus Vs Graphite
        * Prometheus Vs InfluxDB
        * Prometheus Vs OpenTSDB
        * Prometheus Vs Nagios
    * [本章总结](./chapter0/SUMMARY.md)
* 第二章 理解Prometheus模型
    * 什么是Metrics和Lables
    * Metrics类型
    * 任务和实例
    * [Promethues查询语言](./sources/prometheus-query-language.md)
    * 总结
* 第三章 Prometheus告警
    * Prometheus与AlertManager
    * 定义Prometheus告警
    * 安装AlertManager
    * 基于Label的告警规则
    * 与邮件系统集成
    * 与Slack集成
    * 与Webhook集成
    * 总结
* 第四章 可视化一切
    * Grafana简介
    * 自定义仪表盘
    * 自定义图表
    * 告警配置
    * 共享你的仪表盘
    * 总结
* 第五章 扩展Prometheus
    * 常用Exporter
        * 使用NodeExporter采集主机数据
        * 使用MysqlExporter采集Mysql Server数据
        * 使用RabbitMQExporter采集RabbitMQ数据
        * 使用Cadvisor采集容器数据
    * 使用Java创建自定义Metrics
    * 使用Golang创建自定义Metrics
    * 扩展Spring Boot应用支持应用指标采集
    * 总结
* 第六章 Prometheus服务发现
    * 基于DNS的服务发现
    * 基于Consul的服务发现
    * 基于Kubernetes的服务发现
    * 总结
* [第七章 运行和管理Prometheus](./chapter7/READMD.md)
    * 数据管理
        * 本地存储
        * 远端数据存储
        * 创建快照
    * 使用Prometheus Opertor管理Prometheus
    * 使用Promgen管理Prometheus
    * [功能分片](./sources/scale-promethues-with-functional-sharding.md)
    * [联邦集群](./sources/scale-prometheus-with-federation.md)
    * 从1.0迁移到2.0
    * [总结](./chapter4/SUMMARY.md)
* 第八章 Kubernetes监控实战
    * Kubernetes简介
    * 搭建Kubernetes本地测试环境
    * Prometheus Vs Heapster
    * [采集集群级别指标](./sources/expose-cluster-level-metrics-with-kube-state-metrics.md)
    * 采集Pod指标
    * 采集Kubelet指标
    * 采集集群Node指标
    * 采集运行运行指标
    * 采集应用监控指标
    * 弹性伸缩
    * 使用Grafana创建可视化仪表盘
    * 总结
* [参考资料](./REFERENCES.md)