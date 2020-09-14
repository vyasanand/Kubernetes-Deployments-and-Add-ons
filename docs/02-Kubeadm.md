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
> Run the below steps to validate and perform the required pre-requirements

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
