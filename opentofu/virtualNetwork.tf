variable "VirtualNetworkAddressSpace" {
  type = string
  default = "10.2.0.0/16"
  description = "The Address space of the virtual network"
}
variable "AppSubnetName" {
    type = string
    default = "app"
    description = "The name of the Subnet where we will attach our app service"
}

variable "AppSubnetPrefix" {
    type = string
    default = "10.2.0.0/24"
    description = "The Address Prefix for the app service subnet"
}

variable "DBSubnetName" {
  type = string
  default = "database"
  description = "The name of the Subnet where we will attach our database"
}

variable "DBSubnetPrefix" {
    type = string
    default = "10.2.1.0/24"
    description = "The Address Prefix for the DB subneet"
}

variable "CacheSubnetName" {
  type = string
  default = "cache"
  description = "The name of the Subnet where we will attach our Redis cache"
}

variable "CacheSubnetPrefix" {
    type = string
    default = "10.2.2.0/24"
    description = "The Address Prefix for the Redis cache subneet"
}

resource "azurerm_resource_group" "resource_group" {
    name = var.ResourceGroupName
    location = var.Location
}

resource "azurerm_virtual_network" "vnet" {
    name = "${var.ResourceBaseName}-vnet"
    location = var.Location
    resource_group_name = azurerm_resource_group.resource_group.name
    address_space = [var.VirtualNetworkAddressSpace]
}

resource "azurerm_subnet" "app_subnet" {
    name = var.AppSubnetName
    resource_group_name = azurerm_resource_group.resource_group.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [var.AppSubnetPrefix]
    service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "db_subnet" {
    name = var.DBSubnetName
    resource_group_name = azurerm_resource_group.resource_group.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [var.DBSubnetPrefix]
    delegation {
        name = "MySQLFlexibleServers"
        service_delegation {
          name = "Microsoft.DBforMySQL/flexibleServers"
        }
    }  
}

resource "azurerm_subnet" "cache_subnet" {
  name = var.CacheSubnetName
  resource_group_name = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [var.CacheSubnetPrefix]
  
}