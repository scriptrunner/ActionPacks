#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Adds an owner or member to the team

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
    Requires Library script MSTLibrary.ps1

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Members
 
.Parameter MSTCredential
    Provides the user ID and password for organizational ID credentials 

.Parameter GroupId
    GroupId of the team
    
.Parameter User
    User's UPN (user principal name)
    
.Parameter Users
    One or more User UPN's (user principal name)

.Parameter Role
    User role

.Parameter TenantID
    Specifies the ID of a tenant
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Single")]   
    [Parameter(Mandatory = $true, ParameterSetName = "Multi")]   
    [pscredential]$MSTCredential,
    [Parameter(Mandatory = $true, ParameterSetName = "Single")]   
    [Parameter(Mandatory = $true, ParameterSetName = "Multi")]   
    [string]$GroupId,
    [Parameter(Mandatory = $true, ParameterSetName = "Single")]   
    [string]$User,        
    [Parameter(Mandatory = $true, ParameterSetName = "Multi")]   
    [string[]]$Users,    
    [Parameter(ParameterSetName = "Single")]
    [Parameter(ParameterSetName = "Multi")]
    [ValidateSet('Member','Owner')]
    [string]$Role,
    [Parameter(ParameterSetName = "Single")]
    [Parameter(ParameterSetName = "Multi")]
    [string]$TenantID
)

Import-Module microsoftteams

try{
    ConnectMSTeams -MTCredential $MSTCredential -TenantID $TenantID

    $team = Get-Team -GroupId $GroupId -ErrorAction Stop | Select-Object -ExpandProperty DisplayName
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'GroupId' = $GroupId
                            }      
    if([System.String]::IsNullOrWhiteSpace($Role) -eq $false){
        $cmdArgs.Add('Role',$Role)
    }    
    if($PSCmdlet.ParameterSetName -eq 'Single'){
        $Users = @($User)
    }

    $result = @()
    foreach($usr in $Users){
        try{
            $null = Add-TeamUser @cmdArgs -User $usr
            $result += "User $($usr) added to team $($team)"
        }
        catch{
            $result += "Error. Add user $($usr) to team $($team)"
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
    DisconnectMSTeams
}