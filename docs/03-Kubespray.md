# Create a Kubernetes cluster using kubespray
In this demo we will setup a 3 node Kubernetes cluster using kubespray

## Pre-requirements

#### Hardware and OS
Below are the pre-requirements that we will perform in order to install the cluster without any issues. Check the [kubespray GitHub page](https://github.com/kubernetes-sigs/kubespray#requirements) for detailed list of pre-requirements.

```shell
01) RHEL 7
02) Control Plane node memory: 1.5GB, Worker nodes memory: 1GB
03) Ansible v2.9+, Jinja 2.11+ and python-netaddr is installed on the machine that will run Ansible commands
04) The target servers are configured to allow IPv4 forwarding
05) Your ssh key must be copied to all the servers part of your inventory
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

Copy SSH key to each server

```shell
for ip in `cat ~/ips.txt`
do
scp -i kubeadmin_ssh_privatekey.pem kubeadmin_ssh_privatekey.pem kubeadmin@$ip:/home/kubeadmin
done
```
> Output

```shell
kubeadmin_ssh_privatekey.pem                                                                                   100% 3244   321.8KB/s   00:00
kubeadmin_ssh_privatekey.pem                                                                                   100% 3244   401.5KB/s   00:00
kubeadmin_ssh_privatekey.pem                                                                                   100% 3244   353.4KB/s   00:00
```

We will be using control-plane node ```kubernetes-1``` as our Ansible host. Fetch the Public IP of the host.

```shell

```
