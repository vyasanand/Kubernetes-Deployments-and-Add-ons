resource "azurerm_public_ip" "kubernetes_pip_4" {
  name                = "${azurerm_resource_group.rg.name}-4-pip"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  location            = var.loc
  sku                 = "Basic"
}

resource "azurerm_network_interface" "kubernetes_nic_4" {
  name                = "${azurerm_resource_group.rg.name}-4-nic"
  location            = var.loc
  resource_group_name = azurerm_resource_group.rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "${azurerm_resource_group.rg.name}-4-nic"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.240.0.14"
    public_ip_address_id          = azurerm_public_ip.kubernetes_pip_4.id
    
  }
}

resource "azurerm_linux_virtual_machine" "kubernetes-vm-4" {
  name = "${azurerm_resource_group.rg.name}-4"
  location = var.loc
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [
    azurerm_network_interface.kubernetes_nic_4.id,
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
 
  computer_name  = "${azurerm_resource_group.rg.name}-4"
  admin_username = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
        username       = var.admin_username
        public_key     = tls_private_key.kubeadmin_ssh.public_key_openssh
    }

}

resource "azurerm_network_interface_security_group_association" "worker-3" {
network_interface_id      = azurerm_network_interface.kubernetes_nic_4.id
network_security_group_id = azurerm_network_security_group.worker-nsg.id
}