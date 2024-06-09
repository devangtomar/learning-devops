# Resource Limit, Environment Variable

## Resource Limit

- Pods can consume resources (cpu, memory) up to physical resource limits, if there was not any limitation.
- Pods' used resources can be limited.
  - use 1 cpu core => cpu = "1" = "1000" = "1000m"
  - use 10% of 1 cpu core => cpu = "0.1" = "100" = "100m"
  - use 64 MB => memory: "64M"
- CPU resources are exactly limited when it defines.
- When pod requests memory resource more than limitation, pod changes its status to "OOMKilled" and restarts itself to limit memory usage.
- Example (below), pod requests 64MB memory and 0.25 CPU core, uses maximum 256MB memory and 0.5 CPU core.

Example :

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: pods
  name: pods
spec:
  containers:
    - args:
        - firstpod
      image: nginx
      name: pods
      resources:
        requests:
          cpu: 100m
          memory: 100Mi # can be 100M
        limits:
          cpu: 200m
          memory: 200Mi
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

## Environment Variable

- Environment Variables can be defined for each pods in the YAML file.

To fast create it.. : `kubectl run pods firstpod --image=nginx --dry-run=client -o yaml --env USER=user;`

```yml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: pods
  name: pods
spec:
  containers:
  - image: nginx
    name: pods
    env:
    - name: USER
      value: "username"
    - name: DATABASE_HOST
      value: "testdb.test.com"
```
