@description('name of the Vnet we will attach our VM to')
param vnetName string

@description('Subnet we will attach our VM to')
param storageSubnetName string = 'storage'

@description('Provide Virtual Network Address Prefix')
param vnetAddressPrefix string = '10.1.0.0/16'

@description('Provide VM Subnet Address Prefix')
param storageSubnetPrefix string = '10.1.0.0/24'

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
        name: storageSubnetName
        properties: {
          addressPrefix: storageSubnetPrefix
        }
      }
    ]
  }
}

@description('Name base name of the resources')
param resourceBaseName string

param location string = 'Central US'

@description('Provide the administrator login name for the MySQL server.')
param administratorLogin string

@description('Provide the administrator login password for the MySQL server.')
@secure()
param administratorLoginPassword string


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

resource mySQLServer 'Microsoft.DBforMySQL/flexibleServers@2023-06-30' = {
  name: toLower(resourceBaseName)
  location: location
  sku: {
    name: databaseSkuName
    tier: serverEdition
  }
  properties: {
    version: serverVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    availabilityZone: availabilityZone
    highAvailability: {
      mode: haEnabled
      standbyAvailabilityZone: standbyAvailabilityZone
    }
    storage: {
      storageSizeGB: storageSizeGB
      iops: storageIops
      autoGrow: storageAutogrow
    }
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    network: {
      publicNetworkAccess: 'Enabled'
    }
  }
}

resource nextcloud_database 'Microsoft.DBforMySQL/flexibleServers/databases@2023-06-30' = {
  parent: mySQLServer
  name: databaseName
  properties: {
    charset: 'utf8mb4'
    collation: 'utf8mb4_unicode_ci'

  }
}


resource redisCache 'Microsoft.Cache/redis@2023-08-01' = {
  location: location
  name: toLower(resourceBaseName)
  properties: {
    enableNonSslPort: true
    publicNetworkAccess: 'Enabled'
    redisConfiguration: {

    }
    sku: {
      capacity: 1
      family: 'C'
      name: 'Standard'
    }
  }
}
