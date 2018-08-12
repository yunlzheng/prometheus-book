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