#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.0.2"}

<#
.SYNOPSIS
    Set the archived state of a team

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module microsoftteams 1.0.2 or greater
    Requires .NET Framework Version 4.7.2.
    Requires a ScriptRunner Microsoft 365 target

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Teams

.Parameter GroupId
    [sr-en] GroupId of the team
    [sr-de] Gruppen ID des Teams
    
.Parameter Archived
    [sr-en] Archived state
    [sr-de] Archivierungs-Status

.Parameter SetSpoSiteReadOnlyForMembers
    [sr-en] SharePoint site is read-only for team members  
    [sr-de] SharePoint Seite read-only für Mitglieder  
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$GroupId,
    [Parameter(Mandatory = $true)]   
    [bool]$Archived,
    [bool]$SetSpoSiteReadOnlyForMembers
)

Import-Module microsoftteams

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'GroupId' = $GroupId
                            'Archived' = $Archived
                            }  
    if($PSBoundParameters.ContainsKey('SetSpoSiteReadOnlyForMembers')){
        $cmdArgs.Add('SetSpoSiteReadOnlyForMembers',$SetSpoSiteReadOnlyForMembers)
    } 

    $result = Set-TeamArchivedState @cmdArgs | Select-Object *
    
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