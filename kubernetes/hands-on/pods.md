# Imperative way to deal with pods

## Kubectl Config – Usage

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

## To fetch only names

`kubectl get pods -o=jsonpath='{.items[*].metadata.name}';`

### OR

`kubectl get pods -o json | jq -r '.items[].metadata.name'`

### For running the pods

```bash
kubectl run podName --image=imageName
kubectl get pods -o wide
```

### For checking logs and details of pods

```bash
kubectl logs podName -f # -f for tracing
kubectl describe pods podName
```

### For executing and attaching the pod

```bash
kubectl exec podName -- command

# for interacting directly..
kubectl exec -it podName -- bash

# this is similar to above but this connects to STDIN and STDOUT
kubectl attach podName
```

### Note : Use Ctrl + P + Q to exit the exec and attach mode

### For deleting the pod

```bash
kubectl delete pods podName
```

# Imperative way (via CLI) to deal with pods

```bash
kubectl run pod_1 --image=nginx --dry-run=client -o yaml
```

# Declarative way (YAML) to deal with pods

```yml
apiVersion: v1
kind: Pod # type of K8s object: Pod
metadata:
  name: firstpod # name of pod
  labels:
    app: frontend # label pod with "app:frontend"
spec:
  containers:
    - name: nginx
      image: nginx:latest # image name:image version, nginx downloads from DockerHub
      ports:
        - containerPort: 80 # open ports in the container
      env: # environment variables
        - name: USER
          value: "username"
```

## Apply/Run the file to create the pod

`kubectl apply -f pod1.yaml`

## Delete the pod via

`kubectl delete -f pod1.yaml`

## Getting a running pod in a YAML..

 `kubectl get pods yourPodName -o yaml;`

# Pod lifecycle

- Pending
- Creating
- ImagePullBackOff : Image not found..
- Running
- Successed
- Failed
- CrashLoopBackoff : Container keeps restarting

## MultiContainer Pod, Init Container

- Best Practice: 1 Container runs in 1 Pod normally, because the smallest element in K8s is Pod (Pod can be scaled up/down).
- Multicontainers run in the same Pod when containers are dependent of each other.
- Multicontainers in one Pod have following features:
    - Multi containers that run on the same Pod run on the same Node.
    - Containers in the same Pod run/pause/deleted at the same time.
    - Containers in the same Pod communicate with each other on localhost, there is not any network isolation.
    - Containers in the same Pod use one volume commonly and they can reach same files in the volume.

## Init containers

- Init containers are used for configuration of apps before running app container.
- Init containers handle what it should run, then it closes successfully, after init containers close, app containers start.
- Example below shows how to define init containers in one Pod. There are 2 containers: appcontainer and initcontainer. Initcontainer is polling the service (myservice). When it finds, it closes and app container starts.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: initcontainerpod
spec:
  containers:
    - name: appcontainer # after initcontainer closed successfully, appcontainer starts.
      image: busybox
      command: ["sh", "-c", "echo The app is running! && sleep 3600"]
  initContainers:
    - name: initcontainer
      image: busybox # init container starts firstly and look up myservice is up or not in every 2 seconds, if there is myservice available, initcontainer closes.
      command:
        [
          "sh",
          "-c",
          "until nslookup myservice; do echo waiting for myservice; sleep 2; done",
        ]
```

```yml
# save as service.yaml and run after pod creation
apiVersion: v1
kind: Service
metadata:
  name: myservice
spec:
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```

## Multi containers - Sidecar - Emptydir Volume - Port forwarding

```yml
# how to create multicontainer in one pod,
apiVersion: v1
kind: Pod
metadata:
  name: multicontainer
spec:
  containers:
    - name: webcontainer # container name: webcontainer
      image: nginx # image from nginx
      ports: # opening-port: 80
        - containerPort: 80
      volumeMounts:
        - name: sharedvolume
          mountPath: /usr/share/nginx/html # path in the container
    - name: sidecarcontainer
      image: busybox # sidecar, second container image is busybox
      command: ["/bin/sh"] # it pulls index.html file from github every 15 seconds
      args:
        [
          "-c",
          "while true; do wget -O /var/log/index.html https://raw.githubusercontent.com/omerbsezer/Fast-Kubernetes/main/index.html; sleep 15; done",
        ]
      volumeMounts:
        - name: sharedvolume
          mountPath: /var/log
  volumes: # define emptydir temporary volume, when the pod is deleted, volume also deleted
    - name: sharedvolume # name of volume
      emptyDir: {}
```

Post this just run : `kubectl apply -f multi-pods.yml`

then execute something via : `kubectl exec -it multicontainer -c webcontainer -- /bin/sh`

### Note : look at `-c` option above.. it's used for executing a command for a particular container..

## Port forwarding

```yaml
kubectl port-forward podName 8080:80 # it's basically hostPort:containerPort
```
