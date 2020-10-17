resource "azurerm_network_security_group" "control-nsg" {
  name                = "${var.name}-control-plane-nsg"
  location            = var.loc
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Kubernetes_API_Server"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

security_rule {
    name                       = "ETCD_Server_Client_API"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "2379-2380"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "Kubelet_API_Kube_Scheduler_Kube_Controller_Manager"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "10250-10252"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

   security_rule {
    name                       = "SSH_Access"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
    }


  tags = {
    node = "Control-Plane"
  }
}

resource "azurerm_network_security_group" "worker-nsg" {
  name                = "${var.name}-worker-nsg"
  location            = var.loc
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Kubelet_API"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "10250"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

security_rule {
    name                       = "Node_Port_Service_Range"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "30000-32767"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

   tags = {
    node = "Worker"
  }
}

resource "azurerm_network_interface_security_group_association" "control-plane-nsg-assoc" {
network_interface_id      = azurerm_network_interface.kubernetes_nic[0].id
network_security_group_id = azurerm_network_security_group.control-nsg.id
}

resource "azurerm_network_interface_security_group_association" "worker-nsg-assoc" {
count = 2
network_interface_id      = azurerm_network_interface.kubernetes_nic[count.index+1].id
network_security_group_id = azurerm_network_security_group.worker-nsg.id
}
                   