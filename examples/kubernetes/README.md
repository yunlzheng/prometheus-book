在Kubernetes下安装部署Prometheus
==================

部署Prometheus

```
kubectl create -f prometheus/prometheus-rbac-setup.yml
kubectl create -f prometheus/prometheus-config.yml
kubectl create -f prometheus/prometheus-deployment.yml
kubectl create -f prometheus/prometheus-ingress.yml
```

部署Exporters

```
kubectl create prometheus/node-exporter-daemonset.yml
kubectl create -f prometheus/blackbox-exporter-deployment.yml
```