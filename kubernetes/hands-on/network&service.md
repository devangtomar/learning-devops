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

- ClusterIP Service created. If any resource in the cluster sends a request to the ClusterIP and Port 5000, this request will reach to one of the pod behind the ClusterIP Service.
- We can show it from frontend pods.
- Connect one of the front-end pods (list: "kubectl get pods", connect: "kubectl exec -it frontend-5966c698b4-b664t -- bash")
- In the K8s, there is DNS server (core dns based) that provide us to query ip/name of service.
- When running nslookup (backend), we can reach the complete name and IP of this service (serviceName.namespace.svc.cluster_domain, e.g. backend.default.svc.cluster.local).
- When running curl to the one of the backend pods with port 5000, service provides us to make connection with one of the backend pods.

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

- With NodePort Service (you can see the image below), frontend pods can be reachable from the opening port (32098). In other words, someone can reach frontend pods via WorkerNodeIP:32098. NodePort service listens all of the worker nodes' port (in this example: port 32098).
- While working with minikube, it is only possible with minikube tunnelling. Minikube simulates the reaching of the NodeIP:Port with tunneling feature.

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

## Create Loadbalancer Service on the cloud K8s cluster to reach frontend pods from Internet.

- LoadBalancer Service is only available wih cloud services (because in the local cluster, it can not possible to get external-ip of the load-balancer service). So if you have connection to the one of the cloud service (Azure-AKS, AWS EKS, GCP GKE), please create loadbalance service on it (run: "kubectl apply -f backend_loadbalancer.yaml").
- If you run on the cloud, you'll see the external-ip of the loadbalancer service.
- In addition, it can be possible service with Imperative way (with command).

```yml
apiVersion: v1
kind: Service
metadata:
  name: frontendlb
spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

`kubectl expose deployment backend --type=clusterip --name=backend`

Also you could use :  `kubectl create service loadbalancer lb_1 --tcp=80:80 --dry-run=client -o yaml`

## Create external Service on the cloud K8s cluster to reach frontend pods from Internet.

`kubectl create service externalname ext1  --tcp=80:80 --dry-run=client -o yaml --external-name=ewew;`
