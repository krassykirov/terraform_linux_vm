# https://docs.microsoft.com/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure
# terraform plan -out terraform_azure.tfplan 
# terraform apply terraform_azure.tfplan

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.61.0"
    }
  }
}

provider "azurerm" {
   subscription_id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
   client_id       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
   client_secret   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
   tenant_id       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
features {}
}

# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = "TerraformRG"
  location = "West Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet_name" {
  name                = "TNET"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

 subnet {
    name           = "subnet1"
    address_prefix = "10.0.0.0/24"
  }
  subnet {
    name           = "subnet2"
    address_prefix = "10.0.1.0/24"
  }
}

resource "azurerm_subnet" "myterraformsubnet1" {
    name                 = "Subnet3"
    resource_group_name  = "${azurerm_resource_group.main.name}"
    virtual_network_name = azurerm_virtual_network.vnet_name.name
    address_prefixes       = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "myterraformsubnet2" {
    name                 = "Subnet4"
    resource_group_name  = "${azurerm_resource_group.main.name}"
    virtual_network_name = azurerm_virtual_network.vnet_name.name
    address_prefixes       = ["10.0.3.0/24"]
}

resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "NSGTerra"
    location            = "${azurerm_resource_group.main.location}"
    resource_group_name = "${azurerm_resource_group.main.name}"

    security_rule {
        name                       = "RDP"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_interface" "myterraformnic" {
    name                        = "myNIC"
    location                    = "${azurerm_resource_group.main.location}"
    resource_group_name         = "${azurerm_resource_group.main.name}"

    ip_configuration {
        name                          = "myIPConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet2.id
        private_ip_address_allocation = "Dynamic"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diagkrassy19"
    resource_group_name         = "${azurerm_resource_group.main.name}"
    location                    = "${azurerm_resource_group.main.location}"
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_windows_virtual_machine" "main" {
  name                = "terraVM"
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${azurerm_resource_group.main.location}"
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "Password&%^$1234!"
  network_interface_ids = [
    azurerm_network_interface.myterraformnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
