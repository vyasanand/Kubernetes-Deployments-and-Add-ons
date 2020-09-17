# Create a Kubernetes cluster using kubespray
In this demo we will setup a 3 node Kubernetes cluster using kubespray.

## Pre-requirements

For this demo I have provisioned three machines on Azure cloud. Check the [Provisioning Infrastructure](docs/01-ProvisionInfra.md) page for the steps.

```shell
Component     Hostname
--------------------------
Control-Plane kubernetes-1
Worker-1      kubernetes-2
Worker-2      kubernetes-3
```

#### Hardware and OS
Below are the pre-requirements that we will perform in order to install the cluster without any issues. Check the [kubespray GitHub page](https://github.com/kubernetes-sigs/kubespray#requirements) for detailed list of pre-requirements.

```shell
01) RHEL 7
02) Control Plane node memory: 1.5GB, Worker nodes memory: 1GB
03) Ansible v2.9+, Jinja 2.11+ and python-netaddr is installed on the machine that will run Ansible commands
04) The target servers are configured to allow IPv4 forwarding
05) SSH key to connect to all servers
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
We will be using control-plane node ```kubernetes-1``` as our Ansible host. Fetch the Public IP of the host.

```shell
IP1=`az vm show -d -g kubernetes --name kubernetes-1 --query publicIps -o tsv  | tr -d [:space:]`
```
Copy SSH key to control-plane server ```kubernetes-1```

```shell
scp -i kubeadmin_ssh_privatekey.pem kubeadmin_ssh_privatekey.pem ~/ips.txt kubeadmin@$IP1:/home/kubeadmin
```

Install required packages on the Ansible host ```kubernetes-1```

```shell
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@$IP1 "sudo yum -y install python3 python3-pip git"
```

SSH to the Ansible host ```kubernetes-1``` to perform the remaining steps

```shell
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@$IP1
```

Perform the below steps to clone ```kubespray``` repository and make changes for our cluster.

```shell
{
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
git checkout release-2.14
sudo pip3 install -r requirements.txt
cp -pr inventory/sample inventory/mykubecluster
ls -l inventory/mykubecluster
}
```
> Output

```shell
Cloning into 'kubespray'...
remote: Enumerating objects: 47294, done.
remote: Total 47294 (delta 0), reused 0 (delta 0), pack-reused 47294
Receiving objects: 100% (47294/47294), 14.07 MiB | 1.65 MiB/s, done.
Resolving deltas: 100% (26198/26198), done.
Branch release-2.14 set up to track remote branch release-2.14 from origin.
Switched to a new branch 'release-2.14'
WARNING: Running pip install with root privileges is generally not a good idea. Try `pip3 install --user` instead.
Collecting ansible==2.9.6 (from -r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/ae/b7/c717363f767f7af33d90af9458d5f1e0960db9c2393a6c221c2ce97ad1aa/ansible-2.9.6.tar.gz (14.2MB)
    100% |████████████████████████████████| 14.2MB 78kB/s
Collecting jinja2==2.11.1 (from -r requirements.txt (line 2))
  Downloading https://files.pythonhosted.org/packages/27/24/4f35961e5c669e96f6559760042a55b9bcfcdb82b9bdb3c8753dbe042e35/Jinja2-2.11.1-py2.py3-none-any.whl (126kB)
    100% |████████████████████████████████| 133kB 7.6MB/s
Collecting netaddr==0.7.19 (from -r requirements.txt (line 3))
  Downloading https://files.pythonhosted.org/packages/ba/97/ce14451a9fd7bdb5a397abf99b24a1a6bb7a1a440b019bebd2e9a0dbec74/netaddr-0.7.19-py2.py3-none-any.whl (1.6MB)
    100% |████████████████████████████████| 1.6MB 646kB/s
Collecting pbr==5.4.4 (from -r requirements.txt (line 4))
  Downloading https://files.pythonhosted.org/packages/7a/db/a968fd7beb9fe06901c1841cb25c9ccb666ca1b9a19b114d1bbedf1126fc/pbr-5.4.4-py2.py3-none-any.whl (110kB)
    100% |████████████████████████████████| 112kB 8.7MB/s
Collecting jmespath==0.9.5 (from -r requirements.txt (line 5))
  Downloading https://files.pythonhosted.org/packages/a3/43/1e939e1fcd87b827fe192d0c9fc25b48c5b3368902bfb913de7754b0dc03/jmespath-0.9.5-py2.py3-none-any.whl
Collecting ruamel.yaml==0.16.10 (from -r requirements.txt (line 6))
  Downloading https://files.pythonhosted.org/packages/a6/92/59af3e38227b9cc14520bf1e59516d99ceca53e3b8448094248171e9432b/ruamel.yaml-0.16.10-py2.py3-none-any.whl (111kB)
    100% |████████████████████████████████| 112kB 8.6MB/s
Collecting PyYAML (from ansible==2.9.6->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/64/c2/b80047c7ac2478f9501676c988a5411ed5572f35d1beff9cae07d321512c/PyYAML-5.3.1.tar.gz (269kB)
    100% |████████████████████████████████| 276kB 3.9MB/s
Collecting cryptography (from ansible==2.9.6->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/43/2e/8d2de0d73d177184bc9a15137cd9aae46c1b3a59842b5fde30c8b80a5b4e/cryptography-3.1-cp35-abi3-manylinux1_x86_64.whl (2.6MB)
    100% |████████████████████████████████| 2.6MB 387kB/s
Collecting MarkupSafe>=0.23 (from jinja2==2.11.1->-r requirements.txt (line 2))
  Downloading https://files.pythonhosted.org/packages/b2/5f/23e0023be6bb885d00ffbefad2942bc51a620328ee910f64abe5a8d18dd1/MarkupSafe-1.1.1-cp36-cp36m-manylinux1_x86_64.whl
Collecting ruamel.yaml.clib>=0.1.2; platform_python_implementation == "CPython" and python_version < "3.9" (from ruamel.yaml==0.16.10->-r requirements.txt (line 6))
  Downloading https://files.pythonhosted.org/packages/88/ff/ec25dc01ef04232a9e68ff18492e37dfa01f1f58172e702ad4f38536d41b/ruamel.yaml.clib-0.2.2-cp36-cp36m-manylinux1_x86_64.whl (549kB)
    100% |████████████████████████████████| 552kB 2.0MB/s
Collecting cffi!=1.11.3,>=1.8 (from cryptography->ansible==2.9.6->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/50/ca/bbca0fd95b24a1d4f0d2e016f09f35ae68d4fe72bf34cc538d0a0d2d3e10/cffi-1.14.3-cp36-cp36m-manylinux1_x86_64.whl (400kB)
    100% |████████████████████████████████| 409kB 2.7MB/s
Collecting six>=1.4.1 (from cryptography->ansible==2.9.6->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/ee/ff/48bde5c0f013094d729fe4b0316ba2a24774b3ff1c52d924a8a4cb04078a/six-1.15.0-py2.py3-none-any.whl
Collecting pycparser (from cffi!=1.11.3,>=1.8->cryptography->ansible==2.9.6->-r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/ae/e7/d9c3a176ca4b02024debf82342dab36efadfc5776f9c8db077e8f6e71821/pycparser-2.20-py2.py3-none-any.whl (112kB)
    100% |████████████████████████████████| 112kB 8.5MB/s
Installing collected packages: MarkupSafe, jinja2, PyYAML, pycparser, cffi, six, cryptography, ansible, netaddr, pbr, jmespath, ruamel.yaml.clib, ruamel.yaml
  Running setup.py install for PyYAML ... done
  Running setup.py install for ansible ... done
Successfully installed MarkupSafe-1.1.1 PyYAML-5.3.1 ansible-2.9.6 cffi-1.14.3 cryptography-3.1 jinja2-2.11.1 jmespath-0.9.5 netaddr-0.7.19 pbr-5.4.4 pycparser-2.20 ruamel.yaml-0.16.10 ruamel.yaml.clib-0.2.2 six-1.15.0
drwxrwxr-x. 4 kubeadmin kubeadmin  52 Sep 17 07:26 group_vars
-rw-rw-r--. 1 kubeadmin kubeadmin 994 Sep 17 07:26 inventory.ini
```

We need to build a ```hosts``` file for our ansible playbook. Below commands will create the file and make required changes.

```shell
{
chmod 600 ~/kubeadmin_ssh_privatekey.pem
declare -a IPS=($(cat ~/ips.txt | tr '\n' ' '))
declare -a PIPS=(10.240.0.11 10.240.0.12 10.240.0.13)
CONFIG_FILE=inventory/mykubecluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
ls -l inventory/mykubecluster/hosts.yaml
for i in 1 2 3; do sed -i "s/node$i/kubernetes-$i/g" inventory/mykubecluster/hosts.yaml; done
for i in 0 1 2; do sed -i "s/ip: ${IPS[i]}/ip: ${PIPS[i]}/g" inventory/mykubecluster/hosts.yaml; done
sed "/access/d" inventory/mykubecluster/hosts.yaml > inventory/mykubecluster/tmp.yaml
mv inventory/mykubecluster/tmp.yaml inventory/mykubecluster/hosts.yaml
sed '16d;19d;25d;26d' inventory/mykubecluster/hosts.yaml > inventory/mykubecluster/tmp.yaml
mv inventory/mykubecluster/tmp.yaml inventory/mykubecluster/hosts.yaml
echo "supplementary_addresses_in_ssl_keys: [${IPS[0]}]" >> inventory/mykubecluster/group_vars/k8s-cluster/k8s-cluster.yml
}
```
> Output

```shell
DEBUG: Adding group all
DEBUG: Adding group kube-master
DEBUG: Adding group kube-node
DEBUG: Adding group etcd
DEBUG: Adding group k8s-cluster
DEBUG: Adding group calico-rr
DEBUG: adding host node1 to group all
DEBUG: adding host node2 to group all
DEBUG: adding host node3 to group all
DEBUG: adding host node1 to group etcd
DEBUG: adding host node2 to group etcd
DEBUG: adding host node3 to group etcd
DEBUG: adding host node1 to group kube-master
DEBUG: adding host node2 to group kube-master
DEBUG: adding host node1 to group kube-node
DEBUG: adding host node2 to group kube-node
DEBUG: adding host node3 to group kube-node
-rw-rw-r--. 1 kubeadmin kubeadmin 622 Sep 17 08:39 inventory/mykubecluster/hosts.yaml
```
Run the Ansible playbook to install the cluster.

```shell
time ansible-playbook -i inventory/mykubecluster/hosts.yaml -u kubeadmin -b -v --private-key=~/kubeadmin_ssh_privatekey.pem cluster.yml
```
> Output

```shell
===============================================================================
kubernetes/master : kubeadm | Initialize first master ----------------------------------------------------------------------------------- 28.57s
kubernetes/kubeadm : Join to cluster ---------------------------------------------------------------------------------------------------- 25.10s
kubernetes-apps/ansible : Kubernetes Apps | Start Resources ------------------------------------------------------------------------------ 9.65s
kubernetes-apps/ansible : Kubernetes Apps | Lay Down CoreDNS Template -------------------------------------------------------------------- 6.97s
etcd : wait for etcd up ------------------------------------------------------------------------------------------------------------------ 5.54s
kubernetes/preinstall : Install packages requirements ------------------------------------------------------------------------------------ 5.41s
download : download | Download files / images -------------------------------------------------------------------------------------------- 5.34s
etcd : Configure | Check if etcd cluster is healthy -------------------------------------------------------------------------------------- 5.30s
kubernetes/preinstall : Get current version of calico cluster version -------------------------------------------------------------------- 4.09s
Gather necessary facts ------------------------------------------------------------------------------------------------------------------- 3.97s
network_plugin/calico : Get current version of calico cluster version -------------------------------------------------------------------- 3.75s
network_plugin/calico : Start Calico resources ------------------------------------------------------------------------------------------- 3.66s
container-engine/docker : ensure docker packages are installed --------------------------------------------------------------------------- 3.61s
network_plugin/calico : Calico | Create calico manifests --------------------------------------------------------------------------------- 3.55s
download : download | Download files / images -------------------------------------------------------------------------------------------- 3.30s
download : download | Download files / images -------------------------------------------------------------------------------------------- 3.03s
policy_controller/calico : Create calico-kube-controllers manifests ---------------------------------------------------------------------- 2.93s
download : download | Download files / images -------------------------------------------------------------------------------------------- 2.84s
download : download | Download files / images -------------------------------------------------------------------------------------------- 2.78s
download : download | Download files / images -------------------------------------------------------------------------------------------- 2.77s
```
> Make sure there are no failures from the above execution

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
NAME           STATUS   ROLES    AGE     VERSION
kubernetes-1   Ready    master   6m20s   v1.18.8
kubernetes-2   Ready    <none>   5m16s   v1.18.8
kubernetes-3   Ready    <none>   5m16s   v1.18.8
```
