# Kubernetes下的服务发现

目前为止，我们已经能够在Kubernetes下部署一个简单的Prometheus实例，不过当前来说它并不能发挥其监控系统的作用，除了Prometheus，暂时没有任何的监控采集目标。在第7章中，我们介绍了Prometheus的服务发现能力，它能够与通过与“中间代理人“交付动态的获取到需要监控的目标实例。而在Kubernetes下Prometheus就是需要与Kubernetes的API进行交互，从而能够动态的发现Kubernetes中部署的所有可监控的目标资源。

## Kubernetes的访问授权

在Kubernetes下，Promethues主要通过Kubernetes API查找以下4类资源，分别是:Node、Service、Pod、Endpoints、Ingress。为了能够让Prometheus能够访问收到认证保护的Kubernetes API，我们首先需要做的是，对Prometheus进行访问授权。

在Kubernetes中主要使用基于角色的访问控制模型(Role-Based Access Control)，用于管理Kubernetes下资源访问权限。首先我们需要在Kubernetes下定义角色（ClusterRole），并且为该角色赋予响应的访问权限。同时创建Prometheus所使用的账号（ServiceAccount），最后则是将该账号与角色进行绑定（ClusterRoleBinding）。这些所有的操作在Kubernetes同样被视为是一系列的资源，可以通过YAML文件进行描述并创建，这里创建prometheus-rbac-setup.yml文件，并写入以下内容：

```
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: prometheus
rules:
- apiGroups: [""]
  resources:
  - nodes
  - nodes/proxy
  - services
  - endpoints
  - pods
  verbs: ["get", "list", "watch"]
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["/metrics"]
  verbs: ["get"]
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: default
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

其中需要注意的是ClusterRole是全局的，不需要指定命名空间。而ServiceAccount是属于特定命名空间的资源。通过kubectl命令创建RBAC对应的各个资源：

```
$ kubectl create -f prometheus-rbac-setup.yml
clusterrole "prometheus" created
serviceaccount "prometheus" created
clusterrolebinding "prometheus" created
```

在完成角色权限以及用户的绑定之后，就可以指定Promtheus使用特定的ServiceAccount创建Pod实例。修改prometheus-deployment.yml文件，并添加serviceAccountName和serviceAccount定义：

```
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      serviceAccountName: prometheus
      serviceAccount: prometheus
```

通过kubectl apply对Deployment进行变更升级：

```
$ kubectl apply -f prometheus-deployment.yml
service "prometheus" configured
deployment "prometheus" configured

$ kubectl get pods
NAME                               READY     STATUS        RESTARTS   AGE
prometheus-55f655696d-wjqcl        0/1       Terminating   0          38m
prometheus-69f9ddb588-czn2c        1/1       Running       0          6s
```

指定ServiceAccount创建的Pod实例中，会自动将用于访问Kubernetes API的CA证书以及当前账户对应的访问令牌文件挂载到Pod实例的/var/run/secrets/kubernetes.io/serviceaccount/目录下，可以通过以下命令进行查看：

```
kubectl exec -it prometheus-69f9ddb588-czn2c ls /var/run/secrets/kubernetes.io/serviceaccount/
ca.crt     namespace  token
```

## 服务发现

通过这些证书和令牌，Prometheus就可以正常的访问Kubernetes的API。如下所示，在Prometheus配置文件中，创建了一个名为kubernetes-nodes的监控采集任务，为了能够使Prometheus能够正常调用Kubernetes API，这里通过ca_file和bearer_token_file指定了CA证书以及令牌，在kubernetes_sd_configs配置中指定当前的服务发现模式为node，该模式下Prometheus会自动发现集群中所有的节点信息。

```
apiVersion: v1
data:
  prometheus.yml: |-
    global:
      scrape_interval:     15s 
      evaluation_interval: 15s
    scrape_configs:
    - job_name: 'kubernetes-nodes'
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      kubernetes_sd_configs:
      - role: node
kind: ConfigMap
metadata:
  name: prometheus-config
```

更新Prometheus配置文件，并重建Prometheus实例：

```
$ kubectl apply -f prometheus-config.yml
configmap "prometheus-config" configured

$ kubectl get pods
prometheus-69f9ddb588-rbrs2        1/1       Running   0          4m

$ kubectl delete pods prometheus-69f9ddb588-rbrs2
pod "prometheus-69f9ddb588-rbrs2" deleted

$ kubectl get pods
prometheus-69f9ddb588-rbrs2        0/1       Terminating   0          4m
prometheus-69f9ddb588-wtlsn        1/1       Running       0          14s
```

Promtheus使用新的配置文件重建之后，打开Prometheus UI，通过Service Discovery页面可以查看到当前Prometheus通过Kubernetes发现的所有Node实例了：

![Service Discovery发现的实例](http://p2n2em8ut.bkt.clouddn.com/service-discovery-nodes.png)

查看Target页面，可以看到当前Prometheus中包含一个Target实例，并且Prometheus开始尝试从该实例中获取监控数据：

![](http://p2n2em8ut.bkt.clouddn.com/service-discover-node-targets.png)

这里会提示一个有关证书的错误信息。不过，现在这个问题并不重要，我们已经能够通过服务发现找到Kubernetes下的资源对象。 而且我们也并不需要监控所有的东西，我们还需要通过Prometheus的relabling机制去过滤并找到真正需要监控的资源。

kubernetes_sd_config中除了指定服务发现模式node以外，还支持service、pod、endpoints、ingress等四种模式。不同的服务发现模式适用于不同的场景，例如:

* node适用于与主机相关的监控资源。例如，节点中运行的Kubernetes组件状态、节点上运行的容器状态等；
* service和igress适用于通过黑盒监控的场景。例如，对服务的可用性以及服务质量的监控；
* endpoints和pod均可用于获取Pod实例的监控数据。例如，监控用户或者管理员部署的支持Prometheus的应用。
