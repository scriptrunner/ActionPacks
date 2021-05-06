#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Update Team channels settings

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
    [sr-en] GroupId of the team
    [sr-de] Gruppen ID des Teams

.Parameter CurrentDisplayName
    [sr-en] Current Channel name
    [sr-de] Aktueller Channel Name
    
.Parameter DisplayName
    [sr-en] Channel display name
    [sr-de] Anzeigename des Channels

.Parameter Description
    [sr-en] Updated Channel description
    [sr-de] Channel Beschreibung

.Parameter NewDisplayName
    [sr-en] New Channel display name
    [sr-de] Neuer Anzeigename des Channels
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$GroupId,
    [Parameter(Mandatory = $true)]   
    [ValidateLength(5,50)]
    [string]$CurrentDisplayName,
    [ValidateLength(5,50)]
    [string]$NewDisplayName,
    [ValidateLength(0,1024)]
    [string]$Description
)

Import-Module microsoftteams

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'GroupId' = $GroupId
                            'CurrentDisplayName' = $CurrentDisplayName
                            }      
    if([System.String]::IsNullOrWhiteSpace($Description) -eq $false){
        $cmdArgs.Add('Description',$Description)
    } 
    if([System.String]::IsNullOrWhiteSpace($NewDisplayName) -eq $false){
        $cmdArgs.Add('NewDisplayName',$NewDisplayName)
    }    
    $result = Set-TeamChannel @cmdArgs | Select-Object *
    
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