## Creating deployments and services

```
kubectl create deployment alpaca-prod --image=gcr.io/kuar-demo/kuard-amd64:v0.9-blue --port=8080
kubectl scale deployment alpaca-prod --replicas=5
kubectl expose deployment alpaca-prod
kubectl get services -o wide
```

## Port fowarding

```
kubectl port-forward deployment/alpaca-prod 48858:8080
```

## Edit a deployment

```
kubectl edit deployment alpaca-prod
```

## Get services, deployments and endspoints

```
kubectl get services
kubectl get deployments
kubectl get endpoints
```

## Node ports, load balancer, endpoints and ingress

```
kubectl get services
kubectl get deployments
kubectl get endpoints
kubectl get ingress
```

## Create node ports, load balancer, endpoints and ingress

```
kubectl create deployment alpaca-prod --image=gcr.io/kuar-demo/kuard-amd64:v0.9-blue

kubectl create deployment alpaca-prod --image=gcr.io/kuar-demo/kuard-amd64:v0.9-blue --port=8080 --target-port=8080 --type=NodePort

kubectl  expose alpaca-prod --port=8080 --target-port=8080 --type=LoadBalancer

kubectl create expose alpaca-prod --port=8080 --target-port=8080 --type=ClusterIP

kubectl create expose alpaca-prod --port=8080 --target-port=8080 --type=ExternalName
```

## Delete the deployment

```
kubectl delete deployment alpaca-prod
```

## Create a ingress

```
kubectl create ingress alpaca-prod --class=internal
```