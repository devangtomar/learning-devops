## Namespaces

k8s uses namespaces to organise objects in cluster. You can think of them as folder that holds a set of objects.
By default you'll be using default namespace but it can switch via

`--namespace=yourNameSpaceName`

OR use from all namespaces

`--all-namespace`

## Contexts

If you want to change the default namespace more permanently you can use a context.. This gets recorded in a `kubectl` configuration file.
Located at `$HOME/.kube/config`

### For settings contexts

`kubectl config set-context my-context --namespace=mystuff`

### For getting contexts to switch b/w

`kubectl config get-contexts`

### For using a context

`kubectl config use-context my-context`

## Viewing kubernetes API objects

### Usually it follows like : `kubectl get <resource-type> <resource-name>`

Output can be controlled via `-o` flag :

`kubectl get nodes -o yaml`

OR

`kubectl get nodes -o json`

### For grep/awk certain things..

`kubectl get pods my-pod -o jsonpath --template={.status.podIP}`

## Getting multiple resources

`kubectl get pods,services`

## Describing the resource

`kubectl describe <resource-name> <obj-name>`

Example :

`kubectl describe node docker-desktop`

## Explaining resource type

`kubectl explain <resource type>`

Example :

`kubectl explain pods`

## Creating, Updating and destroying kubernetes objects

### Creation part :

`kubectl apply -f obj.yaml`

### Updation part :

`kubectl apply -f obj.yaml`

OR without opening/changing the YAML

'kubectl edit <resource-name> <obj-name>'

### For checking previously applied settings..

kubectl apply command records previously applied settings

You can use either of these..

- applied
- set-last-applied
- view-last-applied

`kubectl apply -f myobj.yml view-last-applied`

### Deletio part :

`kubectl delete -f myobj.yml`

OR

`kubectl delete <resource-name> <obj-name>`

## Labelling and annotating objects

### For adding a label

`kubectl label <resource-name> <object-name> labelName=labelValue`

Example :

`kubectl label node docker-desktop color=red`

### For overwriting a label

`kubectl label node docker-desktop color=red --overwrite`

### For removing a label

`kubectl label node docker-desktop color-`

## Debugging commands

### Checking logs for a pod (add `-f` flag to continously tailing the logs)

`kubectl logs <pod-name>`

### Executing a command inside the pod

`kubectl exec -it <pod-name> /bin/sh`

### You can attach the pod as well if you don't have any terminal inside the pod

`kubectl attach -it <pod-name>`

### Copying stuff to-fro from pod

`kubectl cp <pod-name>:/file/inside/pod /desired/location`

### Port forwarding

`kubectl port-forward <pod-name> 8080:80`

### Getting events (You can also use `--watch` to see the state continously)

`kubectl get events`

### Getting top resources consuming pods/nodes

`kubectl top nodes`

`kubectl top pods`

## Cluster management

Cordon : Preventing any pods to get schedule on the cluster
Drain : Stopping any running pods on a cluster

For Cordon : `kubectl cordon`
For drain : `kubectl drain`

## For GUI use Rancher dashboard and headlamp project
