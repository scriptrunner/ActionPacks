#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Adds owners or members to all teams

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
    Optional Library Script ReportLibrary from the Action Pack Reporting\_LIB_

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Members
    
.Parameter Users
    [sr-en] User UPN (user principal name)
    [sr-de] UPN der Benutzer

.Parameter Role
    [sr-en] User role
    [sr-de] Rolle der Benutzer
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string[]]$Users,    
    [ValidateSet('Member','Owner')]
    [string]$Role
)

Import-Module microsoftteams

try{
    $teams = Get-Team -ErrorAction Stop

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}      
    if($PSBoundParameters.ContainsKey('Role') -eq $true){
        $cmdArgs.Add('Role',$Role)
    }    

    [string[]]$result = @()
    foreach($team in $teams){
        foreach($usr in $Users){
            try{
                $null = Add-TeamUser @cmdArgs -GroupId $team.GroupId -User ($usr.Trim())
                $result += "User $($usr) added to team $($team.DisplayName)"
            }
            catch{
                $result += "Error. Add user $($usr) to team $($team.DisplayName)"
            }
        } 
    }   
    
    if (Get-Command 'ConvertTo-ResultHtml' -ErrorAction SilentlyContinue) {
        ConvertTo-ResultHtml -Result $result
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