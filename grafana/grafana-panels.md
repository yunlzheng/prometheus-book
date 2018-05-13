# 使用Panel可视化监控数据

面板(Panel)是Grafana中最基本的可视化单元。每一种类型的面板都提供了相应的查询编辑器(Query Editor)，让用户可以从不同的数据源（如Prometheus）中查询出相应的监控数据，并且以可视化的方式展现。

Grafana中所有的面板均以插件的形式进行使用，当前内置了5种类型的面板，分别是：Graph，Singlestat，Heatmap, Dashlist，Table以及Text。

其中像Graph这样的面板允许用户可视化任意多个监控指标以及多条时间序列。而Siglestat则必须要求查询结果为单个样本。Dashlist和Text相对比较特殊，它们与特定的数据源无关。

接下来，我们将带领读者了解如何通过Panel创建精美的可视化图表。

## 添加Panel

通过Grafana UI用户可以在一个Dashboard下添加Panel，点击Dashboard右上角的“Add Panel”按钮，如下所示，将会显示当前系统中所有可使用的Panel类型：

![添加Panel](http://p2n2em8ut.bkt.clouddn.com/grafana_dashboard_add_panel.png)

选择想要创建的面板类型即可。这里以Graph面板为例，创建Panel之后，并切换到编辑模式，就可以看到类似于如下的面板编辑界面了：

![编辑Panel信息](http://p2n2em8ut.bkt.clouddn.com/grafana_edit_panel.png)

## Prometheus Query Editor

所有类型的面板都会包含Metric选项，用于定义当前Panel如何从数据源中查询样本数据。

**Data Source**选项用于指定当前查询的数据源，Grafana会加载当前组织中添加的所有数据源。其中还会包含两个特殊的数据源：**Mixed**和**Grafana**。 Mixed用于需要从多个数据源中查询和渲染数据的场景，Grafana则用于需要查询Grafana自身状态时使用。

由于不同类型的数据源不同，当选中数据源时，Panel会根据当前数据源类型显示不同的Query Editor。这里我们主要介绍Prometheus Query Editor，如下所示，当选中的数据源类型为Protheus时，会显示如下界面：

![Query Editor](http://p2n2em8ut.bkt.clouddn.com/graph_prometheus_query_editor.png)

Grafana提供了对PromQL的完整支持，在Query Editor中，可以添加任意个Query，并且使用PromQL表达式从Promtheus中查询相应的样本数据。

```
avg (irate(node_cpu{mode!='idle'}[2m])) without (cpu)
```

每个PromQL表达式都可能范围多条时间序列。**Legend format**用于控制如何格式化每条时间序列的图例信息。Grafana支持通过模板的方式，根据时间序列的标签动态生成图例名称，例如：使用{{instance}}表示使用当前事件序列instance标签的值作为图例名称：

```
{{instance}}-{{mode}}
```

当查询到的样本数据量非常大时可以导致Grafana渲染图标时出现一些性能问题，通过**Min Step**可以控制Promtheus查询数据时的最小步长（Step），从而减少从Promtheus返回的数据量。

**Resolution**选项，则可以控制Grafana自身渲染的数据量。例如，如果**Resolution**的值为**1/10**，Grafana会将Prometeus返回的10个样本数据合并成一个点。因此**Resolution**越小可视化的精确性越高，反之，可视化的精度越低。

**Format as**选项定义如何格式化Prometheus返回的样本数据。这里提供了3个选项：Table,Time Series和Heatmap，分别用于Tabel Panel，Graph Panel和Heatmap Panel的数据可视化。
