# Rollout and Rollback

- Rollout and Rollback enable to update and return back containers that run under the deployment.
- 2 strategy for rollout:
  - Recreate Strategy: Delete all pods first and create Pods from scratch. If two different versions of SW affect each other negatively, this strategy could be used.
  - RollingUpdate Strategy (default): It updates pods step by step. Pods are updated step by step, all pods are not deleted at the same time.
    - maxUnavailable: At the update duration, it shows the max number of deleted containers (total:10 containers; if maxUn:2, min:8 containers run in that time period)
    - maxSurge: At the update duration, it shows that the max number of containers run on the cluster (total:10 containers; if maxSurge:2, max:12 containers run in a time)

```bash
kubectl set image deployment rolldeployment nginx=httpd:alpine --record     # change image of deployment
kubectl rollout history deployment rolldeployment                           #shows record/history revisions
kubectl rollout history deployment rolldeployment --revision=2              #select the details of the one of the revisions
kubectl rollout undo deployment rolldeployment                              #returns back to previous deployment revision
kubectl rollout undo deployment rolldeployment --to-revision=1              #returns back to the selected revision=1
kubectl rollout status deployment rolldeployment -w                         #show live status of the rollout deployment
kubectl rollout pause deployment rolldeployment                             #pause the rollout while updating pods
kubectl rollout resume deployment rolldeployment                            #resume the rollout if rollout paused
```

# Declarative way to do rollout-rollbacks..

Create Yaml file (recreate-deployment.yaml) in your directory and copy the below definition into the file.

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rcdeployment
  labels:
    team: development
spec:
  replicas: 5 # create 5 replicas
  selector:
    matchLabels: # labelselector of deployment: selects pods which have "app:recreate" labels
      app: recreate
  strategy: # deployment roll up strategy: recreate => Delete all pods firstly and create Pods from scratch.
    type: Recreate
  template:
    metadata:
      labels: # labels the pod with "app:recreate"
        app: recreate
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
```

Create Yaml file (rolling-deployment.yaml) in your directory and copy the below definition into the file.

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rolldeployment
  labels:
    team: development
spec:
  replicas: 10
  selector:
    matchLabels: # labelselector of deployment: selects pods which have "app:rolling" labels
      app: rolling
  strategy:
    type: RollingUpdate # deployment roll up strategy: rollingUpdate => Pods are updated step by step, all pods are not deleted at the same time.
    rollingUpdate:
      maxUnavailable: 2 # shows the max number of deleted containers => total:10 container; if maxUnava:2, min:8 containers run in that time period
      maxSurge: 2 # shows that the max number of containers    => total:10 container; if maxSurge:2, max:12 containers run in a time
  template:
    metadata:
      labels: # labels the pod with "app:rolling"
        app: rolling
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
```

You can edit the deployment by either editing the file and then `kubectl apply -f dpl.yml`

you can also use : `kubectl edit deploy rolldeployment --record`

To get the status of the rollout..

`kubectl rollout status deployment rolldeployment -w`
