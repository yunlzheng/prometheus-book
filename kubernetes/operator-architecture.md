## Prometheus Opterator架构

Prometheus Operator建立在Kubernetes的资源以及控制器的概念之上，通过在Kubernetes中添加自定义资源类型，通过声明式的方式，Operator可以自动部署和管理Prometheus实例的运行状态，并且根据监控目标管理并重新加载Prometheus的配置文件，大大简化Prometheus这类有状态应用运维管理的复杂度。

![Prometheus Operator架构](http://p2n2em8ut.bkt.clouddn.com/prometheus-architecture.png)

如上所示，是Prometheus Operator的架构示意图。为了能够通过声明式的对Prometheus进行自动化管理。Prometheus Operator通过自定义资源类型的方式定义了一下3个主要自定义资源类型：

* Prometheus：声明式的管理Prometheus实例
* ServiceMonitor：声明式的管理监控目标，并自定生成监控配置文件
* Alertmanager：声明式的管理Alertmanager实例

除了上图中展示的3大类型以外，还有自定义资源类型PrometheusRule，用于声明式的管理高级规则。

### Prometheus

自定义资源`Prometheus`中声明式的定义了在Kubernetes集群中所需运行的Prometheus的设置。如下所示：

```
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus
spec:
  serviceMonitorSelector:
    matchLabels:
      team: frontend
  resources:
    requests:
      memory: 400Mi
```

在该Yaml中我们可以定义Prometheus实例所使用的资源，以及需要关联的ServiceMonitor等。除此以外，还可以定义如Replica，Storage，以及关联的Alertmanager实例等信息。

对于每一个Promtheus资源而言，Operator会自动通过StatefulSet的方式部署Prometheus实例。Operator会根据ServiceMonitor定义的自动将Prometheus的配置信息通过Secret的方式进行保存。当ServiceMonitor或者Promtheus更新时，Operator会确保Prometheus实例自动加载最新的配置内容。

如果Prometheus未关联ServiceMonitor，用户则可以自行管理Secret中的配置内容。Operator会确保这些配置内容被加载到Prometheus实例当中。

### ServiceMonitor

通过自定义资源类型`ServiceMonitor`用户可以通过声明式的方式定义需要监控集群中的哪些资源。如下所示：

```
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: example-app
  labels:
    team: frontend
spec:
  selector:
    matchLabels:
      app: example-app
  endpoints:
  - port: web
```

在ServiceMonitor中声明了如何从标签选择器匹配到的这些服务中获取监控指标数据。通过将ServiceMonitor关联到Prometheus从而实现对监控配置的自动管理。在默认情况下ServiceMonitor与Prometheus必须位于相同的命名空间中，而当Prometheus需要跨命名空间获取监控数据时，可以在ServiceMonitor中声明namespaceSelector，如下所示：

```
spec:
  namespaceSelector:
    any: true
```

### Alertmanager

通过自定义资源类型`Alertmanager`，用户可以声明式的定义在Kubernetes集群中所需要运行的Alertmanager信息，如下所示：

```
apiVersion: monitoring.coreos.com/v1
kind: Alertmanager
metadata:
  name: example
spec:
  replicas: 3
```

在Yaml文件中，我们可以定义Alertmanager的实例数量以及持久化相关的配置，Operator会自动通过StatefulSet的方式部署Alertmanager实例，对于当存在多个Alertmanager副本时，Operator会自动以高可用的模式运行Alertmanager实例。而Alertmanager的配置文件则通过Secret的方式进行管理