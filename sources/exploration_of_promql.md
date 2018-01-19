探索PromQL
====

## Data Model

PromQL's data model is based on "labels" and "samples", combining into "time series"

A "time series " cimprses a unique set of "labels" and one or more "samples".

"labels" ars a set of pairs of strings, where the first of the pair is unique

A sample is a pair of (ini64, float64), within a "time series" the first f the pair is Qnique

### What can we describe with this model?

* List

{item="1"} (0, 7)
{item="3"} (0, -Inf)
{item="3"} (0, 3)

* Grid

{x="1", y="1"} (0, 13)
{x="2", y="1"} (0, NaN)
{x="1", y="2"} (0, 90)
{x="2", y="2"} (0, .7)

## Query Language

Can select time series based on existence/non-existence of one or more of their labels. From there there's a few broad classes of operations and functions：

* Relational algebra on labels across time series
* Functions on the samples within a time series
* Operations/Functions on single samples accross time series
* Type conversion functions(PromQL is strongly and statically typed)
* Display related functions

...and one function to mainpulate labels

### Label Manipulation

Normally you can only work with label taht are the same. eg. {x="1", y="1"} and {x="2", y="1"} both have y="1"

the label_replace() function allows us to change the 1 to a 2 via regular expressions.

## Execution Environment

The environment has a counter, and when looking accross time series only the samples with the first value between this counter and 300,00 less that it are available. Of there the sample with the highest first value will be available.

In each cycle this counter increases, typically by 1000 to 60000.

Output of expressions executed in a cycle can be added to the data set, with the first value of samples set to that of the counter.

Expressions are evaluated simultaneously, may see output of other expressions form this cycle.

## So how powerful is this language?

if we can model a list, can do relational algebra and can record new results each cycle the we can use the lit as a tape and build a Finite State Machine.

Been there, done that.

What else can we do thats as powerful, but a little more aesthetically pleasing? Could build a grid and run a simple 2-dimensional cellular automata on top of it.

### Automata

Go for something simple, only two states -0 and 1.

Decimal would be hard for grid posotions, so use unary numbering：
1=1, 2=11, 3=111, 4=1111 etc.

We'll have a time series called ```{__name__=="init"}``` that's the size of the grid,and all with the value 1.

The grid will be stored in ```{__name__="grid"}```

For the edges of the grid, we'll do simple manipulation of counter value to generate random-ish values as here's no RNG available in PromQL.

### if exactly three neighbours are 1, become 1

![](http://p2n2em8ut.bkt.clouddn.com/promql-automata.png)

### Public Health Warning

if you feel uneasiness, headaches or existential dread as a result of this presention stop watching immediately and consult your local Computer Numerologist for advice.

Do not look at the PromQL expressions in these slides with the remaining eye.

Do not attempt to create PromQL expressions of this complexity without professional advice.

If you discard this advice and summon and elder abomination from another realm, Robust Preception Ltd. accepts not responsibility for a( your meddling in higher mathematics or b) Charlie Stross having to throw away yet another book due to reality getting weirder than fiction.

### if you are 1 and exactly two neughbours are 1, stay 1

![](http://p2n2em8ut.bkt.clouddn.com/promql-automata-2.png)

### Otherwise, become 0

init * 0

### Joining these together

The or operator joins these together.

it'd be nice to have each in separate expressions and then do the or, but there's no guarantee which order the expression run in.

## Conways's Life

A cellular automaton devised in 1970 by John Conway.

It is known to be turing capable, proved by conway in 1982.

Full Turing Machines have been implemented by Paul Rendell(2000), Paul Chapman(2002), and Adam P. Goucher(2009).

This eans that if it's possible to compute it on a computer, you can computer it in conway's life, and thus in PromQL.

No monitoring system can have a language more powerful that PromQL!

## References

* https://www.robustperception.io/conways-life-in-prometheus/

# Life of a Label

## Instrumentation Labels

Instrumententation labels are to distinguish things happening at the code level inside one metric.

E.g GET vs POST, Visa vs Mastercard

Could be from a random libray, could be from business logic.

## Instrumentation Example

```
from prometheus_client import Counter

c = Counter('my_request_total', 'HTTP Failures', ['method', 'endpoint'])
c.labels('GET', '/').inc()
```

my_request_total{method="GET", endpoint="/"} 1.0

### So you've got these labels in your app..

You've gone and instrumented your application.

Well done!
Gold Star!

Sp how do you get those nto Prometheus from your live systems?

## Where to find targets to monitor

In a push system targets decide what monitoring systems to talk to.

With Prometheus it's the other way around, allowing each team to chose what they want to monitor.

This means though that we need a way to find our targets, Listing them all by hand is not like to end well.

Enter service discover.

## Service Discovery

There are many supported SD methods: static configs, file, EC2, Consul, Kubernetes, EC2, DNS, Azure, Twitter Serverset And AirBnB Nerve.

File S reads YML or JSON files off local disk, Inotify used to pick up changes automatically. Intended as hook for when other options don't suit you.

All others work by asking some system for targets over the network.

### You've a list of hosts , now what?

So you've got a list of all instances from an EC2 region.

That‘s fine for monitoring the node exporter that runs everywhere, but how about services that run on only some machines?

Need a way to select which machines to scrape.

### And here’s the crux

Different organisations do it dirrenert ways. Some may use the Name tag, others VPC IDs. It's rarely even consistent within a team, let alone an organisation.

Could respsenting is as a set of config options. but with so many variants it'd quickly become unwildy with likely hundreds of interacting config options.

Instead we have relablling.

## What do we want to allow?

## What is relablling?

Relableling is a way to take in metadata about a target, and based on that select which targets to scrape.

You can also use it to choose your target labels, as by default you'll only get and ```__address__/instance``` labe;

### Choosing Targets

How do you allow for any potential way of going arbitrary metadata?

When there's little to no structure, regexes are a good choice.

```
relable_configs:
- source_labels: ["__meta_consul_tags"]
  regex: ".*, production,.*"
  action: keep
```

## Keep and drop

The simplest relabel actions are keep and drop/

if the given regex matches with keep, the target continus on.

if it doesn;t match, processing halts and we try the next target.

drop is the other way round, halting processing if the regex matches.

## What if you want to match against two labels?

sourcelabels is a list so you can specify as many labels are you like.

Results will be concatenated, separated by a semicolon.

Can change separator via separator

Missing labels will have an empty string.

For more complex rules, relabel_configs is a list so you can add as many actions as you like! Acc actions are applied until a keep or drop halts it.

## Label handing

This is relatively simple so far. We have an SD, we use regexes to pick which targets to scrape.

the real power of Prometheus is lables combined with the query language.

Would't ot be nice to be able to make some targets have labels like env="prod" or env="dev" and aggregate across those?

## Munging labels

The core of relablling is the replace action.

It applies a regex to the source_labels, if it matches interpolates the regex match groups into replacement and write the result to the target_label.

An empty label means the label is removed. __meta labels are discarded after relabelling.

This is all simple in theory.

it gets complicated when you try to map your view of the world into Prometheus labels working off whatever metadata you have.

## Example: job name in EC2 Name tag

```
relabel_configs:
- source_labels: ["__mata_ec2_tag_Name"]
  regex: "(.*)"
  action: replace
  replacement: "$(1)"
  target_label: "job"
```

## Defaults to make things simpler

A label copy is very common, so the defaults reduce this two lines:

```
replace_configs:
- source_labels: ["__meta_ec2_tag_Name"]
  target_label: "job"
```

## Instance label

The label that SD returns with the host:port is ```__address__```.

If no instance label is present by the end of relabelling, it defaults to the value of ```__address__```.

This means that you can have the instance label be someing more meaningful than a host:port - such as an EC2 instance id or Zookeeper path.

Avoid adding other labels as readable instance names, it'll break sharing **without** based expressions.

## Other labels

Many other settings are also configurable via relabelling.

scheme, metrics_path,and params are ust defaults, so whether to use http or https could come from service discovery.

For params only the first value of each URL parameter is available for relabelling.

This is how the blackbox and SNMP exporters work, changing what would normally be an ```__address__``` label into a URL parameter.

## Other relabel actions

There's tow more relabel actions for advanced use cases.

lbelmap copies labels based on regex substitution.

it;s different in that regex and replacement apply to label names, not the label values. Useful if you've a set of key/value tags you want to copy wholesale whithout listing every individual label in the relabel config.

hashmod is used with keep for sharding. It takes a modules of a hash of the source labels and puts it in the target label as an integer.

## Other notes on labels: Dealing with label clashes

if there's a clash with instrumentation labels, the target label takes precedence.

The scraped label will be prefixed with exported_

This behaviour can be canged with honor_labels: true, which makes the scraped label win and discards the target label.

In addition, an empty sraped label will remove labels including instance. Use this for the Pushgateway and other places where you don;t want an instance label.

## Metric relabel configs

Sometimes you need to temporarily change the scraped metrics while waiting for instrumentation to be fixed.

metrics_relabel_configs apply to all scraped samples just before they're added to the database. Could use it to drop expensive metrics, or fix a label a label value.

Beware using expensive or extensive rules as it's applied to every sample.

As up is'nt a scraped metrics, only relabel_config apply.

## From alerts...

```
ALERT MyExampleAlert
    IF rate(my_requests_total[5m]) < 10
    FOR 5m
    LABELS {serverity="Page"}
```

The alert will have method and endpoint labels from the aert expression and a new severity label.

External labels and alert relabeling applied too.

## ...to the alertmanager

Just as with the rest of the Prometheus stack, labels are core to Alertmanager.

A tree uses labels to route alerts into groups. Each team can have their own route!

Each group can choose which labels to fan-out notifications by reducing spam.

Silences are specified using labels, suppressing precisely the alerts your want.

## Summary

Instrumentation labels come from the application.

Service discovery creates targets.

Relabelling filters targets and adds target labels to make them meaningful for you.

Metrics relabel configs apply to scraped time series.

Alerts can add labels before sending to the alertmanager.

The alertmanager uses labels for routing, grouping, deduplication and silencing.

## Reference

* https://www.robustperception.io/life-of-a-label/
* https://www.robustperception.io/target-labels-are-for-life-not-just-for-christmas/