#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Submit a new migration job referenced to a previously uploaded package in Azure Blob storage into to a site collection
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Microsoft.Online.SharePoint.PowerShell
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Common

    .Parameter ExecuteCredentials
        Credentials of a site collection administrator to use to connect to the site collection

    .Parameter FileContainerUri
        A fully qualified URL and SAS token representing the Azure Blob Storage container that holds the package content files

    .Parameter PackageContainerUri
        A fully qualified URL and SAS token representing the Azure Blob Storage container that holds the package metadata files

    .Parameter TargetWebUrl
        The fully qualified target web URL where the package will be imported into

    .Parameter AzureQueueUri
        An optional fully qualified URL and SAS token representing the Azure Storage Reporting Queue where import operations will list events during import

    .Parameter EncryptionParameters
        Parameters of the encryption

    .Parameter MigrationPackageAzureLocations
        A set of fully qualified URLs and SAS tokens representing the Azure Blob Storage containers that hold the package content and metadata files and an optional Azure Storage Reporting Queue

    .Parameter NoLogFile
        Indicates to not create a log file
#>

param(     
    [Parameter(Mandatory = $true, ParameterSetName = 'Inline')]
    [Parameter(Mandatory = $true, ParameterSetName = 'Pipebind')]
    [pscredential]$ExecuteCredentials,
    [Parameter(Mandatory = $true, ParameterSetName = 'Inline')]
    [string]$FileContainerUri,
    [Parameter(Mandatory = $true, ParameterSetName = 'Inline')]
    [string]$PackageContainerUri,
    [Parameter(Mandatory = $true, ParameterSetName = 'Pipebind')]
    [string]$MigrationPackageAzureLocations,
    [Parameter(Mandatory = $true, ParameterSetName = 'Inline')]
    [Parameter(Mandatory = $true, ParameterSetName = 'Pipebind')]
    [string]$TargetWebUrl,
    [Parameter(ParameterSetName = 'Inline')]
    [string]$AzureQueueUri,
    [Parameter(ParameterSetName = 'Inline')]
    [Parameter(ParameterSetName = 'Pipebind')]
    [string]$EncryptionParameters,
    [Parameter(ParameterSetName = 'Inline')]
    [Parameter(ParameterSetName = 'Pipebind')]
    [switch]$NoLogFile
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Credentials' = $ExecuteCredentials
                            'NoLogFile' = $NoLogFile
                            'TargetWebUrl' = $TargetWebUrl
                            }

    if($PSCmdlet.ParameterSetName -eq 'Pipebind'){
        $cmdArgs.Add('MigrationPackageAzureLocations',$MigrationPackageAzureLocations)
    }
    else{
        $cmdArgs.Add('FileContainerUri',$FileContainerUri)
        $cmdArgs.Add('PackageContainerUri',$PackageContainerUri)
    }
    if($PSBoundParameters.ContainsKey('EncryptionParameters')){
        $cmdArgs.Add('EncryptionParameters',$EncryptionParameters)
    }
    if($PSBoundParameters.ContainsKey('AzureQueueUri')){
        $cmdArgs.Add('AzureQueueUri',$AzureQueueUri)
    }
    
    $result = Submit-SPOMigrationJob @cmdArgs | Select-Object *
      
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else {
        Write-Output $result 
    }    
}
catch{
    throw
}
finally{
}