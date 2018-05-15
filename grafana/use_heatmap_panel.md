# 分布统计：Heatmap Panel

Heatmap是是Grafana v4.3版本以后新添加的可视化面板，通过热图可以直观的查看样本的分布情况。在Grafana v5.1版本中Heatmap完善了对Prometheus的支持。这部分，将介绍如何使用Heatmap Panel实现对Prometheus监控指标的可视化。

## 使用Heatmap可视化Histogram样本分布情况

在上一小节中，我们尝试了使用Graph Panel来可视化Histogram类型的监控指标prometheus_tsdb_compaction_duration_bucket。虽然能展示各个Bucket区间内的样本分布，但是无论是以线图还是柱状图的形式展示，都不够直观。对于Histogram类型的监控指标来说，更好的选择是采用Heatmap Panel，如下所示，Heatmap Panel可以自动对Histogram类型的监控指标分布情况进行计划，获取到每个区间范围内的样本个数，并且以颜色的深浅来表示当前区间内样本个数的大小。而图形的高度，则反映出当前时间点，样本分布的离散程度。

![Heatmap示例](http://p2n2em8ut.bkt.clouddn.com/grafana_heatmap_sample.png)

在Grafana中使用Heatmap Panel也非常简单，在Dashboard页面右上角菜单中点击“add panel”按钮，并选择Heatmap Panel即可。

如下所示，Heapmap Panel的编辑页面中，主要包含5类配置选项，分别是：General、Metrics、Axes、Display、Time range。

![Heapmap Panel编辑页面](http://p2n2em8ut.bkt.clouddn.com/grafana_heatmap_editor.png)

其中大部分的配置选项与Graph Panel基本保持一致，这里就不重复介绍了。

### Metrics：控制数据源

如下所示，当使用Heatmap可视化Histogram类型的监控指标时，需要设置**Format as**选项为**Heatmap**。当使用Heatmap格式化数据后，Grafana会自动根据样本的中的le标签，计算各个Bucket桶内的分布，并且按照Bucket对数据进行重新排序：

![Mteircs设置](http://p2n2em8ut.bkt.clouddn.com/grafana_heatmap_metrics_setting.png)

而**Legend format**模板将会控制Y轴中的显示内容。

### Axes：管理坐标轴

由于Histogram类型指标自带了分区范围Bucket，因此这里的Date format需要定义为**Time series buckets**。该选项表示Heatmap Panel不需要自身对数据的分布情况进行计算，直接使用时间序列中返回的Bucket即可。

![Axes设置](http://p2n2em8ut.bkt.clouddn.com/grafana_heatmap_axes_setting.png)

通过以上设置，即可实现对Histogram类型监控指标的可视化。

## 使用Heatmap可视化其它类型样本分布情况

对于非Histogram类型，由于其监控样本中并不包含Bucket相关信息，因此在**Metrics选项中**需要定义**Format as**为**Time series**，如下所示：

![Metrics设置](http://p2n2em8ut.bkt.clouddn.com/grafana_heatmap_normal_metrics.png)

并且通过**Axes选项**中选择**Data format**方式为**Time series**。设置该选项后Heatmap Panel会要求用户提供Bucket分布范围的设置，如下所示：

![Axes设置](http://p2n2em8ut.bkt.clouddn.com/grafana_heatmap_normal_axes.png)

在Y轴（Y Axis）中需要通过Scale定义Bucket桶的分布范围，默认的Bucket范围支持包括：liner（线性分布）、log(base 10)（10的对数）、log(base 32)（32的对数）、log(base 1024)（1024的对数）等。

例如，上图中设置的Scale为log(base 2)，那么在Bucket范围将2的对数的形式进行分布，即[1,2,4,8,....]，如下所示：

![Bucket分布情况](http://p2n2em8ut.bkt.clouddn.com/grafana_heatmap_normal_sample.png)

通过以上设置，Heatmap会自动根据用户定义的Bucket范围对Prometheus中查询到的样本数据进行分布统计。