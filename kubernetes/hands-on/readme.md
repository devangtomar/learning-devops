# Kubectl Config – Usage

Pattern for kubectl : kubectl [get|delete|edit|apply] [pods|deployment|services] [podName|serviceName|deploymentName]

## YAML file for pods

```yml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: test-run-pod
  name: test-run-pod
spec:
  containers:
    - name: nginx
      image: nginx:latest
      resources:
        requests:
          memory: "64Mi"
          cpu: "250m"
        limits:
          memory: "128Mi"
          cpu: "500m"
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

## To fetch only names..

`kubectl get pods -o=jsonpath='{.items[*].metadata.name}';`

## Imperative way to deal with pods..

### For running the pods

```bash
kubectl run podName --image=imageName
kubectl get pods -o wide
```

### For checking logs and details of pods..

```bash
kubectl logs podName -f # -f for tracing
kubectl describe pods podName
```

### For executing and attaching the pod..

```bash
kubectl exec podName -- command

# for interacting directly..
kubectl exec -it podName -- bash

# this is similar to above but this connects to STDIN and STDOUT
kubectl attach podName
```

### Note : Use Ctrl + P + Q to exit the exec and attach mode..

### For deleting the pod..

```bash
kubectl delete pods podName
```
