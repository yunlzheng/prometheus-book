# PromQL内置函数

在上一小节中，我们已经看到了类似于irate()这样的函数，可以帮助我们计算监控指标的增长率。除了irate以外，Prometheus还提供了其它大量的内置函数，可以对时序数据进行丰富的处理。本小节将带来读者了解一些常用的内置函数以及相关的使用场景和用法。

## 计算Counter指标增长率

我们知道Counter类型的监控指标其特点是只增不减，在没有发生重置（如服务器重启，应用重启）的情况下其样本值应该是不断增大的。为了能够更直观的表示样本数据的变化剧烈情况，需要计算样本的增长速率。

如下图所示，样本增长率反映出了样本变化的剧烈程度：

![通过正常率表示样本的变化情况](http://p2n2em8ut.bkt.clouddn.com/counter-to-rate.png)

increase(v range-vector)函数是PromQL中提供的众多内置函数之一。其中参数v是一个区间向量，increase函数获取区间向量中的第一个后最后一个样本并返回其增长量。因此，可以通过以下表达式Counter类型指标的增长率：

```
increase(node_cpu[2m]) / 120
```

这里通过node_cpu[2m]获取时间序列最近两分钟的所有样本，increase计算出最近两分钟的增长量，最后除以时间120秒得到node_cpu样本在最近两分钟的平均增长率。并且这个值也近似于主机节点最近两分钟内的平均CPU使用率。

除了使用increase函数以外，PromQL中还直接内置了rate(v range-vector)函数，rate函数可以直接计算区间向量v在时间窗口内平均增长速率。因此，通过以下表达式可以得到与increase函数相同的结果：

```
rate(node_cpu[2m])
```

需要注意的是使用rate或者increase函数去计算样本的平均增长速率，容易陷入“长尾问题”当中，其无法反应在时间窗口内样本数据的突发变化。 例如，对于主机而言在2分钟的时间窗口内，可能在某一个由于访问量或者其它问题导致CPU占用100%的情况，但是通过计算在时间窗口内的平均增长率却无法反应出该问题。

为了解决该问题，PromQL提供了另外一个灵敏度更高的函数irate(v range-vector)。irate同样用于计算区间向量的计算率，但是其反应出的是瞬时增长率。irate函数是通过区间向量中最后两个两本数据来计算区间向量的增长速率。这种方式可以避免在时间窗口范围内的“长尾问题”，并且体现出更好的灵敏度，通过irate函数绘制的图标能够更好的反应样本数据的瞬时变化状态。

irate函数相比于rate函数提供了更高的灵敏度，不过当需要分析长期趋势或者在告警规则中，irate的这种灵敏度反而容器造成干扰。因此在长期趋势分析或者告警中更推荐使用rate函数。

## 预测Gauge指标趋势

## 统计Histogram指标的分位数

## 使用内置函数聚合样本

## 时间序列便签替换








## 数学函数

##### abs()

```abs(v instant-vector)```将瞬时向量中的所有样本值取绝对值。

##### ceil()

```ceil(v instant-vector)```将向量中的所有样本值向上取整。

##### exp()

```exp(v instant-vector)```计算瞬时向量v中所有元素的指数。

特殊情况：

* Exp(+Inf) = +Inf
* Exp(NaN) = NaN

##### floor()

```floor(v instant-vector)```将瞬时向量中所有元素的样本值向下取整。

##### sqrt()

```sqrt(v instant-vector)```计算瞬时向量中所有样本的平方根。

##### round()

```round(v instant-vector, to_nearest=1 scalar)```将瞬时向量中所有样本四舍五入取整。可选参数to_nearest参数可以用于

##### ln()

```ln(v instant-vector)```计算v中所有元素的自然数

##### log2()

```log2(v instant-vector)```计算v中所有元素的二进制对数

##### log10()

```log10(v instant-vector)```计算v中所有元素的小数对数

## 范围限定

##### clamp_max()

```clamp_max(v instant-vector, max scalar)``` 最大值上限。限制瞬时向量中样本值的最大范围，使其具有最大值的上限。 即如果样本值大于最大值，则使用最大值替换该样本值。

##### clamp_min()

```clamp_min(v instant-vector, min scalar)``` 最小值上限。限制瞬时向量中样本值的最小范围。即如果样本值中小于最小值，则使用定义的最小值替换该样本值。

## 日期和时间

##### day_of_month()

```day_of_month(v=vector(time()) instant-vector)``` 返回给定时间戳，在当前月中的日。 返回值在1到31之间。

##### day_of_week()

```day_of_week(v=vector(time()) instant-vector)``` 返回给定时间戳，在一周中的第几天。 返回值范围为0到6， 0表示星期天。

##### days_in_month()

```days_in_month(v=vector(time()) instant-vector)``` 返回给定时间戳所在月份的天数。返回值范围在28到31之间。

##### minute()

minute()返回给定时间戳的当前的分钟数。返回值范围在0到59之间

##### hour()

hour(v=vector(time()) instant-vector)返回给定时间戳在一天当中所在的小时数。返回值范围在0到23之间

##### month()

month()返回给定时间戳在一年当中所在的月份。返回值范围在1到12之间

##### time()

time()返回从1960年月1日到当前时间依赖的秒数。

##### timestamp()

```timestamp(v instant-vector)```放回瞬时向量中所有样本的时间戳

> 注意：从Prometheus2.0才开始支持这个函数

##### year()

```year(v=vector(time()) instant-vector)```

## 排序

##### sort()

```sort(v instant-vector)```按照瞬时向量中的样本值升序排序。

##### sort_desc()

```sort_desc(v instant-vector)```按照瞬时向量中的样本值降序排序。

## 类型转换

##### scalar()

```scalar(v instant-vector)```当瞬时向量中只存在一个样本数据时，通过scalar可以将该瞬时向量转换为标量，如果瞬时向量中不存在任何样本数据或者存在多个样本数据时则返回NaN。

##### vector()

```vector(s scalar)```将一个标量数据转换为一个不包含任何标签的瞬时向量。

## 分位数统计

##### histogram_quantile()

```histogram_quantile(φ float, b instant-vector)```

## 按照时间聚合

##### <aggregation>_over_time()

* ```avg_over_time(range-vector)```
* ```min_over_time(range-vector)```
* ```max_over_time(range-vector)```
* ```sum_over_time(range-vector)```
* ```count_over_time(range-vector)```
* ```quantile_over_time(scalar, range-vector)```
* ```stddev_over_time(range-vector)```
* ```stdvar_over_time(range-vector)```

## 只适用于区间向量

##### changes()

```changes(v range-vector)```changes将返回每一个区间向量中样本变化的次数，作为一个新的瞬时向量。

##### delta()

```delta(v range-vector)```计算区间向量v中每一个时间序列元素的第一个值和最后一个值之间的差值，并且以该增量作为瞬时向量的样本值。

例如，使用表达式，可以查询当前CPU与两个小时之间的差异。

```
delta(cpu_temp_celsius{host="zeus"}[2h])
```

> 注意：delta只适用于仪表盘。

##### deriv()

deriv(v range-vector)使用简单线性回归计算区间向量v中的时间序列每秒的导数。

> 注意：deriv只适用于仪表盘。

##### rate()

```rate()```

##### irate()

```irate()```

##### holt_winters()

```holt_winters(v range-vector, sf scalar, tf scalar)```

##### idelta()

```idelta(v range-vector)```

##### predict_linear()

```predict_linear(v range-vector, t scalar)```

## 只适用于计数器

##### increase()

```increase(v range-vector)``` 计算时间序列在一段时间范围内的增长量。

##### resets()

```resets(v range-vector)```计算输入每一条时间序列数据重置的次数。对于计数器类型的时间序列，只要出现样本值减少的情况就认为是一次重置。

> 注意： 只适用于计数器

## 标签变更

##### label_join()

```label_join(v instant-vector, dst_label string, separator string, src_label_1 string, src_label_2 string, ...)```

##### label_replace()

```label_replace(v instant-vector, dst_label string, replacement string, src_label string, regex string)```

## 判断缺失的值

##### absent()

```absent(v instant-vector)```判断当前序列是否不存在。