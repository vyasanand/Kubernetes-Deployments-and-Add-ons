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
NAME                       READY   STATUS              RESTARTS   AGE
weave-net-kfsb9            2/2     Running             0          110s
weave-net-vsc25            2/2     Running             0          110s
```


Next: [Validation](05-Validation.md)
