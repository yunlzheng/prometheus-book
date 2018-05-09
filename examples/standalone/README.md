Standalone Prometheus Sample
=======

## Components:

* Prometheus
* Node Exporter
* cAdvisor
* Grafana

## How To Run

```
go get github.com/mattn/goreman
```

```
docker volume create grafana-storage
```

```
goreman -f prometheus.procfile start
```
