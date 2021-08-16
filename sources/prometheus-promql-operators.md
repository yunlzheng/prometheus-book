# PromQL操作符

PromQL除了能够对数据进行基本的查询统计以外，还支持时间序列之间进行逻辑和数学运算。这一小节中将重点介绍如何利用PromQL对时间序列进行各种逻辑和数学运算的。

## 数学运算符

算术运算支持用于：标量和标量、瞬时向量和标量、瞬时向量和瞬时之间的运算。

在PromQL中支持使用常用的算术运算符：

* ```+``` (加法)
* ```-``` (减法)
* ```*``` (乘法)
* ```/``` (除法)
* ```%``` (求余)
* ```^``` (幂运算)

#### 标量与标量

标量和标量之间进行数学运算，产生一个新的标量。

```
2 * 2 # 产生标量4
```

#### 标量与瞬时向量

标量和瞬时向量之间进行数学运算，数学运算符将被作用于瞬时向量中的每一个样本值。并且产生一个新的瞬时向量。

```
http_requests_total{}
```

```
http_requests_total{code="200",handler="alerts",instance="localhost:9090",job="prometheus",method="get"} => 1@1518145642.308
http_requests_total{code="200",handler="federate",instance="localhost:9090",job="prometheus",method="get"} => 1@1518145642.308
```

例如，如果表达式http_requests_total{}查询出一组时间序列的瞬时样本数据，那```*5```操作会将每一条时间序列数据中的瞬时样本数据```*5```， 并且产生一组新的时间序列。

```
http_requests_total{} * 5
```

返回结果：

```
http_requests_total{code="200",handler="alerts",instance="localhost:9090",job="prometheus",method="get"} => 5@1518145642.308
http_requests_total{code="200",handler="federate",instance="localhost:9090",job="prometheus",method="get"} => 5@1518145642.308
```

#### 瞬时向量与瞬时向量

两个瞬时向量之间进行数学运算，数学运算将将会作用于左边数据中的每一个样本数据，与该样本在右边数据中**匹配**到的样本数据之间。

例如,

```
node_disk_bytes_written + node_disk_bytes_written
```

表达式node_disk_bytes_written返回当前主机中各个磁盘的写入数据总量的瞬时向量。

```
node_disk_bytes_written{device="sda",instance="localhost:9100",job="node_exporter"}=>1634967552@1518146427.807
node_disk_bytes_written{device="sdb",instance="localhost:9100",job="node_exporter"}=>0@1518146427.807
```

表达式node_disk_bytes_read{}会返回，当前主机中各个磁盘的读取数据总量的瞬时向量。

```
node_disk_bytes_read{device="sda",instance="localhost:9100",job="node_exporter"}=>864551424@1518146427.807
node_disk_bytes_read{device="sdb",instance="localhost:9100",job="node_exporter"}=>1744384@1518146427.807
```

匹配规则会比较两个表达式返回的瞬时向量中的所有标签。标签的键值对完全相等则表示匹配成功，并将运算符作用域两个匹配的样本数据中。返回一组新的瞬时向量，同时结果中会丢弃指标名称。对于没有匹配的样本数据，则不会出现在运算结果中。

```
{device="sda",instance="localhost:9100",job="node_exporter"}=>1634967552@1518146427.807 + 864551424@1518146427.807
{device="sdb",instance="localhost:9100",job="node_exporter"}=>0@1518146427.807 + 1744384@1518146427.807
```

即结果为

```
{device="sda",instance="localhost:9100",job="node_exporter"}=>2499568128@1518146427.807
{device="sdb",instance="localhost:9100",job="node_exporter"}=>1744384@1518146427.807
```

### 比较运算符

比较运算符运算支持：标量和标量、瞬时向量和标量、瞬时向量和瞬时向量之间的运算。

目前，Prometheus支持以下，比较运算符：

* ```==``` (相等)
* ```!=``` (不相等)
* ```>``` (大于)
* ```<``` (小于)
* ```>=``` (大于等于)
* ```<=``` (小于等于)

#### 瞬时向量与标量

瞬时向量和标量之间进行比较运算时，PromQL的默认行为会依次将瞬时向量中的所有样本与标量之间进行比较运算。如果比较结果为true则保留样本，如果比较结果为false则丢弃该样本，从而产生一条新的瞬时时间序列。

例如，当需要找到当前系统请求量大于100次的处理模块，可以使用表达式：

```
http_requests_total > 100
```

该表达式会过滤监控指标http_requests_total的所有时间序列，返回瞬时样本值满足条件比较条件(> 1000)的所有时间序列。

```
http_requests_total{code="200",handler="prometheus",instance="localhost:9090",job="prometheus",method="get"}  36733
http_requests_total{code="200",handler="prometheus",instance="localhost:9100",job="node_exporter",method="get"}  37131
http_requests_total{code="200",handler="query",instance="localhost:9090",job="prometheus",method="get"}  126
```

#### 使用bool改变比较运算的默认行为

默认情况下比较运算符的默认行为是对时序数据进行过滤。而在其它的情况下我们可能需要的是真正的布尔结果。例如，只需要知道当前模块的HTTP请求量是否>=1000，如果大于等于1000则返回1（true）否则返回0（false）。这时我们可以使用bool改变比较运算的默认行为。

例如：

```
http_requests_total > bool 100
```

使用bool修改比较运算的默认行为之后，比较运算不会对时间序列进行过滤，而是直接依次瞬时向量中的各个样本数据与标量的比较结果0或者1。从而形成一条新的时间序列。

```
http_requests_total{code="200",handler="query",instance="localhost:9090",job="prometheus",method="get"}  1
http_requests_total{code="200",handler="query_range",instance="localhost:9090",job="prometheus",method="get"}  0
```

#### 标量和标量

标量和标量之间进行比较运算，根据比较的结果产生一个新的标量0（false）或者1（true）用于返回比较的结果。需要注意的时，标量和标量之间进行比较时，必须使用bool进行修饰，例如：

```
2 == bool 2 # 结果为1
```

#### 瞬时向量和瞬时向量

瞬时向量和瞬时向量之间，进行比较运算时，根据默认的匹配规则，依次比较匹配到的样本数据。默认情况下，如果匹配到的数据比较结果为true则保留，反之则丢弃。从而形成一条新的时间序列。 同样，我们可以通过bool修饰符来改变比较运算的默认行为。

例如，使用表达式获取当前正常的任务状态：


```
up == 1
```

或者我们只想知道当前任务的状态是否为正常：

```
up == bool 1
```

### 逻辑/集合运算符

逻辑运算符只支持在瞬时向量和瞬时向量之间使用。

目前，Prometheus支持以下，比较逻辑运算符有：

* ```and``` (并且)
* ```or``` (或者)
* ```unless``` (排除)

***vector1 and vector2*** 会产生一个由vector1的元素组成的新的向量。该向量包含vector1中完全匹配vector2中的元素组成。

***vector1 or vector2*** 会产生一个新的向量，该向量包含vector1中所有的样本数据，以及vector2中没有与vector1匹配到的样本数据。

***vector1 unless vector2*** 会产生一个新的向量，新向量中的元素由vector1中没有与vector2匹配的元素组成。

## 向量匹配模式

向量与向量之间进行运算操作时会基于默认的匹配规则：依次找到与左边向量元素匹配（标签完全一致）的右边向量元素进行运算，如果没找到匹配元素，则直接丢弃。

接下来将介绍在PromQL中有两种典型的匹配模式：一对一（one-to-one）,多对一（many-to-one）或一对多（one-to-many）。

### 一对一匹配

一对一匹配模式会从操作符两边表达式获取的瞬时向量依次比较并找到唯一匹配(标签完全一致)的样本值。默认情况下，使用表达式：

```
vector1 <operator> vector2
```

在操作符两边表达式标签不一致的情况下，可以使用on(label list)或者ignoring(label list）来修改便签的匹配行为。使用ignoreing可以在匹配时忽略某些便签。而on则用于将匹配行为限定在某些便签之内。

```
<vector expr> <bin-op> ignoring(<label list>) <vector expr>
<vector expr> <bin-op> on(<label list>) <vector expr>
```

例如当存在样本：

```
method_code:http_errors:rate5m{method="get", code="500"}  24
method_code:http_errors:rate5m{method="get", code="404"}  30
method_code:http_errors:rate5m{method="put", code="501"}  3
method_code:http_errors:rate5m{method="post", code="500"} 6
method_code:http_errors:rate5m{method="post", code="404"} 21

method:http_requests:rate5m{method="get"}  600
method:http_requests:rate5m{method="del"}  34
method:http_requests:rate5m{method="post"} 120
```

使用PromQL表达式：

```
method_code:http_errors:rate5m{code="500"} / ignoring(code) method:http_requests:rate5m
```

该表达式会返回在过去5分钟内，HTTP请求状态码为500的在所有请求中的比例。如果没有使用ignoring(code)，操作符两边表达式返回的瞬时向量中将找不到任何一个标签完全相同的匹配项。

因此结果如下：

```
{method="get"}  0.04            //  24 / 600
{method="post"} 0.05            //   6 / 120
```

同时由于method为put和del的样本找不到匹配项，因此不会出现在结果当中。

### 多对一和一对多

多对一和一对多两种匹配模式指的是“一”侧的每一个向量元素可以与"多"侧的多个元素匹配的情况。在这种情况下，必须使用group修饰符：group_left或者group_right来确定哪一个向量具有更高的基数（充当“多”的角色）。

```
<vector expr> <bin-op> ignoring(<label list>) group_left(<label list>) <vector expr>
<vector expr> <bin-op> ignoring(<label list>) group_right(<label list>) <vector expr>
<vector expr> <bin-op> on(<label list>) group_left(<label list>) <vector expr>
<vector expr> <bin-op> on(<label list>) group_right(<label list>) <vector expr>
```

多对一和一对多两种模式一定是出现在操作符两侧表达式返回的向量标签不一致的情况。因此需要使用ignoring和on修饰符来排除或者限定匹配的标签列表。

例如,使用表达式：

```
method_code:http_errors:rate5m / ignoring(code) group_left method:http_requests:rate5m
```

该表达式中，左向量```method_code:http_errors:rate5m```包含两个标签method和code。而右向量```method:http_requests:rate5m```中只包含一个标签method，因此匹配时需要使用ignoring限定匹配的标签为code。 在限定匹配标签后，右向量中的元素可能匹配到多个左向量中的元素
因此该表达式的匹配模式为多对一，需要使用group修饰符group_left指定左向量具有更好的基数。

最终的运算结果如下：

```
{method="get", code="500"}  0.04            //  24 / 600
{method="get", code="404"}  0.05            //  30 / 600
{method="post", code="500"} 0.05            //   6 / 120
{method="post", code="404"} 0.175           //  21 / 120
```

> 提醒：group修饰符只能在比较和数学运算符中使用。在逻辑运算and,unless和or才注意操作中默认与右向量中的所有元素进行匹配。

## 聚合操作

Prometheus还提供了下列内置的聚合操作符，这些操作符作用域瞬时向量。可以将瞬时表达式返回的样本数据进行聚合，形成一个新的时间序列。

* ```sum``` (求和)
* ```min``` (最小值)
* ```max``` (最大值)
* ```avg``` (平均值)
* ```stddev``` (标准差)
* ```stdvar``` (标准差异)
* ```count``` (计数)
* ```count_values``` (对value进行计数)
* ```bottomk``` (后n条时序)
* ```topk``` (前n条时序)
* ```quantile``` (分布统计)

使用聚合操作的语法如下：

```
<aggr-op>([parameter,] <vector expression>) [without|by (<label list>)]
```

其中只有```count_values```, ```quantile```, ```topk```, ```bottomk```支持参数(parameter)。


without用于从计算结果中移除列举的标签，而保留其它标签。by则正好相反，结果向量中只保留列出的标签，其余标签则移除。通过without和by可以按照样本的问题对数据进行聚合。

例如：

```
sum(http_requests_total) without (instance)
```

等价于

```
sum(http_requests_total) by (code,handler,job,method)
```

如果只需要计算整个应用的HTTP请求总量，可以直接使用表达式：

```
sum(http_requests_total)
```

count_values用于时间序列中每一个样本值出现的次数。count_values会为每一个唯一的样本值输出一个时间序列，并且每一个时间序列包含一个额外的标签。

例如：

```
count_values("count", http_requests_total)
```

topk和bottomk则用于对样本值进行排序，返回当前样本值前n位，或者后n位的时间序列。

获取HTTP请求数前5位的时序样本数据，可以使用表达式：

```
topk(5, http_requests_total)
```

quantile用于计算当前样本数据值的分布情况quantile(φ, express)其中0 ≤ φ ≤ 1。

例如，当φ为0.5时，即表示找到当前样本数据中的中位数：

```
quantile(0.5, http_requests_total)
```

## 操作符优先级

最后对于复杂类型的表达式，我们需要了解运算操作的优先级。

例如，查询主机的CPU使用率，我们可以使用表达式：

```
100 * (1 - avg (irate(node_cpu{mode='idle'}[5m])) by(job) )
```

其中irate是PromQL中的内置函数，用于计算区间向量中时间序列每秒的即时增长率。关于内置函数的部分，会在下一节详细介绍。

在PromQL操作符中优先级由高到低依次为：

1. ```^```
2. ```*, /, %```
3. ```+, -```
4. ```==, !=, <=, <, >=, >```
5. ```and, unless```
6. ```or```