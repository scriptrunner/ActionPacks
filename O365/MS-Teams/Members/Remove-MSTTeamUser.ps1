#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Remove an owner or member from a team. 
    Last owner cannot be removed from the team

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
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Members
 
.Parameter GroupId
    [sr-en] GroupId of the team
    [sr-de] Gruppen ID des Teams
    
.Parameter Users
    [sr-en] One or more User UPN's (user principal name)
    [sr-de] Ein oder mehrere UPNs
    
.Parameter User
    [sr-en] User's UPN (user principal name)
    [sr-de] UPN

.Parameter UserIsOwner
    [sr-en] User is member of owner role
    [sr-de] Benutzer ist Besitzer
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Single")]   
    [Parameter(Mandatory = $true, ParameterSetName = "Multi")]   
    [string]$GroupId,
    [Parameter(Mandatory = $true, ParameterSetName = "Multi")]   
    [string[]]$Users,
    [Parameter(Mandatory = $true, ParameterSetName = "Single")]   
    [string]$User,    
    [Parameter(ParameterSetName = "Single")]
    [switch]$UserIsOwner
)

Import-Module microsoftteams

try{
    $team = Get-Team -GroupId $GroupId -ErrorAction Stop | Select-Object -ExpandProperty DisplayName
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'GroupId' = $GroupId
                            }      
       
    if($PSCmdlet.ParameterSetName -eq 'Single'){
        $Users = @($User)
    }
    else{
        if($UserIsOwner -eq $true){
            $cmdArgs.Add('Role','Owner')
        }     
    }

    $result = @()
    foreach($usr in $Users){
        try{
            $null = Remove-TeamUser @cmdArgs -User $usr
            $result += "User $($usr) removed from team $($team)"
        }
        catch{
            $result += "Error. Remove user $($usr) from team $($team)"
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