#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Teams 

<#
    .SYNOPSIS
        Create new navigation property to channels for groups
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.Teams 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Teams

    .Parameter GroupId
        [sr-en] Group identifier
        [sr-de] Gruppen ID

    .Parameter DisplayName
        [sr-en] Name of the channel
        [sr-de] Kanal Name

    .Parameter Description
        [sr-en] Description of the channel
        [sr-de] Kanal Beschreibung

    .Parameter EMail
        [sr-en] Mail of the channel
        [sr-de] Kanal Maildresse

    .Parameter WebUrl
        [sr-en] Hyperlink to the channel in Microsoft Teams
        [sr-de] Link zum Kanal

    .Parameter IsFavoriteByDefault
        [sr-en] Automatically be marked 'favorite' for all members of the team
        [sr-de] Automatisch Favorit für alle Team-Mitglieder
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [string]$Description,
    [string]$EMail,
    [switch]$IsFavoriteByDefault,
    [string]$WebUrl
)

Import-Module Microsoft.Graph.Teams 

try{
    [string[]]$Properties = @('DisplayName','Id','Description','CreatedDateTime','IsFavoriteByDefault')
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'GroupId' = $GroupId
                        'DisplayName' = $DisplayName
                        'Confirm' = $false
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('EMail') -eq $true){
        $cmdArgs.Add('EMail',$EMail)
    }
    if($PSBoundParameters.ContainsKey('WebUrl') -eq $true){
        $cmdArgs.Add('WebUrl',$WebUrl)
    }
    if($IsFavoriteByDefault.IsPresent -eq $true){
        $cmdArgs.Add('IsFavoriteByDefault',$null)
    }

    $mgChannel = New-MgGroupTeamChannel @cmdArgs | Select-Object $Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $mgChannel
    }
    else{
        Write-Output $mgChannel
    }
}
catch{
    throw 
}
finally{
}