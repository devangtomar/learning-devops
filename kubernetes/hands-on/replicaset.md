# Replicaset

- Deployment object create Replicaset object. Deployment provides the transition of the different replicaset automatically.
- Replicaset is responsible for the management of replica creation and remove. But, when the pods are updated (e.g. image changed), it can not update replicaset pods. However, deployment can update for all change. So, best practice is to use deployment, not to use replicaset directly.
- Important: It can be possible to create replicaset directly, but we could not use rollout/rollback, undo features with replicaset. Deployment provide to use rollout/rollback, undo features.

## How to fetch replicaset..

```bash
kubectl get replicaset

# or

kubectl get rs
```
