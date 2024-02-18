#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Creates all the resources we need to create an Nextcloud instance on Azure Web Apps using Containers

.Example
    ./deployandConfigAppService.ps1 -ResourceBaseName nextcloud -ResourceGroupName nextcloud -Location "Central US" -DBdminName ncadmin -DBPassword <password> -SFTPPassword <password>
#>
param(
    [Parameter(Mandatory=$true)][string]$ResourceBaseName,
    [Parameter(Mandatory=$true)][string]$ResourceGroupName,
    [Parameter(Mandatory=$true)][string]$Location,
    [Parameter(Mandatory=$true)][string]$DBAdminName,
    [Parameter(Mandatory=$true)][string]$DBPassword,
    [Parameter(Mandatory=$true)][string]$VnetName,
    [Parameter(Mandatory=$true)][string]$SubnetName,
    [Parameter(Mandatory=$true)][bool]$UseDockerCompose
)

$mySQlServerName = $ResourceBaseName
$redisCacheName = $ResourceBaseName
$appName = "${ResourceBaseName}jimmy"

# Creates the service plan
az appservice plan create --name $appName --resource-group $ResourceGroupName --is-linux --location $Location --sku P1V3

# Creates the web app
if($UseDockerCompose)
{
    az webapp create --name $appName --plan $appName --resource-group $ResourceGroupName --multicontainer-config-type compose --multicontainer-config-file docker_compose.yml
}
else
{
    az webapp create --name $appName --plan $appName --resource-group $ResourceGroupName --deployment-container-image-name "dorthl/blogifier:latest"
}

# Stops the Web app
az webapp stop --name $appName --resource-group $ResourceGroupName

# Add vnet integration, which basically associates this webapp with a vnet
az webapp vnet-integration add --name $appName --resource-group $ResourceGroupName --vnet $VNetName --subnet $SubnetName

# Create app-insights
az monitor app-insights component create --app $appName --location $location --resource-group $ResourceGroupName
$appInsightsConnectionString = az monitor app-insights component show --app $appName --resource-group $ResourceGroupName --query "connectionString"
$appInsightsConnectionString = appInsightsConnectionString -replace "`"", ""

# Get the FQDN for the Azure Database for Mysql Flexible Server
$mySqlHostname = az mysql flexible-server show --name ${mySQlServerName} --resource-group ${ResourceGroupName} --query 'fullyQualifiedDomainName'
# Remove the " characters
$mySqlHostname = $mySqlHostname -replace "`"", ""

# Get the FQDN and the password for Azure Cache for Redis
$redisHostname = az redis show --name ${redisCacheName} --resource-group ${ResourceGroupName} --query 'hostName'
$redisHostname = $redisHostname -replace "`"", ""
$redisKey = az redis list-keys --name ${redisCacheName} --resource-group ${ResourceGroupName} --query 'primaryKey'
$redisKey = $redisKey -replace "`"", ""

# Add the webapp app settings
az webapp config appsettings set --name $appName --resource-group $ResourceGroupName --settings TZ="America/Los_Angeles" Blogifier__DbProvider="MySql" `
Blogifier__ConnString="Server=${mySqlHostname};Database=blogifier;User=${DBAdminName};Password=${DBPassword};" `
Blogifier__Redis="${redisHostname}:6379,password=${redisKey},defaultDatabase=0" DOCKER_REGISTRY_SERVER_URL="https://index.docker.io" ` DOCKER_REGISTRY_SERVER_USERNAME="" DOCKER_REGISTRY_SERVER_PASSWORD="" WEBSITES_ENABLE_APP_SERVICE_STORAGE="false" `
APPLICATIONINSIGHTS_CONNECTION_STRING="${appInsightsConnectionString}" ApplicationInsightsAgent_EXTENSION_VERSION="~3" `
XDT_MicrosoftApplicationInsights_Mode="Recommended"

az webapp start --name $appName --resource-group $ResourceGroupName