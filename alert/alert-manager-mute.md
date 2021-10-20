## 临时屏蔽告警通知

除了基于抑制机制可以控制告警通知的行为以外，用户或者管理员还可以直接通过Alertmanager的UI临时屏蔽特定的告警通知。通过定义标签的匹配规则(字符串或者正则表达式)，如果新的告警通知满足静默规则的设置，则不停止向receiver发送通知。

进入Alertmanager UI，点击"New Silence"显示如下内容：

![创建静默规则](./static/alertmanager-new-slicense.png)

用户可以通过该UI定义新的静默规则的开始时间以及持续时间，通过Matchers部分可以设置多条匹配规则(字符串匹配或者正则匹配)。填写当前静默规则的创建者以及创建原因后，点击"Create"按钮即可。

通过"Preview Alerts"可以查看预览当前匹配规则匹配到的告警信息。静默规则创建成功后，Alertmanager会开始加载该规则并且设置状态为Pending,当规则生效后则进行到Active状态。

![活动的静默规则](./static/alertmanager-active-silences.png)

当静默规则生效以后，从Alertmanager的Alerts页面下用户将不会看到该规则匹配到的告警信息。

![告警信息](./static/alertmanager-slicense-alerts-result.png)

对于已经生效的规则，用户可以通过手动点击“Expire”按钮使当前规则过期。