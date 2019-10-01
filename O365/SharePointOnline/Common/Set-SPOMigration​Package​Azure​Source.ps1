#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Create Azure containers, upload migration package files into the appropriate containers and snapshot the uploaded content
    
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

    .Parameter AccountKey
        The account key for the Azure Storage account
    
    .Parameter AccountName
        The account name for the Azure Storage account

    .Parameter MigrationPackageAzureLocations
        A set of fully qualified URLs and SAS tokens representing the Azure Blob Storage 
        containers that hold the package content and metadata files and an optional Azure Storage Reporting Queue

    .Parameter SourceFilesPath
        The directory location where the package’s source content files exist

    .Parameter SourcePackagePath
        The directory location where the package’s metadata files exist

    .Parameter FileContainerName
        The optional name of the Azure Blob Storage container that will be created if it does not currently exist

    .Parameter NoLogFile
        Indicates to not create a log file

    .Parameter NoSnapshotCreation
        Indicates to not perform snapshots on the content in the containers

    .Parameter NoUpload
        Indicates to not upload the package files

    .Parameter PackageContainerName
        The optional name of the Azure Blob Storage container that will be created if it does not currently exist

    .Parameter AzureQueueName
        An optional name of the Azure Storage Reporting Queue where import operations lists events during import
    
    .Parameter Overwrite

    .Parameter EncryptionMetaInfo

    .Parameter EncryptionParameters
        Parameters of the encryption
#>

param(     
    [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSourceExplicitAzure')]
    [Parameter(Mandatory = $true, ParameterSetName = 'ImplicitSourceExplicitAzure')]
    [string]$AccountKey,
    [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSourceExplicitAzure')]
    [Parameter(Mandatory = $true, ParameterSetName = 'ImplicitSourceExplicitAzure')]
    [string]$AccountName,
    [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSourceImplicitAzure')]
    [Parameter(Mandatory = $true, ParameterSetName = 'ImplicitSourceImplicitAzure')]
    [string]$MigrationPackageAzureLocations,
    [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSourceExplicitAzure')]
    [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSourceImplicitAzure')]
    [string]$SourceFilesPath,
    [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSourceExplicitAzure')]
    [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSourceImplicitAzure')]
    [string]$SourcePackagePath,
    [Parameter(Mandatory = $true, ParameterSetName = 'ImplicitSourceImplicitAzure')]
    [Parameter(Mandatory = $true, ParameterSetName = 'ImplicitSourceExplicitAzure')]
    [string]$MigrationSourceLocations,    
    [Parameter(ParameterSetName = 'ExplicitSourceExplicitAzure')]
    [Parameter(ParameterSetName = 'ImplicitSourceExplicitAzure')]
    [string]$AzureQueueName,
    [Parameter(ParameterSetName = 'ExplicitSourceExplicitAzure')]
    [Parameter(ParameterSetName = 'ExplicitSourceImplicitAzure')]
    [Parameter(ParameterSetName = 'ImplicitSourceImplicitAzure')]
    [Parameter(ParameterSetName = 'ImplicitSourceExplicitAzure')]
    [string]$EncryptionMetaInfo,
    [Parameter(ParameterSetName = 'ExplicitSourceExplicitAzure')]
    [Parameter(ParameterSetName = 'ExplicitSourceImplicitAzure')]
    [Parameter(ParameterSetName = 'ImplicitSourceExplicitAzure')]
    [Parameter(ParameterSetName = 'ImplicitSourceImplicitAzure')]
    [string]$EncryptionParameters,
    [Parameter(ParameterSetName = 'ExplicitSourceExplicitAzure')]
    [Parameter(ParameterSetName = 'ImplicitSourceExplicitAzure')]
    [string]$FileContainerName,
    [Parameter(ParameterSetName = 'ExplicitSourceExplicitAzure')]
    [Parameter(ParameterSetName = 'ImplicitSourceExplicitAzure')]
    [string]$PackageContainerName,
    [Parameter(ParameterSetName = 'ExplicitSourceExplicitAzure')]
    [Parameter(ParameterSetName = 'ImplicitSourceExplicitAzure')]
    [Parameter(ParameterSetName = 'ExplicitSourceImplicitAzure')]
    [Parameter(ParameterSetName = 'ImplicitSourceImplicitAzure')]
    [switch]$NoLogFile,
    [Parameter(ParameterSetName = 'ExplicitSourceExplicitAzure')]
    [Parameter(ParameterSetName = 'ImplicitSourceExplicitAzure')]
    [Parameter(ParameterSetName = 'ExplicitSourceImplicitAzure')]
    [Parameter(ParameterSetName = 'ImplicitSourceImplicitAzure')]
    [switch]$NoSnapshotCreation,
    [Parameter(ParameterSetName = 'ExplicitSourceExplicitAzure')]
    [Parameter(ParameterSetName = 'ImplicitSourceExplicitAzure')]
    [Parameter(ParameterSetName = 'ExplicitSourceImplicitAzure')]
    [Parameter(ParameterSetName = 'ImplicitSourceImplicitAzure')]
    [switch]$NoUpload,
    [Parameter(ParameterSetName = 'ExplicitSourceExplicitAzure')]
    [Parameter(ParameterSetName = 'ImplicitSourceExplicitAzure')]
    [Parameter(ParameterSetName = 'ExplicitSourceImplicitAzure')]
    [Parameter(ParameterSetName = 'ImplicitSourceImplicitAzure')]
    [switch]$Overwrite
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'NoLogFile' = $NoLogFile
                            'NoSnapshotCreation' = $NoSnapshotCreation
                            'NoUpload' = $NoUpload
                            'Overwrite' = $Overwrite
                            }
    
    if($PSCmdlet.ParameterSetName -eq 'ExplicitSourceImplicitAzure'){        
        $cmdArgs.Add('MigrationPackageAzureLocations',$MigrationPackageAzureLocations)
        $cmdArgs.Add('SourceFilesPath',$SourceFilesPath)
        $cmdArgs.Add('SourcePackagePath',$SourcePackagePath)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'ExplicitSourceExplicitAzure'){        
        $cmdArgs.Add('AccountKey',$AccountKey)
        $cmdArgs.Add('AccountName',$AccountName)
        $cmdArgs.Add('SourceFilesPath',$SourceFilesPath)
        $cmdArgs.Add('SourcePackagePath',$SourcePackagePath)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'ImplicitSourceImplicitAzure'){
        $cmdArgs.Add('MigrationPackageAzureLocations',$MigrationPackageAzureLocations)
        $cmdArgs.Add('MigrationSourceLocations',$MigrationSourceLocations)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'ImplicitSourceExplicitAzure'){
        $cmdArgs.Add('AccountKey',$AccountKey)
        $cmdArgs.Add('AccountName',$AccountName)
        $cmdArgs.Add('MigrationSourceLocations',$MigrationSourceLocations)
    }
    if($PSBoundParameters.ContainsKey('AzureQueueName')){
        $cmdArgs.Add('AzureQueueName',$AzureQueueName)
    }
    if($PSBoundParameters.ContainsKey('EncryptionMetaInfo')){
        $cmdArgs.Add('EncryptionMetaInfo',$EncryptionMetaInfo)
    }
    if($PSBoundParameters.ContainsKey('EncryptionParameters')){
        $cmdArgs.Add('EncryptionParameters',$EncryptionParameters)
    }
    if($PSBoundParameters.ContainsKey('FileContainerName')){
        $cmdArgs.Add('FileContainerName',$FileContainerName)
    }
    if($PSBoundParameters.ContainsKey('PackageContainerName')){
        $cmdArgs.Add('PackageContainerName',$PackageContainerName)
    }

    $result = Set-SPOMigrationPackageAzureSource @cmdArgs | Select-Object *
      
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