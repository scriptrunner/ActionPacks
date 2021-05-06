#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Generates a report with the team members of the roles

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module microsoftteams
    Requires a ScriptRunner Microsoft 365 target
    Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/_REPORTS_
 
.Parameter Roles
    [sr-en] Role types
    [sr-de] Rollentypen
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [ValidateSet('Owner','Member','Guest')]
    [string[]]$Roles
)

Import-Module microsoftteams

try{
    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}

    $teams = Get-Team @getArgs | Sort-Object DisplayName
    $result = @()
    foreach ($team in $teams) { 
        foreach($grp in $Roles){
            Get-TeamUser -GroupId $team.GroupId -Role $grp | Sort-Object Name | ForEach-Object{
                $result += [pscustomobject]@{
                    'Team' = $Team.DisplayName
                    'UserName' = $_.Name
                    'User' = $_.User
                    'Role' = $_.Role
                }
            }
        }
    }
    
    ConvertTo-ResultHtml -Result $result          
<#    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }#>
}
catch{
    throw
}
finally{
}