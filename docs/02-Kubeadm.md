# Create a Kubernetes cluster using kubeadm
In this demo we will setup a 3 node Kubernetes cluster using kubeadm

## Pre-requirements

#### Hardware and OS
Below are the pre-requirements that we will perform in order to install the cluster without any issues. Check the [kubernetes offical guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) for detailed list of pre-requirements.

```shell
01) RHEL 7
02) 2GB+ of RAM per machine
03) 2CPUs or more per machine
04) Full network connectivity between all machines in the cluster
05) Unique hostname, MAC address, and product_uuid for every node
06) Certain ports are open on your machines (Current setup has no restrictions on the ports, not recommended for prod)
07) Swap disabled
08) Verify br_netfilter module is loaded
09) Linux nodes iptables to correctly see bridged traffic
10) Installing Runtime (We will use Docker as our container runtime)
```
Run the below steps to validate and perform the required pre-requirements

```shell
for i in 1 2 3; \
do \
az vm show -d -g kubernetes --name kubernetes-$i --query publicIps -o tsv | tr -d [:space:] >> ~/ips.txt; \
echo " " >> ~/ips.txt; \
done
```
```shell
for ip in `cat ~/ips.txt`
do
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@$ip "cat /etc/redhat-release;free -g;lscpu | grep ^CPU"
done
```
> Output

```shell
X11 forwarding request failed on channel 0
Red Hat Enterprise Linux Server release 7.8 (Maipo)
              total        used        free      shared  buff/cache   available
Mem:              7           0           5           0           1           6
Swap:             0           0           0
CPU op-mode(s):        32-bit, 64-bit
CPU(s):                2
CPU family:            6
CPU MHz:               2095.194
X11 forwarding request failed on channel 0
Red Hat Enterprise Linux Server release 7.8 (Maipo)
              total        used        free      shared  buff/cache   available
Mem:              7           0           5           0           1           6
Swap:             0           0           0
CPU op-mode(s):        32-bit, 64-bit
CPU(s):                2
CPU family:            6
CPU MHz:               2095.193
X11 forwarding request failed on channel 0
Red Hat Enterprise Linux Server release 7.8 (Maipo)
              total        used        free      shared  buff/cache   available
Mem:              7           0           7           0           0           7
Swap:             0           0           0
CPU op-mode(s):        32-bit, 64-bit
CPU(s):                2
CPU family:            6
CPU MHz:               2095.078
```

```shell
for ip in `cat ~/ips.txt`
do
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@$ip "hostname -f; \
cat /sys/class/dmi/id/product_uuid; sudo ip link show eth0 | grep link/ether; \
sudo swapoff -a; free -h | grep Swap; sudo modprobe br_netfilter; sudo lsmod | grep br_netfilter; \
sudo sysctl -a | grep net.bridge.bridge-nf-call-iptables; sudo sysctl -a | grep net.bridge.bridge-nf-call-ip6tables"
done
```
> Output

```shell
X11 forwarding request failed on channel 0
kubernetes-1.xxxxxxxxxxxxxxx.xx.internal.cloudapp.net
XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
    link/ether 00:0a:3a:ca:aa:0a brd ff:ff:ff:ff:ff:ff
Swap:            0B          0B          0B
br_netfilter           22256  0
bridge                151336  2 br_netfilter,ebtable_broute
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
X11 forwarding request failed on channel 0
kubernetes-2.xxxxxxxxxxxxxxx.xx.internal.cloudapp.net
XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
    link/ether 00:0c:aa:d7:xx:xx brd ff:ff:ff:ff:ff:ff
Swap:            0B          0B          0B
br_netfilter           22256  0
bridge                151336  2 br_netfilter,ebtable_broute
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
X11 forwarding request failed on channel 0
kubernetes-3.xxxxxxxxxxxxxxx.xx.internal.cloudapp.net
XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
    link/ether 00:0c:aa:d7:yy:yy brd ff:ff:ff:ff:ff:ff
Swap:            0B          0B          0B
br_netfilter           22256  0
bridge                151336  2 br_netfilter,ebtable_broute
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
```
Install the container run-time. We will be using ```Docker```

```shell
cat > ~/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

```
```shell
for ip in `cat ~/ips.txt`
do
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@$ip "sudo yum install -y yum-utils device-mapper-persistent-data lvm2; \
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo; \
sudo yum update -y ; \
sudo yum install -y containerd.io-1.2.13 docker-ce-19.03.11 docker-ce-cli-19.03.11; \
sudo mkdir -p /etc/systemd/system/docker.service.d"
done
```

If you see below issue after running the above command, its a known issue: [CentOS 7/RHEL 7 installations broken](https://github.com/docker/for-linux/issues/1111)

```shell
failure: repodata/repomd.xml from docker-ce-stable: [Errno 256] No more mirrors to try.
https://download.docker.com/linux/centos/7Server/x86_64/stable/repodata/repomd.xml: [Errno 14] HTTPS Error 404 - Not Found
Loaded plugins: langpacks, product-id, search-disabled-repos
https://download.docker.com/linux/centos/7Server/x86_64/stable/repodata/repomd.xml: [Errno 14] HTTPS Error 404 - Not Found
Trying other mirror.
```

To fix it run the below command and run the original command again.

```shell
for ip in `cat ~/ips.txt`
do
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@$ip "sudo sed -i 's_\$releasever_7_g' /etc/yum.repos.d/docker-ce.repo"
done
```

```shell
for ip in `cat ~/ips.txt`
do
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@$ip "sudo yum install -y yum-utils device-mapper-persistent-data lvm2; \
sudo yum update -y ; \
sudo yum install -y containerd.io-1.2.13 docker-ce-19.03.11 docker-ce-cli-19.03.11; \
sudo mkdir -p /etc/systemd/system/docker.service.d"
done
```

```shell
for ip in `cat ~/ips.txt`
do
scp -i kubeadmin_ssh_privatekey.pem ~/daemon.json kubeadmin@$ip:/tmp
done
```
```shell
for ip in `cat ~/ips.txt`
do
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@$ip "sudo mv /tmp/daemon.json /etc/docker/ ;\
sudo systemctl daemon-reload; \
sudo systemctl enable docker; \
sudo systemctl start docker"
done
```
Validate Docker installation

```shell
for ip in `cat ~/ips.txt`
do
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@$ip "sudo docker run hello-world"
done
```
> Output

```shell
X11 forwarding request failed on channel 0
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
0e03bdcc26d7: Pulling fs layer
0e03bdcc26d7: Download complete
0e03bdcc26d7: Pull complete
Digest: sha256:4cf9c47f86df71d48364001ede3a4fcd85ae80ce02ebad74156906caff5378bc
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
...
....
```
> You should see similar output three times

Next Step: [Install Cluster](02a-InstallKubeadmCluster.md)
