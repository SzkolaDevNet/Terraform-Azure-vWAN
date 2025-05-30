# Azure Subscription should ne defined as environmental variable to import
variable "AZURE_SUBSCRIPTION_ID" {
  type = string
}

variable "lab-rg" {
  description = "Resource Group for this lab"
  type        = string
  default     = "vwanrg"
}

variable "lab-location" {
  description = "Resource location"
  type        = string
  default     = "WestEurope"
}

variable "tags" {
  description = "Set of tags for resources"
  type        = map(any)
  default = {
    environment = "vwan-demo"
    deployment  = "terraform"
  }
}