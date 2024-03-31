# ConfigMap

- It is same as "secrets". The difference is that configmap does not save sensitive information. It stores config variables.
- Configmap stores data with key-value pairs.
- Configmaps are called by the pod in 2 different ways: volume and environment variable
- Scenario shows the usage of configmaps.

Dry run : `kubectl create configmap myconfig --from-literal=name=devang --dry-run=client -o yaml`

Config map via the volume :

```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myconfigmap
data:
  db_server: "db.example.com" # configmap key-value parameters
  database: "mydatabase"
  site.settings: |
    color=blue
    padding:25px
---
apiVersion: v1
kind: Pod
metadata:
  name: configmappod
spec:
  containers:
    - name: configmapcontainer
      image: nginx
      env: # configmap using environment variable
        - name: DB_SERVER
          valueFrom:
            configMapKeyRef:
              name: myconfigmap # configmap name, from "myconfigmap"
              key: db_server
        - name: DATABASE
          valueFrom:
            configMapKeyRef:
              name: myconfigmap
              key: database
      volumeMounts:
        - name: config-vol
          mountPath: "/config"
          readOnly: true
  volumes:
    - name: config-vol # transfer configmap parameters using volume
      configMap:
        name: myconfigmap
```
