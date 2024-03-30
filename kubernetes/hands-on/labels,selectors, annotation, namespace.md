## Label and Selector, Annotation, Namespace

### Label

- Label is important to reach the K8s objects with key:value pairs.
- key:value is used for labels. E.g. tier:frontend, stage:test, name:app1, team:development
- prefix may also be used for optional with key:value. E.g. example.com/tier:front-end, kubernetes.io/ , k8s.io/
- In the file (declerative way), labels are added under metadata. It is possible to add multiple labels.

```yml
apiVersion: v1
kind: Pod
metadata:
  name: pod1
  labels: # here go the labels!
    app: firstapp
    tier: firstend
    mycluster.local/team: team1
spec:
  containers:
    - name: nginx
      image: nginx
      command: ["/bin/sh"] # it pulls index.html file from github every 15 seconds
      args:
        [
          "-c",
          "while true; do wget -O /var/log/index.html https://raw.githubusercontent.com/omerbsezer/Fast-Kubernetes/main/index.html; sleep 15; done",
        ]
      ports:
        - containerPort 80
      volumeMounts:
        - name: volumeMount
          mountPath: "/var/log"
```

## Imperative way for labelling the pods

```bash
kubectl label pods pod1 team=development # For adding the label
kubectl get pods --show-label # For showing labels for each pods
kubectl label pods pod1 team- # For removing team label from pod pod1
kubectl label pods pod1 --overwrite team=development # For overwriting pods labels
kubectl label pods --all foo=bar # Adding foo=bar label to all pods
```

# Selector : how to select the labelled pods..

```bash
kubectl get pods -l "app=firstapp" --show-labels
kubectl get pods -l "app=firstapp,tier=frontend" --show-labels
kubectl get pods -l "app=firstapp,tier!=frontend" --show-labels
kubectl get pods -l "app,tier=frontend" --show-labels #equality-based selector
kubectl get pods -l "app in (firstapp)" --show-labels  #set-based selector
kubectl get pods -l "app not in (firstapp)" --show-labels  #set-based selector
kubectl get pods -l "app=firstapp,app=secondapp" --show-labels # comma means and => firstapp and secondapp
kubectl get pods -l "app in (firstapp,secondapp)" --show-labels # it means or => firstapp or secondapp
```

# Node selector

With Node Selector, we can specify which pod run on which Node.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod1
spec:
  containers:
    - name: nginx
      image: nginx
      ports:
        - containerPort: 80
      nodeSelector:
        hddtype: ssd
```

It is also possible to label nodes with imperative way.

```bash
kubectl apply -f podnode.yaml
kubectl get pods -w #always watch
kubectl label nodes minikube hddtype=ssd #after labelling node, pod11 configuration can run, because node is labelled with hddtype:ssd
```

# Annotation

- It is similar to label, but it is used for the detailed information (e.g. owner, notification-email, releasedate, etc.) that are not used for linking objects.

```yml
apiVersion: v1
kind: Pod
metadata:
  name: pod1
  annotations:
    owner: "owner-name"
    notification-email: "owner@email.com"
    release-date: "01.01.2022"
spec:
  containers:
    - name: nginx
      image: nginx
      ports:
        - containerPort: 80
```

## Imperative commands for annotation

```bash
kubectl apply -f podannotation.yaml
kubectl describe pod annotationpod
kubectl annotate pods annotationpod foo=bar #imperative way
kubectl delete -f podannotation.yaml
```
