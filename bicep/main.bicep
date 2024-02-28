@description('name of the Vnet we will attach our VM to')
param vnetName string

@description('Provide Virtual Network Address Prefix')
param vnetAddressPrefix string = '10.1.0.0/16'

@description('Subnet we will attach our Web App to')
param appSubnetName string = 'app'

@description('Provide VM Subnet Address Prefix')
param appSubnetPrefix string = '10.1.0.0/24'

@description('Subnet we will attach our database to')
param dbSubnetName string = 'database'

@description('Provide Subnet Address Prefix')
param dbSubnetPrefix string = '10.1.1.0/24'

@description('Subnet we will attach our database to')
param cacheSubnetName string = 'cache'

@description('Provide Subnet Address Prefix')
param cacheSubnetPrefix string = '10.1.2.0/24'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: appSubnetName
        properties: {
          addressPrefix: appSubnetPrefix
        }
      }
      {
        name: dbSubnetName
        properties: {
          addressPrefix: dbSubnetPrefix
          delegations: [
            {
              name: 'MySQLflexibleServers'
              properties: {
                serviceName: 'Microsoft.DBforMySQL/flexibleServers'
              }
            }
          ]
        }
      }
      {
        name: cacheSubnetName
        properties: {
          addressPrefix: cacheSubnetPrefix
        }
      }
    ]
  }
}

@description('The Key Vault resource group')
param keyVaulResourceGroupName string = 'key-vault'

@description('The Key Vault name')
param keyVaultName string = 'jimmykeys'

@description('Provide the key name that coincides with the admin password')
param adminPasswordSecretName string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup(keyVaulResourceGroupName)
}

@description('Name base name of the resources')
param resourceBaseName string

param location string = 'Central US'

@description('Provide the administrator login name for the MySQL server.')
param adminLogin string

@description('The tier of the particular SKU. High Availability is available only for GeneralPurpose and MemoryOptimized sku.')
@allowed([
  'Burstable'
  'GeneralPurpose'
  'MemoryOptimized'
])
param serverEdition string = 'Burstable'

@description('Server version')
@allowed([
  '5.7'
  '8.0.21'
])
param serverVersion string = '8.0.21'

@description('Availability Zone information of the server. (Leave blank for No Preference).')
param availabilityZone string = ''

@description('High availability mode for a server : Disabled, SameZone, or ZoneRedundant')
@allowed([
  'Disabled'
  'SameZone'
  'ZoneRedundant'
])
param haEnabled string = 'Disabled'

@description('Availability zone of the standby server.')
param standbyAvailabilityZone string = '2'

param storageSizeGB int = 120
param storageIops int = 360
@allowed([
  'Enabled'
  'Disabled'
])
param storageAutogrow string = 'Enabled'

@description('The name of the sku, e.g. Standard_D32ds_v4.')
param databaseSkuName string = 'Standard_B1ms'

param backupRetentionDays int = 7

@allowed([
  'Disabled'
  'Enabled'
])
param geoRedundantBackup string = 'Disabled'

param databaseName string = 'blogifier'

module mySql 'modules/mySql.bicep' = {
  name: 'mySql-${resourceBaseName}'
  params: {
    mySqlName: resourceBaseName
    adminLogin: adminLogin
    adminPassword: keyVault.getSecret(adminPasswordSecretName)
    location: location
    availabilityZone: availabilityZone
    backupRetentionDays: backupRetentionDays
    databaseName: databaseName
    databaseSkuName: databaseSkuName
    geoRedundantBackup: geoRedundantBackup
    haEnabled: haEnabled
    serverEdition: serverEdition
    serverVersion: serverVersion
    standbyAvailabilityZone: standbyAvailabilityZone
    storageAutogrow: storageAutogrow
    storageIops: storageIops
    storageSizeGB: storageSizeGB
    dbSubnetId: virtualNetwork.properties.subnets[1].id
  }
}

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param redisSkuName string = 'Premium'

@description('Only select values from 1-4 for Premium, 0-6 for Basic or Standard')
@allowed([
  0
  1
  2
  3
  4
  5
  6
])
param redisSkuCapcity int = 1

@allowed([
  'Enabled'
  'Disabled'
])
param redisPublicNetworkAccess string = 'Disabled'

module redis 'modules/redis.bicep' = {
  name: 'redis-${resourceBaseName}'
  params: {
    location: location
    redisName: resourceBaseName
    redisPublicNetworkAccess: redisPublicNetworkAccess
    redisSkuCapcity: redisSkuCapcity
    redisSkuName: redisSkuName
    cacheSubnetId: virtualNetwork.properties.subnets[2].id
  }
}
