# 在Kubernetes下部署Prometheus

## 访问授权

为了能够让Prometheus能够通过Kubernetes自动发现集中中需要监控的资源，我们需要对创建全局的ClusterRole并且为其分配对nodes、nodes/proxy、services、endpoints、pods的访问权限。并在相应的namespace中创建对应的ServiceAccount，并与ClusterRole进行绑定。

上述的所有操作，可以通过Yaml文件prometheus-rbac-setup.yml进行描述。 文件内容如下所示：

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

通过kubectl命令行工具完成在集群中的资源创建：

```
kubectl create -f prometheus-rbac-setup.yml
```

## 部署Prometheus

## Kubernetes下的服务发现

Prometheus允许通过Kubernetes的REST API自动发现需要监控的Target实例。目前主要支持4种发现模式：

**Node**

在基于Node模式的服务发现中，Prometheus会通过Kubernetes API找到集群中的所有节点（Node）作为样本数据抓取的目标。默认情况下Prometheus会使用节点中Kubelet服务的HTTP地址作为标签```__address__```的值。

通过Node模式自动发现的Target对象还会包含以下额外的标签信息：

* ```__meta_kubernetes_node_name```: 节点的名称
* ```__meta_kubernetes_node_label_<labelname>```: Kubernetes或则用户未该节点定义的标签
* ```__meta_kubernetes_node_annotation_<annotationname>```: Kubernetes为该节点自动生成的注解信息
* ```__meta_kubernetes_node_address_<address_type>```: 该节点的的地址访问信息。address_type可能为：NodeInternalIP、NodeExternalIP、NodeLegacyHostIP、以及NodeHostName

```
- job_name: 'kubernetes-nodes'
  scheme: https
  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  kubernetes_sd_configs:
  - role: node
  relabel_configs:
  - action: labelmap
    regex: __meta_kubernetes_node_label_(.+)
  - target_label: __address__
    replacement: kubernetes.default.svc:443
  - source_labels: [__meta_kubernetes_node_name]
    regex: (.+)
    target_label: __metrics_path__
    replacement: /api/v1/nodes/${1}/proxy/metrics
```

```
- job_name: 'kubernetes-cadvisor'
  scheme: https
  tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  kubernetes_sd_configs:
  - role: node
  relabel_configs:
  - action: labelmap
    regex: __meta_kubernetes_node_label_(.+)
  - target_label: __address__
    replacement: kubernetes.default.svc:443
  - source_labels: [__meta_kubernetes_node_name]
    regex: (.+)
    target_label: __metrics_path__
    replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor
```