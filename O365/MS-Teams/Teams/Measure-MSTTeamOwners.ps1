#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Check the owner's number of the team

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
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Teams

.Parameter ThresholdValue
    [sr-en] Minimum number of owners
    [sr-de] Mindestanzahl der Besitzer

.Parameter Archived
    [sr-en] Filters to return teams that have been archived or not
    [sr-de] Archivierte Teams anzeigen
#>

[CmdLetBinding()]
Param(
    [ValidateRange(1,10)]
    [int]$ThresholdValue = 1,
    [bool]$Archived
)

Import-Module microsoftteams

try{
    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'
                            'Archived' = $Archived
                            }                              
    
    $teams = Get-Team @getArgs 
    $result = @()
    foreach($item in $teams){
        try{
            $users = Get-TeamUser -GroupId  $item.GroupId -ErrorAction Stop | `
                        Where-Object {$_.Role -like "owner"}
            if(($null -eq $users) -or ($users.Count -lt $ThresholdValue)){
                $result += "$($users.Count) owners of the team $($item.DisplayName)"
            }
        }
        catch{
            $result += "Error read team users from team $($item.DisplayName)"
        }
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