#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Deletes a specified Team from Microsoft Teams

.DESCRIPTION
    Removes a specified team via GroupID and all its associated components, like O365 Unified Group

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
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Teams

.Parameter GroupId
    [sr-en] GroupId of the team
    [sr-de] Gruppen ID des Teams
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$GroupId
)

Import-Module microsoftteams

try{
    $result = Get-Team -GroupId $GroupId | Select-Object DisplayName
    $null = Remove-Team -GroupId $GroupId
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Team $($result.DisplayName) successfully removed"
    }
    else{
        Write-Output "Team $($result.DisplayName) successfully removed"
    }
}
catch{
    throw
}
finally{
}