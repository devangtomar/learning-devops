# Node - Pod Affinity

Affinity means closeness, proximity, familiarity.

## Node Affinity

- With node affinity, specific pods can enable to run on the desired node (Node selector also supports that feature, but node affinity is more flexible).

- If node is labelled with key-value, we can run some of the pods on that specific node.

- Terms for Node Affinity:

  - requiredDuringSchedulingIgnoredDuringExecution: Find a node during scheduling according to "matchExpression" and run pod on that node. If it is not found, do not run this pod until finding specific node "matchExpression".
  - IgnoredDuringExecution: After scheduling, if the node label is removed/deleted from node, ignore it while executing.
  - preferredDuringSchedulingIgnoredDuringExecution: Find a node during scheduling according to "matchExpression" and run pod on that node. If it is not found, run this pod wherever it finds.
    - weight: Preference weight. If weight is more than other weights, this weight is higher priority than others.

Sample node-affinity

```yml
apiVersion: v1
kind: Pod
metadata:
  name: nodeaffinitypod1
spec:
  containers:
    - name: nodeaffinity1
      image: nginx:latest # "requiredDuringSchedulingIgnoredDuringExecution" means
  affinity: # Find a node during scheduling according to "matchExpression" and run pod on that node.
    nodeAffinity: # If it is not found, do not run this pod until finding specific node "matchExpression".
      requiredDuringSchedulingIgnoredDuringExecution: # "...IgnoredDuringExecution" means
        nodeSelectorTerms: # after scheduling, if the node label is removed/deleted from node, ignore it while executing.
          - matchExpressions:
              - key: app
                operator: In # In, NotIn, Exists, DoesNotExist
                values: # In => key=value,    NotIn => key!=value
                  - production # Exists => only key
---
apiVersion: v1
kind: Pod
metadata:
  name: nodeaffinitypod2
spec:
  containers:
    - name: nodeaffinity2
      image: nginx:latest
  affinity: # "preferredDuringSchedulingIgnoredDuringExecution" means
    nodeAffinity: # Find a node during scheduling according to "matchExpression" and run pod on that node.
      preferredDuringSchedulingIgnoredDuringExecution: # If it is not found, run this pod wherever it finds.
        - weight: 1 # if there is a pod with "app=production", run on that pod
          preference: # if there is NOT a pod with "app=production" and there is NOT any other preference,
            matchExpressions: # run this pod wherever scheduler finds a node.
              - key: app
                operator: In
                values:
                  - production
        - weight: 2 # this is highest prior, weight:2 > weight:1
          preference: # if there is a pod with "app=test", run on that pod
            matchExpressions: # if there is NOT a pod with "app=test", goto weight:1 preference
              - key: app
                operator: In
                values:
                  - test
---
apiVersion: v1
kind: Pod
metadata:
  name: nodeaffinitypod3
spec:
  containers:
    - name: nodeaffinity3
      image: nginx:latest
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: app
                operator: Exists # In, NotIn, Exists, DoesNotExist
```

# Pod Affinity

- Some of the pods should run with other pods on same node or same availability zone (e.g. frontend pods run with cache pod on the same availability zone)
- If pod affinity is defined for one pod, that pod runs with the related pod on same node or same availability zone.
- Each node in the cluster is labelled with default labels.
  - "kubernetes.io/hostname": e.g "kubernetes.io/hostname=minikube"
  - "kubernetes.io/arch": e.g "kubernetes.io/arch=amd64"
  - "kubernetes.io/os": e.g "kubernetes.io/os=linux"
- Each node in the cluster that runs on the Cloud is labelled with following labels.
  - "topology.kubernetes.io/region": e.g. "topology.kubernetes.io/region=northeurope"
  - "topology.kubernetes.io/zone": e.g. "topology.kubernetes.io/zone=northeurope-1"

```yml
apiVersion: v1
kind: Pod
metadata:
  name: frontendpod
  labels:
    app: frontend # defined labels
    deployment: test
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: cachepod
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution: # required: if not found, not run this pod on any node
        - labelSelector:
            matchExpressions:
              - key: app
                operator: In
                values:
                  - frontend
          topologyKey: kubernetes.io/hostname # run this pod with the POD which includes "app=frontend" on the same worker NODE
      preferredDuringSchedulingIgnoredDuringExecution: # preferred: if not found, run this pod on any node
        - weight: 1
          podAffinityTerm:
            labelSelector:
              matchExpressions:
                - key: branch
                  operator: In
                  values:
                    - develop
            topologyKey: topology.kubernetes.io/zone # run this pod with the POD which includes "branch=develop" on the any NODE in the same ZONE
    podAntiAffinity: # anti-affinity: NOT run this pod with the following match ""
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchExpressions:
                - key: deployment
                  operator: In
                  values:
                    - prod
            topologyKey: topology.kubernetes.io/zone # NOT run this pod with the POD which includes "deployment=prod" on the any NODE in the same ZONE
  containers:
    - name: cachecontainer # cache image and container name
      image: redis:6-alpine
```
