# Add Network Security Group

If you have deployed Azure infra using [Terraform script](/docs/01-ProvisionInfra.md) as part of this project, you might have noticed there is no security group attached to kubernetes-vnet.
While this setup works fine for learning or development environment, it's always a best practice to secure the cluster.

In this post we will add ```Network Security Group (nsg) ``` to our deployed infra on Azure.

### Required Ports

We require following ports to be opened for kubernetes cluster to work.

```Control-Plane node```

![Control Plane Node](/config/control_plane_ports.PNG)

```Worker node```

![Worker Node](/config/worker_node_ports.PNG)

Source: [Check required ports](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports)

### Deploy Network Security Group

Go to the [Terraform directory](https://github.com/vyasanand/Kubernetes-deployments-and-add-ons/blob/master/docs/01-ProvisionInfra.md#deploy-infra) we had created during the ```Deploy Infra``` step.

```shell
{
cd terraform
ls
}
```
> Output

```shell
deployazureinfra.tf    terraform.tfstate.backup
kubeadmin_ssh_privatekey.pem  terraform.tfstate
```

Download the ```nsg``` Terraform configuration file to this directory.

```shell
wget https://raw.githubusercontent.com/vyasanand/Kubernetes-deployments-and-add-ons/master/config/nsg.tf
```

Run the below command to validate the plan.

```shell
terraform.exe plan -var 'loc=southeastasia'
```
> Output

```shell
Plan: 5 to add, 0 to change, 0 to destroy.
```

Run the below command to execute the plan and enter ```yes``` when prompted for input.

```shell
terraform.exe apply -var 'loc=southeastasia'
```
> Output

```shell
Plan: 5 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
  .
  . <Skipping the extra part here>
  .
  Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

tls_private_key = -----BEGIN RSA PRIVATE KEY-----
.
<Skipping the extra part here>
```

### Validation

Run the below command to list the nsg rules.

```shell
{
az network nsg rule list -g kubernetes --nsg-name kubernetes-control-plane-nsg \
--query "[].{Name:name, Direction:direction, Priority:priority, Port:destinationPortRange}" -o table
az network nsg rule list -g kubernetes --nsg-name kubernetes-worker-nsg \
--query "[].{Name:name, Direction:direction, Priority:priority, Port:destinationPortRange}" -o table
}
```
> Output

```shell
Name                                                Direction    Priority    Port
--------------------------------------------------  -----------  ----------  -----------
Kubelet_API_Kube_Scheduler_Kube_Controller_Manager  Inbound      120         10250-10252
SSH_Access                                          Inbound      130         22
Kubernetes_API_Server                               Inbound      100         6443
ETCD_Server_Client_API                              Inbound      110         2379-2380
Name                     Direction    Priority    Port
-----------------------  -----------  ----------  -----------
Node_Port_Service_Range  Inbound      110         30000-32767
Kubelet_API              Inbound      100         10250
```

Run the below command to validate SSH connectivity to the hosts.

```shell
for ip in `cat ~/ips.txt`
do
ssh -i kubeadmin_ssh_privatekey.pem kubeadmin@$ip "hostname -s"
done
```
> Output

```shell
X11 forwarding request failed on channel 0
kubernetes-1
ssh: connect to host 52.139.198.193 port 22: Connection timed out
ssh: connect to host 52.139.198.189 port 22: Connection timed out
```

As expected you can only connect via SSH to ```Control-Plane node```. You can access ```Worker nodes``` from it.

Next: Run the [validation](https://github.com/vyasanand/Kubernetes-deployments-and-add-ons/blob/master/docs/05-Validation.md#validation) on kubernetes cluster to make sure ```nsg``` deployment doesn't cause any impact.


