## Applying Labels and Annotations

```
kubectl create deployment alpaca --image=gcr.io/kuar-demo/kuard-amd64:blue # you can add the replicas here as well

kubectl scale deployment alpaca --replicas=2

kubectl label deployment alpaca ver=1 app=alpaca env=prod
```

## Viewing Labels and Annotations

```
 kubectl get deployment --show-labels
```

## Modifying Labels and Annotations

```
kubectl label deployment alpaca foo=bar
```

### To show labels and annotations

```
kubectl get deployment -L <label-key>
```

## Removing Labels and Annotations

```
kubectl annotate deployment alpaca foo-
```

OR

```
kubectl label deployment alpaca foo-
```

## For selecting pods/deployments based on labels

```
kubectl get deployments --selector="foo=bar"
```

### For selecting multiple labels

```
kubectl get deployments --selector="foo=bar,ver=1"
```

### For selecting from a list of labels

```
kubectl get deployments --selector="foo in (bar, baz)"
```

### For not selecting from a range of labels

```
kubectl get deployments --selector="foo notin (bar, baz)"
```

### For selecting based on if labels exists or not

```
kubectl get deployments --selector="foo"
kubectl get deployments --selector="!foo"
```

## How labels are different from annotations

Labels are used to select pods/deployments/services based on labels.
In contrast, annotations are not used to identify and select objects.
