# 第2章： 探索PromQL

本章将带领读者探秘Prometheus的自定义查询语言PromQL。通过PromQL用户可以非常方便地对监控样本数据进行统计分析，PromQL支持常见的运算操作符，同时PromQL中还提供了大量的内置函数可以实现对数据的高级处理。当然在学习PromQL之前，用户还需要了解Prometheus的样本数据模型。PromQL作为Promtheus的核心能力除了实现数据的对外查询和展现，同时告警监控也是依赖PromQL实现的。

本章的主要内容：

* Promtheus的数据模型
* Promthues中监控指标的类型
* 深入PromQL
* 监控的最佳实践