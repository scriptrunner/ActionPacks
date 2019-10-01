#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Convert your XML files into a new migration package
    
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

    .Parameter ExecuteCredential
        Fill out the Regular Credentials

    .Parameter SourceFilesPath
        Defines the temporary Path where are located the XML source files

    .Parameter SourcePackagePath
        Defines the source package path location 

    .Parameter TargetDocumentLibraryPath
        Defines the target document library path

    .Parameter TargetListPath
        Defines the Target list path

    .Parameter TargetWebUrl
        The fully qualified URL of the site collection where the job will be deleted if found

    .Parameter AzureADUserCredentials
        Receives Azure Active Directory User Credentials

    .Parameter TargetWebUrl
        The fully qualified URL of the site collection where the job will be deleted if found
    
    .Parameter OutputPackagePath
        Output package path

    .Parameter ParallelImport
        Boost file share migration performance

    .Parameter NoAzureADLookup
        If the command should or should not look up for Azure AD
    
    .Parameter NoLogFile
        Indicates to not create a log file

    .Parameter PartitionSizeInBytes
        Define the partition size in Bytes where it will be located the target package

    .Parameter TargetDocumentLibrarySubFolderPath
        Defines the target document library subfolder path

    .Parameter TargetEnvironment
        Defines the Target environment
 
    .Parameter UserMappingFile
        Defines the file mapping of the user 
#>

param(     
    [Parameter(Mandatory = $true,ParameterSetName = 'DocumentImport')]
    [Parameter(Mandatory = $true,ParameterSetName = 'FileImport')]
    [pscredential]$ExecuteCredential,   
    [Parameter(Mandatory = $true,ParameterSetName = 'DocumentImport')]
    [Parameter(Mandatory = $true,ParameterSetName = 'FileImport')]
    [string]$SourceFilesPath,
    [Parameter(Mandatory = $true,ParameterSetName = 'DocumentImport')]
    [Parameter(Mandatory = $true,ParameterSetName = 'FileImport')]
    [string]$SourcePackagePath,
    [Parameter(Mandatory = $true,ParameterSetName = 'DocumentImport')]
    [string]$TargetDocumentLibraryPath,
    [Parameter(Mandatory = $true,ParameterSetName = 'FileImport')]
    [string]$TargetListPath,
    [Parameter(Mandatory = $true,ParameterSetName = 'DocumentImport')]
    [Parameter(Mandatory = $true,ParameterSetName = 'FileImport')]
    [string]$TargetWebUrl,
    [Parameter(ParameterSetName = 'DocumentImport')]
    [Parameter(ParameterSetName = 'FileImport')]
    [pscredential]$AzureADUserCredentials,  
    [Parameter(ParameterSetName = 'DocumentImport')]
    [Parameter(ParameterSetName = 'FileImport')]
    [string]$OutputPackagePath,
    [Parameter(ParameterSetName = 'DocumentImport')]
    [Parameter(ParameterSetName = 'FileImport')]
    [switch]$ParallelImport,
    [Parameter(ParameterSetName = 'DocumentImport')]
    [Parameter(ParameterSetName = 'FileImport')]
    [switch]$NoAzureADLookup,    
    [Parameter(ParameterSetName = 'DocumentImport')]
    [Parameter(ParameterSetName = 'FileImport')]
    [switch]$NoLogFile,
    [Parameter(ParameterSetName = 'DocumentImport')]
    [Parameter(ParameterSetName = 'FileImport')]
    [int64]$PartitionSizeInBytes,
    [Parameter(ParameterSetName = 'DocumentImport')]
    [string]$TargetDocumentLibrarySubFolderPath,
    [Parameter(ParameterSetName = 'DocumentImport')]
    [Parameter(ParameterSetName = 'FileImport')]
    [Validateset('Production','ProductionChina','None','OnPremises')]
    [string]$TargetEnvironment,
    [Parameter(ParameterSetName = 'DocumentImport')]
    [Parameter(ParameterSetName = 'FileImport')]
    [string]$UserMappingFile
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Credential' = $ExecuteCredential
                            'NoLogFile' = $NoLogFile
                            'NoAzureADLookup' = $NoAzureADLookup
                            'ParallelImport' = $ParallelImport
                            'SourceFilesPath' = $SourceFilesPath
                            'SourcePackagePath' = $SourcePackagePath
                            'TargetWebUrl' = $TargetWebUrl
                            }
    
    If($PSCmdlet.ParameterSetName -eq 'DocumentImport'){
        $cmdArgs.Add('TargetDocumentLibraryPath',$TargetDocumentLibraryPath)
    }
    else{
        $cmdArgs.Add('TargetListPath',$TargetListPath)
    }
    if($PSBoundParameters.ContainsKey('TargetDocumentLibrarySubFolderPath')){
        $cmdArgs.Add('TargetDocumentLibrarySubFolderPath',$TargetDocumentLibrarySubFolderPath)
    }
    if($PSBoundParameters.ContainsKey('AzureADUserCredentials')){
        $cmdArgs.Add('AzureADUserCredentials',$AzureADUserCredentials)
    }
    if($PSBoundParameters.ContainsKey('OutputPackagePath')){
        $cmdArgs.Add('OutputPackagePath',$OutputPackagePath)
    }
    if($PSBoundParameters.ContainsKey('TargetEnvironment')){
        $cmdArgs.Add('TargetEnvironment',$TargetEnvironment)
    }
    if($PSBoundParameters.ContainsKey('UserMappingFile')){
        $cmdArgs.Add('UserMappingFile',$UserMappingFile)
    }
    if($PartitionSizeInBytes -gt 0){
        $cmdArgs.Add('PartitionSizeInBytes',$PartitionSizeInBytes)
    }
    
    $result = ConvertTo-SPOMigrationTargetedPackage @cmdArgs | Select-Object *
      
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