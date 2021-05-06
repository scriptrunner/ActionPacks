#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.0.5"}

<#
.SYNOPSIS
    Applying a policy package to users in a tenant

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module microsoftteams 1.0.5 or greater
    Requires a ScriptRunner Microsoft 365 target

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Policies
    
.Parameter Users
    [sr-en] A list of one or more users in the tenant
    [sr-de] Benutzer-Liste 

.Parameter PackageName 
    [sr-en] The name of a specific policy package to apply
    [sr-de] Name des Policy Pakets
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string[]]$Users,
    [Parameter(Mandatory = $true)]   
    [string]$PackageName
)

Import-Module microsoftteams

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'PackageName' = $PackageName
                            'Identity' = $Users
                            }        
    $null = Grant-CsUserPolicyPackage @cmdArgs

    $result = @()    
    foreach($usr in $Users){
        $result += $usr
        $result += Get-CsUserPolicyPackage -Identity $usr -ErrorAction Stop | Select-Object *
    }    
    
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