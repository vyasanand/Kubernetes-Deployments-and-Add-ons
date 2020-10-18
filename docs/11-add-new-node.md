# Add Node to Kubernetes Cluster (Kubeadm)

In this post we will add a new node to our kubernetes cluster deployed using [Kubeadm](/docs/02-Kubeadm.md)

### Add a new node

Let's create a new node ```kubernetes-4``` which is exactly same as other worker nodes.

```shell
cd terraform
```

Download the Terraform script to add a new node.

```shell
wget https://raw.githubusercontent.com/vyasanand/Kubernetes-deployments-and-add-ons/master/config/addnewnode.tf
```

Run the below command to validate the plan.

```shell
terraform.exe plan -var 'loc=southeastasia'
```
> Output

```shell
Plan: 4 to add, 0 to change, 0 to destroy.
```

Run the below command to execute the plan and enter ```yes``` when prompted for input.

```shell
terraform.exe apply -var 'loc=southeastasia'
```
> Output

```shell
Plan: 4 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
  .
  . <Skipping the extra part here>
  .
  Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

tls_private_key = -----BEGIN RSA PRIVATE KEY-----
.
<Skipping the extra part here>
```

List the machines to fetch the public Ips

```shell
az vm list -d -g kubernetes -o table
```

> output

```shell
Name          ResourceGroup    PowerState    PublicIps      Fqdns    Location       Zones
------------  ---------------  ------------  -------------  -------  -------------  -------
kubernetes-1  kubernetes       VM running    xx.xx.xx.xx             southeastasia
kubernetes-2  kubernetes       VM running    xx.xx.xxx.xxx           southeastasia
kubernetes-3  kubernetes       VM running    xx.xx.xx.xxx            southeastasia
kubernetes-4  kubernetes       VM running    xx.xx.xx.xxx            southeastasia
```

### Pre-requirements

We need to perform the pre-requirements on this node before adding it to the cluster. If you are following steps from this project, in the previous post I have added a network security group so SSH to worker nodes can only be done from the control-plane node.

Run the below command to copy the private key to ```Control-Plane``` node.

```shell
scp -i kubeadmin_ssh_privatekey.pem kubeadmin_ssh_privatekey.pem kubeadmin@$IP1:/home/kubeadmin/
```

Login to ```Control-Plane``` node and run the below commands.

```shell
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@$IP1
```

```shell
{
chmod 600 kubeadmin_ssh_privatekey.pem
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@10.240.0.14 "hostname -f; \
cat /sys/class/dmi/id/product_uuid; sudo ip link show eth0 | grep link/ether; \
sudo swapoff -a; free -h | grep Swap; sudo modprobe br_netfilter; sudo lsmod | grep br_netfilter; \
sudo sysctl -a | grep net.bridge.bridge-nf-call-iptables; sudo sysctl -a | grep net.bridge.bridge-nf-call-ip6tables"
}
```
> Output

```shell
kubernetes-4.xxxxxxxxxxxxxxx.xx.internal.cloudapp.net
XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
    link/ether 00:0a:3a:ca:aa:0a brd ff:ff:ff:ff:ff:ff
Swap:            0B          0B          0B
br_netfilter           22256  0
bridge                151336  2 br_netfilter,ebtable_broute
sysctl: reading key "net.ipv6.conf.all.stable_secret"
sysctl: reading key "net.ipv6.conf.default.stable_secret"
sysctl: reading key "net.ipv6.conf.eth0.stable_secret"
sysctl: reading key "net.ipv6.conf.lo.stable_secret"
net.bridge.bridge-nf-call-iptables = 1
sysctl: reading key "net.ipv6.conf.all.stable_secret"
sysctl: reading key "net.ipv6.conf.default.stable_secret"
sysctl: reading key "net.ipv6.conf.eth0.stable_secret"
sysctl: reading key "net.ipv6.conf.lo.stable_secret"
net.bridge.bridge-nf-call-ip6tables = 1
```

```shell
{
scp -i kubeadmin_ssh_privatekey.pem /etc/docker/daemon.json kubeadmin@10.240.0.14:/home/kubeadmin/
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@10.240.0.14 "sudo yum install -y yum-utils device-mapper-persistent-data lvm2; \
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo; \
sudo sed -i 's_\$releasever_7_g' /etc/yum.repos.d/docker-ce.repo ; \
sudo yum update -y ; \
sudo yum install -y containerd.io-1.2.13 docker-ce-19.03.11 docker-ce-cli-19.03.11; \
sudo mkdir -p /etc/systemd/system/docker.service.d ; \
sudo mv daemon.json /etc/docker/ ;\
sudo systemctl daemon-reload; \
sudo systemctl enable docker; \
sudo systemctl start docker"
}
```

Validate Docker installation

```shell
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@10.240.0.14 "sudo docker run hello-world"
```
> Output

```shell
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
0e03bdcc26d7: Pulling fs layer
0e03bdcc26d7: Verifying Checksum
0e03bdcc26d7: Download complete
0e03bdcc26d7: Pull complete
Digest: sha256:8c5aeeb6a5f3ba4883347d3747a7249f491766ca1caa47e5da5dfcf6b9b717c0
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

Install kubeadm, kubelet and kubectl

```shell
{
scp -i kubeadmin_ssh_privatekey.pem /etc/yum.repos.d/kubernetes.repo kubeadmin@10.240.0.14:/home/kubeadmin/
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@10.240.0.14 "sudo mv kubernetes.repo /etc/yum.repos.d/ ;\
sudo setenforce 0; \
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config; \
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes; \
sudo systemctl enable --now kubelet; \
sudo systemctl stop firewalld"
}
```

Validate the installation

```shell
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@10.240.0.14 "sudo kubeadm version; \
sudo kubelet --version; \
sudo kubectl version"
```
> Output

```shell
kubeadm version: &version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", GitCommit:"1e11e4a2108024935ecfcb2912226cedeafd99df", GitTreeState:"clean", BuildDate:"2020-10-14T12:47:53Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"linux/amd64"}
Kubernetes v1.19.3
Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", GitCommit:"1e11e4a2108024935ecfcb2912226cedeafd99df", GitTreeState:"clean", BuildDate:"2020-10-14T12:50:19Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"linux/amd64"}
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

Generate the ```kubeadm join``` command.

```shell
kubeadm token create --print-join-command
```
> Output

```shell
kubeadm join xx.xx.xx.xx:6443 --token xxxxxxxxxxxxxxxxxxxx \
    --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxx1111111111111111122222222
```

Run the command on the new node ```kubernetes-4```

```shell
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@10.240.0.14 "sudo kubeadm join xx.xx.xx.xx:6443 --token xxxxxxxxxxxxxxxxxxxx \
    --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxx1111111111111111122222222"
```
> Output

```shell
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

### Validation

Run the below command on ```Control-Plane``` node to validate the node was added to cluster.

```shell
kubectl get nodes
```
> Output

```shell
NAME           STATUS   ROLES    AGE     VERSION
kubernetes-1   Ready    master   6h36m   v1.19.3
kubernetes-2   Ready    <none>   6h34m   v1.19.3
kubernetes-3   Ready    <none>   6h34m   v1.19.3
kubernetes-4   Ready    <none>   81s     v1.19.3
```

Run the below command to validate ```Daemonsets``` running on the new node.

```shell
kubectl get pods -n kube-system -o wide --sort-by='{.spec.nodeName}'
```
> Output

```shell
NAME                                   READY   STATUS    RESTARTS   AGE     IP            NODE           NOMINATED NODE   READINESS GATES
<---Skipped-Output--->

kube-proxy-p9mp6                       1/1     Running   0          6m26s   10.240.0.14   kubernetes-4   <none>           <none>
weave-net-kv5v2                        2/2     Running   1          6m26s   10.240.0.14   kubernetes-4   <none>           <none>
```

Next: [Validation](/docs/05-Validation.md) or [Other Add-Ons](/README.md)
