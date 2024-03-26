# kubectl commands to generate all the k8s resource objects templates yaml

## Creating pod yaml

kubectl run pod mypod --image=nginx --dry-run=client -o yaml

## Creating service discovery

### Creating nodeport yaml

kubectl create service nodeport my-nodeport --tcp=80:80 --node-port=34344 --dry-run=client -o yaml

### Creating clusterIP yaml

kubectl create service clusterip my-clusterip --tcp=80:80 --dry-run=client -o yaml

### Creating loadbalancer yaml

kubectl create service loadbalancer my-loadbalancer --tcp=80:80 --dry-run=client -o yaml

## Creating Daemonset : used for monitoring/logging & runs on node separate to deployments/services etc.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: my-daemonset
spec:
  selector:
    matchLabels:
      app: my-daemonset
  template:
    metadata:
      labels:
        app: my-daemonset
    spec:
      containers:
        - name: nginx
          image: nginx
```

## Creating Replicaset : for creating a replicas for the pods

```yml
apiVersion: apps/v1
kind: replicaset
metadata:
  name: my-rs
spec:
  selector:
    matchLabels:
      app: my-rs
  template:
    metadata:
      labels:
        app: my-rs
  spec:
    containers:
      - name: nginx
        image: nginx
```

## Creating Deployment

kubectl create deployment test-deployment --image=nginx --port=8080 --replicas=3 --dry-run=client -o yaml

## Creating Persistent volume

```yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /path/to/storage
```

## Creating persistent volume claim

```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard
```

## Create a statefulset : for stateful apps

```yml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: my-sfs
spec:
  serviceName: "my-service"
  replicas: 3
  selector:
    matchLabels:
      app: my-sfs
  template:
    metadata:
      labels:
        app: my-sfs
    spec:
      containers:
        - name: nginx
          image: nginx
```

## Role based access control (RBAC) resources

### For creating the role

kubectl create role my-role --verb=get,list,create,update,delete --resource=pods --dry-run=client -o yaml

### For binding the role to users

kubectl create rolebinding my-rolebinding --role=my-role --serviceaccount=default:default --dry-run=client -o yaml

## Creating a config map..

can be:

- from-literal=
- from-file=
- from-env-file=

kubectl create configmap my-config --from-literal=key1=config1 --from-literal=key2=config2 --dry-run=client -o yaml

## Creating a secret..

can be:

- from-literal=
- from-file=
- from-env-file=

kubectl create secret generic my-secret --from-literal=usernmae=myuser --from-literal=password=mypass --dry-run=client -o yaml

## Create a jobs :

kubectl create job my-job --image=nginx --dry-run=client -o yaml

## Create a cronjobs :

kubectl create cronjob my-cron --image=nginx --schedule="\*/1 0 0 0 0" --dry-run=client -o yaml

## Create ingresses

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
    - host: "host.example.com"
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: example-service
                port:
                  number: 80
```
## Create a horizontal pod autoscaller (HPA)

kubectl autoscale deployment my-deployment --cpu-percent=50 --min=1 --max=10