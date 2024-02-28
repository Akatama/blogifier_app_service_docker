param redisName string

param location string

param redisSkuName string

param redisSkuCapcity int

param redisPublicNetworkAccess string

param cacheSubnetId string = ''

var redisSkuFamily = redisSkuName == 'Premium' ? 'P' : 'C'

resource redisCache 'Microsoft.Cache/redis@2023-08-01' = {
  location: location
  name: toLower(redisName)
  properties: {
    enableNonSslPort: true
    publicNetworkAccess: redisPublicNetworkAccess
    redisConfiguration: {

    }
    sku: {
      capacity: redisSkuCapcity
      family: redisSkuFamily
      name: redisSkuName
    }
    subnetId: redisSkuName == 'Premium' ? cacheSubnetId : null
  }
}
