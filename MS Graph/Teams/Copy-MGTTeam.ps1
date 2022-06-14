#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Teams 

<#
    .SYNOPSIS
        Copies a Team
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Library script MS Graph\_LIB_\MGLibrary
        Requires Modules Microsoft.Graph.Teams 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Teams

    .Parameter TeamId
        [sr-en] Source team identifier
        [sr-de] Quell-Team ID
        
    .Parameter DisplayName
        [sr-en] Display name of the team
        [sr-de] Team Anzeigename
        
    .Parameter MailNickname
        [sr-en] Description of the team
        [sr-de] Team Beschreibung
        
    .Parameter Description
        [sr-en] Description of the team
        [sr-de] Team Beschreibung
        
    .Parameter PartsToClone
        [sr-en] Parts of the team
        [sr-de] Team Bereiche
        
    .Parameter Visibility
        [sr-en] Team visibility type
        [sr-de] Team Typ  
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$TeamId,
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [Parameter(Mandatory = $true)]
    [string]$MailNickname,
    [string]$Description,    
    [Validateset('apps','tabs','settings','channels','members')]
    [string[]]$PartsToClone =@('apps','tabs','settings','channels','members'),
    [Validateset('Public','Private')]
    [string]$Visibility = 'Public'
)

Import-Module Microsoft.Graph.Teams 

try{
    [string[]]$Properties = @('DisplayName','Id','Description','CreatedDateTime')
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'TeamID' = $TeamId
                        'DisplayName' = $DisplayName
                        'MailNickname' = $MailNickname
                        'PassThru' = $null
                        'Confirm' = $false
                        'Visibility' = $Visibility
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('PartsToClone') -eq $true){
        $cmdArgs.Add('PartsToClone',($PartsToClone -join ','))
    }
    $mgTeam = Copy-MgTeam @cmdArgs #| Select-Object $Properties PassThru erroneous in v1.9.2

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $mgTeam
    }
    else{
        Write-Output $mgTeam
    }
}
catch{
    throw 
}
finally{
    DisconnectMSGraph
}