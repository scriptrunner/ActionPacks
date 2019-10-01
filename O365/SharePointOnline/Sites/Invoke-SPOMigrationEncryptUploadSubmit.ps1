#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Creates a new migration job in the target site collection
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Sites

    .Parameter TenantCredentials
        Parameter to fill out credentials of the SPO tenant

    .Parameter TargetWebUrl
        Target web URL

    .Parameter SourceFilesPath
        Source files Path

    .Parameter SourcePackagePath
        Source Package Path
 
    .Parameter NoLogFile
        Controls if a log will be created or not
#>

param(        
    [Parameter(Mandatory = $true)]
    [pscredential]$TenantCredentials,
    [Parameter(Mandatory = $true)]
    [string]$TargetWebUrl,
    [Parameter(Mandatory = $true)]
    [string]$SourceFilesPath,
    [Parameter(Mandatory = $true)]
    [string]$SourcePackagePath,
    [string]$NoLogFile
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Credentials' = $TenantCredentials
                            'TargetWebUrl' = $TargetWebUrl
                            'SourceFilesPath' = $SourceFilesPath
                            'SourcePackagePath' = $SourcePackagePath
                            }      
    
    if($PSBoundParameters.ContainsKey('NoLogFile')){
        $cmdArgs.Add('NoLogFile',$null)
    }
    $result = Invoke-SPOMigrationEncryptUploadSubmit @cmdArgs | Select-Object *

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