# Daemonset

- It provides to run pods on EACH nodes. It can be configured to run only specific nodes.
- For example, you can run log application that runs on each node in the cluster and app sends these logs to the main log server. Manual configuration of each nodes could be headache in this sceneario, so using deamon sets would be beneficial to save time and effort.
- If the new nodes are added on the cluster and running deamon sets on the cluster at that time period, default pods which are defined on deamon sets also run on the new nodes without any action.


## How to run a daemonset on worker nodes..

```yml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: logdaemonset
  labels:
    app: fluentd-logging
spec:
  selector:
    matchLabels: # label selector should be same labels in the template (template > metadata > labels)
      name: fluentd-elasticsearch
  template:
    metadata:
      labels:
        name: fluentd-elasticsearch
    spec:
      tolerations:
        - key: node-role.kubernetes.io/master # this toleration is to have the daemonset runnable on master nodes
          effect: NoSchedule # remove it if your masters can't run pods
      containers:
        - name: fluentd-elasticsearch
          image: quay.io/fluentd_elasticsearch/fluentd:v2.5.2 # installing fluentd elasticsearch on each nodes
          resources:
            limits:
              memory: 200Mi # resource limitations configured
            requests:
              cpu: 100m
              memory: 200Mi
          volumeMounts: # definition of volumeMounts for each pod
            - name: varlog
              mountPath: /var/log
            - name: varlibdockercontainers
              mountPath: /var/lib/docker/containers
              readOnly: true
      terminationGracePeriodSeconds: 30
      volumes: # ephemerial volumes on node (hostpath defined)
        - name: varlog
          hostPath:
            path: /var/log
        - name: varlibdockercontainers
          hostPath:
            path: /var/lib/docker/containers
```

Post this you can see..

`kubectl get daemonset`