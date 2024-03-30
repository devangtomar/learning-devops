# Deployment

- A Deployment provides declarative updates for Pods and ReplicaSets.
- We define states in the deployment, deployment controller compares desired state and take necessary actions to keep desire state.
- Deployment object is the higher level K8s object that controls and keeps state of single or multiple pods automatically.

## Imperative way:

```bash
kubectl create deployment firstdeployment --image=nginx:latest --replicas=2
kubectl get deployments
kubectl get pods -w    #on another terminal
kubectl delete pods <oneofthepodname> #we can see another terminal, new pod will be created (to keep 2 replicas)
kubectl scale deployments firstdeployment --replicas=5
kubectl delete deployments firstdeployment
```

Note : to quickly generate deployment YAML use

```bash
kubectl create deployment first-deployment --image=busybox --replicas=2 --dry-run=client -o yaml;
```

## LAB: K8s Deployment - Scale Up/Down - Bash Connection - Port Forwarding

Sample deployment yaml file..

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: firstdeployment
  labels:
    team: development
spec:
  replicas: 3
  selector: # deployment selector
    matchLabels: # deployment selects "app:frontend" pods, monitors and traces these pods
      app: frontend # if one of the pod is killed, K8s looks at the desire state (replica:3), it recreate another pods to protect number of replicas
  template:
    metadata:
      labels: # pod labels, if the deployment selector is same with these labels, deployment follows pods that have these labels
        app: frontend # key: value
    spec:
      containers:
        - name: nginx
          image: nginx:latest # image download from DockerHub
          ports:
            - containerPort: 80 # open following ports
```
