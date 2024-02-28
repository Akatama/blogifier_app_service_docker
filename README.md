# blogifier_app_service_docker

## How to Run
#### Manual
1. Create a resource group
2. Call main.bicep with either the Azure CLI or Azure PowerShell
  New-AzResourceGroupDeployment -ResourceGroupName "blogifier" -Name main -TemplateFile ./bicep/main.bicep -resourceBaseName blogifier -location "Central US" -vnetName "blogifier-vnet" -adminLogin mysqlAdmin -adminPasswordSecretName mySqlAdminPassword  
3. Run deployandconfigAppService.ps1
  ./deployandConfigAppService.ps1 -ResourceBaseName blogifier -ResourceGroupName blogifier -Location "Central US" -DBAdminName mysqlAdmin -KeyVaultName <keyvaultname> -AdminPasswordSecretName mySqlAdminPassword -VnetName blogifier-vnet -SubnetName app

#### Azure Pipelines YAML
You can look at the example YAML pipeline I have created. This does the same above steps
I make heavy use of pipeline variables. Here are what you need add to your pipeline

1. DBAdminName
2. DBPassword
3. Location
4. ResourceBaseName
5. ResourceGroupName
6. SubnetName
7. VnetName

## Future Work:
#### Try out Azure Private Link for the Redis Cache
Currently, the Redis cache is able to be accessed by the Azure Web App because it is either open to public access, or it is a Premium tier Redis cache and can be attached to a subnet. I want to use Azure Private Link Service to attach the Redis cache to the subnet no matter if it is Premium or not.