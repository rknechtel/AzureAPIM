#requires -version <PowerShell Version>
<#
.SYNOPSIS
  APIM Backup and Restore Examples
  
.DESCRIPTION
  Example Script to backup and restore APIM Services.
  
.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>
	
.INPUTS
  <Inputs if any, otherwise state None>
  
.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>
  
.NOTES
  Script Name: BackupRestoreAPIMService.ps1
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
New-PSDrive -Name X -PSProvider FileSystem -Root C:\Scripts\PowerShell
Set-Location X:
Import-module X:\Functions\Write-Log.psm1 -Force

$global:ReturnCodeMsg = "Completed Successfully"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Log File Info
$sLogPath = "C:\Temp" # Change to where you want to Log to
$sLogName = "BackupRestoreAPIMService.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

Write-Host "Log File is $sLogFile;
Write-Log -Message "Log File is -Path $sLogFile; 


#-----------------------------------------------------------[Functions]------------------------------------------------------------

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Starting BackupRestoreAPIMService script.";
Write-Log -Message "********************************" -Path $sLogFile -Level Info;
Write-Log -Message "Starting BackupRestoreAPIMService script." -Path $sLogFile -Level Info; 

try 
{
  Write-Log -Message "Examples of Backup and Restore APIM Configs" -Path $sLogFile -Level Info;
  

  $random = (New-Guid).ToString().Substring(0,8)

  # Azure specific details
  $subscriptionId = "my-azure-subscription-id"
   
  # Api Management service specific details
  $apiManagementName = "apim-$random"
  $resourceGroupName = "apim-rg-$random"
  $location = "US West"
  $organisation = "MyOrganization"
  $adminEmail = "admin@myorganization.com"
   
  # Storage Account details
  $storageAccountName = "backup$random"
  $containerName = "backups"
  $backupName = $apiManagementName + "-apimbackup"
   
  # Select default azure subscription
  Select-AzSubscription -SubscriptionId $subscriptionId
   
  # Create a Resource Group 
  New-AzResourceGroup -Name $resourceGroupName -Location $location -Force
   
  # Create storage account    
  New-AzStorageAccount -StorageAccountName $storageAccountName -Location $location -ResourceGroupName $resourceGroupName -Type Standard_LRS
  $storageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName)[0].Value
  $storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey
  
  # Create blob container
  New-AzStorageContainer -Name $containerName -Context $storageContext -Permission blob
   
  # Create API Management service
  New-AzApiManagement -ResourceGroupName $resourceGroupName -Location $location -Name $apiManagementName -Organization $organisation -AdminEmail $adminEmail
   
  # Backup API Management service.
  Backup-AzApiManagement -ResourceGroupName $resourceGroupName -Name $apiManagementName -StorageContext $storageContext -TargetContainerName $containerName -TargetBlobName $backupName
   
  # Restore API Management service
  Restore-AzApiManagement -ResourceGroupName $resourceGroupName -Name $apiManagementName -StorageContext $storageContext -SourceContainerName $containerName -SourceBlobName $backupName
  
  
  Write-Log -Message "FINISHED DONIG SOMETHING" -Path $sLogFile -Level Info;
}  
catch
{
  # catch any errors and report them
  $ErrorMessage = $_.Exception.Message;
  $FailedItem = $_.Exception.ItemName;
  Write-Log -Message "Exception caught in BackupRestoreAPIMService: $ErrorMessage" -Path $sLogFile -Level Error;
}
finally
{
  Write-Host "Removing mapped Drive X";
  Write-Log -Message "Removing mapped Drive X" -Path $sLogFile -Level Info;
  Remove-PSDrive-name X
  
  # Retrun to the calling location
  ReturnToCallingLocation

  Write-Host "Finished running BackupRestoreAPIMService script.";
  Write-Log -Message "Finished running BackupRestoreAPIMService script." -Path $sLogFile -Level Info; 
  Write-Log -Message "********************************" -Path $sLogFile -Level Info;

  # Example setting return code/message
  $global:ReturnCodeMsg="There was an Error in BackupRestoreAPIMService."
}

# Some Value or Variable
return $ReturnCodeMsg
