variable "RedisSkuName" {
  type = string
  default = "Premium"
  description = "The SkuName of the Redis Cache. Valid values are Basic, Standard and Premium"
}

variable "RedisFamily" {
  type = string
  default = "P"
  description = "The Redis Sku Family. Valid values are C for Basic/Standard or P for Premium"
}

variable "redisCapacity" {
  type = number
  default = 1
  description = "The Capcity value of the Redis Cache. Valid values are 0-6 for Basic and Standard. 1-5 for Premium"
}

variable "RedisPublicNetworkAccess" {
  type = bool
  default = false
  
}

resource "azurerm_redis_cache" "cache" {
  name = "${lower(var.ResourceBaseName)}"
  location = var.Location
  resource_group_name = azurerm_resource_group.resource_group.name
  capacity = var.redisCapacity
  family = var.RedisFamily
  sku_name = var.RedisSkuName
  enable_non_ssl_port = true
  public_network_access_enabled = var.RedisPublicNetworkAccess
  subnet_id = azurerm_subnet.cache_subnet.id
}