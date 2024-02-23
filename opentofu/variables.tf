// Used by all
variable "ResourceBaseName" {
    type = string
    description = "The base name of the resource"
}

variable "ResourceGroupName" {
  type = string
  description = "Name of the resource group for the Database and the Blob Storage"
  default = "blogifier"
}

variable "Location" {
  type = string
  default = "Central US"
}