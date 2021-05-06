#Requires -Version 5.0
#Requires -Modules microsoftteams

<#
.SYNOPSIS
    Add new channels to all teams

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
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Channels
    
.Parameter ChannelNames
    [sr-en] One or more channel display names, comma separated
    [sr-de] Ein oder mehrere Channel Anzeigenamen, komma getrennt

.Parameter Description
    [sr-en] Channel description
    [sr-de] Channel Beschreibung
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ChannelNames, 
    [ValidateLength(0,1024)]
    [string]$Description
)

Import-Module microsoftteams

try{
    $teams = Get-Team -ErrorAction Stop

    [string[]]$result = @()
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}  
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }   

    foreach($cnl in $ChannelNames.Split(',')){
        foreach($team in $teams){
            try{
                $null = New-TeamChannel @cmdArgs -GroupId $team.GroupId -DisplayName ($cnl.Trim())
                $result += "Channel $($cnl) added to team $($team.DisplayName)"
            }
            catch{
                $result += "Error. Add channel $($cnl) to team $($team.DisplayName)"
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