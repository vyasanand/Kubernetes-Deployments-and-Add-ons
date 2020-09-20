# Install Portainer

## Pre-requirements

To install [Portainer](https://www.portainer.io/) add-on you will need a working Kubernetes cluster. Supported versions are 1.16, 1.17 and 1.18 only. You can follow the steps here to install a cluster using [Kubespray](03-Kubespray.md)

## Installation

To install Portainer, we can use [Helm](https://helm.sh/) or manifest files.

#### Helm Package Manager

To use Helm we need to install it first on the kubernetes cluster. Run the below command to install Helm on ```kubernetes-1``` node.

```shell
{
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
}
```
> Output

```shell
Downloading https://get.helm.sh/helm-v3.3.3-linux-amd64.tar.gz
Verifying checksum... Done.
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm
```
> Validate by checking the version

```shell
helm version
```
> Output

```shell
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/kubeadmin/.kube/config
version.BuildInfo{Version:"v3.3.3", GitCommit:"55e3ca022e40fe200fbc855938995f40b2a68ce0", GitTreeState:"clean", GoVersion:"go1.14.9"}
```

Add the Helm repo for Portainer

```shell
{
helm repo add portainer https://portainer.github.io/k8s/
helm repo update
}
```
> Output

```shell
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "portainer" chart repository
Update Complete. ⎈Happy Helming!⎈
```

Create a portainer pv and pvc manifest file. We will use this as for storage later instead of the default deployed pvc.

```shell
cat << EOF > ~/pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: portainer
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/data"
EOF
```
```shell
cat << EOF > ~/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: portainer
  namespace: portainer
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
```

Create a namespace Portainer and deploy it.

```shell
{
kubectl create namespace portainer
helm install -n portainer portainer portainer/portainer
}
```
> Output

```shell
namespace/portainer created
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/kubeadmin/.kube/config
NAME: portainer
LAST DEPLOYED: Sun Sep 20 07:01:54 2020
NAMESPACE: portainer
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export NODE_PORT=$(kubectl get --namespace portainer -o jsonpath="{.spec.ports[0].nodePort}" services portainer)
  export NODE_IP=$(kubectl get nodes --namespace portainer -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT
```

If you check the pvc deployed by default using portainer will be in ```pending``` state.

```shell
kubectl get pvc -n portainer
```
> Output

```shell
NAME        STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
portainer   Pending                                                     23s
```

Delete the above pvc and deploy the pv and pvc created earlier.

```shell
{
kubectl delete pvc -n portainer portainer
kubectl apply -f ~/pv.yaml
kubectl apply -f ~/pvc.yaml
}
```
> Output

```shell
persistentvolumeclaim "portainer" deleted
persistentvolume/portainer created
persistentvolumeclaim/portainer created
```

Validate that the claim is bound to pv

```shell
kubectl get pvc -n portainer portainer
```
> Output

```shell
NAME        STATUS   VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS   AGE
portainer   Bound    portainer   1Gi        RWO            manual         58s
```
Run the below command to vaidate all the portainer components are deployed and pods are in running state.

```shell
kubectl get -n portainer all
```
> Output

```shell
NAME                             READY   STATUS    RESTARTS   AGE
pod/portainer-5d544b9f6b-hlw6m   1/1     Running   0          7m36s

NAME                TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)                         AGE
service/portainer   NodePort   xx.xxx.xxx.xx   <none>        9000:30777/TCP,8000:30776/TCP   7m36s

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/portainer   1/1     1            1           7m36s

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/portainer-5d544b9f6b   1         1         1       7m36s
```
Run the below command to get the node on which the pod is running and port on which the service is exposed

```shell
{
kubectl get pods -n portainer -o jsonpath="{.items[*].spec.nodeName}"
kubectl get --namespace portainer -o jsonpath="{.spec.ports[0].nodePort}" services portainer
}
```
> Output

```shell
kubernetes-230777
```
> In your cluster the node and port could be different from above output

Fetch the public IP for kubernetes-2 node as our pod is running on it

```shell
az vm show -d -g kubernetes --name kubernetes-2 --query publicIps -o tsv
```

In the browser enter the IP address fetched from above command and NodePort fetched from the weave-scope-app service.

> `https://<kubernetes-2-host-ip-here>:30777`


