
param mySqlName string

param location string = 'Central US'


param adminLogin string


@secure()
param adminPassword string

param serverEdition string

param serverVersion string

param availabilityZone string

param haEnabled string

param standbyAvailabilityZone string

param storageSizeGB int

param storageIops int

param storageAutogrow string

param databaseSkuName string

param backupRetentionDays int

param geoRedundantBackup string

param databaseName string

param dbSubnetId string

resource mySQLServer 'Microsoft.DBforMySQL/flexibleServers@2023-06-30' = {
  name: toLower(mySqlName)
  location: location
  sku: {
    name: databaseSkuName
    tier: serverEdition
  }
  properties: {
    version: serverVersion
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
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
      delegatedSubnetResourceId: dbSubnetId
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
