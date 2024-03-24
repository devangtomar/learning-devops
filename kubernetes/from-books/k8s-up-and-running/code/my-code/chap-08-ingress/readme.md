Ingress is a unique system in Kubernetes. It is simply a schema, and the implementa‐
tions of a controller for that schema must be installed and managed separately. But it
is also a critical system for exposing services to users in a practical and cost-efficient
way. As Kubernetes continues to mature, expect to see Ingress become more and
more relevant

## Pre-requisite for creating a ingress controller

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml
```

## Now first create a few upstream services

```bash
kubectl create deployment alpaca-prod --image=gcr.io/kuar-demo/kuard-amd64:v0.9-blue --port=8080 --replicas=3

kubectl expose deployment alpaca-prod
```

## Now creating a simple ingress

```bash
kubectl create -f ingress.yaml
```

## For fetching all ingress

```bash
kubectl get ingress

kubectl apply -f simple-ingress.yml

```

## For describing ingress

```
kubectl describe ingress simple-ingress
```

## Cleanup

```bash
kubectl delete ingress host-ingress path-ingress simple-ingress
kubectl delete service alpaca bandicoot be-default
kubectl delete deployment alpaca bandicoot be-default
```
