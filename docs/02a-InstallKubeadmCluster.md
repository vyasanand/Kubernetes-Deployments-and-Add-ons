#### Install kubeadm, kubelet and kubectl

```shell
cat > ~/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
```
```shell
for ip in `cat ~/ips.txt`
do
scp -i kubeadmin_ssh_privatekey.pem ~/kubernetes.repo kubeadmin@$ip:/tmp
done
```
```shell
for ip in `cat ~/ips.txt`
do
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@$ip "sudo mv /tmp/kubernetes.repo /etc/yum.repos.d/ ;\
sudo setenforce 0; \
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config; \
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes; \
sudo systemctl enable --now kubelet; \
sudo systemctl stop firewalld"
done
```
Validate the installation

```shell
for ip in `cat ~/ips.txt`
do ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@$ip "sudo kubeadm version; \
sudo kubelet --version; \
sudo kubectl version"
done
```
> Output

```shell
X11 forwarding request failed on channel 0
kubeadm version: &version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", GitCommit:"1e11e4a2108024935ecfcb2912226cedeafd99df", GitTreeState:"clean", BuildDate:"2020-10-14T12:47:53Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"linux/amd64"}
Kubernetes v1.19.3
Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", GitCommit:"1e11e4a2108024935ecfcb2912226cedeafd99df", GitTreeState:"clean", BuildDate:"2020-10-14T12:50:19Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"linux/amd64"}
The connection to the server localhost:8080 was refused - did you specify the right host or port?
X11 forwarding request failed on channel 0
kubeadm version: &version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", GitCommit:"1e11e4a2108024935ecfcb2912226cedeafd99df", GitTreeState:"clean", BuildDate:"2020-10-14T12:47:53Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"linux/amd64"}
Kubernetes v1.19.3
Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", GitCommit:"1e11e4a2108024935ecfcb2912226cedeafd99df", GitTreeState:"clean", BuildDate:"2020-10-14T12:50:19Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"linux/amd64"}
The connection to the server localhost:8080 was refused - did you specify the right host or port?
X11 forwarding request failed on channel 0
kubeadm version: &version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", GitCommit:"1e11e4a2108024935ecfcb2912226cedeafd99df", GitTreeState:"clean", BuildDate:"2020-10-14T12:47:53Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"linux/amd64"}
Kubernetes v1.19.3
Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", GitCommit:"1e11e4a2108024935ecfcb2912226cedeafd99df", GitTreeState:"clean", BuildDate:"2020-10-14T12:50:19Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"linux/amd64"}
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

#### Initialize Control Plane

In our environment, we will consider ```kubernetes-1``` as our control plane server and ```kubernetes-2``` and ```kubernetes-3``` as worker nodes
Run the below command to get the public IP for our control plane server and SSH to the server.

```shell
IP1=`az vm show -d -g kubernetes --name kubernetes-1 --query publicIps -o tsv  | tr -d [:space:]`
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@$IP1
```

```shell
[kubeadmin@kubernetes-1 ~]$ sudo kubeadm init
```
> Output

```shell
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join xx.xx.xx.xx:6443 --token xxxxxxxxxxxxxxxxxxxx \
    --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxx1111111111111111122222222
```

Copy the kubeadm join token to a text file. We will need this token to run on worker nodes.
Run the below commands to use the cluster as ```kubeadmin``` user.

```shell
{
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
}
```

Validate using the below command.

```shell
kubectl get nodes
```
> Output

```shell
NAME           STATUS     ROLES    AGE    VERSION
kubernetes-1   NotReady   master   5m3s   v1.19.3
```

Run the below commands to get the public IPs for our worker nodes.

```shell
worker1=`az vm show -d -g kubernetes --name kubernetes-2 --query publicIps -o tsv  | tr -d [:space:]`
worker2=`az vm show -d -g kubernetes --name kubernetes-3 --query publicIps -o tsv  | tr -d [:space:]`
```

Run the below command to join the worker nodes to the cluster.

```shell
for ip in $worker1 $worker2
do
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@$ip "sudo kubeadm join xx.xx.xx.xx:6443 --token xxxxxxxxxxxxxxxxxxxx \
    --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxx1111111111111111122222222 "
done
```
> Output

```shell
X11 forwarding request failed on channel 0
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

X11 forwarding request failed on channel 0
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

Run the below command on control-plane server to validate.

```shell
kubectl get nodes
```
> Output

```shell
NAME           STATUS     ROLES    AGE    VERSION
kubernetes-1   NotReady   master   11m    v1.19.3
kubernetes-2   NotReady   <none>   105s   v1.19.3
kubernetes-3   NotReady   <none>   95s    v1.19.3
```
> Dont worry about the ```NotReady``` status. We are yet to install a network add-on.

Next Step: [Deploy Networking Add-on](04-Deploy-network-add-on.md)
