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
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module microsoftteams
    Requires Library script MSTLibrary.ps1

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Members
 
.Parameter MSTCredential
    Provides the user ID and password for organizational ID credentials 

.Parameter GroupId
    GroupId of the team
    
.Parameter User
    User's UPN (user principal name)

.Parameter UserIsOwner
    User is member of owner role

.Parameter TenantID
    Specifies the ID of a tenant
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$MSTCredential,
    [Parameter(Mandatory = $true)]   
    [string]$GroupId,
    [Parameter(Mandatory = $true)]   
    [string]$User,    
    [switch]$UserIsOwner,
    [string]$TenantID
)

Import-Module microsoftteams

try{
    ConnectMSTeams -MTCredential $MSTCredential -TenantID $TenantID

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'User' = $User
                            'GroupId' = $GroupId
                            }      
       
    if($UserIsOwner -eq $true){
        $cmdArgs.Add('Role','Owner')
    }                              
    $null = Remove-TeamUser @cmdArgs
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Team user $($User) successfully removed"
    }
    else{
        Write-Output "Team user $($User) successfully removed"
    }
}
catch{
    throw
}
finally{
    DisconnectMSTeams
}