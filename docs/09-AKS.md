# Deploy a Azure Managed Kubernetes Cluster (AKS) using Terraform

In this demo we will deploy a AKS cluster with three nodes.

## Terraform

If you are using Terraform for the first time follow the steps in the link to [Install Terraform](/docs/01-ProvisionInfra.md#installation)

### Deploy AKS Cluster

Create a directory to download the Terraform configuration file.

```shell
{
mkdir aks
cd aks
}
```
Download the tf file.

```shell
wget https://raw.githubusercontent.com/vyasanand/Kubernetes-deployments-and-add-ons/master/config/deployaks.tf
```
> Verify the file is downloaded

```shell
ls
deployaks.tf
```

Run the below command to initialize Terraform.

```shell
terraform.exe init
```
> Output

```shell
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/azurerm versions matching "~> 2.0"...
- Installing hashicorp/azurerm v2.31.1...
- Installed hashicorp/azurerm v2.31.1 (signed by HashiCorp)

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Run the below command to validate the plan. Change the loc variable to deploy to another location.

```shell
terraform.exe plan -var 'loc=southeastasia'
```
> Output

```shell
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------
<-Omitting some output->

  # azurerm_resource_group.rg will be created
  + resource "azurerm_resource_group" "rg" {
      + id       = (known after apply)
      + location = "southeastasia"
      + name     = "kubernetes"
    }

Plan: 2 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

Run the below command to execute the plan. Change the loc variable to deploy to another location.
It will prompt for input for which enter the value ```yes``` and ```output``` will create a ```kube-config``` file.

```shell
terraform.exe apply -var 'loc=southeastasia'
```
> Output

```shell
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

kube_config = apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0121bsifdibg
 
<-Omitting the kubeconfig output->
```

Run the command ```terraform.exe output kube_config > aks_kubeconfig``` to save the output of ```kubec-config``` to a file

> Output

```shell
ls aks_kubeconfig*
aks_kubeconfig
```

In order to explictly provide the kubeconfig parameter everytime to point aks_kubeconfig file, I will copy the kubeconfig to home directory.
Since I am using ```MobaXTerm``` as my client my ```$home``` points to ```/home/mobaxterm```.

Run the below commands to create a ```.kube``` directory and copy the ```aks_kubeconfig``` file.

```shell
{ 
mkdir ${HOME}/.kube
cp aks_kubeconfig ${HOME}/.kube/config
}
```

### Verification

Run the below command to verify the connectivity to AKS cluster

```shell
kubectl get nodes
```

> Output

```shell
NAME                              STATUS   ROLES   AGE     VERSION
aks-default-12345678-vmss000000   Ready    agent   9m54s   v1.17.11
aks-default-12345678-vmss000001   Ready    agent   9m55s   v1.17.11
aks-default-12345678-vmss000002   Ready    agent   9m34s   v1.17.11
```

### Validation

Run the busybox [validation](/docs/05-Validation.md#validation). Services can be created but not accessible as we haven't provisioned HTTP LB in our cluster.

### Clean up

The following command will delete the `kubernetes` resource group and all related resources created during this tutorial.
Go to the aks directory on run the cmd below.

```shell
terraform.exe destroy -var 'loc=southeastasia'
```
> Output

```shell
Do you really want to destroy all resources?
Terraform will destroy all your managed infrastructure, as shown above.
There is no undo. Only 'yes' will be accepted to confirm.

Enter a value: yes

.
.
Destroy complete! Resources: 2 destroyed.
  
```
