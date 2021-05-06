#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Generates a report with the channels for a team

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
    [sr-en] Specify the GroupId of the team
    [sr-de] Gibt die Gruppen-Id des Teams an
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$GroupId
)

Import-Module microsoftteams

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'GroupId' = $GroupId
                            }  

    $result = Get-TeamChannel @cmdArgs | Select-Object DisplayName,Description,ID
    
    ConvertTo-ResultHtml -Result $result
}
catch{
    throw
}
finally{
}