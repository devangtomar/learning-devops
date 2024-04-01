# Persistent Volume and Persistent Volume Claim

- Volumes are ephemeral/temporary area that stores data. Emptydir and hostpath create volume on node which runs related pod.
- In the scenario of creating Mysql pod on cluster, we can not use emptydir and hostpath for long term. Because they don't provide the long term/persistent volume.
- Persistent volume provides long term storage area that runs out of the cluster.
- There are many storage solutions that can be enabled on the cluster: nfs, iscsi, azure disk, aws ebs, google pd, cephfs.
- Container Storage Interface (CSI) provides the connection of K8s cluster and different storage solution.

## Persistent volume

- "accessModes" types:
  - "ReadWriteOnce": read/write for only 1 node.
  - "ReadOnlyMany" : only read for many nodes.
  - "ReadWriteMany": read/write for many nodes.
- "persistentVolumeReclaimPolicy" types: it defines the behaviour of volume after the end of using volume.
  - "Retain" : volume remains with all data after using it.
  - "Recycle": volume is not deleted but all data in the volume is deleted. We get empty volume if it is chosen.
  - "Delete" : volume is deleted after using it.

```yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysqlpv
  labels:
    app: mysql
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  nfs:
    path: /tmp
    server: 10.255.255.10
```

## Persistent Volume Claim (PVC)

- We should create PVCs to use volume. With PVCs, existed PVs can be chosen.
- The reason why K8s manage volume with 2 files (PVC and PV) is to seperate the management of K8s Cluster (PV) and using of volume (PVC).
- If there is seperate role of system management of K8s cluster, system manager creates PV (to connect different storage vendors), developers only use existed PVs with PVCs.

```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysqlclaim
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem # VolumeMode
  resources:
    requests:
      storage: 5Gi
  storageClassName: ""
  selector:
    matchLabels:
      app: mysql # choose/select "mysql" PV that is defined above.
```

Deployment yaml to set everything up..

```yml
apiVersion: v1 # Create Secret object for password
kind: Secret
metadata:
  name: mysqlsecret
type: Opaque
stringData:
  password: P@ssw0rd!
---
apiVersion: apps/v1
kind: Deployment # Deployment
metadata:
  name: mysqldeployment
  labels:
    app: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql # select deployment container (template > metadata > labels)
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql
          ports:
            - containerPort: 3306
          volumeMounts: # VolumeMounts on path and volume name
            - mountPath: "/var/lib/mysql"
              name: mysqlvolume # which volume to select (volumes > name)
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom: # get mysql password from secrets
                secretKeyRef:
                  name: mysqlsecret
                  key: password
      volumes:
        - name: mysqlvolume # name of Volume
          persistentVolumeClaim:
            claimName: mysqlclaim # chose/select "mysqlclaim" PVC that is defined above.
```
