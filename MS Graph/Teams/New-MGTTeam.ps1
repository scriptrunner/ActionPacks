#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Teams 

<#
    .SYNOPSIS
        Creates a Team
    
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
                
    .Parameter DisplayName
        [sr-en] Display name of the team
        [sr-de] Team Anzeigename
        
    .Parameter Description
        [sr-en] Description of the team
        [sr-de] Team Beschreibung

    .Parameter Visibility
        [sr-en] Team visibility type
        [sr-de] Team Typ  
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [string]$Description,    
    [Validateset('Public','Private')]
    [string]$Visibility = 'Public'
)

Import-Module Microsoft.Graph.Teams 

try{
    [string[]]$Properties = @('DisplayName','Id','Description','CreatedDateTime')
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'DisplayName' = $DisplayName
                        'Confirm' = $false
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('Visibility') -eq $true){
        $cmdArgs.Add('Visibility',$Visibility)
    }
    $cmdArgs.Add('AdditionalProperties', @{
        "template@odata.bind" = "https://graph.microsoft.com/beta/teamsTemplates('standard')"
    })
    $mgTeam = New-MgTeam @cmdArgs | Select-Object $Properties # erroneous in v1.9.2

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