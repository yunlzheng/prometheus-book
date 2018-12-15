## 使用Operator管理Prometheus

当集群中已经安装Prometheus Operator之后，对于部署Prometheus Server实例就变成了生命一个Prometheus资源：

```
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: instance
spec:
  resources:
    requests:
      memory: 400Mi
```

通过定义类型为Prometheus的资源对象，Prometheus Operator会自动在Kubernetes集群中通过StatefulSet的方式部署Prometheus实例。通过关联Secret的方式，用户可以自行管理Prometheus的配置文件：

> TODO例子

而更多的情况下，我们希望Prometheus的配置文件也是自动化管理的，那么我们就可以使用ServiceMonitor对象。通过自定义资源类型ServiceMonitor用户可以通过声明式的方式定义需要监控集群中的哪些资源。如下所示：：

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

而如果希望Prometheus监控ServiceMonitor定义的目标对象，我们只需要在Prometheus的定义中添加serviceMonitorSelector即可：

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

在默认情况下ServiceMonitor与Prometheus必须位于相同的命名空间中，而当Prometheus需要跨命名空间获取监控数据时，可以在ServiceMonitor中声明namespaceSelector，如下所示：

```
spec:
  namespaceSelector:
    any: true
```