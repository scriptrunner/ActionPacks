﻿#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Generates a report with the users of a team

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

.Parameter GroupId
    [sr-en] Specify the specific GroupId of the team
    [sr-de] Gibt die Gruppen-Id des Teams an

.Parameter Role
    [sr-en] Filter the results to only users with the given role
    [sr-de] Nur Benutzer der angegebenen Rolle
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$GroupId,
    [ValidateSet('Member','Owner','Guest')]
    [string]$Role
)

Import-Module microsoftteams

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'GroupId' = $GroupId
                            }  

 #   $team = Get-Team @cmdArgs | Select-Object -ExpandProperty DisplayName

    if([System.String]::IsNullOrWhiteSpace($Role) -eq $false){
        $cmdArgs.Add('Role',$Role)
    }                              
    
   # $result = @("Users of the team $($team)", '')
    $result = Get-TeamUser @cmdArgs | Select-Object *
    
    ConvertTo-ResultHtml -Result $result
}
catch{
    throw
}
finally{
}