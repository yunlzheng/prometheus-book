# 第5章 可视化一切

"You can't fix what you can't see"。可视化是监控的核心目标之一，在本章中我们将介绍Prometheus下的可视化技术。例如，Prometheus自身提供的Console Template能力以及Grafana这一可视化工具实现监控数据可视化。Prometheus UI提供了基本的数据可视化能力，可以帮助用户直接使用PromQL查询数据，并将数据通过可视化图表的方式进行展示，而实际的应用场景中往往不同的人对于可视化的需求不一样，关注的指标也不一样，因此我们需要能够有能力，构建出不同的可视化报表页面。 本章学习的内容就主要解决以上问题。

本章的主要内容：

* 使用Console Template创建可视化页面
* 使用Grafana创建更精美的数据仪表盘