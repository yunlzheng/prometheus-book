# 神兵天降

## 为什么需要监控

* Know when things go wrong
  * to call in a human to prevent a bussioness-level issue, or prevent an issue in advance
* Be able to debug and gain insight
* Trending to see changes over time, and drive technical/business decisions
* To feed into other systems/processes（eg. QA, security, automation）

## 回顾一下过去

* 基础设施
* 应用架构
* old monitor system

## 监控的挑战

### 基本挑战

Themes common among companies o've talk to:

* Monitoring tools are limited, both technically and conceptually.
* Tools don‘t scale weel and are unwieldy to manage.
* Operation practices don't align with the business

For example:

Your customers care about increased latency and it;s in your SLAs. You can only alert on individual machine CPU usage.

Result: Engineers continously worken up for non-issues, get fatigued.

### 应用架构的演变

### 基础设施的演变

## Fundamental Challenge is Limited Visibility

## Prometheus来了

Inspired by Google's Borgmon monitoring system.

Started in 2012 by ex-Googlers working in Soundcoud as an open source project, mainly written in Go. Plblically lauched in early 2015, and continues to be independent of any one company.

Over 100 companies have started relying on it since then.

### What does Prometheus offer?

* Inclusive Monitoring
* Powerful data model
* Powerfule query language
* Manageable and Reliable
* Efficient
* Scalable
* Easy to integrate with
* Dashboards

### Services have internals

### Monitor the internals

### Monitor as a Service, not as Machines

### Inclusive Monitoring

Don't monitor just at the edges:

* Instrument client libraries
* Instrument server libraries
* Instrument bussiness logic

Library authors get information about usage.

Application developers get monitor of common components for free.

Dashboard and alerting can be provided out of the box, customised for your organisation!

## Powerfule Data Model

All metrics have arbitrary multi-dimensional labels.

No need to force your model into dotted string.

Can aggregate, cute and slice along them.

Support any double values, labels support full unicode.

## Powerful Query Language

Can multiply, add , aggregate, join, predict, take quantiles across many metrics in the same query. Can evaluate right now, and graph back in time.

Anwser questions like:

* What's the 95th percentile latency in the European datacenter?
* How full will the disks be in 4 hours?(预测趋势)
* Which service are the top 5 users of CPU?

## Manageable and Reliable

Core Prometheus server is a single binay.

Doesn't depend on Zookeeper, Consul, Cassandra, Hadoop or the internet/

On;y require local disk(SSD recommented). No potential for cascading failure.

Pull based, so easy to on run a workstation for testing and rogue servers can't push bad metrics.

Advanced service discovery finds what to monitor.

## Efficient

Instrumenting everything means a lot of data.

Prometheus is best in class for lossless storage effiency, 3.5 bytes per datapoint.

A single server can hanle;

* millions of metrics
* hundreds of thousands of datapoints per second.

## Scalable

Prometheus is easy to run, can give one to each team in each datacenter.

Federation allows pulling key metrics from other Prometheus servers.

When one job is too big for single Prometheus, can use sharding+federation to scale out. Needed with thousands of machines.

## Easy to integrate with

Many existing integrations: Java, JMX, Python, Go, Ruby, .Net, Machine, Cloudwatch, EC2, MySQL, PostgresSQL, Haskell, Bash, Nodejs , SNMP, Consul, Haproxy, Mesos, Bind, CouchDB, Diango, Mtail, Heka, Memcached, RabbiitMQ, Redis, RethinkDB, Rsyslog, Meteor.js, Minecaraft..

Graphitem Statsd, Collected, Scollector, muini, Nagios integrations adi transition.

it's so easy, most of the above were written without the core team even knowing about them.

## Dashboards

* Grafana
    * latest relase has full Prometheus support
* Promdash
    * Prometheus-specific Ruby-on-Rails dashboarding solution
    * Direction is moving toward Grafana instead
* Console templates
    * Templating language inside Prometheus
    * Good for having your dashboards checked in, and for fully-custom dashbaords.
* Expression Browser
    * Inclued in prometheus, good for ad-hoc debuging
* Roll your own
    * JSON API

## Final Thought: Instrument Once, Use Everywhere

When an application is instrumented, tends to be limited in which monitoring system it supports.

Your're left with a choice: Have N Monitoring systems, or run extra services to act as shims to translate.

Prometheus clients aren't just limited to outputing metrics in the prometheus format, can also output to Graphite and other monitoring systems.

prometheus client can be your instrumentation and metrics interchange, even when not using Prometheus itselft!