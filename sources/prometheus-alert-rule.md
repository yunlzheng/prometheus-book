# 自定义Prometheus告警规则

Prometheus中的告警规则允许你基于PromQL表达式定义报警条件，并且将告警通知发送到外部服务如Alertmanager中。

在Prometheus全局配置文件中，可以通过rule_files指定一个或者多个告警规则文件的路径。
Prometheus启动后会自动扫描这些路径下规则文件中定义的内容，并且根据这些规则计算是否向外部发送通知。计算告警触发条件的周期可以通过global下的evaluation_interval进行配置。

```
global:
  [ evaluation_interval: <duration> | default = 1m ]
rule_files:
  [ - <filepath_glob> ... ]
```

## 定义告警规则

告警规则文件使用Yaml格式进行定义，一个典型的告警配置如下：

```
groups:
- name: example
  rules:
  - alert: HighErrorRate
    expr: job:request_latency_seconds:mean5m{job="myjob"} > 0.5
    for: 10m
    labels:
      severity: page
    annotations:
      summary: High request latency
```

在告警规则文件中，我们可以将一组相关的规则设置定义在一个group下。每一个group中我们可以定义多个告警规则(rule)。一条告警规则主要由以下几部分组成：

* alert: 告警规则的名称。
* expr: 基于PromQL表达式告警触发条件，用于计算是否有时间序列满足该条件。
* for: 评估等待时间，可选参数。用于表示只有当触发条件持续一段时间后才发送告警。在等待期间新产生告警的状态为pending。
* labels: 自定义标签，允许用户指定要附加到告警上的一组附加标签。
* annotations: 用于指定一组附加信息，比如用于描述告警详细信息的文字等。

Prometheus根据global.evaluation_interval定义的周期计算PromQL表达式。如果PromQL表达式能够找到匹配的时间序列则会为每一条时间序列产生一个告警实例。

## 模板化

告警规则中label和annotations的值可以进行模板化。例如通过$labels变量可以访问当前告警实例的所有标签以及标签值。$value则可以获取当前PromQL表达式计算的样本值。

```
# To insert a firing element's label values:
{{ $labels.<labelname> }}
# To insert the numeric expression value of the firing element:
{{ $value }}
```

示例如下：

```
groups:
- name: example
  rules:

  # Alert for any instance that is unreachable for >5 minutes.
  - alert: InstanceDown
    expr: up == 0
    for: 5m
    labels:
      severity: page
    annotations:
      summary: "Instance {{ $labels.instance }} down"
      description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes."

  # Alert for any instance that has a median request latency >1s.
  - alert: APIHighRequestLatency
    expr: api_http_request_latencies_second{quantile="0.5"} > 1
    for: 10m
    annotations:
      summary: "High request latency on {{ $labels.instance }}"
      description: "{{ $labels.instance }} has a median request latency above 1s (current value: {{ $value }}s)"
```

## 查看告警状态

用户可以通过Prometheus WEB界面中的Alerts菜单查看当前Prometheus下的所有告警规则，以及其当前所处的活动状态。

> 补充图示

同时对于已经pending或者firing的告警，Prometheus也会将它们存储到时间序列ALERTS{}中。

可以通过表达式，查询告警实例：

```
ALERTS{alertname="<alert name>", alertstate="pending|firing", <additional alert labels>}
```

样本值为1表示当前告警处于活动状态（pending或者firing），当告警从活动状态转换为非活动状态时，样本值则为0。