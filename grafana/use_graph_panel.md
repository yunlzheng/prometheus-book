# 变化趋势：Graph Panel

Graph面板是最常用的一种可视化面板，其通过折线图或者柱状图的形式显示监控样本随时间而变化的趋势。Graph面板天生适用于Prometheus中Gauge和Counter类型监控指标的监控数据可视化。例如，当需要查看主机CPU、内存使用率的随时间变化的情况时，可以使用Graph面板。同时，Graph还可以非常方便的支持多个数据之间的对比。

![Graph面板](http://p2n2em8ut.bkt.clouddn.com/grafana_graph_panel.png)

## Graph Panel与Prometheus

Graph Panel通过折线图或者柱状图的形式，能够展示监控样本数据在一段时间内的变化趋势，因此其天生适合Prometheus中的Counter和Gauge类型的监控指标的可视化，对于Histogram类型的指标也可以支持，不过可视化效果不如Heatmap Panel来的直观。

接下来，我们将尝试使用Graph Panel可视化Prometheus中常用的4中指标类型的监控指标。

### 使用Graph Panel可视化Counter/Gauge

![Prometheus Counter可视化](http://p2n2em8ut.bkt.clouddn.com/grafana_graph_counter_demo_v2.png)

#### Metrics：控制数据源

这里以可视化主机CPU使用率为例，选中**Metrics选项**：

![Metrics选项](http://p2n2em8ut.bkt.clouddn.com/grafana_graph_counter_demo_metrics.png)

如上所示，这里使用了如下PromQL查询主机的CPU使用率：

```
1 - (avg(irate(node_cpu{mode='idle'}[5m])) without (cpu))
```

根据当前Promtheus的数据采集情况，该PromQL会返回多条时间序列（在示例中会返回3条）。Graph Panel会从时间序列中获取样本数据，并绘制到图表中。 为了让折线图有更好的可读性，我们可以通过定义**Legend format**为```{{ instance }}```控制每条线的图例名称：

![使用Legend format模板化图例](http://p2n2em8ut.bkt.clouddn.com/grafana_graph_counter_demo_metrics_legend.png)

在Graph Panel的**Axes选项**中可以控制图标的X轴和Y轴相关的行为，如下所示：

#### Axes：管理坐标轴

![Axes选项](http://p2n2em8ut.bkt.clouddn.com/grafana_graph_counter_demo_axes.png)

默认情况下，Y轴会直接显示当前样本的值，通过**Left Y**的**Unit**可以让Graph Panel自动格式化样本值。当前表达式返回的当前主机CPU使用率的小数表示，因此，这里选择单位为**percent(0.0.-1.0)**。除了百分比以外，Graph Panel支持如日期、货币、重量、面积等各种类型单位的自动换算，用户根据自己当前样本的值含义选择即可。

#### Legend：图例管理

除了在Metrics设置图例的显示名称以外，在Graph Panel的**Legend选项**可以进一步控制图例的显示方式，如下所示：

![Legend选项](http://p2n2em8ut.bkt.clouddn.com/grafana_graph_counter_demo_legend.png)

**Options中**可以设置图例的显示方式以及展示位置，**Vlaues**中可以设置是否显示当前时间序列的最小值，平均值等。 **Decimals**用于配置这些值显示时保留的小数位，如下所示：

![Legend控制图例的显示示例](http://p2n2em8ut.bkt.clouddn.com/grafana_graph_counter_demo_legend_sample.png)

#### Display: 自定义图形展示

**Display选项**主要用于控制可视化图形的显示，包含三个部分：Draw options、Series overrides和Thresholds。

![Display选项](http://p2n2em8ut.bkt.clouddn.com/grafana_graph_counter_demo_display_draw.png)

**Draw Options**用于设置当前图标的展示形式、样式以及交互提示行为。其中，Draw Modes用于控制图形展示形式：Bar（柱状）、Lines（线条）、Points（点），用户可以根据自己的需求同时启用多种模式。Mode Options则设置各个展示模式下的相关样式。Hover tooltip用于控制当鼠标移动到图形时，显示提示框中的内容。

如果希望当前图表中的时间序列以不同的形式展示，则可以通过**Series overrides**控制，顾名思义，可以为指定的时间序列指定自定义的Draw Options配置，从而让其以不同的样式展示。例如：

![Series overrides](http://p2n2em8ut.bkt.clouddn.com/grafana_series_overrides.png)

这里定义了一条自定义规则，其匹配图例名称满足**/localhost/**的时间序列，并定义其以点的形式显示在图表中，修改后的图标显示效果如下：

![Series overrides效果](http://p2n2em8ut.bkt.clouddn.com/grafana_series_overrides_demo.png)

Display选项中的最后一个是**Thresholds**，Threshold主要用于一些自定义一些样本的阈值，例如，定义一个Threshold规则，如果CPU超过50%的区域显示为warning状态，可以添加如下配置：

![Threshold设置](http://p2n2em8ut.bkt.clouddn.com/grafana_thresholds_demo.png)

Graph Panel则会在图表中显示一条阈值，并且将所有高于该阈值的区域显示为warining状态，通过可视化的方式直观的在图表中显示一些可能出现异常的区域。

需要注意的是，如果用户为该图表自定义了Alert（告警）配置，Thresholds将会被警用，并且根据Alert中定义的Threshold在图形中显示阈值内容。关于Alert的使用会在后续部分，详细介绍。

### 使用Graph Panel可视化Histogram

这里以Prometheus自身的监控指标prometheus_tsdb_compaction_duration为例，该监控指标记录了Prometheus进行数据压缩任务的运行耗时的分布统计情况。如下所示，是Prometheus返回的样本数据：

```
# HELP prometheus_tsdb_compaction_duration Duration of compaction runs.
# TYPE prometheus_tsdb_compaction_duration histogram
prometheus_tsdb_compaction_duration_bucket{le="1"} 2
prometheus_tsdb_compaction_duration_bucket{le="2"} 36
prometheus_tsdb_compaction_duration_bucket{le="4"} 36
prometheus_tsdb_compaction_duration_bucket{le="8"} 36
prometheus_tsdb_compaction_duration_bucket{le="16"} 36
prometheus_tsdb_compaction_duration_bucket{le="32"} 36
prometheus_tsdb_compaction_duration_bucket{le="64"} 36
prometheus_tsdb_compaction_duration_bucket{le="128"} 36
prometheus_tsdb_compaction_duration_bucket{le="256"} 36
prometheus_tsdb_compaction_duration_bucket{le="512"} 36
prometheus_tsdb_compaction_duration_bucket{le="+Inf"} 36
prometheus_tsdb_compaction_duration_sum 51.31017077500001
prometheus_tsdb_compaction_duration_count 36
```

在第2章的“Metric类型”小节中，我们已经介绍过Histogram的指标，Histogram用于统计样本数据的分布情况，其中标签le定义了分布桶Bucket的边界，如上所示，表示当前Promtheus共进行了36次数据压缩，总耗时为51.31017077500001ms。其中任务耗时在0~1ms区间内的为2次、在0~2ms区间范围内为36次，以此类推。

如下所示，如果需要在Graph中显示Histogram类型的监控指标，需要在Query Editor中定义查询结果的**Format as**为Heatmap。通过该设置Grafana会自动计算Histogram中的Bucket边界范围以及该范围内的值：

![Metrics设置](http://p2n2em8ut.bkt.clouddn.com/grafana_bucket_setting.png)

Graph Panel重新计算了Bucket边界，如下所示，在0~1ms范围内的任务次数为2，在1~2ms范围内的运行任务次数为34。通过图形的面积，可以反映出各个Bucket下的大致数据分布情况：

![Histogram数据可视化](http://p2n2em8ut.bkt.clouddn.com/grafana_bucket_demo.png)

不过通过Graph Panel展示Histogram也并不太直观，其并不能直接反映出Bucket的大小以及分布情况，因此在Grafana V5版本以后更推荐使用Heatmap Panel的方式展示Histogram样本数据。关于Heatmap Panel的使用将会在接下来的部分介绍。
