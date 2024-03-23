## Deploying on Kubernetes on GKE (Google Kubernetes Engine)

Once you have gcloud installed, set a default zone:

```
$ gcloud config set compute/zone us-west1-a
```

Then you can create a cluster:

```
$ gcloud container clusters create kuar-cluster --num-nodes=3
```

This will take a few minutes. When the cluster is ready, you can get credentials for the cluster using:

```
$ gcloud container clusters get-credentials kuar-cluster
```

If you run into trouble, you can find the complete instructions for creating a GKE cluster in the Google Cloud Platform documentation.

## Deploying on Kubernetes on AKS (Azure Kubernetes Service)

When you have the shell up and working, you can run:

```
$ az group create --name=kuar --location=westus
```

Once the resource group is created, you can create a cluster using:

```
$ az aks create --resource-group=kuar --name=kuar-cluster
```

This will take a few minutes. Once the cluster is created, you can get credentials for the cluster with:

```
$ az aks get-credentials --resource-group=kuar --name=kuar-cluster
```

If you don’t already have the kubectl tool installed, you can install it using:

```
$ az aks install-cli
```

You can find complete instructions for installing Kubernetes on Azure in the Azure documentation.

## Deploying on Kubernetes on EKS (Elastic Kubernetes Service)

Once you have eksctl installed and in your path, you can run the following command to create a cluster:

```
$ eksctl create cluster
```

For more details on installation options (such as node size and more), view the help using this command:

```
$ eksctl create cluster --help
```

The cluster installation includes the right configuration for the kubectl command-line tool. If you don’t already have kubectl installed, follow the instructions in the documentation.

## Deploying on Kubernetes on Minikube

You can find the minikube tool on GitHub. There are binaries for Linux, macOS, and Windows that you can download. Once you have the minikube tool installed, you can create a local cluster using:

```
$ minikube start
```

This will create a local VM, provision Kubernetes, and create a local kubectl configuration that points to that cluster. As mentioned previously, this cluster only has a single node, so while it is useful, it has some differences with most production deployments of Kubernetes.

When you are done with your cluster, you can stop the VM with:

```
$ minikube stop
```

If you want to remove the cluster, you can run:

```
$ minikube delete
```

## Checking cluster status

**This returns 2 different versions : version of the local kubectl tools as the version of k8s API server.**

`kubectl version`

```bash
Client Version: v1.29.3
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
Server Version: v1.29.1
```

## Simple diagnostic for the cluster

`kubectl get componentstatus`

Sample output :

```bash
Warning: v1 ComponentStatus is deprecated in v1.19+
NAME                 STATUS    MESSAGE   ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-0               Healthy   ok
```

## Listing kubernetes nodes

`kubectl get nodes`

```bash
NAME             STATUS   ROLES           AGE     VERSION
docker-desktop   Ready    control-plane   5d19h   v1.29.1
```

`kubectl describe node docker-desktop`

```bash
Name:               docker-desktop
Roles:              control-plane
Labels:             beta.kubernetes.io/arch=arm64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=arm64
                    kubernetes.io/hostname=docker-desktop
                    kubernetes.io/os=linux
                    node-role.kubernetes.io/control-plane=
                    node.kubernetes.io/exclude-from-external-load-balancers=
Annotations:        kubeadm.alpha.kubernetes.io/cri-socket: unix:///var/run/cri-dockerd.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Mon, 18 Mar 2024 00:24:14 +0530
Taints:             <none>
Unschedulable:      false
Lease:
  HolderIdentity:  docker-desktop
  AcquireTime:     <unset>
  RenewTime:       Sat, 23 Mar 2024 20:03:15 +0530
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------
  MemoryPressure   False   Sat, 23 Mar 2024 20:03:05 +0530   Mon, 18 Mar 2024 00:24:13 +0530   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Sat, 23 Mar 2024 20:03:05 +0530   Mon, 18 Mar 2024 00:24:13 +0530   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Sat, 23 Mar 2024 20:03:05 +0530   Mon, 18 Mar 2024 00:24:13 +0530   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Sat, 23 Mar 2024 20:03:05 +0530   Mon, 18 Mar 2024 00:24:14 +0530   KubeletReady                 kubelet is posting ready status
Addresses:
  InternalIP:  192.168.65.3
  Hostname:    docker-desktop
Capacity:
  cpu:                10
  ephemeral-storage:  61202244Ki
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  hugepages-32Mi:     0
  hugepages-64Ki:     0
  memory:             8029236Ki
  pods:               110
Allocatable:
  cpu:                10
  ephemeral-storage:  56403987978
  hugepages-1Gi:      0
  hugepages-2Mi:      0
  hugepages-32Mi:     0
  hugepages-64Ki:     0
  memory:             7926836Ki
  pods:               110
System Info:
  Machine ID:                 c0580727-d849-45a5-b090-c0683fb7b411
  System UUID:                c0580727-d849-45a5-b090-c0683fb7b411
  Boot ID:                    1b91da06-a9c4-4410-bc4e-a2f22ac62116
  Kernel Version:             6.6.16-linuxkit
  OS Image:                   Docker Desktop
  Operating System:           linux
  Architecture:               arm64
  Container Runtime Version:  docker://25.0.3
  Kubelet Version:            v1.29.1
  Kube-Proxy Version:         v1.29.1
Non-terminated Pods:          (9 in total)
  Namespace                   Name                                      CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                                      ------------  ----------  ---------------  -------------  ---
  kube-system                 coredns-76f75df574-549wp                  100m (1%)     0 (0%)      70Mi (0%)        170Mi (2%)     5d19h
  kube-system                 coredns-76f75df574-zhp59                  100m (1%)     0 (0%)      70Mi (0%)        170Mi (2%)     5d19h
  kube-system                 etcd-docker-desktop                       100m (1%)     0 (0%)      100Mi (1%)       0 (0%)         5d19h
  kube-system                 kube-apiserver-docker-desktop             250m (2%)     0 (0%)      0 (0%)           0 (0%)         5d19h
  kube-system                 kube-controller-manager-docker-desktop    200m (2%)     0 (0%)      0 (0%)           0 (0%)         5d19h
  kube-system                 kube-proxy-z79jh                          0 (0%)        0 (0%)      0 (0%)           0 (0%)         5d19h
  kube-system                 kube-scheduler-docker-desktop             100m (1%)     0 (0%)      0 (0%)           0 (0%)         5d19h
  kube-system                 storage-provisioner                       0 (0%)        0 (0%)      0 (0%)           0 (0%)         5d19h
  kube-system                 vpnkit-controller                         0 (0%)        0 (0%)      0 (0%)           0 (0%)         5d19h
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests    Limits
  --------           --------    ------
  cpu                850m (8%)   0 (0%)
  memory             240Mi (3%)  340Mi (4%)
  ephemeral-storage  0 (0%)      0 (0%)
  hugepages-1Gi      0 (0%)      0 (0%)
  hugepages-2Mi      0 (0%)      0 (0%)
  hugepages-32Mi     0 (0%)      0 (0%)
  hugepages-64Ki     0 (0%)      0 (0%)
Events:              <none>
```

## Getting namespaces

`kubectl get namespaces`

```bash
NAME              STATUS   AGE
default           Active   5d19h
kube-node-lease   Active   5d19h
kube-public       Active   5d19h
kube-system       Active   5d19h
```

## Clusters components

### kubernetes proxy

`kubectl get daemonSets --namespace=default`

### kubernetes DNS

### For Getting all deployments in a namespace

`kubectl get deployments --namespace=default`

### For Getting all services in a namespace

`kubectl get services --namespace=default`

```bash
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   5d19h
```
