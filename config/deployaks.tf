provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you're using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
}

# Store run time parameter in loc variable
variable "loc" {
    type = string
}

# Variable to prepend every resource
variable "name" {
  type = string
  default = "kubernetes"
}

# Define resource group name
resource "azurerm_resource_group" "rg" {
    name = var.name
    location= var.loc
}

# Create Kubernetes cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = var.loc
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.name

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
 
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}
