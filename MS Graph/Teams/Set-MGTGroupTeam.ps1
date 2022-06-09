#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Teams 

<#
    .SYNOPSIS
        Update the navigation property team in groups
    
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

    .Parameter GroupId
        [sr-en] Group identifier
        [sr-de] Gruppen ID

    .Parameter DisplayName
        [sr-en] Team name
        [sr-de] Name des Teams

    .Parameter Description
        [sr-en] Team description
        [sr-de] Beschreibung des Teams

    .Parameter WebUrl
        [sr-en] Hyperlink that will go to the team in the Microsoft Teams client
        [sr-de] Link des Teams
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [string]$DisplayName,
    [string]$Description,
    [string]$WebUrl
)

Import-Module Microsoft.Graph.Teams 

try{
    ConnectMSGraph  
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'GroupId' = $GroupId
                        'Confirm' = $false
                        'PassThru' = $null
    }
    if($PSBoundParameters.ContainsKey('DisplayName') -eq $true){
        $cmdArgs.Add('DisplayName',$DisplayName)    
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)    
    }
    if($PSBoundParameters.ContainsKey('WebUrl') -eq $true){
        $cmdArgs.Add('WebUrl',$WebUrl)    
    }

    $null = Update-MgGroupTeam @cmdArgs
    $mgTeam = Get-MgGroupTeam -GroupId $GroupId | Select-Object @('DisplayName','Description','WebUrl')
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