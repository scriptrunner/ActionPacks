#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Report on SPO migration jobs that are in progress
    
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

    .Parameter MigrationPackageAzureLocations
        A set of fully qualified URLs and SAS tokens representing the Azure Blob Storage containers that hold the package content and metadata files and an optional Azure Storage Reporting Queue

    .Parameter DontWaitForEndJob
        Not wait for the job to end

    .Parameter EncryptionParameters
        Parameters of the encryption

    .Parameter JobIds
        Id of a previously created migration job that exists on the target site collection, comma separated

    .Parameter NoLogFile
        Used to not create a log file

    .Parameter AzureQueueUri
        An optional fully qualified URL and SAS token representing the Azure Storage Reporting Queue where import operations will list events during import

    .Parameter TargetWebUrl
        The fully qualified target web URL where the package will be imported into
#>

param(     
    [Parameter(Mandatory = $true, ParameterSetName = 'Implicit')]
    [Parameter(Mandatory = $true, ParameterSetName = 'Inline')]
    [pscredential]$ExecuteCredentials,
    [Parameter(Mandatory = $true, ParameterSetName = 'Implicit')]
    [string]$MigrationPackageAzureLocations,
    [Parameter(Mandatory = $true, ParameterSetName = 'Inline')]
    [string]$AzureQueueUri,
    [Parameter(ParameterSetName = 'Implicit')]
    [Parameter(ParameterSetName = 'Inline')]  
    [switch]$DontWaitForEndJob,
    [Parameter(ParameterSetName = 'Implicit')]
    [Parameter(ParameterSetName = 'Inline')]
    [string]$EncryptionParameters,
    [Parameter(ParameterSetName = 'Implicit')]
    [Parameter(ParameterSetName = 'Inline')]
    [string]$JobIds,
    [Parameter(ParameterSetName = 'Implicit')]
    [Parameter(ParameterSetName = 'Inline')]
    [switch]$NoLogFile,
    [Parameter(ParameterSetName = 'Implicit')]
    [Parameter(ParameterSetName = 'Inline')]
    [string]$TargetWebUrl
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'DontWaitForEndJob' = $DontWaitForEndJob
                            'Credentials' = $ExecuteCredentials
                            'NoLogFile' = $NoLogFile
                            }

    if($PSCmdlet.ParameterSetName -eq 'Implicit'){
        $cmdArgs.Add('MigrationPackageAzureLocations',$MigrationPackageAzureLocations)
    }else{
        $cmdArgs.Add('AzureQueueUri',$AzureQueueUri)
    }
    if($PSBoundParameters.ContainsKey('EncryptionParameters')){
        $cmdArgs.Add('EncryptionParameters',$EncryptionParameters)
    }
    if($PSBoundParameters.ContainsKey('JobIds')){
        $cmdArgs.Add('JobIds',$JobIds)
    }
    if($PSBoundParameters.ContainsKey('TargetWebUrl')){
        $cmdArgs.Add('TargetWebUrl',$TargetWebUrl)
    }

    $result = Get-SPOMigrationJobProgress @cmdArgs | Select-Object *
      
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