# Add Node to Kubernetes Cluster (Kubespray)

In this post we will add a new node to our kubernetes cluster deployed using [Kubespray](/docs/03-Kubespray.md)

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

```shell
Name          ResourceGroup    PowerState    PublicIps      Fqdns    Location       Zones
------------  ---------------  ------------  -------------  -------  -------------  -------
kubernetes-1  kubernetes       VM running    xx.xx.xx.xx             southeastasia
kubernetes-2  kubernetes       VM running    xx.xx.xxx.xxx           southeastasia
kubernetes-3  kubernetes       VM running    xx.xx.xx.xxx            southeastasia
kubernetes-4  kubernetes       VM running    xx.xx.xx.xxx            southeastasia
```

### Installation

We need to perform the pre-requirements on this node before adding it to the cluster. If you are following steps from this project, in the previous post I have added a network security group so SSH to worker nodes can only be done from the control-plane node.

Add the ```kubernetes-4``` public IP to the ```ips.txt``` file.

```shell
az vm show -d -g kubernetes --name kubernetes-4 --query publicIps -o tsv | tr -d [:space:] >> ~/ips.txt
```

Copy the latest ```ips.txt``` file and login to ```Control-Plane``` node to run the below commands.

```shell
{
scp -i kubeadmin_ssh_privatekey.pem ~/ips.txt kubeadmin@$IP1:/home/kubeadmin/
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@$IP1
}
```

```shell
{
cd kubespray
declare -a IPS=($(cat ~/ips.txt | tr '\n' ' '))
declare -a PIPS=(10.240.0.11 10.240.0.12 10.240.0.13 10.240.0.14)
mv inventory/mykubecluster/hosts.yaml inventory/mykubecluster/hosts.yaml.ori
CONFIG_FILE=inventory/mykubecluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${PIPS[@]}
ls -l inventory/mykubecluster/hosts.yaml
for i in 1 2 3 4; do sed -i "s/node$i/kubernetes-$i/g" inventory/mykubecluster/hosts.yaml; done
for i in 0 1 2 3; do sed -i "s/ip: ${IPS[i]}/ip: ${PIPS[i]}/g" inventory/mykubecluster/hosts.yaml; done
sed "/access/d" inventory/mykubecluster/hosts.yaml > inventory/mykubecluster/tmp.yaml
mv inventory/mykubecluster/tmp.yaml inventory/mykubecluster/hosts.yaml
sed '19d;22d;29d;30d' inventory/mykubecluster/hosts.yaml > inventory/mykubecluster/tmp.yaml
mv inventory/mykubecluster/tmp.yaml inventory/mykubecluster/hosts.yaml
}
```

```shell
time ansible-playbook -i inventory/mykubecluster/hosts.yaml scale.yml -b -v \
  --private-key=~/kubeadmin_ssh_privatekey.pem
```
> Output

```shell
PLAY RECAP **************************************************************************************************************************************
kubernetes-1               : ok=39   changed=3    unreachable=0    failed=0    skipped=201  rescued=0    ignored=0
kubernetes-2               : ok=298  changed=9    unreachable=0    failed=0    skipped=465  rescued=0    ignored=0
kubernetes-3               : ok=272  changed=8    unreachable=0    failed=0    skipped=404  rescued=0    ignored=0
kubernetes-4               : ok=299  changed=77   unreachable=0    failed=0    skipped=398  rescued=0    ignored=0
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

Sunday 18 October 2020  08:33:12 +0000 (0:00:00.439)       0:06:58.682 ********
===============================================================================
kubernetes/preinstall : Install packages requirements ----------------------------------------------------------------------------------- 74.83s
container-engine/docker : ensure docker packages are installed -------------------------------------------------------------------------- 56.91s
download : download_container | Download image if required ------------------------------------------------------------------------------ 13.08s
download : download_container | Download image if required ------------------------------------------------------------------------------- 9.94s
download : download_container | Download image if required ------------------------------------------------------------------------------- 8.79s
download : download_container | Download image if required ------------------------------------------------------------------------------- 8.24s
download : download_file | Download item ------------------------------------------------------------------------------------------------- 7.72s
download : download_file | Download item ------------------------------------------------------------------------------------------------- 7.66s
kubernetes/kubeadm : Join to cluster ----------------------------------------------------------------------------------------------------- 6.69s
download : download_container | Download image if required ------------------------------------------------------------------------------- 6.61s
download : download | Download files / images -------------------------------------------------------------------------------------------- 4.86s
Gather necessary facts ------------------------------------------------------------------------------------------------------------------- 4.54s
kubernetes/node : Modprobe Kernel Module for IPVS ---------------------------------------------------------------------------------------- 4.24s
kubernetes/preinstall : Get current version of calico cluster version -------------------------------------------------------------------- 4.09s
download : download_file | Download item ------------------------------------------------------------------------------------------------- 3.83s
network_plugin/calico : Get current version of calico cluster version -------------------------------------------------------------------- 3.71s
download : download | Download files / images -------------------------------------------------------------------------------------------- 3.16s
download : download | Download files / images -------------------------------------------------------------------------------------------- 3.10s
download : download | Download files / images -------------------------------------------------------------------------------------------- 2.84s
download : download_file | Download item ------------------------------------------------------------------------------------------------- 1.84s

real    7m3.106s
user    3m4.874s
sys     1m0.685s

```

### Validation

Run the below command on ```Control-Plane``` node to validate the node was added to cluster.

```shell
kubectl get nodes
```
> Output

```shell
NAME           STATUS   ROLES    AGE     VERSION
kubernetes-1   Ready    master   142m    v1.18.9
kubernetes-2   Ready    <none>   141m    v1.18.9
kubernetes-3   Ready    <none>   141m    v1.18.9
kubernetes-4   Ready    <none>   2m25s   v1.18.9
```

Run the below command to validate ```Daemonsets``` running on the new node.

```shell
kubectl get pods -n kube-system -o wide --sort-by='{.spec.nodeName}'
```
> Output

```shell
NAME                                   READY   STATUS    RESTARTS   AGE     IP            NODE           NOMINATED NODE   READINESS GATES
<---Skipped-Output--->

calico-node-vjcct                             1/1     Running   2          3m47s   10.240.0.14    kubernetes-4   <none>           <none>
kube-proxy-q5g6l                              1/1     Running   0          3m47s   10.240.0.14    kubernetes-4   <none>           <none>
nodelocaldns-qcw2c                            1/1     Running   0          3m47s   10.240.0.14    kubernetes-4   <none>           <none>
```

Next: [Validation](/docs/05-Validation.md) or [Other Add-Ons](/README.md)
