# Storage Class

- Creating volume with PV is manual way of creating volume. With storage classes, it can be automated.
- Cloud providers provide storage classes on their infrastructure.
- When pod/deployment is created, storage class is triggered to create PV automatically (Trigger order: Pod -> PVC -> Storage Class -> PV).

```yml
# Storage Class Creation on Azure
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standarddisk
parameters:
  cachingmode: ReadOnly
  kind: Managed
  storageaccounttype: StandardSSD_LRS
provisioner: kubernetes.io/azure-disk
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

"storageClassName" is added into PVC file.

```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysqlclaim
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 5Gi
  storageClassName: "standarddisk" # selects/binds to storage class (defined above)
```


When deployment/pod request PVC (claim), storage class provides volume on the infrastructure automatically.