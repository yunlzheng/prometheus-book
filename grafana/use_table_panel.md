# 表格：Tabel Panel

通过表格的形式可以同时显示多条时间序列中的数据，可以方便的查看和比较监控指标的数据。Table Panel是Grafana提供的基础可视化组件之一。

![Table Panel示例](http://p2n2em8ut.bkt.clouddn.com/grafana_table_panel_example2.png)

对于Promtheus采集到的时间序列数据，Table Panel支持直接将PromQL返回的时间序列格式化为表格的形式进行展示，也可以直接展示时间序列并且对样本数据进行统计聚合。

## 格式化时间序列

如下所示，Table Panel在默认情况下**Format as**配置选项为**Table**。该配置会直接将PromQL查询到的所有样本格式化为Grafana的Table数据结构，并直接展示到表格当中。

![Format As Table](http://p2n2em8ut.bkt.clouddn.com/grafana_format_as_table.png)

其中样本的所有标签都被映射成表格的列，其中名为Value列会显示当前样本的值。默认情况下样本值不带任何的单位，为了让Table Panel能够自动化格式化样本值，可以通过Column Styles为Value定义样本值的格式化方式，如下所示：

![Column Styles选项](http://p2n2em8ut.bkt.clouddn.com/grafana_table_panel_cloum_style.png)

## 使用Table可视化时间序列

## 按行显示时间序列

## 按列显示时间序列

## 对样本数据进行聚合