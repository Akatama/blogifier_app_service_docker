variable "AdminUserName" {
  type = string
  description = "Administrator username for the DB"
}

variable "AdminPassword" {
    type = string
    description = "Administrator password for the DB"
}

variable "ServerEdition" {
    type = string
    description = "The tier of the particular SKU. Valid values are B for Burstable, GP for GeneralPurpose and MO for Memory Optimized. High Availability is available for GeneralPurpose and MemoryOptimized sku."
    default = "B"
}

variable "ServerVersion" {
    type = string
    description = "Valid values are 5.7 and 8.0.21"
    default = "8.0.21"
}

variable "AvailabilityZone" {
    type = string
    description = "Availability Zone info for the server. (Leave blank for no preference)."
    default = null
}

variable "HighAvailabilityMode" {
    type = string
    description = "High availability mode for a server : SameZone or ZoneRedundant"
    default = "SameZone"
}

variable "StandbyAvailabilityZone" {
    type = string
    description = "Availability zone of the standby server."
    default = "2"
}

variable "StorageSizeGB" {
    type = number
    default = 120
}

variable "StorageIOPS" {
    type = number
    default = 360
}

variable "StorageAutoGrow" {
    type = bool
    default = true
}

variable "DBSkuName" {
    type = string
    default = "Standard_B1ms"
    description = "The name of the sku, e.g. Standard_D32ds_v4."
}

variable "BackupRetentionDays" {
  type = number
  default = 7
}

variable "GeoRedundantBackup" {
    type = bool
    default = false
}

variable "DatabaseName" {
    type = string
    default = "blogifier"
  
}

resource "azurerm_mysql_flexible_server" "mysql_server" {
    name = "${lower(var.ResourceBaseName)}"
    resource_group_name = azurerm_resource_group.resource_group.name
    location = var.Location
    
    sku_name = "${var.ServerEdition}_${var.DBSkuName}"
    version = var.ServerVersion
    administrator_login = var.AdminUserName
    administrator_password = var.AdminPassword
    zone = var.AvailabilityZone

    storage {
        size_gb = var.StorageSizeGB
        iops = var.StorageIOPS
        auto_grow_enabled = var.StorageAutoGrow
    }
    delegated_subnet_id = azurerm_subnet.db_subnet.id
    
    backup_retention_days = var.BackupRetentionDays
    geo_redundant_backup_enabled = var.GeoRedundantBackup
}

resource "azurerm_mysql_flexible_database" "blogifier" {
    name = var.DatabaseName
    resource_group_name = azurerm_resource_group.resource_group.name
    server_name = azurerm_mysql_flexible_server.mysql_server.name
    charset = "utf8mb4"
    collation = "utf8mb4_unicode_ci"
}