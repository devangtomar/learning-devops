# Liveness and Readiness Probe

## Liveness Probe

- "The kubelet uses liveness probes to know when to restart a container. For example, liveness probes could catch a deadlock, where an application is running, but unable to make progress." (Ref: Kubernetes.io)
- There are different ways of controlling Pods:
  - httpGet,
  - exec command,
  - tcpSocket,
  - grpc, etc.
- initialDelaySeconds: waiting some period of time after starting. e.g. 5sec, after 5 sec start to run command
- periodSeconds: in a period of time, run command.

# Hands-on

- In the first pod (e.g. web app), it sends HTTP Get Request to "http://localhost/healthz:8080" (port 8080)
  - If returns 400 > HTTP Code > 200, this Pod works correctly.
  - If returns HTTP Code > = 400, this Pod does not work properly.
  - initialDelaySeconds:3 => after 3 seconds, start liveness probe.
  - periodSecond: 3 => Wait 3 seconds between each request.

```yml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: pods
  name: pods
spec:
  containers:
    - name: pods
      args:
        - firstpod
      image: nginx
      livenessProbe:
        httpGet:
          path: /healthz
          port: 8080
          httpHeaders:
            - name: Customer-header
              value: Awesome
        initialDelaySeconds: 5
        periodSeconds: 10
      readinessProbe:
        initialDelaySeconds: 5
        periodSeconds: 10
      resources:
        requests:
          cpu: "200m"
          memory: "200Mi"
        limits:
          cpu: "300m"
          memory: "300Mi"
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

- In the second pod (e.g. console app), it controls whether a file ("healty") exists or not under specific directory ("/tmp/") with "cat" app.
  - If returns 0 code, this Pod works correctly.
  - If returns different code except for 0 code, this Pod does not work properly.
  - initialDelaySeconds: 5 => after 5 seconds, start liveness probe.
  - periodSecond: 5 => Wait 5 seconds between each request.

```yml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-exec
spec:
  containers:
    - name: liveness
      image: k8s.gcr.io/busybox
      args:
        - /bin/sh
        - -c
        - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
      livenessProbe:
        exec:
          command:
            - cat
            - /tmp/healthy
        initialDelaySeconds: 5
        periodSeconds: 5
```

- In the third pod (e.g. database app: mysql), it sends request over TCP Socket.
  - If returns positive response, this Pod works correctly.
  - If returns negative response (e.g. connection refuse), this Pod does not work properly.
  - initialDelaySeconds: 15 => after 15 seconds, start liveness probe.
  - periodSecond: 20 => Wait 20 seconds between each request.

```yml
apiVersion: v1
kind: Pod
metadata:
  name: goproxy
  labels:
    app: goproxy
spec:
  containers:
    - name: goproxy
      image: k8s.gcr.io/goproxy:0.1
      ports:
        - containerPort: 8080
      livenessProbe:
        tcpSocket:
          port: 8080
        initialDelaySeconds: 15
        periodSeconds: 20
```


## Readiness Probe

- "Sometimes, applications are temporarily unable to serve traffic. For example, an application might need to load large data or configuration files during startup, or depend on external services after startup. In such cases, you don't want to kill the application, but you don't want to send it requests either. Kubernetes provides readiness probes to detect and mitigate these situations. A pod with containers reporting that they are not ready does not receive traffic through Kubernetes Services." (Ref: Kubernetes.io)
- Readiness probe is similar to liveness pod. Only difference is to define "readinessProbe" instead of "livenessProbe".