# Network and service

## K8s Networking Requirements

- Each pod has unique and own IP address (Containers within a pod share network namespaces).
- All PODs can communicate with all other pods without NAT (Network Address Translation)
- All NODEs can communicate with all pods without NAT.
- The IP of the POD is same throughout the cluster.

## Service

- "An abstract way to expose an application running on a set of Pods as a network service.
- Kubernetes ServiceTypes allow you to specify what kind of Service you want. The default is ClusterIP.
- Type values and their behaviors are:
  - ClusterIP: Exposes the Service on a cluster-internal IP. Choosing this value makes the Service only reachable from within the cluster. This is the default ServiceType.
  - NodePort: Exposes the Service on each Node's IP at a static port (the NodePort). A ClusterIP Service, to which the NodePort Service routes, is automatically created. You'll be able to contact the NodePort Service, from outside the cluster, by requesting :.
  - LoadBalancer: Exposes the Service externally using a cloud provider's load balancer. NodePort and ClusterIP Services, to which the external load balancer routes, are automatically created.
  - ExternalName: Maps the Service to the contents of the externalName field (e.g. foo.bar.example.com), by returning a CNAME record with its value. No proxying of any kind is set up." (Ref: Kubernetes.io)
- Example of Service Object Definition: (Selector binds service to the related pods, get traffic from port 80 to port 9376)

## LAB: K8s Service Implementations (ClusterIp, NodePort and LoadBalancer)

### Create Deployments for frontend and backend.

To generate quickly via dry run use.. `kubectl create deploy frontend --image=nginx --replicas=3 --tcp=80 --dry-run=client -o yaml;`

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: frontend
  name: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: nginx
          ports:
            - containerPort: 80
          resources:
            requests:
              memory: "64Mi"
              cpu: "250m"
            limits:
              memory: "128Mi"
              cpu: "500m"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: backend
  name: backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: backend
    spec:
      containers:
        - name: backend
          image: ozgurozturknet/k8s:backend
          ports:
            - containerPort: 5000
          resources:
            requests:
              memory: "128Mi"
              cpu: "250m"
            limits:
              memory: "256Mi"
              cpu: "500m"
```

### Create ClusterIP Service to reach backend pods.

To generate quickly via dry run use.. `kubectl create service clusterip my-clusterip --tcp=80:80 --dry-run=client -o yaml`

```yml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: my-clusterip
  name: my-clusterip
spec:
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
  selector:
    app: my-clusterip
  type: ClusterIP
status:
  loadBalancer: {}
```

### Create NodePort Service to reach frontend pods from Internet.

To generate quickly via dry run use.. `kubectl create service nodeport frontend --tcp=80:80 --dry-run=client -o yaml;`

```yml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: frontend
  name: frontend
spec:
  ports:
    - name: 80-80
      port: 80
      protocol: TCP
      targetPort: 80
  selector:
    app: frontend
  type: NodePort
status:
  loadBalancer: {}
```

Once nodeport service is up.. then run this.. `curl http://localhost:30594`
