terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.58.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "50818730-e898-4bc4-bc35-d998af53d719"
}

resource "azurerm_resource_group" "myRG" {
  name     = "myRG"
  location = "West Europe"
}
resource "azurerm_virtual_network" "myVNet" {
  name                = "myVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myRG.location
  resource_group_name = azurerm_resource_group.myRG.name
}

resource "azurerm_subnet" "mySubnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.myRG.name
  virtual_network_name = azurerm_virtual_network.myVNet.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_network_security_group" "myNSG" {
  name                = "myNSG"
  location            = azurerm_resource_group.myRG.location
  resource_group_name = azurerm_resource_group.myRG.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "myPublicIP" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.myRG.location
  resource_group_name = azurerm_resource_group.myRG.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "myNIC" {
  name                = "myNIC"
  location            = azurerm_resource_group.myRG.location
  resource_group_name = azurerm_resource_group.myRG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mySubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myPublicIP.id
  }

}

resource "azurerm_network_interface_security_group_association" "myNICNSG" {
  network_interface_id      = azurerm_network_interface.myNIC.id
  network_security_group_id = azurerm_network_security_group.myNSG.id
}

resource "azurerm_linux_virtual_machine" "myVM" {
  name                            = "myVM"
  resource_group_name             = azurerm_resource_group.myRG.name
  location                        = azurerm_resource_group.myRG.location
  size                            = "Standard_B1s"
  admin_username                  = "azureuser"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.myNIC.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

output "ssh_command" {
  value = "ssh ${azurerm_linux_virtual_machine.myVM.admin_username}@${azurerm_public_ip.myPublicIP.ip_address}"
  description = "SSH command to connect to the VM"
}