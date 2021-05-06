#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.0.5"}

<#
.SYNOPSIS
    Generates a report with all the policy packages available on a tenant

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
    Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/_REPORTS_
    
.Parameter Identity
    [sr-en] The user that will receive policy package recommendations
    [sr-de] Benutzer ID dessen Policies-Vorschläge angezeigt werden
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$Identity
)

Import-Module microsoftteams

try{
    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'
                            'Identity' = $Identity
                            }        

    $result = @()
    $null = Get-CsUserPolicyPackageRecommendation @getArgs | Select-Object * | ForEach-Object{
        $result += [pscustomobject]@{
            Name = $_.Name
            Description  = $_.Description
            PackageType = $_.PackageType
            RecommendationType = $_.RecommendationType
            Policies = ($_.Policies.Keys -join ';')
        }
    }
    
    ConvertTo-ResultHtml -Result $result
}
catch{
    throw
}
finally{
}