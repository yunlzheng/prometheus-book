# 使用Prometheus监控Kubernetes集群

上一小节中，我们介绍了Promtheus在Kubernetes下的服务发现能力，并且通过kubernetes_sd_config实现了对Kubernetes下各类资源的自动发现。在本小节中，我们将带领读者利用Promethues提供的服务发现能力，实现对Kubernetes集群以及其中部署的各类资源的监控。

下表中，梳理了监控Kubernetes集群监控的各个维度以及策略：

|目标|服务发现模式| 监控方法 |数据源|
|-----|------| ----|---|
|从集群各节点kubelet组件中获取节点kubelet的基本运行状态的监控指标|node|白盒监控| kubelet |
|从集群各节点kubelet内置的cAdvisor中获取，节点中运行的容器的监控指标|node|白盒监控| kubelet|
|从部署到各个节点的Node Exporter中采集主机资源相关的运行资源|node|白盒监控| node exporter |
|对于内置了Promthues支持的应用，需要从Pod实例中采集其自定义监控指标|pod|白盒监控| pod|
|获取API Server组件的访问地址，并从中获取Kubernetes集群相关的运行监控指标|endpoints|白盒监控| api server |
|获取集群中Service的访问地址，并通过Blackbox Exporter获取网络探测指标|service|黑盒监控| blackbox exporter|
|获取集群中Ingress的访问信息，并通过Blackbox Exporter获取网络探测指标|ingress|黑盒监控| blackbox exporter |

## 监控节点中kubelet运行状态

Kubelet组件运行在Kubernetes集群的各个节点中，其复杂维护和管理节点上Pod的运行状态。kubelet组件的正常运行直接关系到该节点是否能够正常的被Kubernetes集群正常使用。

基于Node模式，Prometheus会自动发现Kubernetes中所有Node节点的信息并作为监控的目标Target。 而这些Target的访问地址实际上就是Kubelet的访问地址，并且Kubelet实际上直接内置了对Promtheus的支持。

修改prometheus.yml配置文件，并添加以下采集任务配置：

```
  - job_name: 'kubernetes-kubelet'
    scheme: https
    tls_config:
    ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    kubernetes_sd_configs:
    - role: node
    relabel_configs:
    - action: labelmap
      regex: __meta_kubernetes_node_label_(.+)
```

这里使用Node模式自动发现集群中所有Kubelet作为监控的数据采集目标，同时通过labelmap步骤，将Node节点上的标签，作为样本的标签保存到时间序列当中。

重新加载promethues配置文件，并重建Promthues的Pod实例后，查看kubernetes-kubelet任务采集状态，我们会看到以下错误提示信息：

```
Get https://192.168.99.100:10250/metrics: x509: cannot validate certificate for 192.168.99.100 because it doesn't contain any IP SANs
```

这是由于当前使用的ca证书中，并不包含192.168.99.100的地址信息。为了解决该问题，第一种方法是直接跳过ca证书校验过程，通过在tls_config中设置
insecure_skip_verify为true即可。 这样Promthues在采集样本数据时，将会自动跳过ca证书的校验过程，从而从kubelet采集到监控数据：

```
  - job_name: 'kubernetes-kubelet'
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        insecure_skip_verify: true
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      kubernetes_sd_configs:
      - role: node
      relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
```

![直接采集kubelet监控指标](http://p2n2em8ut.bkt.clouddn.com/kubernetes-kubelets-step2.png)

第二种方式，不直接通过kubelet的metrics服务采集监控数据，而通过Kubernetes的api-server提供的代理API访问各个节点中kubelet的metrics服务，如下所示：

```
  - job_name: 'kubernetes-kubelet'
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

通过relabeling，将从Kubernetes获取到的默认地址```__address__```替换为kubernetes.default.svc:443。同时将```__metrics_path__```替换为api-server的代理地址/api/v1/nodes/${1}/proxy/metrics。

![通过api-server代理获取kubelet监控指标](http://p2n2em8ut.bkt.clouddn.com/kubernetes-kubelets-step3.png)

通过获取各个节点中kubelet的监控指标，用户可以评估集群中各节点的性能表现。例如,通过指标kubelet_pod_start_latency_microseconds可以获得当前节点中Pod启动时间相关的统计数据。

```
kubelet_pod_start_latency_microseconds{quantile="0.99"}
```

![99%的Pod启动时间](http://p2n2em8ut.bkt.clouddn.com/kubelet_pod_start_latency_microseconds.png)

Pod平均启动时间大致为42s左右（包含镜像下载时间）：

```
kubelet_pod_start_latency_microseconds_sum / kubelet_pod_start_latency_microseconds_count
```

![Pod平均启动时间](http://p2n2em8ut.bkt.clouddn.com/kubelet_pod_start_latency_microseconds_avg.png)

除此以外，监控指标kubelet_docker_*还可以体现出kubelet与当前节点的docker服务的调用情况，从而可以反映出docker本身是否会影响kubelet的性能表现等问题。

## 监控集群中容器的资源使用情况