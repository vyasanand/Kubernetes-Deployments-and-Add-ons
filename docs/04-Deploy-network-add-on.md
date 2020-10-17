## Deploy Network Add-on

If you have installed [Kubernetes cluster using kubeadm](02-Kubeadm.md) you will need to deploy a networking add-on solution.
We will use [Weave-Net](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/) as our networking solution.

### Installation

Run the below command on ```kubernetes-1``` node.

```shell
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```
> Output

```shell

```
### Verification

```shell
kubectl get pods -n kube-system
```
> output

```shell
NAME                                   READY   STATUS    RESTARTS   AGE
coredns-f9fd979d6-pxw4z                1/1     Running   0          9m40s
coredns-f9fd979d6-q97wl                1/1     Running   0          9m40s
etcd-kubernetes-1                      1/1     Running   0          9m46s
kube-apiserver-kubernetes-1            1/1     Running   0          9m46s
kube-controller-manager-kubernetes-1   1/1     Running   0          9m46s
kube-proxy-btfm4                       1/1     Running   0          8m25s
kube-proxy-jvf5z                       1/1     Running   0          9m40s
kube-proxy-thw94                       1/1     Running   0          8m34s
kube-scheduler-kubernetes-1            1/1     Running   0          9m46s
weave-net-bb59x                        2/2     Running   0          46s
weave-net-jgqm9                        2/2     Running   0          46s
weave-net-vdxns                        2/2     Running   0          46s
```


Next: [Validation](05-Validation.md) or [Add Network Security Group](10-add-nsg.md) or [Add a New Worker Node](11-add-new-node.md)
