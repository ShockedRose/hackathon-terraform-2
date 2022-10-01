resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
  tags = var.tags
}

resource "azurerm_virtual_network" "my_terraform_network" {
  name                = var.vnet_name
  address_space       = var.network_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = var.tags
}

# Create subnet
resource "azurerm_subnet" "my_terraform_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = var.subnet_space
}

# Create public IPs
resource "azurerm_public_ip" "linux_VM_virtual_machine_IP" {
  name                = var.linux_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  tags = var.tags
}
resource "azurerm_public_ip" "windows_VM_virtual_machine_IP" {
  name                = var.windows_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  tags = var.tags
}
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22-80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = var.tags
}

resource "azurerm_network_interface" "my_terraform_linux_nic" {
  name                = var.linux_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "my_Linux_nic_configuration"
    subnet_id                     = azurerm_subnet.my_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux_VM_virtual_machine_IP.id
  }
  tags = var.tags
}
resource "azurerm_network_interface" "my_terraform_windows_nic" {
  name                = var.windows_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "my_Windows_nic_configuration"
    subnet_id                     = azurerm_subnet.my_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows_VM_virtual_machine_IP.id
  }
  tags = var.tags
}
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.my_terraform_linux_nic.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}
resource "random_id" "random_id" {
  keepers = {
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "my_linux_terraform_vm" {
  name                  = var.linux_VM_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.my_terraform_linux_nic.id]
  size                  = "Standard_B2s"
  tags = var.tags
  os_disk {
    name                 = "myOsDiskLinux"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
    }

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  disable_password_authentication = true
  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

}
resource "azurerm_windows_virtual_machine" "my_windows_terraform_vm" {
  name                  = var.windows_VM_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.my_terraform_windows_nic.id]
  size                  = "Standard_B2s"
  tags = var.tags
  os_disk {
    name                 = "myOsDiskWindows"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
     publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
    }

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  admin_password = "8Digitos*"

}