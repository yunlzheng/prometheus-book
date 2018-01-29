## 为什么需要服务发现

在前面章节中，我们大量使用了static_config来定义我们的监控目标。在本地或者开发环境中，static_config是最直接的定义监控目标的方式。

![](http://dockerone.com/uploads/article/20180117/406c11fa0ec204505b091098caecbf43.png)

现在我们已经清楚，Prometheus通过Job定义一个采集任务，一个Job可以对应多个Target或者称为Instance。

对于Zabbix以及Nagios这类Push系统而言，通常由采集的Agent来决定和哪一个监控服务进行通讯。而对于Prometheus这类基于Pull的监控平台而言，则由Server侧决定采集的目标有哪些。

![](http://dockerone.com/uploads/article/20180117/30ffeaa9ddeb0e30382f713ae3d81328.png)

当然相比于Push System而言，Pull System：

* 只要Exporter在运行，你可以在任何地方（比如在本地），搭建你的监控系统
* 你可以更容器的去定位Instance实例的健康状态以及故障定位
* 更利于构建DevOps文化的团队
* 更适合于云原生的部署环境

现在越来越多的企业将自己的基础设施，应用托管到云(公有或者私有)当中。云环境可以更好的根据当前系统容量需求去扩容或者缩容我们的基础设施，或者应用实例。在这种场景下Push System几乎无法有效的适应这种场景，因为所有的监控对象都是耦合了监控系统的信息。

而对于Pull System而言，Server侧和Agent是一种解耦的关系，因此更适合于云下的监控场景。 当然对于Promtheus这类Pull System而言，需要解决的一个问题就是如何去发现和管理这些具有动态属性的监控目标。

### 自动发现监控对象

为了解决以上问题，Prometheus提供了服务发现的机制来自动发现这些自动创建或者销毁的监控目标。

![](http://dockerone.com/uploads/article/20180117/ace221c3c96a2915a6753c1cf8ab9d4f.png)

Prometheus提供了多种服务发现机制。包括：file, DNS, Consul, Kubernetes, OpenStack, EC2等等。而无论对于哪一种服务发现机制而言，工作原理都类似：Promtheus通过与服务发现注册中心进行通讯，发现注册到服务发现注册中心的服务实例。再对获取到的这些实例进行筛选(relabel机制),从而维护一个动态的Target列表。

因此相比于Zabbix这一类老牌监控解决方案。通过Promtheus提供的服务发现机制以及Pull的设计原则。监控对象(基础设施，应用，服务等)与监控服务器直接解耦，更适合于在当前云原生的趋势当中。因此Prometheus也被称为下一代监控系统的首选，而其中下一代即代表这云原生。