#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.0.3"}

<#
.SYNOPSIS
    Creates a new app in the Teams tenant app store

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module microsoftteams 1.0.3 or greater
    Requires .NET Framework Version 4.7.2.
    Requires a ScriptRunner Microsoft 365 target

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Apps

.Parameter AppPath
    [sr-en] The local path of the app manifest zip file
    [sr-de] Lokaler Pfad der Anwendungs-Manifest-Zip-Datei

.Parameter DistributionMethod    
    [sr-en] The type of app in Teams. For LOB apps, use "organization" 
    [sr-de] Art der Anwendung in Teams. Für LOB-Apps verwenden Sie "Organisation"
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$AppPath,
    [Parameter(Mandatory = $true)]   
    [ValidateSet('organization','global')]
    [string]$DistributionMethod = 'organization'
)

Import-Module microsoftteams

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Path' = $AppPath
                            'DistributionMethod' = $DistributionMethod
                            }  
    
    $result = New-TeamsApp @cmdArgs | Select-Object *
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw
}
finally{
}