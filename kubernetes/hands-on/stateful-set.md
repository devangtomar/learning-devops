# Stateful set

- Pods/Deployments are stateless objects. Stateful set provides to run stateful apps.
- Differences between Deployment and Statefulset:
  - Name of the pods in the statefulset are not assigned randomly. It gives name statefulsetName_0,1,2,3.
  - Pods in the statefulset are not created at the same time. Pods are created in order (new pod creation waits until previous pod's running status).
  - When scaling down of statefulset, pods are deleted in random. Pods are deleted in order.
  - If PVC is defined in the statefulset, each pod in the statefulset has own PV

```yml
apiVersion: v1
kind: Service
metadata:
  name: nginx # create a service with "nginx" name
  labels:
    app: nginx
spec:
  ports:
    - port: 80
      name: web # create headless service if clusterIP:None
  clusterIP: None # when requesting service name, service returns one of the IP of pods
  selector: # headless service provides to reach pod with podName.serviceName
    app: nginx # selects/binds to app:nginx (defined in: spec > template > metadata > labels > app:nginx)
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web # statefulset name: web
spec:
  serviceName: nginx # binds/selects service (defined in metadata > name: nginx)
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: k8s.gcr.io/nginx-slim:0.8
          ports:
            - containerPort: 80
              name: web
          volumeMounts:
            - name: www
              mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
    - metadata:
        name: www
      spec:
        accessModes: ["ReadWriteOnce"] # creates PVCs for each pod automatically
        resources: # hence, each node has own PV
          requests:
            storage: 512Mi
```
