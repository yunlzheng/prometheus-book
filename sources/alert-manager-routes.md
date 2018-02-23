# 基于Label的动态告警处理

在前面章节中已经简单介绍过，在Alertmanager中通过路由(Route)来定义告警的处理方式。路由是一个基于标签匹配的树状匹配结构。根据接收到告警的标签匹配响应的处理方式。这里将详细介绍路由相关的内容。

## 路由配置

路由的配置格式如下：

```
[ receiver: <string> ]
[ group_by: '[' <labelname>, ... ']' ]
[ continue: <boolean> | default = false ]

match:
  [ <labelname>: <labelvalue>, ... ]

match_re:
  [ <labelname>: <regex>, ... ]

[ group_wait: <duration> | default = 30s ]

[ group_interval: <duration> | default = 5m ]

[ repeat_interval: <duration> | default = 4h ]

routes:
  [ - <route> ... ]
```

首先每一个告警都会从配置文件中顶级的route进入路由树，需要注意的是顶级的route必须匹配所有告警(即不能有任何的匹配设置)，每一个路由都可以定义自己的接受器。告警进入到顶级路由后会遍历所有的子节点。如果设置了**continue**的值为false，则告警在匹配到第一个子节点之后就直接定制。如果**continue**为true，报警则会继续进行后续子节点的匹配。如果当前告警匹配不到任何的子节点，那么该告警将会基于当前路由节点的接收器配置方式进行处理。

其中告警的匹配有两种方式可以选择。一种方式基于字符串验证，通过设置**match**规则判断当前告警中是否存在标签labelname并且其值等于labelvalue。第二种方式则基于正则表达式，通过设置**match_re**验证当前告警标签的值是否满足正则表达式的内容。

除此以外，在路由设置中还可以定义告警的分组规则。基于告警中包含的标签，如果满足**group_by**中定义标签名称，那么这些告警将会合并为一个通知发送给接收器。

通过**group_wait**配置选项，可以在发送告警通知之前的等待一段时间，当有新的告警进入时则可以一起发送通知。
而**group_interval**配置选择，则用于定义相同的Gourp发送告警通知的时间间隔。