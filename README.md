# blogifier_app_service_docker

## How to Run
Note: For either of the ways to deploy provided here, you will need to set up Azure Key Vault. That is not covered in this project, because it doesn't make sense to create an Azure Key Vault each time we want to deploy this application.

I have my Azure Key Vault open to Public Access from all networks, but I do have it limited with Azure RBAC so only people I want to access can access it. This is not super ideal, but its the only way I could figure to allow access for the Azure Pipelines YAML. See below for more info on that.
#### Manual
1. Create a resource group
2. Call main.bicep with either the Azure CLI or Azure PowerShell -OR- call the files in the opentofu folder with OpenTofu or Terraform
   
  New-AzResourceGroupDeployment -ResourceGroupName "blogifier" -Name main -TemplateFile ./bicep/main.bicep -resourceBaseName blogifier -location "Central US" -vnetName "blogifier-vnet" -adminLogin mysqlAdmin -adminPasswordSecretName mySqlAdminPassword
4. Call Azure Key Vault to get the password, we will call it <password> here
5. Run deployandconfigAppService.ps1
  ./deployandConfigAppService.ps1 -ResourceBaseName blogifier -ResourceGroupName blogifier -Location "Central US" -DBAdminName mysqlAdmin -DBPassword <password> -VnetName blogifier-vnet -SubnetName app

#### Azure Pipelines YAML
Note: If you are using Azure Key Vault, you will need to set it up so that your App Registration (or whatver Service Principal you are using to access the Vault) has access. I personally use Azure RBAC. All I did there was go to my Subscription -> Access control (IAM) -> Add -> Add role assignment -> Key Vault Secrets User -> Assign to App Registration. If you are not using Azure RBAC, you can follow this guide: https://learn.microsoft.com/en-us/azure/devops/pipelines/release/key-vault-in-own-project?view=azure-devops&tabs=portal

You can look at the example YAML pipeline I have created. This does the same above steps
I make heavy use of pipeline variables. Here are what you need add to your pipeline

1. DBAdminName
2. DBPassword
3. Location
4. ResourceBaseName
5. ResourceGroupName
6. SubnetName
7. VnetName
8. The name of the passowrd in the keyvault (mySqlAdminPassword)

## Future Work:
#### Try out Azure Private Link for the Redis Cache
Currently, the Redis cache is able to be accessed by the Azure Web App because it is either open to public access, or it is a Premium tier Redis cache and can be attached to a subnet. I want to use Azure Private Link Service to attach the Redis cache to the subnet no matter if it is Premium or not.
