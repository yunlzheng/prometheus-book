# 监控Kubernetes中运行的容器

在第4章的”监控容器运行状态“小节中，我们介绍了如何使用cAdvisor监控主机中容器的运行状态。而Kubernetes直接在Kubelet组件中集成了cAdvisor。cAdvisor会自动采集CPU，内存，文件系统，网络等资源的使用情况，默认运行端口为4194。因此在Kubernetes集群中的各个节点，已经默认包含了cAdvisor的支持：

登录到MiniKube主机，并且访问本机的4194端口，可以获取到当前节点上cAdvisor的监控样本数据：

```
$ minikube ssh

$  curl 127.0.0.1:4194/metrics
...
# HELP process_start_time_seconds Start time of the process since unix epoch in seconds.
# TYPE process_start_time_seconds gauge
process_start_time_seconds 1.52506226634e+09
# HELP process_virtual_memory_bytes Virtual memory size in bytes.
# TYPE process_virtual_memory_bytes gauge
process_virtual_memory_bytes 1.1649622016e+10
```

在本节中，我们将利用Prometheus的服务发现能力，自动的找到这些cAdvisor的采集目标。

## 基于Node的服务发现模式

在上一小节中，我们已经能够通过Kubernetes自动的发现当前集群中的所有Node节点。

```
 kubernetes_sd_configs:
 - role: node
```

如上所示，当role的配置为node时，Prometheus会通过Kubernetes API找到集群中的所有Node对象，并且将其转换为Prometheus的Target对象，从Prometheus UI中可以查看该Target实例包含的所有Metadata标签信息，如下所示，在从MiniKube集群中获取到的一个节点Metadata标签信息：

```
__address__="192.168.99.100:10250"  __meta_kubernetes_node_address_Hostname="minikube" __meta_kubernetes_node_address_InternalIP="192.168.99.100" __meta_kubernetes_node_annotation_alpha_kubernetes_io_provided_node_ip="192.168.99.100" 
__meta_kubernetes_node_annotation_node_alpha_kubernetes_io_ttl="0" __meta_kubernetes_node_annotation_volumes_kubernetes_io_controller_managed_attach_detach="true" 
__meta_kubernetes_node_label_beta_kubernetes_io_arch="amd64"  __meta_kubernetes_node_label_beta_kubernetes_io_os="linux" __meta_kubernetes_node_label_kubernetes_io_hostname="minikube"  __meta_kubernetes_node_name="minikube"
__metrics_path__="/metrics" 
__scheme__="https"  
instance="minikube"  
job="kubernetes-nodes"
```

其中```__address__```默认为当前节点上运行的kubelet的访问地址。从上面的结果可以看出，通过node动态发现的Target会包含如下几类标签：

* ```__meta_kubernetes_node_name```：该节点在集群中的名称；
* ```__meta_kubernetes_node_label_<labelname>```：该节点中包含的用户自定义标签以及Kubernetes自动生成的标签；
* ```__meta_kubernetes_node_annotation_<annotationname>```：该节点中包含的Kubernetes自动生成的注解信息；
* ```__meta_kubernetes_node_address_<address_type>```：该节点各种类型（NodeInternalIP，NodeExternalIP，NodeLegacyHostIP，NodeHostName）的访问地址。

用户也可以通过以下命令查看节点的详细信息：

```
$ kubectl get nodes/minikube -o yaml
```

## 使用Relabel修改Target采集任务设置

为了能够通过Prometheus采集到cAdvisor的metrics服务，我们为cAdvisor定义了单独采集任务。该任务将基于Node模式发现集群中所有的节点，并通过Relabel修改Target的数据采集配置，从而获取到cAdvisor的监控数据，修改prometheus-config.yml如下：

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |-
    global:
      scrape_interval:     15s
      evaluation_interval: 15s
    scrape_configs:
    - job_name: 'kubernetes-cadvisor'
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      kubernetes_sd_configs:
      - role: node
      relabel_configs:
      - source_labels: [__address__]
        regex: (.+):(.+)
        action: replace
        target_label: __address__
        replacement: $1:4194
      - action: replace
        target_label: __scheme__
        replacement: http
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
```

这里定义了三个relabel步骤：

1，默认获取到的target地址为，当前节点中kubelet的访问地址。因此通过通过正则表达式(.+):(.+)匹配出IP地址和端口，并将将匹配到的内容按照$1:4194的形式覆盖```__address__```的值。 从而获得cAdvisor访问地址；
2，默认返回的```__scheme__```为https，通过直接修改其值为http，从而可以让Prometheus通过访问[http://IP:4193/metrics](http://IP:4193/metrics)作为采集目标地址；
3，最后通过labelmap将该节点上的自定义标签，写入到样本中，从而可以方便用户通过这些标签对数据进行聚合。

![cAdvisor数据采集状态](http://p2n2em8ut.bkt.clouddn.com/k8s-sd-with-node-with-relabel-1.png)

如上所示，Prometheus通过自动发现Node节点，并通过Relabel自定义采集方式后的结果。

需要注意的是，通过集群中主机的4194端口获取cAdvisor数据，并不适用于所以Kubernetes集群，这种方式限制了cAdvisor服务的运行端口。除了直接访问各个节点的cAdvisor服务以外，我们还可以通过Kubernetes的API Server作为代理获取节点上的cAdvisor监控数据。

例如，想要获取节点minikube上cAdvisor的监控数据可以ca证书和令牌在Kubernetes集群内访问地址获取：

```
https://kubernetes.default.svc:443/api/v1/nodes/minikube/proxy/metrics/cadvisor
```

因此，修改kubernetes-cadvisor的relabel配置，将最终任务采集的数据指向API Server提供的代理地址即可：

```
    - job_name: 'kubernetes-cadvisor'
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      kubernetes_sd_configs:
      - role: node
      relabel_configs:
      - target_label: __address__
        replacement: kubernetes.default.svc:443
      - source_labels: [__meta_kubernetes_node_name]
        regex: (.+)
        target_label: __metrics_path__
        replacement: /api/v1/nodes/${1}/proxy/metrics/cadvisor
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
```

如下图所示，Prometheus使用了访问地址后的任务采集状态：

![基于API Server获取cAdvisor监控数据状态](http://p2n2em8ut.bkt.clouddn.com/k8s-sd-with-node-with-relabel-2.png)