# 在HTTP API中使用PromQL

Prometheus当前稳定的HTTP API可以通过/api/v1访问。

## API响应格式

Prometheus API使用了JSON格式的响应内容。 当API调用成功后将会返回2xx的HTTP状态码。

反之，当API调用失败时可能返回一下几种不同的HTTP状态码：

* 404 Bad Request：当参数错误或者缺失时。
* 422 Unprocessable Entity 当表达式无法执行时。
* 503 Service Unavailiable 当请求超时或者被中断时。

所有的API请求均使用以下的JSON格式：

```
{
  "status": "success" | "error",
  "data": <data>,

  // Only set if status is "error". The data field may still hold
  // additional data.
  "errorType": "<string>",
  "error": "<string>"
}
```

## 在HTTP API中使用PromQL

通过HTTP API我们可以分别通过/api/v1/query和/api/v1/query_range查询PromQL表达式当前或者一定时间范围内的计算结果。

### 瞬时数据查询

通过使用QUERY API我们可以查询PromQL在特定时间点下的计算结果。

```
GET /api/v1/query
```

URL请求参数：

* query=<string>: PromQL表达式。
* time=<rfc3339 | unix_timestamp>: 用于指定用于计算PromQL的时间戳。可选参数，默认情况下使用当前系统时间。
* timeout=<duration>: 超时设置。可选参数，默认情况下使用-query,timeout的全局设置。

例如使用以下表达式查询表达式up在时间点2015-07-01T20:10:51.781Z的计算结果：

```
$ curl 'http://localhost:9090/api/v1/query?query=up&time=2015-07-01T20:10:51.781Z'
{
   "status" : "success",
   "data" : {
      "resultType" : "vector",
      "result" : [
         {
            "metric" : {
               "__name__" : "up",
               "job" : "prometheus",
               "instance" : "localhost:9090"
            },
            "value": [ 1435781451.781, "1" ]
         },
         {
            "metric" : {
               "__name__" : "up",
               "job" : "node",
               "instance" : "localhost:9100"
            },
            "value" : [ 1435781451.781, "0" ]
         }
      ]
   }
}
```

### 响应数据类型

当API调用成功后，Prometheus会返回JSON格式的响应内容，格式如上小节所示。并且在data节点中返回查询结果。data节点格式如下：

```
{
  "resultType": "matrix" | "vector" | "scalar" | "string",
  "result": <value>
}
```

在前面我们已经了解了，PromQL表达式可能返回多种数据类型，在响应内容中使用resultType表示当前返回的数据类型，包括：

* 瞬时向量：vector

当返回数据类型resultType为vector时，result响应格式如下：

```
[
  {
    "metric": { "<label_name>": "<label_value>", ... },
    "value": [ <unix_time>, "<sample_value>" ]
  },
  ...
]
```

其中metrics表示当前时间序列的特征维度，value只包含一个唯一的样本。

* 区间向量：matrix

当返回数据类型resultType为matrix时，result响应格式如下：

```
[
  {
    "metric": { "<label_name>": "<label_value>", ... },
    "values": [ [ <unix_time>, "<sample_value>" ], ... ]
  },
  ...
]
```

其中metrics表示当前时间序列的特征维度，values包含当前事件序列的一组样本。

* 标量：scalar

当返回数据类型resultType为scalar时，result响应格式如下：

```
[ <unix_time>, "<scalar_value>" ]
```

由于标量不存在时间序列一说，因此result表示为当前系统时间一个标量的值。

* 字符串：string

当返回数据类型resultType为string时，result响应格式如下：

```
[ <unix_time>, "<string_value>" ]
```

字符串类型的响应内容格式和标量相同。

### 区间数据查询

使用QUERY_RANGE API我们则可以直接查询PromQL表达式在一段时间返回内的计算结果。

```
GET /api/v1/query_range
```

URL请求参数：

* query=<string>: PromQL表达式。
* start=<rfc3339 | unix_timestamp>: 起始时间。
* end=<rfc3339 | unix_timestamp>: 结束时间。
* step=<duration>: 查询步长。
* timeout=<duration>: 超时设置。可选参数，默认情况下使用-query,timeout的全局设置。

当使用QUERY_RANGE API查询PromQL表达式时，返回结果一定是一个区间向量：

```
{
  "resultType": "matrix",
  "result": <value>
}
```

> 需要注意的是，在QUERY_RANGE API中PromQL只能使用瞬时向量选择器类型的表达式。

例如使用以下表达式查询表达式up在30秒范围内以15秒为间隔计算PromQL表达式的结果。

```
$ curl 'http://localhost:9090/api/v1/query_range?query=up&start=2015-07-01T20:10:30.781Z&end=2015-07-01T20:11:00.781Z&step=15s'
{
   "status" : "success",
   "data" : {
      "resultType" : "matrix",
      "result" : [
         {
            "metric" : {
               "__name__" : "up",
               "job" : "prometheus",
               "instance" : "localhost:9090"
            },
            "values" : [
               [ 1435781430.781, "1" ],
               [ 1435781445.781, "1" ],
               [ 1435781460.781, "1" ]
            ]
         },
         {
            "metric" : {
               "__name__" : "up",
               "job" : "node",
               "instance" : "localhost:9091"
            },
            "values" : [
               [ 1435781430.781, "0" ],
               [ 1435781445.781, "0" ],
               [ 1435781460.781, "1" ]
            ]
         }
      ]
   }
}
```