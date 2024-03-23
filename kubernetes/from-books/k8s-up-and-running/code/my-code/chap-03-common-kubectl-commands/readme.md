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

### For grep/awk certain things