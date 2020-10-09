# Kubernetes-deployments-and-add-ons

This project is to share different ways and methods of deploying kubernetes cluster, deployments and add-ons. This is NOT for people who are looking to learn kubernetes the hard way. You can check out my other project to build [kubernetes-the-hard-way-on-azure](https://github.com/vyasanand/kubernetes-the-hard-way-on-azure).

In this project I have used [Microsoft Azure](https://azure.microsoft.com) to provision the required infrastructure.

### Client Tools

In this project I will be using [MobaXterm](https://mobaxterm.mobatek.net/) to run the Azure CLI. Follow the [documentation](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest&tabs=azure-cli) to Install Azure CLI on Windows.

MobaXterm has local terminal features that allow to run Unix commands on your local Windows computer [Start Local Terminal](https://mobaxterm.mobatek.net/documentation.html#2_2)

In order to quickly provision infra, I have shared Terraform script which can quickly launch VMs on Azure cloud. Most of the environments would be three machine cluster unless there is a requirement in design for HA.

# Deployments

* [Provision Infra on Azure Cloud](docs/01-ProvisionInfra.md)
* [Create a Kubernetes cluster using kubeadm](docs/02-Kubeadm.md)
* [Create a Kubernetes cluster using kubespray](docs/03-Kubespray.md)
* [Install Visualization add-on - Weave Scope](docs/07-Install-Weave-Scope.md)
* [Install Portainer](docs/08-Portainer.md)
* [Deploy an Azure Managed Kubernetes Cluster (AKS) using Terraform](docs/09-AKS.md)
