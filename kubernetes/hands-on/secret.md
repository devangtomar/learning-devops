# Secret

- Secret objects store the sensitive and secure information like username, password, ssh-tokens, certificates.
- Secrets (that you defined) and pods (that you defined) should be in the same namespace (e.g. if defined secret is in the "default" namespace, pod should be also in the "default" namepace).
- There are 8 different secret types (basic-auth, tls, ssh-auth, token, service-account-token, dockercfg, dockerconfigjson, opaque). Opaque type is the default one and mostly used.
- Secrets are called by the pod in 2 different ways: volume and environment variable

Imperative way, run on the terminal (geneneric in the command = opaque):

`kubectl create secret generic mysecret2 --from-literal=db_server=db.example.com --from-literal=db_username=admin --from-literal=db_password=P@ssw0rd!`

Imperative way with file to hide pass in the command history

`kubectl create secret generic mysecret3 --from-file=db_server=server.txt --from-file=db_username=username.txt --from-file=db_password=password.txt`

Imperative way with json file to hide pass in the command history

`kubectl create secret generic mysecret4 --from-file=config.json`

# Lab

how to create secrets with file,

```yml
apiVersion: v1
data:
  db_server: ZGIuZXhhbXBsZS5jb20=
  db_username: YWRtaW4=
kind: Secret
metadata:
  creationTimestamp: null
  name: mysecret2
```

Secrets from volume..

```yml
apiVersion: v1
kind: Pod
metadata:
  name: secretvolumepod
spec:
  containers:
    - name: secretcontainer
      image: nginx
      volumeMounts:
        - name: secret-vol
          mountPath: /secret
  volumes:
    - name: secret-vol
      secret:
        secretName: mysecret
---
apiVersion: v1
kind: Pod
metadata:
  name: secretenvpod
spec:
  containers:
    - name: secretcontainer
      image: nginx
      env:
        - name: username
          valueFrom:
            secretKeyRef:
              name: mysecret
              key: db_username
        - name: password
          valueFrom:
            secretKeyRef:
              name: mysecret
              key: db_password
        - name: server
          valueFrom:
            secretKeyRef:
              name: mysecret
              key: db_server
---
apiVersion: v1
kind: Pod
metadata:
  name: secretenvallpod
spec:
  containers:
    - name: secretcontainer
      image: nginx
      envFrom:
        - secretRef:
            name: mysecret
```
