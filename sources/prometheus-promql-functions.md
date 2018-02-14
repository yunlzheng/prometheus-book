# 内置函数

在上一小节中，我们已经看到了类似于irate()这样的函数，可以帮助我们计算监控指标的实时增长率。除了irate以外，Prometheus还提供了其它大量的内置函数，可以对时序数据进行更多的处理。

## abs()

绝对值

```abs(v instant-vector)```

## absent()

```absent(v instant-vector)```

判断当前序列是否不存在。

## ceil()

```ceil(v instant-vector)```

将向量中的所有元素样本值舍入为最接近的整数。

## changes()

```changes(v range-vector)```

changes将返回每一个区间向量中样本变化的次数，作为一个新的瞬时向量。

## clamp_max()

```clamp_max(v instant-vector, max scalar)``` 最大值上限。

限制瞬时向量中样本值的最大范围，使其具有最大值的上限。 即如果样本值大于最大值，则使用最大值替换该样本值。

## clamp_min()

```clamp_min(v instant-vector, min scalar)``` 最小值上限，

限制瞬时向量中样本值的最小范围。即如果样本值中小于最小值，则使用定义的最小值替换该样本值。

## day_of_month()

```day_of_month(v=vector(time()) instant-vector)``` 返回给定时间戳，在当前月中的日。 返回值在1到31之间。

## day_of_week()

```day_of_week(v=vector(time()) instant-vector)``` 返回给定时间戳，在一周中的第几天。 返回值范围为0到6， 0表示星期天。

## days_in_month()

```days_in_month(v=vector(time()) instant-vector)``` 给定时间戳所在月份的天数。返回值范围在28到31之间。

## delta()

```delta(v range-vector)```

计算区间向量v中每一个时间序列元素的第一个值和最后一个值之间的差值，并且以该增量作为瞬时向量的样本值。

例如，使用表达式，可以查询当前CPU与两个小时之间的差异。

```
delta(cpu_temp_celsius{host="zeus"}[2h])
```

delta只适用于仪表盘。

## deriv()

```
deriv(v range-vector)
```

使用简单线性回归计算区间向量v中的时间序列每秒的导数。

deriv只适用于仪表盘。

## exp()

```exp(v instant-vector)```

计算瞬时向量v中所有元素的指数。

特殊情况：

* Exp(+Inf) = +Inf
* Exp(NaN) = NaN

## floor()

```
floor(v instant-vector)
```

将v中所有元素的样本舍入到最接近的整数。

## histogram_quantile()

```histogram_quantile(φ float, b instant-vector)```

## holt_winters()

## hour()

## idelta()

## increase()

## irate()

## label_join()

## label_replace()

## ln()

## log2()

## log10()

## minute()

## month()

## predict_linear()

## rate()

## resets()

## round()

## scalar()

## sort()

## sort_desc()

## sqrt()

## time()

## timestamp()

## vector()

## year()

## <aggregation>_over_time()