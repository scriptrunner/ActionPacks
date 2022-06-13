#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Teams 

<#
    .SYNOPSIS
        The details for each version of the app
    
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

    .Parameter TeamsAppId
        [sr-en] Id of teams app
        [sr-de] Id der Teams App

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$TeamsAppId,
    [ValidateSet('*','LastModifiedDateTime','Description','DisplayName','Id','PublishingState','ShortDescription','TeamsAppId','Version')]
    [string[]]$Properties = @('DisplayName','Id','ShortDescription','LastModifiedDateTime')
)

Import-Module Microsoft.Graph.Teams 

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'TeamsAppId' = $TeamsAppId
    }
    $mgDef = Get-MgAppCatalogTeamAppDefinition @cmdArgs | Sort-Object DisplayName | Select-Object $Properties

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $mgDef
    }
    else{
        Write-Output $mgDef
    }
}
catch{
    throw 
}
finally{
    DisconnectMSGraph
}