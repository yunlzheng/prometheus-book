# 与Slack集成

Slack是非常流行的团队沟通应用，提供群组聊天和直接消息发送功能，支持移动端，Web 和桌面平台。在国外有大量的IT团队使用Slack作为团队协作平台。同时其提供了强大的集成能力，在Slack的基础上也衍生出了大量的ChatOps相关的技术实践。这部分将介绍如何将Slack集成到Alertmanager中。

## 认识Slack

![Slack](./static/slack-overview.png)

Slack作为一款即时通讯工具，协作沟通主要通过Channel（平台）来完成，用户可以在企业中根据用途添加多个Channel，并且通过Channel来集成各种第三方工具。

例如，我们可以为监控建立一个单独的Channel用于接收各种监控信息：

![创建Channel](./static/slack-create-channel.png)

通过一个独立的Channle可以减少信息对用户工作的干扰，并且将相关信息聚合在一起：

![Monitoring](./static/slack-channel.png)

Slack的强大之处在于在Channel中添加各种第三方服务的集成，用户也可以基于Slack开发自己的聊天机器人来实现一些更高级的能力，例如自动化运维，提高开发效率等。

## 添加应用：Incomming Webhooks

为了能够在Monitoring中接收来自Alertmanager的消息，我们需要在Channel的设置选项中使用"Add an App"为Monitoring channel添加一个名为`Incoming WebHooks`的应用：

![添加Incomming Webhooks](./static/add-incomming-webhooks.png)

添加成功后Slack会显示`Incoming WebHooks`配置和使用方式：

![Incomming Webhhook配置](./static/incomming-webhooks-setting.png)

Incomming Webhook的工作方式很简单，Slack为当前Channel创建了一个用于接收消息的API地址：

```
https://hooks.slack.com/services/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
```

用户只需要使用Post方式向Channel发送需要通知的消息即可，例如，我们可以在命令行中通过curl模拟一次消息通知：


```
curl -d "payload={'text': 'This is a line of text in a channel.\nAnd this is another line of text.'}" https://hooks.slack.com/services/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
```

在网络正常的情况下，在Channel中会显示新的通知信息，如下所示：

![测试消息](./static/slack-receiver-message.png)

除了发送纯文本以外，slack还支持在文本内容中添加链接，例如：

```
payload={"text": "A very important thing has occurred! <https://alert-system.com/alerts/1234|Click here> for details!"}
```

此时接收到的消息中建辉包含一个可点击的超链接地址。除了payload以外，Incomming Webhhook还支持一些其他的参数：

|参数|作用|示例|
|--|--|--|
|username|设置当前聊天机器人的名称| webhookbot |
|icon_url|当前聊天机器人的头像地址|https://slack.com/img/icons/app-57.png|
|icon_emoji|使用emoji作为聊天机器人的头像|:ghost:|
|channel|消息发送的目标channel, 需要直接发给特定用户时使用@username即可|#monitoring 或者 @username|

例如，使用以上参数发送一条更有趣的消息：

```
curl -X POST --data-urlencode "payload={'channel': '#monitoring', 'username': 'webhookbot', 'text': 'This is posted to #monitoring and comes from a bot named webhookbot.', 'icon_emoji': ':ghost:'}" https://hooks.slack.com/services/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
```

![自定义消息](./static/custom-slack-message.png)

## 在Alertmanager中使用Slack

在了解了Slack以及Incomming Webhhook的基本使用方式后，在Alertmanager中添加Slack支持就非常简单了。

在Alertmanager的全局配置中，将Incomming Webhhook地址作为slack_api_url添加到全局配置中即可：

```
global:
  slack_api_url: https://hooks.slack.com/services/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
```

当然，也可以在每个receiver中单独定义自己的slack_configs即可：

```
receivers：
- name: slack
  slack_configs:
    - channel: '#monitoring'
      send_resolved: true
```

这里如果我们手动拉高当前主机的CPU利用率，在#Monitoring平台中，我们会接收到一条告警信息如下所示：

![告警信息](./static/slack_alert_message.png)

而当告警项恢复正常后，则可以接收到如下通知：

![告警恢复信息](./static/slack_resolved_message.png)