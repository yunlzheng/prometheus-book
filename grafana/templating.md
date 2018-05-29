# 模板化Dashboard

在前面的小节中介绍了Grafana中4中常用的可视化面板的使用，通过在面板中使用PromQL表达式，Grafana能够方便的将Prometheus返回的数据进行可视化展示。例如，在展示主机CPU使用率时，我们使用了如下表达式：

```
1 - (avg(irate(node_cpu{mode='idle'}[5m])) without (cpu))
```

该表达式会返回当前Promthues中存储的所有时间序列，每一台主机都会有一条单独的曲线用于体现其CPU使用率的变化情况：

![主机CPU使用率](http://p2n2em8ut.bkt.clouddn.com/grafana_templating_variables_example.png)

而当用户只想关注其中某些主机时，基于当前我们已经学习到的知识只有两种方式，要么每次手动修改Panel中的PromQL表达式，要么直接为这些主机创建单独的Panel。但是无论如何，这些硬编码方式都会直接导致Dashboard配置的频繁修改。在这一小节中我们将学习使用Dashboard变量的方式解决以上问题。

## 变量

在Grafana中用户可以为Dashboard定义一组变量（Variables），变量一般包含一个到多个可选值。如下所示，Grafana通过将变量渲染为一个下拉框选项，从而使用户可以动态的改变变量的值：

![Dashboard变量](http://p2n2em8ut.bkt.clouddn.com/grafana_templating_variables_example1.png)

例如，这里定义了一个名为node的变量，用户可以通过在PromQL表达式或者Panel的标题中通过以下形式使用该变量：

```
1 - (avg(irate(node_cpu{mode='idle', instance=~"$node"}[5m])) without (cpu))
```

变量的值可以支持单选或者多选，当对接Prometheus时，Grafana会自动将$node的值格式化为如“**host1|host2|host3**”的形式。配合使用PromQL的标签正则匹配“**=~**”，通过动态改变PromQL从而实现基于标签快速对时间序列进行过滤。

## 变量定义

通过Dashboard页面的Settings选项，可以进入Dashboard的配置页面并且选择Variables子菜单。

![为Dashboard添加变量](http://p2n2em8ut.bkt.clouddn.com/grafana_templating_add_variables.png)

|类型|工作方式|
|-|--|
|Query|允许用户通过Datasource查询表达式的返回值动态生成变量的可选值|
|Interval|该变量代表时间跨度，通过Interval类型的变量，可以动态改变PromQL区间向量表达式中的时间范围。如rate(node_cpu[2m])|
|Datasource|允许用户动态切换当前Dashboard的数据源，特别适用于同一个Dashboard展示多个数据源数据的情况|
|Custom|用户直接通过手动的方式，定义变量的可选值|
