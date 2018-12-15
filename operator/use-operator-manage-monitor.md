## 使用PrometheusRule管理告警规则

> TODO

对于Prometheus而言，在传统的管理方式上，我们还需要手动管理Prometheus的告警规则文件，并且在文件发生变化手动通知Prometheus加载这些文件。 而在Prometheus Operator模式下，我们只需要通过自定义资源类型PrometheusRule声明即可

```
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  labels:
    prometheus: example
    role: alert-rules
  name: prometheus-example-rules
spec:
  groups:
  - name: ./example.rules
    rules:
    - alert: ExampleAlert
      expr: vector(1)
```

将以上内容保存为example-rule.yaml文件，并且通过kubectl命令创建相应的资源：

```
$ kubectl create -f example-rule.yaml
prometheusrule "prometheus-example-rules" created
```

告警规则创建成功后，通过ruleSelector选择需要关联的PrometheusRule即可

```
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus
  labels:
    prometheus: prometheus
spec:
  replicas: 2
  serviceAccountName: prometheus
  serviceMonitorSelector:
    matchLabels:
      team: frontend
  ruleSelector:
    matchLabels:
      role: alert-rules
      prometheus: example
```

Prometheus重新加载配置后，从UI中我们可以查看到通过PrometheusRule自动创建的告警规则配置：

![Prometheus告警规则](./static/prometheus-rule.png)

到目前为止，通过Prometheus Operator自定义的资源类型Prometheus和ServiceMonitor声明了需要在Kubernetes集群中部署的Prometheus实例以及相应的监控配置。通过监听Prometheus和ServicMonitor资源的变化，自动创建和管理Prometheus的配置信息，从而实现了对Prometheus声明式的自动化管理。

到目前为止，我们已经通过Prometheus Operator的自定义资源类型管理了Promtheus的实例，监控配置以及告警规则等资源。通过Prometheus Operator将原本手动管理的工作全部变成声明式的管理模式，大大简化了Kubernetes下的Prometheus运维管理的复杂度。 接下来，我们将继续使用Promtheus Operator定义和管理Alertmanager相关的内容。
