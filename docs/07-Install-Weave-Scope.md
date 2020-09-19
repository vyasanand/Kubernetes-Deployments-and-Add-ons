# Install Visualization add-on - Weave Scope

## Pre-requirements

To install [Weave Scope](https://github.com/weaveworks/scope) add-on you will need a working Kubernetes cluster. You can follow the steps here to install a cluster using [Kubeadm](02-Kubeadm.md) or [Kubespray](03-Kubespray.md)

## Installation

Run the below command once on the ```control-plane``` node. This creates ```weave``` namespace and deploys required components on the cluster.

```shell
kubectl apply -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```
> Output

```shell
namespace/weave created
serviceaccount/weave-scope created
clusterrole.rbac.authorization.k8s.io/weave-scope created
clusterrolebinding.rbac.authorization.k8s.io/weave-scope created
deployment.apps/weave-scope-app created
service/weave-scope-app created
deployment.apps/weave-scope-cluster-agent created
daemonset.apps/weave-scope-agent created
```

Edit the service ```weave-scope-app``` from ```ClusterIP``` to ```NodePort``` so we can access it from client machine.

```shell
kubectl edit -n weave service weave-scope-app
```
```shell
.....
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}
```
Validate using the below command

```shell
kubectl get svc -n weave
```
> Output

```shell
NAME              TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
weave-scope-app   NodePort   xx.xxx.xxx.xx   <none>        80:30647/TCP   5m12s
```

Run the below command to get the node on which the pod is running and port on which the service is exposed

```shell
{
kubectl get pods -l weave-scope-component=app -n weave -o jsonpath="{.items[*].spec.nodeName}"
kubectl get svc -n weave -l weave-scope-component=app -o jsonpath="{.items[*].spec.ports[*].nodePort}"
}
```
> Output

```shell
kubernetes-230647
```
> In your cluster the node and port could be different from above output

Fetch the public IP for kubernetes-2 node as our pod is running on it

```shell
az vm show -d -g kubernetes --name kubernetes-2 --query publicIps -o tsv
```

In the browser enter the IP address fetched from above command and NodePort fetched from the weave-scope-app service.

> `https://<kubernetes-2-host-ip-here>:30647`
  
You should see the ```Dashboard```

![Dashboard](/config/weavescope.PNG)

## Cleanup

Run the below command to delete ```Weave``` namespace and all the components deployed under it.

```shell
kubectl delete namespace weave
```
> Output

```shell
namespace "weave" deleted
```

If you have provisioned the kubernetes cluster using the links I have shared above, Next step: [Cleanup](06-Cleanup.md)
