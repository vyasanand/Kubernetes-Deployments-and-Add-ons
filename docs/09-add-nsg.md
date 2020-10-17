# Add Network Security Group

If you have deployed Azure infra using [Terraform script](docs/01-ProvisionInfra.md) as part of this project, you might have noticed there is no security group attached to kubernetes-vnet.
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
PPlan: 5 to add, 0 to change, 0 to destroy.

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

Run the kubernetes [validation](https://github.com/vyasanand/Kubernetes-deployments-and-add-ons/blob/master/docs/05-Validation.md#validation)



