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

# Login username for every machine
variable "admin_username" {
  type = string
  default = "kubeadmin"
}

# Define resource group name
resource "azurerm_resource_group" "rg" {
    name = var.name
    location= var.loc
}

# Define virtual network
resource "azurerm_virtual_network" "vnet" {
      name= "${var.name}-vnet"
      address_space = ["10.240.0.0/24"]
      location=var.loc
      resource_group_name = azurerm_resource_group.rg.name
  }

# Define subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.name}-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.240.0.0/24"]

}

# Create ssh keys
resource "tls_private_key" "kubeadmin_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Display private key at console
output "tls_private_key" { value = "${tls_private_key.kubeadmin_ssh.private_key_pem}" }

# Create 3 public ips to assign to NIC
resource "azurerm_public_ip" "kubernetes_pip" {
  count               = 3
  name                = "${azurerm_resource_group.rg.name}-${count.index+1}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  location            = var.loc
  sku                 = "Basic"
}

# Create 3 NIC to assign to VM
resource "azurerm_network_interface" "kubernetes_nic" {
  count               = 3
  name                = "${azurerm_resource_group.rg.name}-${count.index+1}-nic"
  location            = var.loc
  resource_group_name = azurerm_resource_group.rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "${azurerm_resource_group.rg.name}-${count.index+1}-nic"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.240.0.1${count.index+1}"
    public_ip_address_id          = azurerm_public_ip.kubernetes_pip[count.index].id
    
  }
}

# Create 3 VMs
resource "azurerm_linux_virtual_machine" "kubernetes-vm" {
  count = 3
  name = "${azurerm_resource_group.rg.name}-${count.index+1}"
  location = var.loc
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [
    azurerm_network_interface.kubernetes_nic[count.index].id,
  ]
   size = "Standard_D2S_v3"

   os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  
  source_image_reference {
    publisher = "redhat"
    offer     = "RHEL"
    sku       = "7.8" 
    version   = "latest"
  }
 
  computer_name  = "${azurerm_resource_group.rg.name}-${count.index+1}"
  admin_username = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
        username       = var.admin_username
        public_key     = tls_private_key.kubeadmin_ssh.public_key_openssh
    }

}
