#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.0.7"}

<#
.SYNOPSIS
    Update the picture of a team

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module microsoftteams 1.0.7 or greater
    Requires .NET Framework Version 4.7.2.
    Requires Library script MSTLibrary.ps1

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Teams
 
.Parameter MSTCredential
    Provides the user ID and password for organizational ID credentials

.Parameter GroupId
    GroupId of the team
    
.Parameter ImagePath
    File path and image ( .png, .gif, .jpg, or .jpeg)

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
    [string]$ImagePath,
    [string]$TenantID
)

Import-Module microsoftteams

try{
    ConnectMSTeams -MTCredential $MSTCredential -TenantID $TenantID

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'GroupId' = $GroupId
                            'ImagePath' = $ImagePath
                        }

    $null = Set-TeamPicture @cmdArgs
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Team Picture set"
    }
    else{
        Write-Output "Team Picture set"
    }
}
catch{
    throw
}
finally{
    DisconnectMSTeams
}