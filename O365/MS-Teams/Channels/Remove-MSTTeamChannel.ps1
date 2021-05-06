#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Delete a channel

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
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Channels

.Parameter GroupId
    [sr-en] Specifies the object id of the group
    [sr-de] ID der Gruppe
    
.Parameter DisplayName
    [sr-en] Channel display name
    [sr-de] Anzeigename des Channels
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$GroupId,
    [Parameter(Mandatory = $true)]   
    [ValidateLength(5,50)]
    [string]$DisplayName
)

Import-Module microsoftteams

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'DisplayName' = $DisplayName
                            'GroupId' = $GroupId
                            }      
       
    $null = Remove-TeamChannel @cmdArgs
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Team channel $($DisplayName) successfully removed"
    }
    else{
        Write-Output "Team channel $($DisplayName) successfully removed"
    }
}
catch{
    throw
}
finally{
}