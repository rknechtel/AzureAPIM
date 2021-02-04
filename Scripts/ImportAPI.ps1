

<#
.SYNOPSIS
  Example of Importing an APIM and adding it to a Product in API Management
  
.DESCRIPTION
  Example of Importing an APIM and adding it to a Product in API Management 
  Note: 
  Adding the Imported API to a Product is needed, so that it can be used by a Subscription.
  
.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>
	
.INPUTS
  <Inputs if any, otherwise state None>
  
.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>
  
.NOTES
  Script Name: ImportAPI.ps1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  09/04/2020
  Purpose/Change: Initial script development

.LICENSE
 This script is in the public domain, free from copyrights or restrictions.

.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------
param(
[Parameter(Mandatory=$true)]
[string]$Parameter1,
[Parameter(Mandatory=$true)]
[string]$Parameter2,
[Parameter(Mandatory=$true)]
[string]$Parameter3
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins
Import-Module PSLogging

<#
 Example (Levels: Fatal, Error, Warn, Info):
 Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error
#>
New-PSDrive -Name X -PSProvider FileSystem -Root C:\Users\rknechtel\Data\Documents\RICHDOCS\Programming\Scripts\PowerShell
Set-Location X:
Import-module X:\Functions\Write-Log.psm1 -Force

$global:ReturnCodeMsg = "Completed Successfully"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Log File Info
$sLogPath = "C:\Temp" # Change to where you want to Log to
$sLogName = "ImportAPI.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

Write-Host "Log File is $sLogFile;
Write-Log -Message "Log File is -Path $sLogFile; 


#-----------------------------------------------------------[Functions]------------------------------------------------------------

# NONE

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Starting ImportAPI script.";
Write-Log -Message "********************************" -Path $sLogFile -Level Info;
Write-Log -Message "Starting ImportAPI script." -Path $sLogFile -Level Info; 

try 
{
  Write-Log -Message "Example of Importing and API" -Path $sLogFile -Level Info;
  
  $random = (New-Guid).ToString().Substring(0,8)

  #Azure specific details
  $subscriptionId = "my-azure-subscription-id"
  
  # Api Management service specific details
  $apimServiceName = "apim-$random"
  $resourceGroupName = "apim-rg-$random"
  $location = "US West"
  $organisation = "MyCompany"
  $adminEmail = "admin@cmycompany.com"
  
  # Api Specific Details
  $swaggerUrl = "http://myapp.swagger.io/v2/swagger.json"
  $apiPath = "myapp"
  
  # Set the context to the subscription Id where the cluster will be created
  Select-AzSubscription -SubscriptionId $subscriptionId
  
  # Create a resource group.
  New-AzResourceGroup -Name $resourceGroupName -Location $location
  
  # Create the Api Management service. Since the SKU is not specified, it creates a service with Developer SKU. 
  New-AzApiManagement -ResourceGroupName $resourceGroupName -Name $apimServiceName -Location $location -Organization $organisation -AdminEmail $adminEmail
  
  # Create the API Management context
  $context = New-AzApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $apimServiceName
  
  # import api from Url
  $api = Import-AzApiManagementApi -Context $context -SpecificationUrl $swaggerUrl -SpecificationFormat Swagger -Path $apiPath
  
  $productName = "Pet Store Product"
  $productDescription = "Product giving access to Petstore api"
  $productState = "Published"
  
  # Create a Product to publish the Imported Api. This creates a product with a limit of 10 Subscriptions
  $product = New-AzApiManagementProduct -Context $context -Title $productName -Description $productDescription -State $productState -SubscriptionsLimit 10 
  
  # Add the petstore api to the published Product, so that it can be called in developer portal console
  Add-AzApiManagementApiToProduct -Context $context -ProductId $product.ProductId -ApiId $api.ApiId
  
  
  Write-Log -Message "FINISHED DONIG SOMETHING" -Path $sLogFile -Level Info;
}  
catch
{
  # catch any errors and report them
  $ErrorMessage = $_.Exception.Message;
  $FailedItem = $_.Exception.ItemName;
  Write-Log -Message "Exception caught in ImportAPI: $ErrorMessage" -Path $sLogFile -Level Error;
}
finally
{
  Write-Host "Removing mapped Drive X";
  Write-Log -Message "Removing mapped Drive X" -Path $sLogFile -Level Info;
  Remove-PSDrive-name X
  
  # Retrun to the calling location
  ReturnToCallingLocation

  Write-Host "Finished running ImportAPI script.";
  Write-Log -Message "Finished running ImportAPI script." -Path $sLogFile -Level Info; 
  Write-Log -Message "********************************" -Path $sLogFile -Level Info;

  # Example setting return code/message
  $global:ReturnCodeMsg="There was an Error in ImportAPI."
}

# Some Value or Variable
return $ReturnCodeMsg
