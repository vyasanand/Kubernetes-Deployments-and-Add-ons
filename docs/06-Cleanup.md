# Cleaning Up

The following command will delete the `kubernetes` resource group and all related resources created during this tutorial.
Go to the Terraform directory on run the cmd below.

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
Destroy complete! Resources: 13 destroyed.
  
```
