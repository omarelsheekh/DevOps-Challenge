variable "resource_group" {
  description = "The name of the resource group in which to create the resources."
  default = "myresourcegroup"
}

variable "env" {
  description = "The name of the enviroment tag."
  default = "DevOps-Challenge"
}

variable "location" {
  description = "The location/region where the resources are created."
  default     = "eastus"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.0.0/24"
}

variable "virtual_network_name" {
  description = "The name for the virtual network."
  default     = "vnet"
}

variable "db_name" {
  description = "Specifies the DB name."
  default     = "test_db"
}

variable "db_username" {
  description = "Specifies the DB username."
  default     = "db_user"
}

variable "db_userpass" {
  description = "Specifies the db user password."
  default     = "db_pass"
}

variable "db_replicapass" {
  description = "Specifies the db replicator user password."
  default     = "123456789"
}

# App VM Variables
variable "app_vm_name" {
  description = "VM name referenced also in storage-related names."
  default = "app_vm"
}

variable "app_vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_DS1_v2"
}

variable "app_vm_private_ip" {
  description = "Specifies the private ip of the virtual machine."
  default     = "10.0.0.10"
}

# DBMaster VM Variables
variable "dbmaster_vm_name" {
  description = "VM name referenced also in storage-related names."
  default = "dbmaster_vm"
}

variable "dbmaster_vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_DS1_v2"
}

variable "dbmaster_vm_private_ip" {
  description = "Specifies the private ip of the virtual machine."
  default     = "10.0.0.11"
}

# DBSlave VM Variables
variable "dbslave_vm_name" {
  description = "VM name referenced also in storage-related names."
  default = "dbslave_vm"
}

variable "dbslave_vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_DS1_v2"
}

variable "dbslave_vm_private_ip" {
  description = "Specifies the private ip of the virtual machine."
  default     = "10.0.0.12"
}