variable "KeyVaultName" {
  type = string
  default = "jimmykeys"
}

variable "KeyVaultResourceGroup" {
  type = string
  default = "key-vault"  
}

variable "AdminPasswordSecretName" {
  type = string
  default = "mySqlAdminPassword"
}

data "azurerm_key_vault" "key_vault" {
  name = var.KeyVaultName
  resource_group_name = var.KeyVaultResourceGroup
}

data "azurerm_key_vault_secret" "my_sql_admin_password" {
  name = var.AdminPasswordSecretName
  key_vault_id = data.azurerm_key_vault.key_vault.id
}