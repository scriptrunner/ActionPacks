﻿#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.1.5"}

<#
.SYNOPSIS
    Generates a report with users of a channel

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

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/_REPORTS_

.Parameter GroupId
    [sr-en] GroupId of the parent team
    [sr-de] Gruppen ID des Teams

.Parameter DisplayName
    [sr-en] Display name of the private channel
    [sr-de] Anzeigename des Channels

.Parameter Role
    [sr-en] Filter the results to only users with the given role
    [sr-de] Filtert nach der Benutzer-Rolle
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$GroupId,
    [Parameter(Mandatory = $true)]   
    [string]$Displayname,
    [ValidateSet('Member','Owner','Guest')]
    [string]$Role
)

Import-Module microsoftteams

try{
    [string[]]$Properties = @('Name','User','Role','UserID')

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'GroupId' = $GroupId
                            'DisplayName' = $Displayname
                            }  

    if([System.String]::IsNullOrWhiteSpace($Role) -eq $false){
        $cmdArgs.Add('Role',$Role)
    }
    $result = Get-TeamChannelUser @cmdArgs | Sort-Object Name | Select-Object $Properties
    ConvertTo-ResultHtml -Result $result
}
catch{
    throw
}
finally{
}