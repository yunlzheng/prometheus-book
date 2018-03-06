# 内置函数

> TODO： 补充各个函数的使用案例

在上一小节中，我们已经看到了类似于irate()这样的函数，可以帮助我们计算监控指标的实时增长率。除了irate以外，Prometheus还提供了其它大量的内置函数，可以对时序数据进行更多的处理。

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

> 注意：从Prometheus2.0开始支持

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