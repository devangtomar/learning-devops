# Taint and Toleration

- Node affinity is a property of Pods that attracts/accepts them to a set of nodes. Taints are the opposite, they allow a node to repel/reject a set of pods.
- TAINTs are assigned to the NODEs. TOLERATIONs assigned to the PODs
  - "kubectl describe nodes minikube", at taints section, it can be seen taints.
  - To add taint to the node with commmand: "kubectl taint node minikube app=production:NoSchedule"
  - To delete taint to the node with commmand: "kubectl taint node minikube app-"
- If pod has not any toleration for related taint, it can not be started on the tainted node (status of pod remains pending)
- Taint Types:
  - key1=value1:effect: (e.g."kubectl taint node minikube app=production:NoSchedule")
- Taint "effect" types:
  - NoSchedule: If pod is not tolerated with this effect, it can not run on the related node (status will be pending, until toleration/untaint)
  - PreferNoSchedule: If pod is not tolerated with this effect and if there is not any untainted node, it can run on the related node.
  - NoExecute: If pod is not tolerated with this effect, it can not run on the related node. If there are pods running on the node before assigning "NoExecute" taint, after tainting "NoExecute", untolerated pods stopped on this node.

## For adding tainting a node..

`kubectl taint node nodename platform=production:NoSchedule`

## To remove taint from node..

kubectl taint node nodename platform-

## For adding tolerating a pods..

```yml
apiVersion: v1
kind: Pod
metadata:
  name: toleratedpod1
  labels:
    env: test
spec:
  containers:
    - name: toleratedcontainer1
      image: nginx:latest
  tolerations: # pod tolerates "app=production:NoSchedule"
    - key: "app"
      operator: "Equal"
      value: "production"
      effect: "NoSchedule"
---
apiVersion: v1
kind: Pod
metadata:
  name: toleratedpod2
  labels:
    env: test
spec:
  containers:
    - name: toleratedcontainer2
      image: nginx:latest
  tolerations:
    - key: "app" # pod tolerates "app:NoSchedule", value is not important in this pod
      operator: "Exists" # pod can run on the nodes which has "app=test:NoSchedule" or "app=production:NoSchedule"
      effect: "NoSchedule"
```
