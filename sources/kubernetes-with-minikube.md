# 初识Kubernetes

Kubenetes是一款由Google开发的开源的容器编排工具（[GitHub源码](https://github.com/kubernetes/kubernetes)），在Google已经使用超过15年（Kubernetest前身是Google的内部工具Borg）。Kubernetes将一系列的主机看做是一个受管理的海量资源，这些海量资源组成了一个能够方便进行扩展的操作系统。而在Kubernetes中运行着的容器则可以视为是这个操作系统中运行的“进程”，通过Kubernetes这一中央协调器，解决了基于容器应用程序的调度、伸缩、访问负载均衡以及整个系统的管理和监控的问题。

## Kubernetes应用管理模型

下图展示了，Kubernetes的应用管理模型

![Kubernetes应用管理模型](http://p2n2em8ut.bkt.clouddn.com/kubernetes-app-model.png)

Pod是Kubernetes中的最小调度资源。Pod中会包含一组容器，它们一起工作，并且对外提供一个（或者一组）功能。对于这组容器而言它们共享相同的网络和存储资源，因此它们之间可以直接通过本地网络（127.0.0.1）直接进行访问。当Pod被创建时，调度器（kube-schedule）会从集群中找到满足条件的节点运行它。

如果部署应用程序时，需要启动多个实例（副本），则需要使用到控制器（Controller）。用户可以在Controller定义Pod的调度规则、运行的副本数量以及升级策略等等信息，当某些Pod发生故障之后，Controller会尝试自动修复，直到Pod的运行状态满足Controller中定义的预期状态为止。Kubernetes中提供了多种Controller的实现，包括：Deployment（无状态应用）、StatefulSet（有状态应用）、Daemonset（守护模式）等多种Controller实现，以支持不同类型应用的部署和调度模式。

通过Controller和Pod我们定义了应用程序是如何运行的，接下来需要解决如何使用这些部署在Kubernetes集群中的应用。Kubernetes将这一问题划分为两个问题域，第一，集群内的应用如何通讯。第二，外部的用户如何访问部署在集群内的应用？

对于第一个问题，在Kubernetes中通过定义Service（服务）来解决。Service在Kubernetes集群内扮演了服务发现和负载均衡的作用。在Kubernetes下部署的Pod实例都会包含一组描述自身信息的Lable，而创建Service，可以声明一个Selector（标签选择器）。Service通过Selector，找到匹配标签规则的Pod实例，并将对Service的请求转发到代理的Pod中。Service创建完成后，集群内的应用就可以通过使用Service的名称作为DNS域名进行相互访问。

而对于第二个问题，Kubernetes中定义了单独的资源Ingress（入口）。Ingress是一个工作在7层的负载均衡器，其负责代理外部进入集群内的请求，并将流量转发到对应的服务中。

最后，对于同一个Kubernetes集群其可能被多个组织使用，为了隔离这些不同组织创建的应用程序，Kubernetes定义了命名空间（Namespace）对资源进行隔离。

## 搭建本地Kubernetes集群

为了能够更直观的了解和使用Kubernetes，我们将在本地通过工具Minikube([https://github.com/kubernetes/minikube](https://github.com/kubernetes/minikube))搭建一个本地的Kubernetes测试环境。Minikube会在本地通过虚拟机运行一个单节点的Kubernetes集群，可以方便用户或者开发人员在本地进行与Kubernetes相关的开发和测试工作。

安装MiniKube的方式很简单，对于Mac用户可以直接使用Brew进行安装:

```
brew cask install minikube
```

其它操作系统用户，可以查看Minikube项目的官方说明文档进行安装即可。安装完成后，在本机通过命令行启动Kubernetes集群:

```
$ minikube start
Starting local Kubernetes v1.7.5 cluster...
Starting VM...
SSH-ing files into VM...
Setting up certs...
Starting cluster components...
Connecting to cluster...
Setting up kubeconfig...
Kubectl is now configured to use the cluster.
```

MiniKube会自动配置本机的kubelet命令行工具，用于与对集群资源进行管理。同时Kubernetes也提供了一个Dashboard管理界面，在MiniKube下可以通过以下命令打开：

```
$ minikube dashboard
Opening kubernetes dashboard in default browser...
```

Kubernetes中的Dashboard本身也是通过Deployment进行部署的，因此可以通过MiniKube找到当前集群虚拟机的IP地址：

```
$ minikube ip
192.168.99.100
```

通过kubectl命令行工具，找到Dashboard对应的Service对外暴露的端口，如下所示，kubernetes-dashboard是一个NodePort类型的Service，并对外暴露了30000端口：

```
kubectl get service --namespace=kube-system
NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
kube-dns               ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP   131d
kubernetes-dashboard   NodePort    10.105.168.160   <none>        80:30000/TCP    131d
```

在Dashbord中，用户可以可视化的管理当前集群中运行的所有资源，以及监视其资源运行状态。

![Kubernetes Dashboard](http://p2n2em8ut.bkt.clouddn.com/kubernetes-dashboard.png)

## 在Kubernetes下部署应用程序

Kubernetes环境准备完成后，就可以开始尝试在Kubernetes下尝试部署一个应用程序。Kubernetes中管理的所有资源都可以通过YAML文件进行描述。如下所示，创建了一个名为nginx-deploymeht.yml文件：

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

在该YAML文件中，我们定义了需要创建的资源类型为Deployment，在metadata中声明了该Deployment的名称以及标签。spec中则定义了该Deployment的具体设置，通过replicas定义了该Deployment创建后将会自动创建3个Pod实例。运行的Pod以及进行则通过template进行定义。

在命令行中使用，如下命令：

```
$ kubectl create -f nginx-deploymeht.yml
deployment "nginx-deployment" created
```

在未指定命名空间的情况下，kubectl默认关联default命名空间。由于这里没有指定Namespace，该Deployment将会在默认的命令空间default中创建。 通过kubectl get命令查看当前Deployment的部署进度：

```
# 查看Deployment的运行状态
$ kubectl get deployments
NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3         3         3            3           1m

# 查看运行的Pod实例
$ kubectl get pods
NAME                                READY     STATUS    RESTARTS   AGE
nginx-deployment-6d8f46cfb7-5f9qm   1/1       Running   0          1m
nginx-deployment-6d8f46cfb7-9ppb8   1/1       Running   0          1m
nginx-deployment-6d8f46cfb7-nfmsw   1/1       Running   0          1m
```

为了能够让用户或者其它服务能够访问到Nginx实例，这里通过一个名为nginx-service.yml的文件定义Service资源：

```
kind: Service
apiVersion: v1
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: NodePort
```

默认情况下，Service资源只能通过集群网络进行访问(type=ClusterIP)。这里为了能够直接访问该Service，需要将容器端口映射到主机上，因此定义该Service类型为NodePort。

创建并查看Service资源：

```
$ kubectl create -f nginx-service.yml
service "nginx-service" created

$ kubectl get svc
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP   10.96.0.1        <none>        443/TCP        131d
nginx-service   NodePort    10.104.103.112   <none>        80:32022/TCP   10s
```

通过nginx-server映射到虚拟机的32022端口，就可以直接访问到Nginx实例的80端口：

![Nginx主页](http://p2n2em8ut.bkt.clouddn.com/nginx-home-page.png)

部署完成后，如果需要对Nginx实例进行扩展，可以使用：

```
$ kubectl scale deployments/nginx-deployment --replicas=4
deployment "nginx-deployment" scaled
```

通过kubectl命令还可以对镜像进行滚动升级：

```
$ kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
deployment "nginx-deployment" image updated

$ kubectl get pods
NAME                                READY     STATUS              RESTARTS   AGE
nginx-deployment-58b94fcb9-8fjm6    0/1       ContainerCreating   0          52s
nginx-deployment-58b94fcb9-qzlwx    0/1       ContainerCreating   0          51s
nginx-deployment-6d8f46cfb7-5f9qm   1/1       Running             0          45m
nginx-deployment-6d8f46cfb7-7xs6z   0/1       Terminating         0          2m
nginx-deployment-6d8f46cfb7-9ppb8   1/1       Running             0          45m
nginx-deployment-6d8f46cfb7-nfmsw   1/1       Running             0          45m
```

如果升级后服务出现异常，那么可以通过以下命令对应用进行回滚：

```
$ kubectl rollout undo deployment/nginx-deployment
deployment "nginx-deployment"
```

Kubernetes依托于Google丰富的大规模应用管理经验。通过将集群环境抽象为一个统一调度和管理的云"操作系统，视容器为这个操作中独自运行的“进程”，进程间的隔离通过命名空间（Namespace）完成，实现了对应用生命周期管理从自动化到自主化的跨越。