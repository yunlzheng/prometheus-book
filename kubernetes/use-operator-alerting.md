# 使用Prometheus Operator管理Alertmanager

为了通过Prometheus Operator管理Alertmanager实例，用户可以通过自定义资源Alertmanager进行定义，如下所示，通过replicas可以控制Alertmanager的实例数：

```
apiVersion: monitoring.coreos.com/v1
kind: Alertmanager
metadata:
  name: example
spec:
  replicas: 3
```

当replicas大于1时，Prometheus Operator会自动通过集群的方式创建Alertmanager。将以上内容保存为文件alertmanager-setup.yaml，并通过以下命令创建：

```
$ kubectl create -f alertmanager-setup.yaml
alertmanager "example" created
```

查看Pod的情况如下所示，我们会发现Alertmanager的Pod实例一直处于ContainerCreating的状态中:

```
$ kubectl get pods
NAME                                   READY     STATUS              RESTARTS   AGE
alertmanager-example-0                 0/2       ContainerCreating   0          4m
```

通过kubectl describe命令查看该Pod实例状态，可以看到以下内容：

```
$ kubectl describe pods alertmanager-example-0
...
Warning  FailedMount            4s (x2 over 2m)    kubelet, cn-beijing.i-2ze52j61t5p9z4n60c9m  Unable to mount volumes for pod "alertmanager-example-0_default(f75aff5c-9e37-11e8-9dc5-00163e124757)": timeout expired waiting for volumes to attach or mount for pod "default"/"alertmanager-example-0". list of unmounted volumes=[config-volume]. list of unattached volumes=[config-volume alertmanager-example-db default-token-tzpfg]
```

Prometheus Operator将通过Statefulset的方式创建Alertmanager实例，默认情况下，Alertmanager的实例会通过`alertmanager-{ALERTMANAGER_NAME}`的命名规则去查找Secret配置并以文件挂载的方式，将Secret的内容作为配置文件挂载到Alertmanager实例当中。因此，这里还需要为Alertmanager创建相应的配置内容，如下所示，是Alertmanager的配置文件：

```
global:
  resolve_timeout: 5m
route:
  group_by: ['job']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 12h
  receiver: 'webhook'
receivers:
- name: 'webhook'
  webhook_configs:
  - url: 'http://alertmanagerwh:30500/'
```

将以上内容保存为文件alertmanager.yaml，并且通过以下命令创建名为alrtmanager-example的Secret资源：

```
$ kubectl create secret generic alertmanager-example --from-file=alertmanager.yaml
secret "alertmanager-example" created
```

在Secret创建成功后，查看当前Alertmanager Pod实例状态。如下所示：

```
$ kubectl get pods
alertmanager-example-0                 2/2       Running   0          37m
alertmanager-example-1                 2/2       Running   0          31m
alertmanager-example-2                 2/2       Running   0          31m
```

为了能够访问到这些Alertmanager实例，我们需要创建相应的Service，如下所示：

```
apiVersion: v1
kind: Service
metadata:
  name: alertmanager-example
spec:
  type: NodePort
  ports:
  - name: web
    nodePort: 30903
    port: 9093
    protocol: TCP
    targetPort: web
  selector:
    alertmanager: example
```

访问Alertmanager UI，并查看当前集群状态：

![Alertmanager集群状态](http://p2n2em8ut.bkt.clouddn.com/prometheus-alert-cluster-status.png)

接下来，我们只需要修改我们的Prometheus资源定义，通过alerting指定使用的Alertmanager资源即可：

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
  alerting:
    alertmanagers:
    - namespace: default
      name: alertmanager-example
      port: web
  ruleSelector:
    matchLabels:
      role: alert-rules
      prometheus: example
```

在Prometheus重新加载配置完成后，通过UI可以查看Prometheus最新的配置内容，如下所示：

![Prometheus配置]](http://p2n2em8ut.bkt.clouddn.com/prometheus-alerting-auto.png)

自此，通过使用Prometheus Operator提供的自定义资源内容，声明式的创建和管理Prometheus实例以及Alertmanager集群。