Install Prometheus 
==================

Prometheus

```
kubectl create -f prometheus/prometheus-rbac-setup.yml
kubectl create -f prometheus/prometheus-config.yml
kubectl create -f prometheus/prometheus-deployment.yml
kubectl create -f prometheus/prometheus-ingress.yml
```

Exporters

```
kubectl create prometheus/node-exporter-daemonset.yml
```