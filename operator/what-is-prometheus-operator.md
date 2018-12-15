## 什么是Prometheus Operator

在第8章章中，为了在Kubernetes能够方便的管理和部署Prometheus，我们使用ConfigMap了管理Prometheus配置文件。每次对Prometheus配置文件进行升级时，，我们需要手动移除已经运行的Pod实例，从而让Kubernetes可以使用最新的配置文件创建Prometheus。 而如果当应用实例的数量更多时，通过手动的方式部署和升级Prometheus过程繁琐并且效率低下。

从本质上来讲Prometheus属于是典型的有状态应用，而其有包含了一些自身特有的运维管理和配置管理方式。而这些都无法通过Kubernetes原生提供的应用管理概念实现自动化。为了简化这类应用程序的管理复杂度，CoreOS率先引入了Operator的概念，并且首先推出了针对在Kubernetes下运行和管理Etcd的Etcd Operator。并随后推出了Prometheus Operator。

### Prometheus Operator的工作原理

在前面的例子中我们使用Deployment，Damenset管理应用的Workload，使用Service，Ignress控制

> TODO

从概念上来讲Operator就是针对管理特定应用程序的，在Kubernetes基本的Resource和Controller的概念上，以扩展Kubernetes api的形式。帮助用户创建，配置和管理复杂的有状态应用程序。从而实现特定应用程序的常见操作以及运维自动化。

### 使用Prometheus Operator能干什么

> TODO

### 在Kubernetes集群中部署Prometheus Operator

在Kubernetes中安装Prometheus Operator非常简单，用户可以从以下地址中过去Prometheus Operator的源码：

```
git clone https://github.com/coreos/prometheus-operator.git
```

通过运行一下命令安装Prometheus Operator的Deployment实例：

```
kubectl apply -f bundle.yaml
```

由于Prometheus Operator中需要获取当前集群中运行资源的运行情况，因此在bundle.yaml中定义了名为prometheus-operator的ServiceAccount并且绑定了相应的集群访问权限。
