# Prometheus的核心组件

Prometheus主要包含以下组件：

![Prometheus架构](../chapter0/static/architecture.svg)

* Prometheus Server: 负责采集以及存储时间序列数据；
* Exporter: 用于向Prometheus Server暴露目标监控指标的EndPoint， 社区提供了大量的Exporter可以使Prometheus实现对服务器，容器，中间件等监控数据采集。
* AlertManager: 用于处理由Prometheus产生的告警，实现与第三方如，邮件，Slack,Webhook的集成。
* Push Gateway: Prometheus代理层，支持客户端向Push Gateway主动Push数据。Prometheus与Push Gateway之间依然通过Pull的形式收集数据。