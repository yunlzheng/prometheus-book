## PromQL初识

Prometheus通过指标名称Metrics Name以及对应的一组键值对Labels唯一定义一条时间序列。指标名称反应了监控样本的基本标识，而Label则在这个基本特征上为采集到的数据提供了多种特征维度。用户可以基于这些特征维度过滤，聚合，统计从而产生新的计算后的一条时间序列。

### 使用标签过滤数据

通过PromQL我们可以通过标签描述采集到数据的特征，并且根据该特征得到一条新的时间序列。

例如：

```
# 查询Http返回状态码为500的所有时间序列
http_request_total{code="500"}

# 查询Http返回状态码非200的所有时间序列
http_request_total{code!="200"}

# dc标签的值匹配正则表达式的所有时间序列
http_request_total{dc~="us-west-.*"}
```

### 使用标签对数据进行聚合

一般来说，如果描述样本特征的标签(label)在不是唯一的情况下，通过PromQL查询数据，会返回多条满足这些特征维度的时间序列。而PromQL提供的聚合操作可以用来对这些多条时间序列进行处理，形成一条新的时间序列。

```
# 查询系统所有http请求的总量
sum(http_request_total)

# 按照mode计算主机cpu的平均使用时间
avg(node_cpu) by (mode)

# 按照主机查询各个主机的cpu使用率
sum(sum(irate(node_cpu{mode!='idle'}[5m]))  / sum(irate(node_cpu[5m]))) by (instance)
```

### PromQL的返回值

通过上面的几个简单例子我们可以看出，通过指标名称(metric name)以及指标的维度labels，通过Prometheus提供的PromQL查询语言，我们可以根据样本特征对数据进行过滤。同时多条时间序列之间的数据还可以进行聚合以及数学操作，从而形成一条新的时间序列。

对于PromQL表达式，除了返回一条或者多条时间序列以外。还可能返回一下几种不同的结果。

* 瞬时向量(Instant vector)

例如使用查询语句: 

```
http_request_total{}
```

会返回一组时间序列。如果记这些时间序列分别为A.B：

```
A=(a1@timestamp1, a2@timestamp2, a3@timestamp3)
B=(b1@timestamp1, b2@timestamp2, b3@timestamp3)
```

并且这组时间序列的样本数据a1,a2,a3与b1，b2，b3，共享相同的时间蹉，因此这些具有相同时戳的数据可以进行向量的数学运算。

如使用sum()函数则实际进行的是向量之间的加法。sum(http_request_total{}) = (a1+b1, a2+b2, a3+b3) 从而形成一条新的时间序列。

* 区间向量(Range vector)

即返回一组矩阵,例如当使用表达式:

```
http_request_total[5m]
```

```
A={[a1@timestamp1, a2@timestamp2, a3@timestamp3, a4@timestamp4]}
B={[b1@timestamp1, b2@timestamp2, b3@timestamp3, b4@timestamp4]}
```

* 纯量(Scalar): 一个浮点型的数字值

 __-2.43__作为表达式进行查询，则会直接返回一个浮点型数字

```
-2.43
```

* 字符串(String): 一个简单的字符串值

直接使用字符串，作为PromQL表达式，则会直接返回字符串。

```
"this is a string"
'these are unescaped: \n \\ \t'
`these are not unescaped: \n ' " \t`
```

### 接下来

接下来我们会详细探索Prometheus提供的这一强大工具PromQL。