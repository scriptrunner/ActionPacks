#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Convert your XML files into a new encrypted migration package
    
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

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Common

    .Parameter EncryptionParameters
        [sr-en] Parameters of the encryption, it doesn't accept wildcard characters.
        It accepts parameters like SHA384, SHA256, etc.

    .Parameter MigrationSourceLocations
        [sr-en] Possible Source locations to migrate

    .Parameter SourceFilesPath
        [sr-en] Defines the temporary Path where are located the XML source files

    .Parameter SourcePackagePath
        [sr-en] Defines the source package path location

    .Parameter TargetFilesPath
        [sr-en] Defines the temporary Path where are located the XML source files

    .Parameter TargetPackagePath
        [sr-en] Defines the source package path location of the package to be encrypted

    .Parameter NoLogFile
        [sr-en] Determine if you should get or not a log file
#>

param(     
    [Parameter(Mandatory = $true,ParameterSetName = 'ExplicitSource')]
    [Parameter(Mandatory = $true,ParameterSetName = 'ImplicitSource')]
    [string]$EncryptionParameters,
    [Parameter(Mandatory = $true,ParameterSetName = 'ImplicitSource')]
    [string]$MigrationSourceLocations,    
    [Parameter(Mandatory = $true,ParameterSetName = 'ExplicitSource')]
    [string]$SourceFilesPath,
    [Parameter(Mandatory = $true,ParameterSetName = 'ExplicitSource')]
    [string]$SourcePackagePath,
    [Parameter(Mandatory = $true,ParameterSetName = 'ExplicitSource')]
    [Parameter(Mandatory = $true,ParameterSetName = 'ImplicitSource')]
    [string]$TargetFilesPath,
    [Parameter(Mandatory = $true,ParameterSetName = 'ExplicitSource')]
    [Parameter(Mandatory = $true,ParameterSetName = 'ImplicitSource')]
    [string]$TargetPackagePath,
    [Parameter(ParameterSetName = 'ExplicitSource')]
    [Parameter(ParameterSetName = 'ImplicitSource')]
    [switch]$NoLogFile
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'NoLogFile' = $NoLogFile
                            'EncryptionParameters' = $EncryptionParameters
                            'TargetFilesPath' = $TargetFilesPath
                            'TargetPackagePath' = $TargetPackagePath
                            }

    if($PSCmdlet.ParameterSetName -eq 'ImplicitSource'){
        $cmdArgs.Add('MigrationSourceLocations',$MigrationSourceLocations)
    }
    else{
        $cmdArgs.Add('SourceFilesPath',$SourceFilesPath)
        $cmdArgs.Add('SourcePackagePath',$SourcePackagePath)
    }
    $result = ConvertTo-SPOMigrationEncryptedPackage @cmdArgs | Select-Object *
      
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