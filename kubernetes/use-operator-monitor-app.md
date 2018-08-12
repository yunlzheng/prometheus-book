# 使用Prometheus Operator监控用户应用

本小节将展示，如何通过Prometheus Operator部署Prometheus实例并且实现对部署在Kubernetes中应用程序的监控。

## 部署Prometheus Server

为了能够让Prometheus实例能够正常的使用服务发现能力，我们首先需要基于Kubernetes的RBAC模型为Prometheus创建ServiceAccount并赋予相应的集群访问权限。如下所示：

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources:
  - configmaps
  verbs: ["get"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: prometheus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: default
```

将以上内容保存为prometheus-rbac-setup.yaml文件，并在Kubrnetes集群中创建相应的资源:

```
$ kubectl create -f prometheus-rbac-setup.yaml
serviceaccount "prometheus" created
clusterrole "prometheus" created
clusterrolebinding "prometheus" created
```

在上一小节中已经介绍过Prometheus Operator通过在Kubernetes下实现自定义资源类型，将原本需要手动管理和维护的工作，转换为声明式的管理方式，为了创建Prometheus实例，我们需要创建一个类型为Prometheus的资源，如下所示：

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
```

将文件保存为prometheus.yaml，并且通过Kubectl命令行工具创建相关资源：

```
$ kubectl create -f prometheus.yaml
prometheus "prometheus" created
```

此时如果查看Prometheus Operator的日志的话，可以看到类似于以下内容:

```
level=info ts=2018-08-12T07:43:54.696691736Z caller=operator.go:893 component=prometheusoperator msg="sync prometheus" key=default/prometheus
```

Prometheus Operator监听到Prometheus资源的变化后，会通过Statefulset的方式自动创建Prometheus实例，如下所示：

```
$ kubectl get statefulsets
NAME                    DESIRED   CURRENT   AGE
prometheus-prometheus   2         2         4m
```

为了能够访问通过Prometheus Operator创建的Prometheus实例，需要定义相应的Service资源，如下所示：

```
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: default
spec:
  ports:
  - name: web
    port: 9090
    protocol: TCP
    targetPort: 9090
  selector:
    prometheus: prometheus
  type: NodePort
```

在Service创建完成后，用户可以通过浏览器访问到通过Prometheus Operator创建的实例：

![Prometheus实例](http://p2n2em8ut.bkt.clouddn.com/prometheus-operator-instance.png)

当然，如上所示，目前为止我们的Prometheus还没有包含任何的监控配置信息。

## 监控Kubernetes中部署的服务

为了能够模拟应用监控的场景，首先需要在Kubernetes中安装一个测试应用，如下所示：

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: example-app
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: example-app
    spec:
      containers:
      - name: example-app
        image: fabxc/instrumented_app
        ports:
        - name: web
          containerPort: 8080
---
kind: Service
apiVersion: v1
metadata:
  name: example-app
  labels:
    app: example-app
spec:
  selector:
    app: example-app
  ports:
  - name: web
    port: 8080
```

将以上内容保存为example-app.yaml，并在Kubernetes中创建相应的资源：

```
$ kubectl create -f example-app.yaml
deployment "example-app" created
service "example-app" created
```

访问示例应用的8080端口下的/metrics路径可以获取该应用的监控样本数据。在Prometheus Operator下所有与Prometheus相关的操作都是通过自定义资源类型实现的，对于监控配置也是相同的方式，用户只需要通过ServiceMonitor声明监控目标，并且关联到Prometheus资源即可。

如下所示，定义类型为ServiceMonitor的资源对象，并且通过selector选择需要监控的目标服务标签：

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

将以上内容保存为example-app-monitor.yaml文件，并且创建相应的资源：

```
$ kubectl create -f example-app-monitor.yaml
servicemonitor "example-app" created

$ kubectl get servicemonitor
NAME          AGE
example-app   5s
```

为了告诉Promtheus使用ServiceMonitor，需要修改prometheus.yaml的内容，如下所示：

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
```

通过在Prometheus中添加serviceMonitorSelector选择器，关联需要监控的ServiceMonitor资源标签。自此，Prometheus Operator会自动根据ServiceMonitor相关的内容生成Prometheus的监控配置文件，并在不重建Pod实例的情况下重新加载该配置。

通过UI查看Prometheus配置文件，Prometheus Operator自动为Prometheus创建了一个名为default/example-app/0的监控采集任务，用于采集示例应用程序的监控数据：

![自动生成的Prometheus配置](http://p2n2em8ut.bkt.clouddn.com/prometheus-config-with-servermonitor.png)

查看监控Target页面，可以看到当前所有的监控目标:

![监控Target目标](http://p2n2em8ut.bkt.clouddn.com/prometheus-operator-targets.png)

到目前为止，通过Prometheus Operator自定义的资源类型Prometheus和ServiceMonitor声明了需要在Kubernetes集群中部署的Prometheus实例以及相应的监控配置。通过监听Prometheus和ServicMonitor资源的变化，自动创建和管理Prometheus的配置信息，从而实现了对Prometheus声明式的自动化管理。
