# Provisioning Infrastructure

To install Kubernetes we need to provision virtual machines which will host the control plane and worker components. In this demo, I will be using [Microsoft Azure](https://azure.microsoft.com) cloud. You can provision your own VMs on any of the cloud provider or local machine.

## Terraform
In order to quickly provision infra on Azure, I have created a [Terraform](https://www.terraform.io/downloads.html) script that will provision 3 VMs.

### Installation
Download [Terraform](https://www.terraform.io/downloads.html) and [Install](https://learn.hashicorp.com/tutorials/terraform/install-cli) the binary.
Add the appropiate environment variables as per the installation video.

> Validate the installation by checking the version

```shell
terraform.exe --version
```
> Output

```shell
Terraform v0.13.2
```
### Deploy Infra
Create a directory to download the Terraform configuration file.

```shell
{
mkdir terraform
cd terraform
}
```
Download the tf file.

```shell
wget https://github.com/vyasanand/Kubernetes-add-ons-and-deployments/blob/master/config/deployazureinfra.tf
```
> Verify the file is downloaded

```shell
ls
deployazureinfra.tf
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
- Finding latest version of hashicorp/tls...
- Installing hashicorp/azurerm v2.27.0...
- Installed hashicorp/azurerm v2.27.0 (signed by HashiCorp)
- Installing hashicorp/tls v2.2.0...
- Installed hashicorp/tls v2.2.0 (signed by HashiCorp)

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, we recommend adding version constraints in a required_providers block
in your configuration, with the constraint strings suggested below.

* hashicorp/tls: version = "~> 2.2.0"

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
Plan: 13 to add, 0 to change, 0 to destroy.
Changes to Outputs:
  + tls_private_key = (known after apply)
```

Run the below command to execute the plan. Change the loc variable to deploy to another location.
It will prompt for input for which enter the value ```yes``` and ```output``` will create a ```private-key```.

```shell
terraform.exe apply -var 'loc=southeastasia'
```
> Output

```shell
Plan: 13 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + tls_private_key = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
. 
. <Skipping the extra part here>
.
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:

tls_private_key = -----BEGIN RSA PRIVATE KEY-----
MIIJKQIBAAKCAgEA1FNtwMtT/AgSaUYvep4h6j83UUvOCcz/rH3W8KyjgaAKtcX8
uU71egvVWP3Ji4w6vyX3uo7OD8IfsIyMgk95UXPxjfspvUOKcRqG+mF0T/zXea22
0XpLS/4Y6lkllH76E8rzWwOfeOIw8ko9PEg6vQ1QMBIifTx9M1KKhrZwrKkzH+ra
a922Ka4yF9yVWyMZ+bFM189oRw48+qa7br7bDOmEDmOKmuoWh41qa4Mzpvuy59q9
dRfRpru3sGH0zIkp/a1aCBHx4wa9Dz3Ku3KxuifzW8ax81bC7BFGA+id+Uck5Dmd
J+GW0V373oLNywuWpWVbzh39UAZ6EWRGVes8hf9Zs48CggEBANYCFIG7dEXdMKTA
5RXjt25rdURfXq6UrBpYzjjvCylmz/ZBoTvx5cFbQ5o6n7hnpR9pN27dHRGM3ezo
rQ2R1Q8pd6PWEqtRAMDuKyLr6p83uwOwIhZ3fyPdi/anUu4ufuumP4SZHY8yNRYW
yL+k1o2Q/0XoeQp3XjUUM++XM8fR7V0xVtmUorDmgqJI+yH2q/iqFAgb7sZswpdK
-----END RSA PRIVATE KEY-----
```

Copy the private key starting from ```-----BEGIN RSA PRIVATE KEY-----``` till ```-----END RSA PRIVATE KEY-----``` into a file ```kubeadmin_ssh_privatekey.pem```.This key will be used to login to VMs.

> Output

```shell
ls kubeadmin_ssh*
kubeadmin_ssh_privatekey.pem
```
### Verification

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
```

```shell
for i in 1 2 3; \
do \
az vm show -d -g kubernetes --name kubernetes-$i --query publicIps -o tsv | tr -d [:space:] >> ~/ips.txt; \
echo " " >> ~/ips.txt; \
done
```

SSH to the machines using private key we have saved in above step

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
X11 forwarding request failed on channel 0
kubernetes-2
X11 forwarding request failed on channel 0
kubernetes-3
```

