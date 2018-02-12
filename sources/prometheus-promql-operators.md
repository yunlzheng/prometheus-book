# PromQL操作符

PromQL支持基本的逻辑和数学运算。当在两个瞬时数据之间进行计算时，运算的匹配规则可以进行修改。

## 二进制运算

### 数学运算符

算数运算支持用于：标量和标量、瞬时数据和标量、瞬时数据和瞬时之间的运算。

目前PromQL支持一下算数运算符：

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

#### 标量与瞬时数据

标量和瞬时数据之间进行数学运算，数学运算符将被作用域瞬时数据中的每一个样本值。并且产生一个新的瞬时数据。

```
http_requests_total{}
```

```
http_requests_total{code="200",handler="alerts",instance="localhost:9090",job="prometheus",method="get"} => 1@1518145642.308
http_requests_total{code="200",handler="federate",instance="localhost:9090",job="prometheus",method="get"} => 1@1518145642.308
```

例如，如果表达式http_requests_total{}查询出一组时间序列的瞬时样本数据，那*5操作会将每一条时间序列数据中的瞬时样本数据*5， 并且产生一组新的时间序列。

```
http_requests_total{} * 5
```

返回结果：

```
http_requests_total{code="200",handler="alerts",instance="localhost:9090",job="prometheus",method="get"} => 5@1518145642.308
http_requests_total{code="200",handler="federate",instance="localhost:9090",job="prometheus",method="get"} => 5@1518145642.308
```

#### 瞬时数据与瞬时数据

两个瞬时向量之间进行数学运算，数学运算将将会作用于左边数据中的每一个样本数据，与该样本在右边数据中**匹配**到的样本数据之间。

例如,

```
node_disk_bytes_written + node_disk_bytes_written
```

表达式node_disk_bytes_written返回当前主机中各个磁盘的写入数据总量的瞬时数据。

```
node_disk_bytes_written{device="sda",instance="localhost:9100",job="node_exporter"}=>1634967552@1518146427.807
node_disk_bytes_written{device="sdb",instance="localhost:9100",job="node_exporter"}=>0@1518146427.807
```

表达式node_disk_bytes_read{}会返回，当前主机中各个磁盘的读取数据总量的瞬时数据。

```
node_disk_bytes_read{device="sda",instance="localhost:9100",job="node_exporter"}=>864551424@1518146427.807
node_disk_bytes_read{device="sdb",instance="localhost:9100",job="node_exporter"}=>1744384@1518146427.807
```

匹配规则，会比较两个表达式返回的瞬时数据中的所有标签，标签的键值对完全相等，则表示匹配成功。并将运算符作用域两个匹配的样本数据中。 并且返回一组新的瞬时数据,同时结果中会丢弃指标名称。对于没有匹配的样本数据，则不会出现在运算结果中。

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

比较运算符运算支持：标量和标量、瞬时数据和标量、瞬时数据和瞬时数据之间的运算。

目前，Prometheus支持一下，比较运算符：

* ```==``` (相等)
* ```!=``` (不相等)
* ```>``` (大于)
* ```<``` (小于)
* ```>=``` (大于等于)
* ```<=``` (小于等于)

### 逻辑运算符

逻辑运算符只支持，瞬时数据和瞬时数据之间。

目前，Prometheus支持一下，比较逻辑运算符有：

* ```and``` (并且)
* ```or``` (或者)
* ```unless``` (除非)

## 匹配模式

### one-to-one

### many-to-one 和 one-to-many

## 聚合操作

* ```sum``` (求和)
* ```min``` (最小值)
* ```max``` (最大值)
* ```avg``` (平均值)
* ```stddev``` (标准差)
* ```stdvar``` (标准差异)
* ```count``` (计数)
* ```count_values```
* ```bottomk```
* ```topk```
* ```quantile```

## 操作符优先级

1. ```^```
2. ```*, /, %```
3. ```+, -```
4. ```==, !=, <=, <, >=, >```
5. ```and, unless```
6. ```or```