# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = var.resource_group
    location = var.location

    tags = {
        environment = var.env
    }
}
output "rg_name" { value = azurerm_resource_group.myterraformgroup.name }

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = var.virtual_network_name
    address_space       = [var.address_space]
    location            = var.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    tags = {
        environment = var.env
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "${var.virtual_network_name}Subnet1"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = [var.subnet_prefix]
}
output "subnet_prefix" { value = var.subnet_prefix }

# Create an SSH key
resource "tls_private_key" "myterraformsshkey" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Store private key localy
resource "local_file" "myterraformprivatekey" {
    content  = tls_private_key.myterraformsshkey.private_key_pem
    filename = "ansible/private_key.pem"
}

output "db_name" { value = var.db_name }
output "db_username" { value = var.db_username }
output "db_userpass" { value = var.db_userpass }
output "db_replicapass" { value = var.db_replicapass }

# Create App VM  
# Create public IPs
resource "azurerm_public_ip" "appvmpublicip" {
    name                         = "${var.app_vm_name}PublicIP"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = var.env
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "appvmsg" {
    name                = "${var.app_vm_name}SecurityGroup"
    location            = var.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "http"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "https"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = var.env
    }
}

# Create network interface
resource "azurerm_network_interface" "appvmnic" {
    name                      = "${var.app_vm_name}NIC"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "${var.app_vm_name}NicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = var.app_vm_private_ip
        public_ip_address_id          = azurerm_public_ip.appvmpublicip.id
    }

    tags = {
        environment = var.env
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "appvmass" {
    network_interface_id      = azurerm_network_interface.appvmnic.id
    network_security_group_id = azurerm_network_security_group.appvmsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "appvm" {
    name                  = var.app_vm_name
    location              = var.location
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.appvmnic.id]
    size                  = var.app_vm_size

    os_disk {
        name              = "${var.app_vm_name}OsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "8_2"
        version   = "latest"
    } 

    computer_name  = "appvm"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.myterraformsshkey.public_key_openssh
    }

    tags = {
        environment = var.env
    }
}
output "app_vm_name" { value = azurerm_linux_virtual_machine.appvm.name }

# Create DBMaster VM  
# Create public IPs
resource "azurerm_public_ip" "dbmastervmpublicip" {
    name                         = "${var.dbmaster_vm_name}PublicIP"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = var.env
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "dbmastervmsg" {
    name                = "${var.dbmaster_vm_name}SecurityGroup"
    location            = var.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
 
    tags = {
        environment = var.env
    }
}

# Create network interface
resource "azurerm_network_interface" "dbmastervmnic" {
    name                      = "${var.dbmaster_vm_name}NIC"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "${var.dbmaster_vm_name}NicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = var.dbmaster_vm_private_ip
        public_ip_address_id          = azurerm_public_ip.dbmastervmpublicip.id
    }

    tags = {
        environment = var.env
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "dbmastervmass" {
    network_interface_id      = azurerm_network_interface.dbmastervmnic.id
    network_security_group_id = azurerm_network_security_group.dbmastervmsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "dbmastervm" {
    name                  = var.dbmaster_vm_name
    location              = var.location
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.dbmastervmnic.id]
    size                  = var.dbmaster_vm_size

    os_disk {
        name              = "${var.dbmaster_vm_name}OsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "8_2"
        version   = "latest"
    } 

    computer_name  = "dbmastervm"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.myterraformsshkey.public_key_openssh
    }

    tags = {
        environment = var.env
    }
}
output "dbmaster_vm_name" { value = azurerm_linux_virtual_machine.dbmastervm.name }
output "dbmaster_vm_private_ip" { value = var.dbmaster_vm_private_ip}

# Create DBSlave VM  
# Create public IPs
resource "azurerm_public_ip" "dbslavevmpublicip" {
    name                         = "${var.dbslave_vm_name}PublicIP"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = var.env
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "dbslavevmsg" {
    name                = "${var.dbslave_vm_name}SecurityGroup"
    location            = var.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
 
    tags = {
        environment = var.env
    }
}

# Create network interface
resource "azurerm_network_interface" "dbslavevmnic" {
    name                      = "${var.dbslave_vm_name}NIC"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "${var.dbslave_vm_name}NicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = var.dbslave_vm_private_ip
        public_ip_address_id          = azurerm_public_ip.dbslavevmpublicip.id
    }

    tags = {
        environment = var.env
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "dbslavevmass" {
    network_interface_id      = azurerm_network_interface.dbslavevmnic.id
    network_security_group_id = azurerm_network_security_group.dbslavevmsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "dbslavevm" {
    name                  = var.dbslave_vm_name
    location              = var.location
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.dbslavevmnic.id]
    size                  = var.dbslave_vm_size

    os_disk {
        name              = "${var.dbslave_vm_name}OsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "8_2"
        version   = "latest"
    } 

    computer_name  = "dbslavevm"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.myterraformsshkey.public_key_openssh
    }

    tags = {
        environment = var.env
    }
}
output "dbslave_vm_name" { value = azurerm_linux_virtual_machine.dbslavevm.name }
output "dbslave_vm_private_ip" { value = var.dbslave_vm_private_ip}