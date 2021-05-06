#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.1.7"}

<#
.SYNOPSIS
    Assigns a policy package to a group in a tenant

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
    
.Parameter GroupId
    [sr-en] A group id in the tenant
    [sr-de] Gruppen Identifier

.Parameter PackageName 
    [sr-en] The name of a specific policy package to apply
    [sr-de] Name des Policy Pakets

.Parameter PolicyRankings 
    [sr-en] Policy rankings for each of the policy types in the package
    [sr-de] Rangfolge der Richtlinien für jede der Richtlinienarten im Paket
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string[]]$GroupId,
    [Parameter(Mandatory = $true)]   
    [string]$PackageName,
    [string]$PolicyRankings
)

Import-Module microsoftteams

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'PackageName' = $PackageName
                            'GroupId' = $GroupId
                            }        

    if($PSBoundParameters.ContainsKey('PolicyRankings') -eq $true){
        $cmdArgs.Add('PolicyRankings',$PolicyRankings)        
    }                            
    $result = Grant-CsGroupPolicyPackageAssignment @cmdArgs
       
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