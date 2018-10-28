# Prometheus与Kubernetes

Kubernetes作为开源的容器编排工具，为用户提供了一个可以统一调度，统一管理的云操作系统。其解决如用户应用程序如何运行的问题。而一旦在生产环境中大量基于Kubernetes部署和管理应用程序后，作为系统管理员，还需要充分了解应用程序以及Kubernetes集群服务运行质量如何，通过对应用以及集群运行状态数据的收集和分析，持续优化和改进，从而提供一个安全可靠的生产运行环境。 这一小节中我们将讨论当使用Kubernetes时的监控策略该如何设计。

## Kubernetes架构

为了能够更好的理解Kubernetes下的监控体系，我们需要了解Kubernetes的基本架构，如下所示，是Kubernetes的架构示意图：

![Kubernetes架构](./static/kubernetes-artch-overview.png)

Kubernetes的核心组件主要由两部分组成：Master组件和Node组件，其中Matser组件提供了集群层面的管理功能，它们负责响应用户请求，处理集群实际，并且对集群资源进行统一的调度和管理。Node组件会运行在集群的所有节点上，它们负责管理和维护节点中运行的Pod，为Kubernetes集群提供运行时环境。

Master组件主要包括：

* kube-apiserver：负责对外暴露Kubernetes API；
* etcd：用于存储Kubernetes集群的所有数据；
* kube-scheduler: 负责为新创建的Pod选择可供其运行的节点；
* kube-controller-manager： 包含Node Controller，Deployment Controller，Endpoint Controller等等，通过与apiserver交互使相应的资源达到预期状态。

Node组件主要包括：

* kubelet：负责维护和管理节点上Pod的运行状态；
* kube-proxy：负责维护主机上的网络规则以及转发。
* Container Runtime：如Docker,rkt,runc等提供容器运行时环境。

## 监控Kubernetes

从物理结构上讲Kubernetes主要用于整合和管理底层的基础设施资源，对外提供应用容器的自动化部署和管理能力，这些基础设施可能是物理机、虚拟机、云主机等等。因此，基础资源的使用直接影响当前集群的容量和应用的状态。在这部分，我们需要关注集群中各个节点的主机负载，CPU使用率、内存使用率、存储空间以及网络吞吐等监控指标。

从自身架构上讲，kube-apiserver是Kubernetes提供所有服务的入口，无论是外部的客户端还是集群内部的组件都直接与kube-apiserver进行通讯。因此，kube-apiserver的并发和吞吐量直接决定了集群性能的好坏。其次，对于外部用户而言，Kubernetes是否能够快速的完成pod的调度以及启动，是影响其使用体验的关键因素。而这个过程主要由kube-scheduler负责完成调度工作，而kubelet完成pod的创建和启动工作。因此在Kubernetes集群本身我们需要评价其自身的服务质量，主要关注在Kubernetes的API响应时间，以及Pod的启动时间等指标上。

Kubernetes的最终目标还是需要为业务服务，因此我们还需要能够监控应用容器的资源使用情况。对于内置了对Prometheus支持的应用程序，也要支持从这些应用程序中采集内部的监控指标。最后，结合黑盒监控模式，对集群中部署的服务进行探测，从而当应用发生故障后，能够快速处理和恢复。

因此，在不考虑Kubernetes自身组件的情况下，如果要构建一个完整的监控体系，我们应该考虑，以下5个方面：

* 集群节点状态监控：从集群中各节点的kubelet服务获取节点的基本运行状态；
* 集群节点资源用量监控：通过Daemonset的形式在集群中各个节点部署Node Exporter采集节点的资源使用情况；
* 节点中运行的容器监控：通过各个节点中kubelet内置的cAdvisor中获取个节点中所有容器的运行状态和资源使用情况；
* 从黑盒监控的角度在集群中部署Blackbox Exporter探针服务，检测Service和Ingress的可用性；
* 如果在集群中部署的应用程序本身内置了对Prometheus的监控支持，那么我们还应该找到相应的Pod实例，并从该Pod实例中获取其内部运行状态的监控指标。
