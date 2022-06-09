#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Teams 

<#
    .SYNOPSIS
        Collection of channels and messages associated with the team
    
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
        [sr-en] Team identifier
        [sr-de] Team ID

    .Parameter ChannelId
        [sr-en] Id of channel
        [sr-de] Kanal ID

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$TeamId,
    [string]$ChannelId,
    [ValidateSet('CreatedDateTime','Description','DisplayName','Id','EMail','FilesFolder','IsFavoriteByDefault','Members','MembershipType','Messages','Tabs','WebUrl')]
    [string[]]$Properties = @('DisplayName','Id','Description','CreatedDateTime','IsFavoriteByDefault')
)

Import-Module Microsoft.Graph.Teams 

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'TeamID' = $TeamId
    }
    if($PSBoundParameters.ContainsKey('ChannelId') -eq $true){
        $cmdArgs.Add('ChannelID',$ChannelId)
    }

    $mgChannel = Get-MgTeamChannel @cmdArgs | Select-Object $Properties
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
    DisconnectMSGraph
}