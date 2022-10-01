variable "resource_group_location" {
  default     = "East US 2"
  description = "Allowed region."
}

variable "resource_group_name" {
  default     = "RG-PROD-01"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "tags" {
  default     = {
    CREATEDBY = "Unicyt"
    DPT = "VENTAS"
    AMBIENTE = "PRD"
  }
  description = "Resource tags"
  type        = map(string)
}

variable "vnet_name" {
  default     = "VNET-PROD"

}
variable "subnet_name" {
  default     = "Subnet-01"
}

variable "network_space" {
  default     = ["10.150.0.0/16"]
}

variable "subnet_space" {
  default     = ["10.150.0.0/24"]
}
variable "windows_VM_name" {
  default     = "SRV-PROD-01-AZ"
}
variable "linux_VM_name" {
  default     = "SRV-PROD-02-AZ"
}
variable "windows_ip_name" {
  default     = "PIP-SRV-PROD-01-AZ"
}
variable "linux_ip_name" {
  default     = "PIP-SRV-PROD-02-AZ"
}