#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Generates a report with all or a specific channels for all teams

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
    
.Parameter Channel
    [sr-en] Specify the Channel
    [sr-de] Name des Team-Channels 
#>

[CmdLetBinding()]
Param(
    [string]$Channel
)

Import-Module microsoftteams

try{
    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}

    $teams = Get-Team @getArgs | Sort-Object DisplayName
    $result = @()
    foreach ($team in $teams) { 
        Get-TeamChannel -GroupId $team.GroupId | Sort-Object DisplayName | ForEach-Object{
            if(($PSBoundParameters.ContainsKey('Channel') -eq $false) -or ($_.DisplayName -like "*$($Channel)*")){
                $result += [pscustomobject]@{
                    'Team' = $team.DisplayName
                    'Channel' = $_.DisplayName
                    'Description' = $_.Description
                    'Channel type' = $_.MembershipType
                }
            }
        }
    }
    
    ConvertTo-ResultHtml -Result $result          
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