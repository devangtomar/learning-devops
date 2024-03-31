# Volume

- Ephemeral volume (Temporary volume): Multiple containers reach ephemeral volume in the pod. When the pod is deleted/killed, volume is also deleted. But when container is restarted, volume is still available because pod still runs.
- There are 2 types of ephemeral volumes:
  - Emptydir
  - Hostpath
    - Directory
    - DirectoryOrCreate
    - FileOrCreate

````

For Empty dir..

```yaml
spec:
  containers:
  - name: sidecar
    image: busybox
    command: ["/bin/sh"]
    args: ["-c", "sleep 3600"]
    volumeMounts:                # volume is mounted under "volumeMounts"
    - name: cache-vol            # "name" of the volume type
      mountPath: /tmp/log        # "mountPath" is the path in the container.
  volumes:
  - name: cache-vol
    emptyDir: {}                 # "volume" type "emptydir"
```

For Hostpath

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath
spec:
  containers:
  - name: hostpathcontainer
    image: ImageName                  # e.g. nginx
    volumeMounts:
    - name: directory-vol             # container connects "volume" name
      mountPath: /dir1                # on the container which path this volume is mounted
    - name: dircreate-vol
      mountPath: /cache               # on the container which path this volume is mounted
    - name: file-vol
      mountPath: /cache/config.json   # on the container which file this volume is mounted
  volumes:
  - name: directory-vol               # "volume" name
    hostPath:                         # "volume" type "hostpath"
      path: /tmp                      # "path" on the node, "/tmp" is defined volume
      type: Directory                 # "hostpath" type "Directory", existed directory
  - name: dircreate-vol
    hostPath:                         # "volume" type "hostpath"
      path: /cache                    # "path" on the node
      type: DirectoryOrCreate         # "hostpath" type "DirectoryOrCreate", if it is not existed, create directory
  - name: file-vol
    hostPath:                         # "volume" type "hostpath"
      path: /cache/config.json        # "path" on the node
      type: FileOrCreate              # "hostpath" type "FileOrCreate",  if it is not existed, create file                # "volume" type "emptydir"
```


Another test volumn mount created as a hands-on

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: pods-vol
  name: pods-vol
spec:
  containers:
  - name: pods-vol
    image: nginx:latest
    resources:
      requests:
        cpu: 100m
        memory: 200Mi
      limits:
        cpu: 200m
        memory: 300Mi
    volumeMounts:
    - name: dir-vol
      mountPath: /home/
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  volumes:
  - name: dir-vol
    hostPath:
      path: /Users/d0t077o/Desktop/repos/my-own/learning-devops/kubernetes/hands-on/tester/
      type: Directory

```
