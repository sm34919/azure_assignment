provider "azurerm" {
  features {}
}
  variable "prefix" {
  default = "Shubham"
}

locals {
  vm_name = "${var.prefix}-vm"
}

resource "azurerm_resource_group" "assignment" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "assignment" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.assignment.location
  resource_group_name = azurerm_resource_group.assignment.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.assignment.name
  virtual_network_name = azurerm_virtual_network.assignment.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "assignment" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.assignment.location
  resource_group_name = azurerm_resource_group.assignment.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "shubham" {
  name                  = local.vm_name
  location              = azurerm_resource_group.assignment.location
  resource_group_name   = azurerm_resource_group.assignment.name
  network_interface_ids = [azurerm_network_interface.assignment.id]
  vm_size               = "Standard_F2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = local.vm_name
    admin_username = "shubham34919"
    admin_password = "07653@Azure!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_managed_disk" "shubham" {
  name                 = "${local.vm_name}-disk1"
  location             = azurerm_resource_group.assignment.location
  resource_group_name  = azurerm_resource_group.assignment.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_virtual_machine_data_disk_attachment" "shubham" {
  managed_disk_id    = azurerm_managed_disk.shubham.id
  virtual_machine_id = azurerm_virtual_machine.shubham.id
  lun                = "10"
  caching            = "ReadWrite"
}